<?php
defined('BASEPATH') or exit('No direct script access allowed');

class MonitoringTermin extends CI_Controller
{
    private $Date;
    private $DateTime;
    private $layout = 'layout';

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
        $this->data['page_title'] = "Monitoring Termin Belum Lengkap";
        $this->data['page_content'] = "cbr_app/monitoring_termin";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/cbr_app/monitoring_termin.js?v=' . time() . '"></script>';

        $this->data['employees'] = $this->db->query("SELECT THRMEmpPersonalData.User_ID, THRMEmpPersonalData.Emp_ID, THRMEmpPersonalData.First_Name
        FROM THRMEmpPersonalData, THRMCompany
        WHERE THRMEmpPersonalData.Company_ID = THRMCompany.Company_ID 
        AND THRMCompany.Company_ID = 2 
        AND THRMEmpPersonalData.Terminate_Date IS  NULL
        Order By THRMEmpPersonalData.First_Name ASC")->result();

        $this->load->view($this->layout, $this->data);
    }

    public function DT_List_Incomplete_Termin()
    {
        $requestData = $_REQUEST;
        $columns = array(
            0 => 'H.CBReq_No',
            1 => 'H.CBReq_No',
            2 => 'Type',
            3 => 'Document_Date',
            4 => 'H.Currency_Id',
            5 => 'Amount',
            6 => 'Document_Number',
            7 => 'Descript',
            8 => 'baseamount',
            9 => 'curr_rate',
            10 => 'Approval_Status',
            11 => 'CBReq_Status',
            12 => 'Paid_Status',
            13 => 'Creation_DateTime',
            14 => 'Created_By',
            15 => 'UserDivision',
            16 => 'First_Name',
            17 => 'Update_By',
            18 => 'H.Acc_ID',
            19 => 'H.Approve_Date',
            20 => 'H.Payment_Plan_Date',
            21 => 'Total_Termin_Submitted',
            22 => 'Total_Termin_Amount',
            23 => 'Remaining_Amount',
        );

        $order = $columns[$requestData['order']['0']['column']];
        $dir = $requestData['order']['0']['dir'];
        $searchValue = !empty($requestData['search']['value']) ? $requestData['search']['value'] : '';
        $employeeId = !empty($requestData['columns'][0]['search']['value']) && $requestData['columns'][0]['search']['value'] != 'ALL' ? $requestData['columns'][0]['search']['value'] : '';
        $columnRange = !empty($requestData['columns'][1]['search']['value']) ? $requestData['columns'][1]['search']['value'] : '';
        $fromDate = !empty($requestData['columns'][2]['search']['value']) ? $requestData['columns'][2]['search']['value'] : '';
        $untilDate = !empty($requestData['columns'][3]['search']['value']) ? $requestData['columns'][3]['search']['value'] : '';

        // Base query with LEFT JOIN for termin aggregation (more efficient than subqueries)
        $sql = "SELECT DISTINCT 
                    H.CBReq_No, 
                    H.Type, 
                    H.Document_Date, 
                    H.Document_Number, 
                    H.Acc_ID, 
                    H.Descript, 
                    H.Amount, 
                    H.baseamount, 
                    H.curr_rate, 
                    H.Approval_Status, 
                    H.CBReq_Status, 
                    H.Paid_Status, 
                    H.Creation_DateTime, 
                    H.Created_By, 
                    UP.First_Name AS Created_By_Name, 
                    H.Last_Update, 
                    H.Update_By, 
                    H.Currency_Id, 
                    H.Approve_Date, 
                    A.UserDivision, 
                    H.Payment_Plan_Date,
                    ISNULL(TT.Total_Termin_Count, 0) AS Total_Termin_Submitted,
                    ISNULL(TT.Total_Termin_Amount, 0) AS Total_Termin_Amount,
                    (H.Amount - ISNULL(TT.Total_Termin_Amount, 0)) AS Remaining_Amount
                FROM TAccCashBookReq_Header H
                INNER JOIN TUserGroupL ON H.Created_By = TUserGroupL.User_ID
                INNER JOIN TUserPersonal UP ON H.Created_By = UP.User_ID
                LEFT OUTER JOIN Ttrx_Cbr_Approval A ON H.CBReq_No = A.CBReq_No
                LEFT OUTER JOIN (
                    SELECT CBReq_No, 
                           COUNT(*) AS Total_Termin_Count, 
                           SUM(Amount_Termin) AS Total_Termin_Amount
                    FROM Ttrx_Cbr_Approval_Termin
                    GROUP BY CBReq_No
                ) TT ON H.CBReq_No = TT.CBReq_No
                WHERE H.Type = 'D'
                AND H.Company_ID = 2 
                AND ISNULL(H.isSPJ, 0) = 0
                AND H.Approval_Status = 3
                AND H.CBReq_Status = 3
                AND (H.isClose IS NULL OR H.isClose = 0)
                AND A.CBReq_No IS NOT NULL
                AND A.Status_AppvFinancePerson = 1
                AND (H.Amount - ISNULL(TT.Total_Termin_Amount, 0)) > 0.01";

        // Add search filter
        if (!empty($searchValue)) {
            $searchValue = $this->db->escape_like_str($searchValue);
            $sql .= " AND (
                    H.CBReq_No LIKE '%$searchValue%' 
                    OR UP.First_Name LIKE '%$searchValue%' 
                    OR H.Document_Number LIKE '%$searchValue%' 
                    OR H.Currency_Id LIKE '%$searchValue%' 
                    OR H.Descript LIKE '%$searchValue%' 
                    OR A.UserDivision LIKE '%$searchValue%'
                    OR CAST(H.Document_Date AS VARCHAR) LIKE '%$searchValue%' 
                    OR CAST(H.Payment_Plan_Date AS VARCHAR) LIKE '%$searchValue%' 
                    OR CAST(H.Amount AS VARCHAR) LIKE '%$searchValue%'
                )";
        }

