<?php
defined('BASEPATH') or exit('No direct script access allowed');

class CbrAppFinanceDirector extends CI_Controller
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
        $this->data['page_title'] = "Finance Director Approval-Cash Book Requisition";
        $this->data['page_content'] = "cbr_app/approval";

        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/cbr_app/finance_director.js?v=' . time() . '"></script>
                                       <script src="' . base_url() . 'assets/Pages/cbr_app/history_approval_findir.js?v=' . time() . '"></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function approve_submission()
    {
        $Cbrs = $this->input->post('CBReq_No');
        $username = $this->session->userdata('sys_sba_username');

        $this->db->trans_start();
        foreach ($Cbrs as $CBReq_No) {
            $RowApproval = $this->db->get_where($this->Ttrx_Cbr_Approval, ['CBReq_No' => $CBReq_No])->row();

            if ($RowApproval->IsAppvFinanceDirector == 1 && $RowApproval->AppvFinanceDirector_By == $username) {
                if ($RowApproval->Doc_Legitimate_Pos_On == 'FinanceDirector') {
                    $data = [
                        'Status_AppvFinanceDirector' => 1,
                        'AppvFinanceDirector_Name'   => $this->session->userdata('sys_sba_nama'),
                        'AppvFinanceDirector_At'     => $this->DateTime,
                        'Legitimate' => 1,
                    ];
                } else {
                    $data = [
                        'Status_AppvFinanceDirector' => 1,
                        'AppvFinanceDirector_Name'   => $this->session->userdata('sys_sba_nama'),
                        'AppvFinanceDirector_At'     => $this->DateTime,
                    ];
                }

                $this->db->where('CBReq_No', $CBReq_No)->update($this->Ttrx_Cbr_Approval, $data);
            }
            if ($RowApproval->IsAppvDirector == 1 && $RowApproval->AppvDirector_By == $username) {
                $this->db->where('CBReq_No', $CBReq_No)->update($this->Ttrx_Cbr_Approval, [
                    'Status_AppvDirector' => 1,
                    'AppvDirector_Name'   => $this->session->userdata('sys_sba_nama'),
                    'AppvDirector_At'     => $this->DateTime,
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
                'msg'  => 'Cash Book Requisition successfully approved !',
            ]);
        }
    }

    public function reject_submission()
    {
        $Cbrs = $this->input->post('CBReq_No');
        $username = $this->session->userdata('sys_sba_username');
        $rejection_reason = $this->input->post('rejection_reason');

        $this->db->trans_start();
        foreach ($Cbrs as $CBReq_No) {
            $RowApproval = $this->db->get_where($this->Ttrx_Cbr_Approval, ['CBReq_No' => $CBReq_No])->row();

            if ($RowApproval->IsAppvFinanceDirector == 1 && $RowApproval->AppvFinanceDirector_By == $username) {
                $this->db->where('CBReq_No', $CBReq_No)->update($this->Ttrx_Cbr_Approval, [
                    'Status_AppvFinanceDirector' => 2,
                    'AppvFinanceDirector_Name'   => $this->session->userdata('sys_sba_nama'),
                    'AppvFinanceDirector_At'     => $this->DateTime,
                ]);
            }
            if ($RowApproval->IsAppvDirector == 1 && $RowApproval->AppvDirector_By == $username) {
                $this->db->where('CBReq_No', $CBReq_No)->update($this->Ttrx_Cbr_Approval, [
                    'Status_AppvDirector' => 2,
                    'AppvDirector_Name'   => $this->session->userdata('sys_sba_nama'),
                    'AppvDirector_At'     => $this->DateTime,
                ]);
            }

            $this->help->record_history_approval($CBReq_No, $rejection_reason);
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
                'msg'  => 'Cash Book Requisition successfully Rejected !',
            ]);
        }
    }

    // ========================================== DATATABLE 

    public function DT_List_To_Approve()
    {
        $requestData = $_REQUEST;
        $columns = array(
            0  => 'TAccCashBookReq_Header.CBReq_No',
            1  => 'TAccCashBookReq_Header.CBReq_No',
            2  => 'Type',
            3  => 'Document_Date',
            4  => 'TAccCashBookReq_Header.Currency_Id',
            5  => 'Amount',
            6  => 'Document_Number',
            7  => 'Descript',
            8  => 'baseamount',
            9  => 'curr_rate',
            10 => 'Approval_Status',
            11 => 'CBReq_Status',
            12 => 'Paid_Status',
            13 => 'Creation_DateTime',
            14 => 'Created_By',
            15 => 'First_Name',
            16 => 'Last_Update',
            17 => 'Update_By',
            18 => 'TAccCashBookReq_Header.Acc_ID ',
            19 => 'TAccCashBookReq_Header.Approve_Date',

        );
        $order  = $columns[$requestData['order']['0']['column']];
        $dir    = $requestData['order']['0']['dir'];
        $username = $this->session->userdata('sys_sba_username');

        $sql = "SELECT  distinct TAccCashBookReq_Header.CBReq_No, Type, Document_Date, Document_Number, TAccCashBookReq_Header.Acc_ID, Descript, Amount, baseamount, curr_rate, Approval_Status, CBReq_Status, Paid_Status, Creation_DateTime, Created_By, First_Name AS Created_By_Name, Last_Update, Update_By, TAccCashBookReq_Header.Currency_Id, TAccCashBookReq_Header.Approve_Date, UserDivision
        FROM TAccCashBookReq_Header
        INNER JOIN TUserGroupL ON TAccCashBookReq_Header.Created_By = TUserGroupL.User_ID
        INNER JOIN TUserPersonal ON TAccCashBookReq_Header.Created_By = TUserPersonal.User_ID
        LEFT OUTER JOIN Ttrx_Cbr_Approval ON TAccCashBookReq_Header.CBReq_No = Ttrx_Cbr_Approval.CBReq_No
        WHERE TAccCashBookReq_Header.Type='D'
        AND TAccCashBookReq_Header.Company_ID = 2 
        AND isNull(isSPJ,0) = 0
        AND Approval_Status  = 3
        AND CBReq_Status = 3
        AND TAccCashBookReq_Header.Paid_Status in ('NP','HP')
        AND (isClose IS NULL OR isClose = 0)
        AND Ttrx_Cbr_Approval.CBReq_No IS NOT NULL
        AND (( IsAppvFinanceDirector = 1
                AND Status_AppvFinanceDirector = 0
                AND Ttrx_Cbr_Approval.AppvFinanceDirector_By = '$username'
                AND ((IsAppvStaff = 0) or (IsAppvStaff = 1 and Status_AppvStaff = 1))
                AND ((IsAppvChief = 0) or (IsAppvChief = 1 and Status_AppvChief = 1))
                AND ((IsAppvAsstManager) = 0 or (IsAppvAsstManager = 1 and Status_AppvAsstManager = 1))
                AND ((IsAppvManager = 0) or (IsAppvManager = 1 and Status_AppvManager = 1))
                AND ((IsAppvSeniorManager = 0) or (IsAppvSeniorManager = 1 and Status_AppvSeniorManager = 1))
                AND ((IsAppvGeneralManager = 0) or (IsAppvGeneralManager = 1 and Status_AppvGeneralManager = 1))
                AND ((IsAppvAdditional = 0) or (IsAppvAdditional = 1 and Status_AppvAdditional = 1))
                AND ((IsAppvFinancePerson = 0)  or (IsAppvFinancePerson = 1 and Status_AppvFinancePerson = 1))
                AND ((IsAppvDirector = 0) or (IsAppvDirector = 1 and Status_AppvDirector = 1))
            ) 
        OR ( IsAppvDirector = 1
                AND Status_AppvDirector = 0
                AND Ttrx_Cbr_Approval.AppvDirector_By = '$username'
                AND ((IsAppvStaff = 0) or (IsAppvStaff = 1 and Status_AppvStaff = 1))
                AND ((IsAppvChief = 0) or (IsAppvChief = 1 and Status_AppvChief = 1))
                AND ((IsAppvAsstManager) = 0 or (IsAppvAsstManager = 1 and Status_AppvAsstManager = 1))
                AND ((IsAppvManager = 0) or (IsAppvManager = 1 and Status_AppvManager = 1))
                AND ((IsAppvSeniorManager = 0) or (IsAppvSeniorManager = 1 and Status_AppvSeniorManager = 1))
                AND ((IsAppvGeneralManager = 0) or (IsAppvGeneralManager = 1 and Status_AppvGeneralManager = 1))
                AND ((IsAppvAdditional = 0) or (IsAppvAdditional = 1 and Status_AppvAdditional = 1)) 
                AND ((IsAppvFinancePerson = 0)  or (IsAppvFinancePerson = 1 and Status_AppvFinancePerson = 1)) 
            )) ";

        $totalData = $this->db->query($sql)->num_rows();
        if (!empty($requestData['search']['value'])) {
            $sql .= " AND (TAccCashBookReq_Header.CBReq_No LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR First_Name LIKE '%" . $requestData['search']['value'] . "%' )";
            // $sql .= " OR Document_Number LIKE '%" . $requestData['search']['value'] . "%') ";
            // $sql .= " OR Document_Date LIKE '%" . $requestData['search']['value'] . "%' ";
            // $sql .= " OR Descript LIKE '%" . $requestData['search']['value'] . "%') ";
            // $sql .= " OR CBReq_Status LIKE '%" . $requestData['search']['value'] . "%' ";
            // $sql .= " OR TAccCashBookReq_Header.Currency_Id LIKE '%" . $requestData['search']['value'] . "%' ";
            // $sql .= " OR Amount LIKE '%" . $requestData['search']['value'] . "%') ";
        }
        //----------------------------------------------------------------------------------
        $totalFiltered = $this->db->query($sql)->num_rows();
        $sql .= " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";
        $query = $this->db->query($sql);
        $data = array();
        foreach ($query->result_array() as $row) {
            $nestedData = array();
            $nestedData['CBReq_No']          = $row['CBReq_No'];
            $nestedData['Type']              = $row['Type'];
            $nestedData['Document_Date']     = $row['Document_Date'];
            $nestedData['Acc_ID']            = $row['Acc_ID'];
            $nestedData['Descript']          = $row['Descript'];
            $nestedData['Document_Number']   = $row['Document_Number'];
            $nestedData['Amount']            = $row['Amount'];
            $nestedData['baseamount']        = $row['baseamount'];
            $nestedData['curr_rate']         = $row['curr_rate'];
            $nestedData['Approval_Status']   = $row['Approval_Status'];
            $nestedData['CBReq_Status']      = $row['CBReq_Status'];
            $nestedData['Paid_Status']       = $row['Paid_Status'];
            $nestedData['Creation_DateTime'] = $row['Creation_DateTime'];
            $nestedData['Created_By']        = $row['Created_By'];
            $nestedData['First_Name']        = $row['Created_By_Name'];
            $nestedData['Last_Update']       = $row['Last_Update'];
            $nestedData['Update_By']         = $row['Update_By'];
            $nestedData['Currency_Id']       = $row['Currency_Id'];
            $nestedData['Approve_Date']      = $row['Approve_Date'];
            $nestedData['UserDivision']      = $row['UserDivision'];

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


    public function check_attachment_existence()
    {
        // Inisialisasi daftar CBR (Tidak digunakan untuk filter IN, tapi dipertahankan sebagai placeholder)
        $cbr_numbers = [];

        // User ID yang sedang dicari (Hardcoded dari query Anda)
        $target_user_id = '90112';

        // 1. Ambil data Attachment dari Database dengan JOIN ke Approval

        $this->db->select('Ttrx_Dtl_Attachment_Cbr.SysId, CbrNo, Attachment_FileName, Year_Upload, AttachmentType, ERPQview_User_Employee.First_Name AS Created_By_Name');
        $this->db->from('dbsai_erp_uat.dbo.Ttrx_Dtl_Attachment_Cbr');

        // JOIN ke master user
        $this->db->join('ERPQview_User_Employee', 'Ttrx_Dtl_Attachment_Cbr.Created_By = ERPQview_User_Employee.User_Name', 'inner');

        // 🔥 KOREKSI 1: Menambahkan JOIN ke tabel Approval
        $this->db->join('Ttrx_Cbr_Approval tca', 'Ttrx_Dtl_Attachment_Cbr.CbrNo = tca.CBReq_No', 'inner');

        // 🔥 KOREKSI 2: Filter Tanggal
        $this->db->where('YEAR(Ttrx_Dtl_Attachment_Cbr.Created_at)', 2025);
        $this->db->where('MONTH(Ttrx_Dtl_Attachment_Cbr.Created_at) <', 12);

        // 🔥 KOREKSI 3: Filter Status Approval (Menggunakan kurung kurawal untuk logika OR)
        $approval_condition = "((tca.IsAppvFinanceDirector = 1 AND tca.Status_AppvFinanceDirector = 0 AND tca.AppvFinanceDirector_By = '$target_user_id') 
                           OR 
                           (tca.IsAppvDirector = 1 AND tca.Status_AppvDirector = 0 AND tca.AppvDirector_By = '$target_user_id'))";

        $this->db->where($approval_condition);

        $query = $this->db->get();
        $attachments = $query->result();

        $processed_attachments = [];
        $base_upload_path = FCPATH . 'assets/Files/AttachmentCbr/';

        // 2. Loop dan Verifikasi Keberadaan File
        foreach ($attachments as $row) {

            $attachment_type_clean = trim($row->AttachmentType);

            $file_path = $base_upload_path .
                $row->Year_Upload . '/' .
                $attachment_type_clean . '/' .
                $row->Attachment_FileName;

            // <a target='_blank' href="<?= base_url() >assets/Files/AttachmentCbr/<?= $li->Year_Upload >/<= $li->AttachmentType_Code > /<= $li->Attachment_FileName; >"><?= $li->Attachment_FileName; ></a>

            $is_exist = file_exists($file_path);

            $row->is_exist = $is_exist;
            $processed_attachments[] = $row;
        }

        // 3. OUTPUT TABEL HTML
        echo '<style>
            table { width: 100%; border-collapse: collapse; font-family: Arial, sans-serif; font-size: 14px; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #f2f2f2; }
            .status-ok { color: white; background-color: #28a745; padding: 3px 6px; border-radius: 4px; font-weight: bold; }
            .status-fail { color: white; background-color: #dc3545; padding: 3px 6px; border-radius: 4px; font-weight: bold; }
          </style>';

        echo '<h2>Laporan Pengecekan Keberadaan File Attachment (ESBA)</h2>';
        echo "<h4>Filter: Dibuat Tahun 2025 (Jan-Nov) DAN Menunggu Approval dari User ID: $target_user_id</h4>";
        echo '<table>';

        // Header Tabel
        echo '<thead>';
        echo '<tr>';
        echo '<th>No.</th>';
        echo '<th>CBR No</th>';
        echo '<th>Nama Pembuat</th>';
        echo '<th>Attachment Type</th>';
        echo '<th>File Name</th>';
        echo '<th>Status Exist</th>';
        echo '</tr>';
        echo '</thead>';

        // Body Tabel (Data)
        echo '<tbody>';
        $counter = 1;
        if (empty($processed_attachments)) {
            echo '<tr><td colspan="6" style="text-align: center;">Tidak ada data attachment ditemukan berdasarkan filter yang diberikan.</td></tr>';
        } else {
            foreach ($processed_attachments as $data) {
                $status_class = $data->is_exist ? 'status-ok' : 'status-fail';
                $status_text  = $data->is_exist ? 'EXIST (Ada)' : 'MISSING (Hilang)';

                echo '<tr>';
                echo '<td>' . $counter++ . '</td>';
                echo '<td>' . htmlspecialchars($data->CbrNo) . '</td>';
                echo '<td>' . htmlspecialchars($data->Created_By_Name ?? '-') . '</td>';
                echo '<td>' . htmlspecialchars($data->AttachmentType) . '</td>';
                echo '<td>' . htmlspecialchars($data->Attachment_FileName) . '</td>';
                echo '<td><span class="' . $status_class . '">' . $status_text . '</span></td>';
                echo '</tr>';
            }
        }
        echo '</tbody>';
        echo '</table>';
    }
}
