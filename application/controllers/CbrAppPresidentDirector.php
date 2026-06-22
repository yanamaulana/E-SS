<?php
defined('BASEPATH') or exit('No direct script access allowed');

class CbrAppPresidentDirector extends CI_Controller
{
    private $Date;
    private $DateTime;
    private $layout = 'layout';
    private $Ttrx_Cbr_Approval = 'Ttrx_Cbr_Approval';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->Date = date("Y-m-d");
        $this->DateTime = date("Y-m-d H:i:s");
        $this->load->model('m_helper', 'help');
        $this->load->model('m_DataTable', 'M_Datatables');
    }

    public function index()
    {
        $this->data['page_title'] = "President Director Approval-Cash Book Requisition";
        $this->data['page_content'] = "cbr_app/approval_president_director";

        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/cbr_app/presdir.js?v=' . time() . '"></script>
                                       <script src="' . base_url() . 'assets/Pages/cbr_app/history_approval_presdir.js?v=' . time() . '"></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function approve_submission()
    {
        $Cbrs = $this->input->post('CBReq_No');
        $this->db->trans_start();
        // Asumsikan $Cbrs adalah array CBReq_No yang dikirim dari DataTables
        foreach ($Cbrs as $CBReq_No) {

            // 1. Dapatkan Dulu Termin Berapa yang Sedang Aktif (Status = 0)
            $this->db->where('CBReq_No', $CBReq_No);
            $this->db->where('Status_AppvPresdir', 0); // Cari yang belum di-approve
            $pendingTermin = $this->db->get('Ttrx_Cbr_Approval_Termin')->row();

            if ($pendingTermin) {
                // 2. Update HANYA Termin yang sedang pending tersebut
                $this->db->where('SysID', $pendingTermin->SysID)->update('Ttrx_Cbr_Approval_Termin', [
                    'Status_AppvPresdir' => 1,
                    'AppvPresdir_Name'   => $this->session->userdata('sys_sba_nama'),
                    'AppvPresdir_By'     => $this->session->userdata('sys_sba_username'),
                    'AppvPresdir_At'     => $this->DateTime
                ]);
            }

            // 3. Hitung TOTAL Termin yang SUDAH di-approve
            $this->db->select_sum('Amount_Termin');
            $this->db->where('CBReq_No', $CBReq_No);
            $this->db->where('Status_AppvPresdir', 1);
            $sumTermin = $this->db->get('Ttrx_Cbr_Approval_Termin')->row()->Amount_Termin;

            // 4. Ambil Amount ASLI dari tabel Header
            $headerAmount = $this->db->get_where('TaccCashBookReq_Header', ['CBReq_No' => $CBReq_No])->row()->Amount;

            // 5. Bandingkan Total Termin vs Total CBR
            if (round($sumTermin, 2) >= round($headerAmount, 2)) {

                // TOTAL SUDAH FULL MATCH -> Lakukan update ke tabel Ttrx_Cbr_Approval (Legacy)
                $RowApproval = $this->db->get_where('Ttrx_Cbr_Approval', ['CBReq_No' => $CBReq_No])->row();

                $dataApproval = [
                    'Status_AppvPresidentDirector' => 1,
                    'AppvPresidentDirector_Name'   => $this->session->userdata('sys_sba_nama'),
                    'AppvPresidentDirector_By'     => $this->session->userdata('sys_sba_username'),
                    'AppvPresidentDirector_At'     => $this->DateTime
                ];

                if ($RowApproval->Doc_Legitimate_Pos_On == 'PresidentDirector') {
                    $dataApproval['Legitimate'] = 1;
                }

                $this->db->where('CBReq_No', $CBReq_No)->update('Ttrx_Cbr_Approval', $dataApproval);
            }
        }

        $error_msg = $this->db->error()["message"];
        $this->db->trans_complete();
        if ($this->db->trans_status() === FALSE) {
            $this->db->trans_rollback();
            return $this->help->Fn_resulting_response([
                'code' => 505,
                'msg'  => $error_msg,
            ]);
        } else {
            $this->db->trans_commit();
            return $this->help->Fn_resulting_response([
                'code' => 200,
                'msg' => 'Cash Book Requisition successfully approved !',
            ]);
        }
    }

    public function reject_submission()
    {
        $Cbrs = $this->input->post('CBReq_No');
        $rejection_reason = $this->input->post('rejection_reason');

        $this->db->trans_start();

        foreach ($Cbrs as $CBReq_No) {

            // 1. Dapatkan Termin yang sedang pending (Status = 0)
            $this->db->where('CBReq_No', $CBReq_No);
            $this->db->where('Status_AppvPresdir', 0); // Cari yang menunggu aksi
            $pendingTermin = $this->db->get('Ttrx_Cbr_Approval_Termin')->row();

            if ($pendingTermin) {
                // 2. Update Termin tersebut menjadi Rejected (Status = 2)
                $this->db->where('SysID', $pendingTermin->SysID)->update('Ttrx_Cbr_Approval_Termin', [
                    'Status_AppvPresdir' => 2,
                    'AppvPresdir_Name'   => $this->session->userdata('sys_sba_nama'),
                    'AppvPresdir_By'     => $this->session->userdata('sys_sba_username'),
                    'AppvPresdir_At'     => $this->DateTime
                ]);

                // Record history penolakan untuk termin ini
                $this->help->record_history_approval($CBReq_No, $rejection_reason);
            }

            // 3. Hitung TOTAL Termin yang SUDAH di-reject (Status = 2)
            $this->db->select_sum('Amount_Termin');
            $this->db->where('CBReq_No', $CBReq_No);
            $this->db->where('Status_AppvPresdir', 2); // Hitung yang berstatus Rejected
            $sumRejected = $this->db->get('Ttrx_Cbr_Approval_Termin')->row()->Amount_Termin;

            // 4. Ambil Amount ASLI dari tabel Header
            $headerAmount = $this->db->get_where('TaccCashBookReq_Header', ['CBReq_No' => $CBReq_No])->row()->Amount;

            // 5. Bandingkan! Jika total nominal yang di-reject sama dengan total Header
            if (round($sumRejected, 2) >= round($headerAmount, 2)) {

                // Lakukan update ke tabel Ttrx_Cbr_Approval (Legacy) menjadi Rejected (2)
                $this->db->where('CBReq_No', $CBReq_No)->update($this->Ttrx_Cbr_Approval, [
                    'Status_AppvPresidentDirector' => 2,
                    'AppvPresidentDirector_Name'   => $this->session->userdata('sys_sba_nama'),
                    'AppvPresidentDirector_By'     => $this->session->userdata('sys_sba_username'),
                    'AppvPresidentDirector_At'     => $this->DateTime,
                ]);
            }
        }

        $error_msg = $this->db->error()["message"];
        $this->db->trans_complete();

        if ($this->db->trans_status() === FALSE) {
            $this->db->trans_rollback();
            return $this->help->Fn_resulting_response([
                'code' => 505,
                'msg'  => $error_msg,
            ]);
        } else {
            $this->db->trans_commit();
            return $this->help->Fn_resulting_response([
                'code' => 200,
                'msg' => 'Cash Book Requisition successfully Rejected !',
            ]);
        }
    }

    // ========================================== DATATABLE 

    public function DT_List_To_Approve()
    {
        $requestData = $_REQUEST;
        $columns = array(
            0  => 'H.CBReq_No',
            1  => 'H.CBReq_No',
            2  => 'TM.Termin_Ke',
            3  => 'H.Type',
            4  => 'H.Document_Date',
            5  => 'H.Currency_Id',
            6  => 'TM.Amount_Termin',
            7  => 'H.Document_Number',
            8  => 'H.Descript',
            9  => 'H.baseamount',
            10 => 'H.curr_rate',
            11 => 'H.Approval_Status',
            12 => 'TM.Status_AppvPresdir',
            13 => 'TA.Payment_Status',
            14 => 'H.Creation_DateTime',
            15 => 'H.Created_By',
            16 => 'TA.UserDivision',
            17 => 'U.First_Name',
            18 => 'H.Last_Update',
            19 => 'H.Acc_ID',
            20 => 'H.Approve_Date',
            21 => 'H.Payment_Plan_Date',
        );
        $columnIndex = isset($requestData['order'][0]['column']) ? (int) $requestData['order'][0]['column'] : 0;
        $order = isset($columns[$columnIndex]) ? $columns[$columnIndex] : 'H.CBReq_No';
        $dir = (isset($requestData['order'][0]['dir']) && strtolower($requestData['order'][0]['dir']) === 'asc') ? 'ASC' : 'DESC';
        $username = $this->db->escape($this->session->userdata('sys_sba_username'));

        $select = "SELECT DISTINCT 
            H.CBReq_No, 
            TM.SysID AS Termin_SysID,
            TM.Termin_Ke, 
            TM.Amount_Termin AS Amount,
            H.Payment_Plan_Date,
            H.Type, H.Document_Date, H.Document_Number, H.Acc_ID, H.Descript, 
            H.baseamount, H.curr_rate, H.Approval_Status, H.CBReq_Status, H.Paid_Status, 
            H.Creation_DateTime, H.Created_By, U.First_Name AS Created_By_Name, 
            H.Last_Update, H.Update_By, H.Currency_Id, H.Approve_Date, TA.UserDivision, 
            TM.Status_AppvPresdir AS Status_AppvPresidentDirector, 
            TA.Payment_Status, TA.Payment_Status_Time_Change, TA.Payment_Status_Change_By";

        $fromWhere = "
            FROM TAccCashBookReq_Header H
            INNER JOIN TUserGroupL GL ON H.Created_By = GL.User_ID
            INNER JOIN TUserPersonal U ON H.Created_By = U.User_ID
            INNER JOIN Ttrx_Cbr_Approval TA ON H.CBReq_No = TA.CBReq_No
            INNER JOIN Ttrx_Cbr_Approval_Termin TM ON H.CBReq_No = TM.CBReq_No
            WHERE H.Type = 'D'
                AND H.Company_ID = 2 
                AND ISNULL(H.isSPJ,0) = 0
                AND H.Approval_Status = 3
                AND H.CBReq_Status = 3
                AND (H.isClose IS NULL OR H.isClose = 0)
                AND TA.IsAppvPresidentDirector = 1
                AND TM.Status_AppvPresdir = 0 
                AND TM.AppvPresdir_By = $username
                AND ((TA.IsAppvStaff = 0)          OR (TA.IsAppvStaff = 1 AND TA.Status_AppvStaff = 1))
                AND ((TA.IsAppvChief = 0)          OR (TA.IsAppvChief = 1 AND TA.Status_AppvChief = 1))
                AND ((TA.IsAppvAsstManager = 0)    OR (TA.IsAppvAsstManager = 1 AND TA.Status_AppvAsstManager = 1))
                AND ((TA.IsAppvManager = 0)        OR (TA.IsAppvManager = 1 AND TA.Status_AppvManager = 1))
                AND ((TA.IsAppvSeniorManager = 0)  OR (TA.IsAppvSeniorManager = 1 AND TA.Status_AppvSeniorManager = 1))
                AND ((TA.IsAppvGeneralManager = 0) OR (TA.IsAppvGeneralManager = 1 AND TA.Status_AppvGeneralManager = 1))
                AND ((TA.IsAppvAdditional = 0)     OR (TA.IsAppvAdditional = 1 AND TA.Status_AppvAdditional = 1))
                AND ((TA.IsAppvDirector = 0)       OR (TA.IsAppvDirector = 1 AND TA.Status_AppvDirector = 1))
                AND ((TA.IsAppvFinancePerson = 0)  OR (TA.IsAppvFinancePerson = 1 AND TA.Status_AppvFinancePerson = 1)) 
                AND ((TA.IsAppvFinanceDirector = 0) OR (TA.IsAppvFinanceDirector = 1 AND TA.Status_AppvFinanceDirector = 1))";

        // Search filter (LIKE escape via '!')
        $searchSql = '';
        if (!empty($requestData['search']['value'])) {
            $searchValue = $this->db->escape_like_str($requestData['search']['value']);
            $searchSql = " AND (
                H.CBReq_No LIKE '%$searchValue%' ESCAPE '!'
                OR H.Payment_Plan_Date LIKE '%$searchValue%' ESCAPE '!'
                OR U.First_Name LIKE '%$searchValue%' ESCAPE '!'
                OR H.Document_Number LIKE '%$searchValue%' ESCAPE '!'
                OR H.Currency_Id LIKE '%$searchValue%' ESCAPE '!'
                OR H.Descript LIKE '%$searchValue%' ESCAPE '!'
                OR TA.UserDivision LIKE '%$searchValue%' ESCAPE '!'
            )";
        }

        // Count via wrapped DISTINCT subquery (no full-row hydration like num_rows())
        $totalData     = (int) $this->db->query("SELECT COUNT(*) AS total FROM ($select $fromWhere) AS sub")->row()->total;
        $totalFiltered = (int) $this->db->query("SELECT COUNT(*) AS total FROM ($select $fromWhere $searchSql) AS sub")->row()->total;

        $start  = isset($requestData['start']) ? (int) $requestData['start'] : 0;
        $length = isset($requestData['length']) ? (int) $requestData['length'] : 10;

        $dataSql = "$select $fromWhere $searchSql ORDER BY $order $dir OFFSET $start ROWS FETCH NEXT $length ROWS ONLY";
        $query = $this->db->query($dataSql);
        $data = array();
        foreach ($query->result_array() as $row) {
            $nestedData = array();
            $nestedData['CBReq_No'] = $row['CBReq_No'];
            $nestedData['Type'] = $row['Type'];
            $nestedData['Termin_Ke'] = $row['Termin_Ke'];
            $nestedData['Document_Date'] = $row['Document_Date'];
            $nestedData['Acc_ID'] = $row['Acc_ID'];
            $nestedData['Descript'] = $row['Descript'];
            $nestedData['Document_Number'] = $row['Document_Number'];
            $nestedData['Amount'] = $row['Amount']; // Amount sudah berasal dari TM.Amount_Termin
            $nestedData['baseamount'] = $row['baseamount'];
            $nestedData['curr_rate'] = $row['curr_rate'];
            $nestedData['Approval_Status'] = $row['Approval_Status'];
            $nestedData['CBReq_Status'] = $row['CBReq_Status'];
            $nestedData['Paid_Status'] = $row['Paid_Status'];
            $nestedData['Creation_DateTime'] = $row['Creation_DateTime'];
            $nestedData['Created_By'] = $row['Created_By'];
            $nestedData['First_Name'] = $row['Created_By_Name'];
            $nestedData['Last_Update'] = $row['Last_Update'];
            $nestedData['Update_By'] = $row['Update_By'];
            $nestedData['Currency_Id'] = $row['Currency_Id'];
            $nestedData['Approve_Date'] = $row['Approve_Date'];
            $nestedData['UserDivision'] = $row['UserDivision'];
            $nestedData['Status_AppvPresidentDirector'] = $row['Status_AppvPresidentDirector'];
            $nestedData['Payment_Status'] = $row['Payment_Status'];
            $nestedData['Payment_Plan_Date'] = $row['Payment_Plan_Date'];

            $data[] = $nestedData;
        }
        //----------------------------------------------------------------------------------
        $json_data = array(
            "draw" => intval($requestData['draw']),
            "recordsTotal" => intval($totalData),
            "recordsFiltered" => intval($totalFiltered),
            "data" => $data,
        );
        //----------------------------------------------------------------------------------
        echo json_encode($json_data);
    }

    // public function DT_List_History_Approval()
    // {
    //     $requestData = $_REQUEST;
    //     $columns = array(
    //         0 => 'TAccCashBookReq_Header.CBReq_No',
    //         1 => 'TAccCashBookReq_Header.CBReq_No',
    //         2 => 'Document_Date',
    //         3 => 'Currency_Id',
    //         4 => 'Amount',
    //         5 => 'Descript',
    //         6 => 'isClose',
    //         7 => 'Status_AppvPresidentDirector',
    //         8 => 'Payment_Status',
    //         9 => 'UserDivision',
    //         10 => 'First_Name',
    //         11 => 'IsAppvAsstManager',
    //         12 => 'IsAppvManager',
    //         13 => 'IsAppvSeniorManager',
    //         14 => 'IsAppvGeneralManager',
    //         15 => 'IsAppvAdditional',
    //         16 => 'IsAppvFinancePerson',
    //         17 => 'IsAppvDirector',
    //         18 => 'IsAppvFinanceDirector ',
    //         19 => 'IsAppvPresidentDirector',
    //         20 => 'Payment_Status_Time_Change',
    //     );
    //     $order  = $columns[$requestData['order']['0']['column']];
    //     $dir    = $requestData['order']['0']['dir'];
    //     $from   = $this->input->post('from');
    //     $until  = $this->input->post('until');
    //     $column_range  = $this->input->post('column_range');
    //     $username = $this->session->userdata('sys_sba_username');

    //     $sql = $this->help->generate_sql_spesific_history_approval($username, $column_range, $from, $until);

    //     $totalData = $this->db->query($sql)->num_rows();
    //     if (!empty($requestData['search']['value'])) {
    //         $sql .= " AND (TAccCashBookReq_Header.CBReq_No LIKE '%" . $requestData['search']['value'] . "%' ";
    //         $sql .= " OR Document_Number LIKE '%" . $requestData['search']['value'] . "%' ";
    //         $sql .= " OR TA.UserDivision LIKE '%" . $requestData['search']['value'] . "%' ";
    //         $sql .= " OR First_Name LIKE '%" . $requestData['search']['value'] . "%') ";
    //         // $sql .= " OR TAccCashBookReq_Header.Currency_Id LIKE '%" . $requestData['search']['value'] . "%' ";
    //         // $sql .= " OR Descript LIKE '%" . $requestData['search']['value'] . "%' ";
    //         // $sql .= " OR CBReq_Status LIKE '%" . $requestData['search']['value'] . "%' ";
    //         // $sql .= " OR Amount LIKE '%" . $requestData['search']['value'] . "%') ";
    //     }

    //     // Ambil SEMUA data hasil filter untuk dihitung summary-nya
    //     $all_filtered_query = $this->db->query($sql);
    //     $all_data = $all_filtered_query->result_array();

    //     // Inisialisasi Counter & Sum
    //     $summary = [
    //         'total_rows' => count($all_data),
    //         'approved'   => 0,
    //         'rejected'   => 0,
    //         'paid'       => 0,
    //         'pending'    => 0,
    //         'sum_pending_approved' => [],
    //         'sum_paid_approved'    => [],
    //         'sum_rejected'         => []
    //     ];

    //     foreach ($all_data as $row) {
    //         $status = $row['Status_AppvPresidentDirector']; // Sesuaikan status utama presdir
    //         $payment = $row['Payment_Status'];
    //         $curr = $row['Currency_Id'];
    //         $amt = (float)$row['Amount'];

    //         // 1. Count Rows
    //         if ($status == 1) $summary['approved']++;
    //         if ($status == 2) $summary['rejected']++;
    //         if ($payment == 1) $summary['paid']++;
    //         if ($payment == 0) $summary['pending']++;

    //         // 2. Summing Amount
    //         if ($status == 1 && $payment == 0) { // Approved Pending Payment
    //             $summary['sum_pending_approved'][$curr] = ($summary['sum_pending_approved'][$curr] ?? 0) + $amt;
    //         }
    //         if ($status == 1 && $payment == 1) { // Approved Paid
    //             $summary['sum_paid_approved'][$curr] = ($summary['sum_paid_approved'][$curr] ?? 0) + $amt;
    //         }
    //         if ($status == 2) { // Rejected
    //             $summary['sum_rejected'][$curr] = ($summary['sum_rejected'][$curr] ?? 0) + $amt;
    //         }
    //     }

    //     // --- PAGING LOGIC (Existing) ---
    //     $totalFiltered = count($all_data);
    //     $sql_with_paging = $sql . " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";
    //     $query = $this->db->query($sql_with_paging);
    //     $data = array();
    //     foreach ($query->result_array() as $row) {
    //         $nestedData = array();
    //         $nestedData['CBReq_No'] = $row['CBReq_No'];
    //         $nestedData['isClose'] = $row['isClose'];
    //         $nestedData['Type'] = $row['Type'];
    //         $nestedData['Document_Date'] = $row['Document_Date'];
    //         $nestedData['Acc_ID'] = $row['Acc_ID'];
    //         $nestedData['Descript'] = $row['Descript'];
    //         $nestedData['Document_Number'] = $row['Document_Number'];
    //         $nestedData['Amount'] = $row['Amount'];
    //         $nestedData['baseamount'] = $row['baseamount'];
    //         $nestedData['curr_rate'] = $row['curr_rate'];
    //         $nestedData['Approval_Status'] = $row['Approval_Status'];
    //         $nestedData['CBReq_Status'] = $row['CBReq_Status'];
    //         $nestedData['Paid_Status'] = $row['Paid_Status'];
    //         $nestedData['Creation_DateTime'] = $row['Creation_DateTime'];
    //         $nestedData['Created_By'] = $row['Created_By'];
    //         $nestedData['First_Name'] = $row['Created_By_Name'];
    //         $nestedData['Last_Update'] = $row['Last_Update'];
    //         $nestedData['Update_By'] = $row['Update_By'];
    //         $nestedData['Currency_Id'] = $row['Currency_Id'];
    //         $nestedData['Approve_Date'] = $row['Approve_Date'];
    //         $nestedData['IsAppvStaff'] = $row['IsAppvStaff'];
    //         $nestedData['Status_AppvStaff'] = $row['Status_AppvStaff'];
    //         $nestedData['AppvStaff_By'] = $row['AppvStaff_By'];
    //         $nestedData['AppvStaff_At'] = $row['AppvStaff_At'];
    //         $nestedData['IsAppvChief'] = $row['IsAppvChief'];
    //         $nestedData['Status_AppvChief'] = $row['Status_AppvChief'];
    //         $nestedData['AppvChief_By'] = $row['AppvChief_By'];
    //         $nestedData['AppvChief_Name'] = $row['AppvChief_Name'] ?? '';
    //         $nestedData['AppvChief_At'] = $row['AppvChief_At'];
    //         $nestedData['IsAppvAsstManager'] = $row['IsAppvAsstManager'];
    //         $nestedData['Status_AppvAsstManager'] = $row['Status_AppvAsstManager'];
    //         $nestedData['AppvAsstManager_By'] = $row['AppvAsstManager_By'];
    //         $nestedData['AppvAsstManager_Name'] = $row['AppvAsstManager_Name'] ?? '';
    //         $nestedData['AppvAsstManager_At'] = !empty($row['AppvAsstManager_At']) ? date('Y-m-d H:i', strtotime($row['AppvAsstManager_At'])) : '-';
    //         $nestedData['IsAppvManager'] = $row['IsAppvManager'];
    //         $nestedData['Status_AppvManager'] = $row['Status_AppvManager'];
    //         $nestedData['AppvManager_By'] = $row['AppvManager_By'];
    //         $nestedData['AppvManager_Name'] = $row['AppvManager_Name'] ?? '';
    //         $nestedData['AppvManager_At'] = !empty($row['AppvManager_At']) ? date('Y-m-d H:i', strtotime($row['AppvManager_At'])) : '-';
    //         $nestedData['IsAppvSeniorManager'] = $row['IsAppvSeniorManager'];
    //         $nestedData['Status_AppvSeniorManager'] = $row['Status_AppvSeniorManager'];
    //         $nestedData['AppvSeniorManager_By'] = $row['AppvSeniorManager_By'];
    //         $nestedData['AppvSeniorManager_Name'] = $row['AppvSeniorManager_Name'] ?? '';
    //         $nestedData['AppvSeniorManager_At'] = !empty($row['AppvSeniorManager_At']) ? date('Y-m-d H:i', strtotime($row['AppvSeniorManager_At'])) : '-';
    //         $nestedData['IsAppvGeneralManager'] = $row['IsAppvGeneralManager'];
    //         $nestedData['Status_AppvGeneralManager'] = $row['Status_AppvGeneralManager'];
    //         $nestedData['AppvGeneralManager_By'] = $row['AppvGeneralManager_By'];
    //         $nestedData['AppvGeneralManager_Name'] = $row['AppvGeneralManager_Name'] ?? '';
    //         $nestedData['AppvGeneralManager_At'] = !empty($row['AppvGeneralManager_At']) ? date('Y-m-d H:i', strtotime($row['AppvGeneralManager_At'])) : '-';

    //         $nestedData['IsAppvAdditional'] = $row['IsAppvAdditional'];
    //         $nestedData['Status_AppvAdditional'] = $row['Status_AppvAdditional'];
    //         $nestedData['AppvAdditional_By'] = $row['AppvAdditional_By'];
    //         $nestedData['AppvAdditional_Name'] = $row['AppvAdditional_Name'] ?? '';
    //         $nestedData['AppvAdditional_At'] = !empty($row['AppvAdditional_At']) ? date('Y-m-d H:i', strtotime($row['AppvAdditional_At'])) : '-';

    //         $nestedData['IsAppvFinancePerson'] = $row['IsAppvFinancePerson'];
    //         $nestedData['Status_AppvFinancePerson'] = $row['Status_AppvFinancePerson'];
    //         $nestedData['AppvFinancePerson_By'] = $row['AppvFinancePerson_By'];
    //         $nestedData['AppvFinancePerson_Name'] = $row['AppvFinancePerson_Name'] ?? '';
    //         $nestedData['AppvFinancePerson_At'] = !empty($row['AppvFinancePerson_At']) ? date('Y-m-d H:i', strtotime($row['AppvFinancePerson_At'])) : '-';

    //         $nestedData['IsAppvDirector'] = $row['IsAppvDirector'];
    //         $nestedData['Status_AppvDirector'] = $row['Status_AppvDirector'];
    //         $nestedData['AppvDirector_By'] = $row['AppvDirector_By'];
    //         $nestedData['AppvDirector_Name'] = $row['AppvDirector_Name'] ?? '';
    //         $nestedData['AppvDirector_At'] = !empty($row['AppvDirector_At']) ? date('Y-m-d H:i', strtotime($row['AppvDirector_At'])) : '-';
    //         $nestedData['IsAppvPresidentDirector'] = $row['IsAppvPresidentDirector'];
    //         $nestedData['Status_AppvPresidentDirector'] = $row['Status_AppvPresidentDirector'];
    //         $nestedData['AppvPresidentDirector_By'] = $row['AppvPresidentDirector_By'];
    //         $nestedData['AppvPresidentDirector_Name'] = $row['AppvPresidentDirector_Name'] ?? '';
    //         $nestedData['AppvPresidentDirector_At'] = !empty($row['AppvPresidentDirector_At']) ? date('Y-m-d H:i', strtotime($row['AppvPresidentDirector_At'])) : '-';
    //         // $nestedData['IsAppvFinanceStaff'] = $row['IsAppvFinanceStaff'];
    //         // $nestedData['Status_AppvFinanceStaff'] = $row['Status_AppvFinanceStaff'];
    //         // $nestedData['AppvFinanceStaff_By'] = $row['AppvFinanceStaff_By'];
    //         // $nestedData['AppvFinanceStaff_At'] = $row['AppvFinanceStaff_At'];
    //         // $nestedData['IsAppvFinanceManager'] = $row['IsAppvFinanceManager'];
    //         // $nestedData['Status_AppvFinanceManager'] = $row['Status_AppvFinanceManager'];
    //         // $nestedData['AppvFinanceManager_By'] = $row['AppvFinanceManager_By'];
    //         // $nestedData['AppvFinanceManager_At'] = $row['AppvFinanceManager_At'];
    //         $nestedData['IsAppvFinanceDirector'] = $row['IsAppvFinanceDirector'];
    //         $nestedData['Status_AppvFinanceDirector'] = $row['Status_AppvFinanceDirector'];
    //         $nestedData['AppvFinanceDirector_By'] = $row['AppvFinanceDirector_By'];
    //         $nestedData['AppvFinanceDirector_Name'] = $row['AppvFinanceDirector_Name'] ?? '';
    //         $nestedData['AppvFinanceDirector_At'] = !empty($row['AppvFinanceDirector_At']) ? date('Y-m-d H:i', strtotime($row['AppvFinanceDirector_At'])) : '-';
    //         $nestedData['UserName_User'] = $row['UserName_User'];
    //         $nestedData['Rec_Created_At'] = $row['Rec_Created_At'];
    //         $nestedData['UserDivision'] = $row['UserDivision'];
    //         $nestedData['Legitimate'] = $row['Legitimate'];
    //         $nestedData['Payment_Status'] = $row['Payment_Status'];
    //         $nestedData['Payment_Status_Time_Change'] = !empty($row['Payment_Status_Time_Change']) ? date('Y-m-d H:i', strtotime($row['Payment_Status_Time_Change'])) : '-';

    //         $data[] = $nestedData;
    //     }
    //     //----------------------------------------------------------------------------------
    //     $json_data = array(
    //         "draw" => intval($requestData['draw']),
    //         "recordsTotal" => intval($totalData),
    //         "recordsFiltered" => intval($totalFiltered),
    //         "data" => $data,
    //         "summary"         => $summary
    //     );
    //     //----------------------------------------------------------------------------------
    //     echo json_encode($json_data);
    // }


    public function DT_List_History_Approval()
    {
        $requestData = $_REQUEST;

        // --- 1. MAPPING KOLOM SUDAH DIRAPIKAN (Termin_Ke di index 2) ---
        $columns = array(
            0 => 'H.CBReq_No',
            1 => 'H.CBReq_No',
            2 => 'TM.Termin_Ke', // <-- FIX: Sudah dimasukkan!
            3 => 'H.Document_Date',
            4 => 'H.Currency_Id',
            5 => 'TM.Amount_Termin',
            6 => 'H.Descript',
            7 => 'H.isClose',
            8 => 'TM.Status_AppvPresdir',
            9 => 'TM.Termin_Payment_status',
            10 => 'TA.UserDivision',
            11 => 'U.First_Name',
            12 => 'TA.Status_AppvAsstManager',
            13 => 'TA.Status_AppvManager',
            14 => 'TA.Status_AppvSeniorManager',
            15 => 'TA.Status_AppvGeneralManager',
            16 => 'TA.Status_AppvAdditional',
            17 => 'TA.Status_AppvFinancePerson',
            18 => 'TA.Status_AppvDirector',
            19 => 'TA.Status_AppvFinanceDirector',
            20 => 'TM.Status_AppvPresdir',
            21 => 'TM.Termin_Payment_status_at',
        );

        $order  = $columns[$requestData['order']['0']['column']] ?? 'H.Document_Date';
        $dir    = $requestData['order']['0']['dir'] ?? 'DESC';
        $from   = $this->input->post('from');
        $until  = $this->input->post('until');
        $column_range  = $this->input->post('column_range');
        $username = $this->session->userdata('sys_sba_username');

        // --- 2. KUERI UTAMA ---
        $sql = "SELECT DISTINCT 
                H.CBReq_No, TM.Termin_Ke, H.Document_Date, H.Document_Number, 
                H.Currency_Id, TM.Amount_Termin AS Amount, H.Descript, H.isClose, 
                
                TM.Status_AppvPresdir AS Status_AppvPresidentDirector, 
                TM.AppvPresdir_By AS AppvPresidentDirector_By,
                TM.AppvPresdir_Name AS AppvPresidentDirector_Name,
                TM.AppvPresdir_At AS AppvPresidentDirector_At,
                
                TM.Termin_Payment_status AS Payment_Status,
                TM.Termin_Payment_status_at AS Payment_Status_Time_Change,
                
                TA.UserDivision, U.First_Name,
                
                TA.IsAppvAsstManager, TA.Status_AppvAsstManager, TA.AppvAsstManager_At,
                TA.IsAppvManager, TA.Status_AppvManager, TA.AppvManager_At,
                TA.IsAppvSeniorManager, TA.Status_AppvSeniorManager, TA.AppvSeniorManager_At,
                TA.IsAppvGeneralManager, TA.Status_AppvGeneralManager, TA.AppvGeneralManager_At,
                TA.IsAppvAdditional, TA.Status_AppvAdditional, TA.AppvAdditional_At,
                TA.IsAppvFinancePerson, TA.Status_AppvFinancePerson, TA.AppvFinancePerson_At,
                TA.IsAppvDirector, TA.Status_AppvDirector, TA.AppvDirector_At,
                TA.IsAppvFinanceDirector, TA.Status_AppvFinanceDirector, TA.AppvFinanceDirector_At
                
                FROM Ttrx_Cbr_Approval_Termin TM
                INNER JOIN TAccCashBookReq_Header H ON TM.CBReq_No = H.CBReq_No
                INNER JOIN Ttrx_Cbr_Approval TA ON TM.CBReq_No = TA.CBReq_No
                INNER JOIN TUserPersonal U ON H.Created_By = U.User_ID
                
                WHERE H.Type='D'
                AND H.Company_ID = 2 
                AND ISNULL(H.isSPJ,0) = 0
                AND H.Approval_Status = 3
                AND H.CBReq_Status = 3
                AND TM.AppvPresdir_By = '$username'
                AND TM.Status_AppvPresdir <> 0 ";

        if (!empty($from) && !empty($until) && !empty($column_range)) {
            $sql .= " AND $column_range >= '$from' AND $column_range <= '$until 23:59:59' ";
        }

        $totalData = $this->db->query($sql)->num_rows();

        // --- 3. FILTER PENCARIAN ---
        if (!empty($requestData['search']['value'])) {
            $searchValue = $this->db->escape_like_str($requestData['search']['value']);
            $sql .= " AND (
                H.CBReq_No LIKE '%$searchValue%' ESCAPE '!'
                OR H.Document_Number LIKE '%$searchValue%' ESCAPE '!'
                OR TA.UserDivision LIKE '%$searchValue%' ESCAPE '!'
                OR U.First_Name LIKE '%$searchValue%' ESCAPE '!'
                OR H.Descript LIKE '%$searchValue%' ESCAPE '!'
            ) ";
        }

        // --- 4. KALKULASI SUMMARY ---
        $all_filtered_query = $this->db->query($sql);
        $all_data = $all_filtered_query->result_array();

        $summary = [
            'total_rows' => count($all_data),
            'approved'   => 0,
            'rejected'   => 0,
            'paid'       => 0,
            'pending'    => 0,
            'sum_pending_approved' => [],
            'sum_paid_approved'    => [],
            'sum_rejected'         => []
        ];

        foreach ($all_data as $row) {
            $status = $row['Status_AppvPresidentDirector'];
            $payment = $row['Payment_Status'];
            $curr = $row['Currency_Id'] ?: 'IDR';
            $amt = (float)$row['Amount'];

            if ($status == 1) $summary['approved']++;
            if ($status == 2) $summary['rejected']++;
            if ($payment == 1) $summary['paid']++;
            if ($payment == 0) $summary['pending']++;

            if ($status == 1 && $payment == 0) {
                $summary['sum_pending_approved'][$curr] = ($summary['sum_pending_approved'][$curr] ?? 0) + $amt;
            }
            if ($status == 1 && $payment == 1) {
                $summary['sum_paid_approved'][$curr] = ($summary['sum_paid_approved'][$curr] ?? 0) + $amt;
            }
            if ($status == 2) {
                $summary['sum_rejected'][$curr] = ($summary['sum_rejected'][$curr] ?? 0) + $amt;
            }
        }

        // --- 5. LOGIKA PAGINATION ---
        $totalFiltered = count($all_data);
        $sql_with_paging = $sql . " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";
        $query = $this->db->query($sql_with_paging);

        $data = array();
        foreach ($query->result_array() as $row) {
            $nestedData = array();

            $nestedData['CBReq_No'] = $row['CBReq_No'];
            $nestedData['Termin_Ke'] = $row['Termin_Ke']; // <-- FIX: Sudah dimasukkan!
            $nestedData['isClose'] = $row['isClose'];
            $nestedData['Document_Date'] = $row['Document_Date'];
            $nestedData['Currency_Id'] = $row['Currency_Id'];
            $nestedData['Amount'] = $row['Amount'];
            $nestedData['Descript'] = $row['Descript'];
            $nestedData['UserDivision'] = $row['UserDivision'];
            $nestedData['First_Name'] = $row['First_Name'];

            $nestedData['Status_AppvPresidentDirector'] = $row['Status_AppvPresidentDirector'];
            $nestedData['AppvPresidentDirector_At'] = !empty($row['AppvPresidentDirector_At']) ? date('Y-m-d H:i', strtotime($row['AppvPresidentDirector_At'])) : '-';
            $nestedData['Payment_Status'] = $row['Payment_Status'];
            $nestedData['Payment_Status_Time_Change'] = !empty($row['Payment_Status_Time_Change']) ? date('Y-m-d H:i', strtotime($row['Payment_Status_Time_Change'])) : '-';

            // Assistant Manager
            $nestedData['IsAppvAsstManager'] = $row['IsAppvAsstManager'];
            $nestedData['Status_AppvAsstManager'] = $row['Status_AppvAsstManager'];
            $nestedData['AppvAsstManager_At'] = !empty($row['AppvAsstManager_At']) ? date('Y-m-d H:i', strtotime($row['AppvAsstManager_At'])) : '-';

            // Manager
            $nestedData['IsAppvManager'] = $row['IsAppvManager'];
            $nestedData['Status_AppvManager'] = $row['Status_AppvManager'];
            $nestedData['AppvManager_At'] = !empty($row['AppvManager_At']) ? date('Y-m-d H:i', strtotime($row['AppvManager_At'])) : '-';

            // Senior Manager
            $nestedData['IsAppvSeniorManager'] = $row['IsAppvSeniorManager'];
            $nestedData['Status_AppvSeniorManager'] = $row['Status_AppvSeniorManager'];
            $nestedData['AppvSeniorManager_At'] = !empty($row['AppvSeniorManager_At']) ? date('Y-m-d H:i', strtotime($row['AppvSeniorManager_At'])) : '-';

            // General Manager
            $nestedData['IsAppvGeneralManager'] = $row['IsAppvGeneralManager'];
            $nestedData['Status_AppvGeneralManager'] = $row['Status_AppvGeneralManager'];
            $nestedData['AppvGeneralManager_At'] = !empty($row['AppvGeneralManager_At']) ? date('Y-m-d H:i', strtotime($row['AppvGeneralManager_At'])) : '-';

            // Additional Approval
            $nestedData['IsAppvAdditional'] = $row['IsAppvAdditional'];
            $nestedData['Status_AppvAdditional'] = $row['Status_AppvAdditional'];
            $nestedData['AppvAdditional_At'] = !empty($row['AppvAdditional_At']) ? date('Y-m-d H:i', strtotime($row['AppvAdditional_At'])) : '-';

            // Finance Person
            $nestedData['IsAppvFinancePerson'] = $row['IsAppvFinancePerson'];
            $nestedData['Status_AppvFinancePerson'] = $row['Status_AppvFinancePerson'];
            $nestedData['AppvFinancePerson_At'] = !empty($row['AppvFinancePerson_At']) ? date('Y-m-d H:i', strtotime($row['AppvFinancePerson_At'])) : '-';

            // Director
            $nestedData['IsAppvDirector'] = $row['IsAppvDirector'];
            $nestedData['Status_AppvDirector'] = $row['Status_AppvDirector'];
            $nestedData['AppvDirector_At'] = !empty($row['AppvDirector_At']) ? date('Y-m-d H:i', strtotime($row['AppvDirector_At'])) : '-';

            // Finance Director
            $nestedData['IsAppvFinanceDirector'] = $row['IsAppvFinanceDirector'];
            $nestedData['Status_AppvFinanceDirector'] = $row['Status_AppvFinanceDirector'];
            $nestedData['AppvFinanceDirector_At'] = !empty($row['AppvFinanceDirector_At']) ? date('Y-m-d H:i', strtotime($row['AppvFinanceDirector_At'])) : '-';

            // President Director (Tambahan jika di-render juga di frontend)
            $nestedData['IsAppvPresidentDirector'] = $row['IsAppvPresidentDirector'] ?? 0;
            $nestedData['Status_AppvPresidentDirector'] = $row['Status_AppvPresidentDirector'] ?? 0;
            $nestedData['AppvPresidentDirector_At'] = !empty($row['AppvPresidentDirector_At']) ? date('Y-m-d H:i', strtotime($row['AppvPresidentDirector_At'])) : '-';

            $data[] = $nestedData;
        }

        $json_data = array(
            "draw"            => intval($requestData['draw']),
            "recordsTotal"    => intval($totalData),
            "recordsFiltered" => intval($totalFiltered),
            "data"            => $data,
            "summary"         => $summary
        );
        echo json_encode($json_data);
    }
}