        // Add employee filter
        if (!empty($employeeId)) {
            $employeeId = $this->db->escape($employeeId);
            $sql .= " AND H.Created_By = $employeeId";
        }

        // Add date range filter
        if (!empty($columnRange) && !empty($fromDate) && !empty($untilDate)) {
            $columnRange = $this->db->escape_str($columnRange);
            $fromDate = $this->db->escape($fromDate);
            $untilDate = $this->db->escape($untilDate);
            $sql .= " AND $columnRange >= $fromDate AND $columnRange <= $untilDate";
        }

        // Get total count before pagination
        $totalData = $this->db->query($sql)->num_rows();
        $totalFiltered = $totalData;

        // Add pagination
        $sql .= " ORDER BY $order $dir OFFSET " . (int)$requestData['start'] . " ROWS FETCH NEXT " . (int)$requestData['length'] . " ROWS ONLY ";

        $query = $this->db->query($sql);
        $data = array();

        foreach ($query->result_array() as $row) {
            $data[] = array(
                'CBReq_No' => $row['CBReq_No'],
                'Type' => $row['Type'],
                'Document_Date' => $row['Document_Date'],
                'Acc_ID' => $row['Acc_ID'],
                'Descript' => $row['Descript'],
                'Document_Number' => $row['Document_Number'],
                'Amount' => $row['Amount'],
                'baseamount' => $row['baseamount'],
                'curr_rate' => $row['curr_rate'],
                'Approval_Status' => $row['Approval_Status'],
                'CBReq_Status' => $row['CBReq_Status'],
                'Paid_Status' => $row['Paid_Status'],
                'Creation_DateTime' => $row['Creation_DateTime'],
                'Created_By' => $row['Created_By'],
                'First_Name' => $row['Created_By_Name'],
                'Last_Update' => $row['Last_Update'],
                'Update_By' => $row['Update_By'],
                'Currency_Id' => $row['Currency_Id'],
                'Approve_Date' => $row['Approve_Date'],
                'UserDivision' => $row['UserDivision'],
                'Payment_Plan_Date' => $row['Payment_Plan_Date'],
                'Total_Termin_Submitted' => $row['Total_Termin_Submitted'],
                'Total_Termin_Amount' => $row['Total_Termin_Amount'],
                'Remaining_Amount' => $row['Remaining_Amount'],
            );
        }

        echo json_encode(array(
            "draw" => (int)$requestData['draw'],
            "recordsTotal" => (int)$totalData,
            "recordsFiltered" => (int)$totalFiltered,
            "data" => $data,
        ));
    }

    public function DT_List_Hst_Submission_Termin()
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
        $SegmentMenu = $this->input->post('SegmentMenu');

        $sql = '';
        if ($SegmentMenu != 'CbrAppAccounting') {
            $sql = " AND (
                (IsAppvFinanceDirector = 1 and Status_AppvFinanceDirector <> 0 and AppvFinanceDirector_By = '$username') OR
                (IsAppvPresidentDirector = 1 and Status_AppvPresidentDirector <> 0 and AppvPresidentDirector_By = '$username') OR
                (IsAppvDirector = 1 and Status_AppvDirector <> 0 and AppvDirector_By = '$username') OR
                (IsAppvAdditional = 1 and Status_AppvAdditional <> 0 and AppvAdditional_By = '$username') OR
                (IsAppvGeneralManager = 1 and Status_AppvGeneralManager <> 0 and AppvGeneralManager_By = '$username') OR
                (IsAppvSeniorManager = 1 and Status_AppvSeniorManager <> 0 and AppvSeniorManager_By = '$username') OR
                (IsAppvManager = 1 and Status_AppvManager <> 0 and AppvManager_By = '$username') OR
                (IsAppvAsstManager = 1 and Status_AppvAsstManager <> 0 and AppvAsstManager_By = '$username')
            ) ";
        }


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
                $sql
                AND IsAppvFinancePerson = 1 
                AND Status_AppvFinancePerson <> 0";

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
