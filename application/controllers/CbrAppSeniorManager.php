<?php
defined('BASEPATH') or exit('No direct script access allowed');

class CbrAppSeniorManager extends CI_Controller
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
        $this->data['page_title'] = "Senior Manager Approval-Cash Book Requisition";
        $this->data['page_content'] = "cbr_app/approval";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/cbr_app/seniormanager.js?v=' . time() . '"></script>
                                       <script src="' . base_url() . 'assets/Pages/cbr_app/history_approval.js?v=' . time() . '"></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function approve_submission()
    {
        $Cbrs = $this->input->post('CBReq_No');

        $this->db->trans_start();
        foreach ($Cbrs as $CBReq_No) {
            $this->db->where('CBReq_No', $CBReq_No)->update($this->Ttrx_Cbr_Approval, [
                'Status_AppvSeniorManager' => 1,
                'AppvSeniorManager_Name' => $this->session->userdata('sys_sba_nama'),
                'AppvSeniorManager_By' => $this->session->userdata('sys_sba_username'),
                'AppvSeniorManager_At' => $this->DateTime,
            ]);
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
            $this->db->where('CBReq_No', $CBReq_No)->update($this->Ttrx_Cbr_Approval, [
                'Status_AppvSeniorManager' => 2,
                'AppvSeniorManager_Name' => $this->session->userdata('sys_sba_nama'),
                'AppvSeniorManager_By' => $this->session->userdata('sys_sba_username'),
                'AppvSeniorManager_At' => $this->DateTime,
            ]);

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
                'msg' => 'Cash Book Requisition successfully Rejected !',
            ]);
        }
    }

    // ========================================== DATATABLE 

    public function DT_List_To_Approve()
    {
        // Mendapatkan data request (untuk DataTables)
        $requestData = $_REQUEST;
        $username = $this->session->userdata('sys_sba_username');

        // Kolom untuk pengurutan dan pencarian
        $columns = array(
            0 => 'TAccCashBookReq_Header.CBReq_No',
            1 => 'TAccCashBookReq_Header.CBReq_No',
            2 => 'Type',
            3 => 'Document_Date',
            4 => 'TAccCashBookReq_Header.Currency_Id',
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
            15 => 'First_Name',
            16 => 'Last_Update',
            17 => 'Update_By',
            18 => 'TAccCashBookReq_Header.Acc_ID',
            19 => 'TAccCashBookReq_Header.Approve_Date',
        );

        // Menentukan pengurutan
        $order = $columns[$requestData['order']['0']['column']];
        $dir = $requestData['order']['0']['dir'];

        // --- Membangun Kueri SQL ---

        $sql = "SELECT DISTINCT 
                    H.CBReq_No, H.Type, H.Document_Date, H.Document_Number, 
                    H.Acc_ID, H.Descript, H.Amount, H.baseamount, H.curr_rate, 
                    H.Approval_Status, H.CBReq_Status, H.Paid_Status, H.Creation_DateTime, 
                    H.Created_By, P.First_Name AS Created_By_Name, H.Last_Update, H.Update_By, 
                    H.Currency_Id, H.Approve_Date
                FROM TAccCashBookReq_Header H
                INNER JOIN TUserGroupL GL ON H.Created_By = GL.User_ID
                INNER JOIN TUserPersonal P ON H.Created_By = P.User_ID
                LEFT OUTER JOIN Ttrx_Cbr_Approval A ON H.CBReq_No = A.CBReq_No
                WHERE H.Type='D'
                AND H.Company_ID = 2 
                AND ISNULL(H.isSPJ,0) = 0
                AND H.Approval_Status = 3
                AND H.CBReq_Status = 3
                AND A.CBReq_No IS NOT NULL
                AND 
                (
                    (
                        -- BUG DARI KODE ASLI: Menghilangkan klausa 'AND' di awal blok ini
                        A.AppvSeniorManager_By = '$username' AND A.IsAppvSeniorManager = 1 AND A.Status_AppvSeniorManager = 0 
                        AND ((A.IsAppvStaff = 0) OR (A.IsAppvStaff = 1 AND A.Status_AppvStaff = 1))
                        AND ((A.IsAppvChief = 0) OR (A.IsAppvChief = 1 AND A.Status_AppvChief = 1))
                        AND ((A.IsAppvAsstManager = 0) OR (A.IsAppvAsstManager = 1 AND A.Status_AppvAsstManager = 1))
                        AND ((A.IsAppvManager) = 0 OR (A.IsAppvManager = 1 AND A.Status_AppvManager = 1)) 
                    )
                    OR 
                    (
                        A.AppvAdditional_By = '$username' AND A.IsAppvAdditional = 1 AND A.Status_AppvAdditional = 0 
                        AND ((A.IsAppvStaff = 0) OR (A.IsAppvStaff = 1 AND A.Status_AppvStaff = 1))
                        AND ((A.IsAppvChief = 0) OR (A.IsAppvChief = 1 AND A.Status_AppvChief = 1))
                        AND ((A.IsAppvAsstManager = 0) OR (A.IsAppvAsstManager = 1 AND A.Status_AppvAsstManager = 1))
                        AND ((A.IsAppvManager) = 0 OR (A.IsAppvManager = 1 AND A.Status_AppvManager = 1))
                    )
                )";

        // Total data tanpa filter pencarian
        $totalData = $this->db->query($sql)->num_rows();

        // 2. Menambahkan Filter Pencarian (Search)
        if (!empty($requestData['search']['value'])) {
            // Pencegahan SQL Injection untuk LIKE
            $searchValue = $this->db->escape_like_str($requestData['search']['value']);

            // Tambahkan kondisi search, pastikan dilingkupi oleh tanda kurung ()
            $sql .= " AND (H.CBReq_No LIKE '%" . $searchValue . "%' ";
            $sql .= " OR P.First_Name LIKE '%" . $searchValue . "%' "; // Menggunakan alias P
            $sql .= " OR H.Document_Number LIKE '%" . $searchValue . "%' ";
            $sql .= " OR H.Document_Date LIKE '%" . $searchValue . "%' ";
            $sql .= " OR H.Currency_Id LIKE '%" . $searchValue . "%' ";
            $sql .= " OR H.Descript LIKE '%" . $searchValue . "%' ";
            $sql .= " OR H.CBReq_Status LIKE '%" . $searchValue . "%' ";
            $sql .= " OR H.Amount LIKE '%" . $searchValue . "%') ";
        }

        // Total data setelah filter pencarian
        $totalFiltered = $this->db->query($sql)->num_rows();

        // 3. Menambahkan Urutan dan Batasan (Pagination)
        $sql .= " ORDER BY $order $dir OFFSET " . (int)$requestData['start'] . " ROWS FETCH NEXT " . (int)$requestData['length'] . " ROWS ONLY";

        $query = $this->db->query($sql);
        $data = array();

        foreach ($query->result_array() as $row) {
            $nestedData = array();
            $nestedData['CBReq_No'] = $row['CBReq_No'];
            $nestedData['Type'] = $row['Type'];
            $nestedData['Document_Date'] = $row['Document_Date'];
            $nestedData['Acc_ID'] = $row['Acc_ID'];
            $nestedData['Descript'] = $row['Descript'];
            $nestedData['Document_Number'] = $row['Document_Number'];
            $nestedData['Amount'] = $row['Amount'];
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

            $data[] = $nestedData;
        }

        // Output JSON DataTables
        $json_data = array(
            "draw" => intval($requestData['draw']),
            "recordsTotal" => intval($totalData),
            "recordsFiltered" => intval($totalFiltered),
            "data" => $data,
        );

        echo json_encode($json_data);
    }
}
