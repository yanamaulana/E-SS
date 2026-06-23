<?php
defined('BASEPATH') or exit('No direct script access allowed');

class MonitoringCbr extends CI_Controller
{
    private $Date;
    private $DateTime;
    private $layout = 'layout';
    private $Ttrx_Cbr_Approval = 'Ttrx_Cbr_Approval';

    private $TmstTrxSettingSteppApprovalCbr = 'TmstTrxSettingSteppApprovalCbr';
    private $Ttrx_Dtl_Attachment_Cbr = 'Ttrx_Dtl_Attachment_Cbr';
    private $Ttrx_DtlHst_Attachment_Cbr = 'Ttrx_DtlHst_Attachment_Cbr';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->Date = date("Y-m-d");
        $this->DateTime = date("Y-m-d H:i:s");
        $this->load->model('m_helper', 'help');
        $this->load->model('m_DataTable', 'M_Datatables');
    }

    private function get_datatable_order(array $requestData, array $columns): array
    {
        $columnIndex = isset($requestData['order'][0]['column']) ? intval($requestData['order'][0]['column']) : 0;
        $direction = strtoupper($requestData['order'][0]['dir'] ?? 'ASC');

        if (!isset($columns[$columnIndex])) {
            $columnIndex = 0;
        }

        if ($direction !== 'ASC' && $direction !== 'DESC') {
            $direction = 'ASC';
        }

        return [$columns[$columnIndex], $direction];
    }

    private function build_search_condition(string $searchValue, array $searchColumns): string
    {
        if ($searchValue === '') {
            return '';
        }

        $escapedSearch = $this->db->escape_like_str($searchValue);
        $conditions = array_map(function ($column) use ($escapedSearch) {
            return "$column LIKE '%{$escapedSearch}%'";
        }, $searchColumns);

        return ' AND (' . implode(' OR ', $conditions) . ') ';
    }

    private function build_fts_condition(string $searchValue, array $searchColumns): string
    {
        if ($searchValue === '') {
            return '';
        }

        $ftsKeyword = "'\"*" . $this->db->escape_str($searchValue) . "*\"'";
        $columnStr = implode(', ', $searchColumns);

        return " AND (CONTAINS(($columnStr), $ftsKeyword) OR CONTAINS(TUserPersonal.First_Name, $ftsKeyword)) ";
    }

    private function format_datetime(?string $datetime, string $format = 'Y-m-d H:i'): string
    {
        return !empty($datetime) ? date($format, strtotime($datetime)) : '-';
    }

    private function map_row_with_transform(array $row, array $fieldMap, array $transforms = []): array
    {
        $result = [];
        foreach ($fieldMap as $outputKey => $rowKey) {
            $value = $row[$rowKey] ?? null;

            if (isset($transforms[$outputKey])) {
                $value = call_user_func($transforms[$outputKey], $value);
            }

            $result[$outputKey] = $value;
        }
        return $result;
    }

    private function build_datatable_response(string $baseSql, array $orderColumns, array $searchColumns, array $fieldMap, array $requestData, bool $useFts = false, array $transforms = []): array
    {
        list($order, $dir) = $this->get_datatable_order($requestData, $orderColumns);
        $start = isset($requestData['start']) ? intval($requestData['start']) : 0;
        $length = isset($requestData['length']) ? intval($requestData['length']) : 10;
        $searchValue = trim($requestData['search']['value'] ?? '');

        if ($useFts) {
            $searchCondition = $this->build_fts_condition($searchValue, $searchColumns);
        } else {
            $searchCondition = $this->build_search_condition($searchValue, $searchColumns);
        }

        $filteredSql = $baseSql . $searchCondition;

        $totalData = $this->db->query($baseSql)->num_rows();
        $totalFiltered = $this->db->query($filteredSql)->num_rows();

        $pageSql = $filteredSql . " ORDER BY $order $dir OFFSET $start ROWS FETCH NEXT $length ROWS ONLY ";
        $query = $this->db->query($pageSql);

        $data = [];
        foreach ($query->result_array() as $row) {
            $data[] = $this->map_row_with_transform($row, $fieldMap, $transforms);
        }

        return [
            'draw' => intval($requestData['draw'] ?? 0),
            'recordsTotal' => intval($totalData),
            'recordsFiltered' => intval($totalFiltered),
            'data' => $data,
        ];
    }

    public function index()
    {
        $this->data['page_title'] = "Monitoring Cash Book Requisition";
        $this->data['page_content'] = "cbr_app/monitoring_cbr";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/cbr_app/monitoring_cbr.js"></script>';

        $this->data['employees'] = $this->db->query("SELECT THRMEmpPersonalData.User_ID, THRMEmpPersonalData.Emp_ID, THRMEmpPersonalData.First_Name
        FROM THRMEmpPersonalData, THRMCompany
        WHERE THRMEmpPersonalData.Company_ID = THRMCompany.Company_ID 
        AND THRMCompany.Company_ID = 2 
        AND THRMEmpPersonalData.Terminate_Date IS  NULL
        Order By THRMEmpPersonalData.First_Name ASC")->result();

        $this->load->view($this->layout, $this->data);
    }

    public function approve_submission()
    {
        $Cbrs = $this->input->post('CBReq_No');
        $RulesApprovals = $this->db->get_where($this->TmstTrxSettingSteppApprovalCbr, ['UserName_User' => $this->session->userdata('sys_sba_username')]);
        $this->db->trans_start();

        if ($RulesApprovals->num_rows() == 0) {
            return $this->help->Fn_resulting_response([
                'code' => 505,
                'msg'  => "Your approval request has failed, you do not have an approval step yet !",
            ]);
        }

        $RulesApproval = $RulesApprovals->row();

        foreach ($Cbrs as $CBReq_No) {
            $this->db->insert($this->Ttrx_Cbr_Approval, [
                "CBReq_No" => $CBReq_No,
                "IsAppvStaff" => $RulesApproval->Staff,
                "Status_AppvStaff" => NULL,
                "AppvStaff_By" => NULL,
                "AppvStaff_At" => NULL,
                "IsAppvChief" => $RulesApproval->Chief,
                "Status_AppvChief" => NULL,
                "AppvChief_By" => NULL,
                "AppvChief_At" => NULL,
                "IsAppvAsstManager" => $RulesApproval->AsstManager,
                "Status_AppvAsstManager" => NULL,
                "AppvAsstManager_By" => NULL,
                "AppvAsstManager_At" => NULL,
                "IsAppvManager" => $RulesApproval->Manager,
                "Status_AppvManager" => NULL,
                "AppvManager_By" => NULL,
                "AppvManager_At" => NULL,
                "IsAppvSeniorManager" => $RulesApproval->SeniorManager,
                "Status_AppvSeniorManager" => NULL,
                "AppvSeniorManager_By" => NULL,
                "AppvSeniorManager_At" => NULL,
                "IsAppvGeneralManager" => $RulesApproval->GeneralManager,
                "Status_AppvGeneralManager" => NULL,
                "AppvGeneralManager_By" => NULL,
                "AppvGeneralManager_At" => NULL,
                "IsAppvDirector" => $RulesApproval->Director,
                "Status_AppvDirector" => NULL,
                "AppvDirector_By" => NULL,
                "AppvDirector_At" => NULL,
                "IsAppvPresidentDirector" => $RulesApproval->PresidentDirector,
                "Status_AppvPresidentDirector" => NULL,
                "AppvPresidentDirector_By" => NULL,
                "AppvPresidentDirector_At" => NULL,
                "IsAppvFinanceStaff" => $RulesApproval->FinanceStaff,
                "Status_AppvFinanceStaff" => NULL,
                "AppvFinanceStaff_By" => NULL,
                "AppvFinanceStaff_At" => NULL,
                "IsAppvFinanceManager" => $RulesApproval->FinanceManager,
                "Status_AppvFinanceManager" => NULL,
                "AppvFinanceManager_By" => NULL,
                "AppvFinanceManager_At" => NULL,
                "IsAppvFinanceDirector" => $RulesApproval->FinanceDirector,
                "Status_AppvFinanceDirector" => NULL,
                "AppvFinanceDirector_By" => NULL,
                "AppvFinanceDirector_At" => NULL,
                "UserName_User" => $this->session->userdata('sys_sba_username'),
                "UserDivision" => $this->session->userdata('sys_sba_department'),
                "Rec_Created_At" => $this->DateTime,
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
                'msg' => 'Approval request successful. Please perform periodic monitoring on your submission !',
            ]);
        }
    }

    // -------------------------------------------------- 

    public function DT_List_To_Approve()
    {
        $requestData = $_REQUEST;
        $from = $this->input->post('from');
        $until = $this->input->post('until');
        $createdBy = $this->input->post('employee');
        $sqlCreatedBy = ($createdBy !== 'ALL') ? "AND TAccCashBookReq_Header.Created_By = '" . $this->db->escape_str($createdBy) . "'" : '';

        $orderColumns = [
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
        ];

        $searchColumns = ['TAccCashBookReq_Header.CBReq_No', 'First_Name', 'Document_Number', 'Document_Date', 'TAccCashBookReq_Header.Currency_Id', 'Descript', 'CBReq_Status', 'Amount'];

        $fieldMap = [
            'CBReq_No' => 'CBReq_No',
            'Type' => 'Type',
            'Document_Date' => 'Document_Date',
            'Acc_ID' => 'Acc_ID',
            'Descript' => 'Descript',
            'Document_Number' => 'Document_Number',
            'Amount' => 'Amount',
            'baseamount' => 'baseamount',
            'curr_rate' => 'curr_rate',
            'Approval_Status' => 'Approval_Status',
            'CBReq_Status' => 'CBReq_Status',
            'Paid_Status' => 'Paid_Status',
            'Creation_DateTime' => 'Creation_DateTime',
            'Created_By' => 'Created_By',
            'First_Name' => 'Created_By_Name',
            'Last_Update' => 'Last_Update',
            'Update_By' => 'Update_By',
            'Currency_Id' => 'Currency_Id',
            'Approve_Date' => 'Approve_Date',
        ];

        $baseSql = "SELECT DISTINCT TAccCashBookReq_Header.CBReq_No, Type, Document_Date, Document_Number, TAccCashBookReq_Header.Acc_ID, Descript, Amount, baseamount, curr_rate, Approval_Status, CBReq_Status, Paid_Status, Creation_DateTime, Created_By, First_Name AS Created_By_Name, Last_Update, Update_By, TAccCashBookReq_Header.Currency_Id, TAccCashBookReq_Header.Approve_Date
            FROM TAccCashBookReq_Header
            INNER JOIN TUserGroupL ON TAccCashBookReq_Header.Created_By = TUserGroupL.User_ID
            INNER JOIN TUserPersonal ON TAccCashBookReq_Header.Created_By = TUserPersonal.User_ID
            LEFT OUTER JOIN Ttrx_Cbr_Approval ON TAccCashBookReq_Header.CBReq_No = Ttrx_Cbr_Approval.CBReq_No
            WHERE TAccCashBookReq_Header.Type = 'D'
            AND TAccCashBookReq_Header.Document_Date >= {d '" . $this->db->escape_str($from) . "'}
            AND TAccCashBookReq_Header.Document_Date <= {d '" . $this->db->escape_str($until) . "'}
            AND TAccCashBookReq_Header.Company_ID = 2
            AND isNull(isSPJ, 0) = 0
            AND Approval_Status = 3
            AND CBReq_Status = 3
            AND Paid_Status = 'NP'
            AND Ttrx_Cbr_Approval.CBReq_No IS NULL
            $sqlCreatedBy";

        $response = $this->build_datatable_response($baseSql, $orderColumns, $searchColumns, $fieldMap, $requestData);
        echo json_encode($response);
    }

    public function DT_List_History_Submission()
    {
        $requestData = $_REQUEST;
        $from = $this->input->post('from');
        $until = $this->input->post('until');
        $username = $this->session->userdata('sys_sba_userid');

        $orderColumns = [
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
        ];

        $searchColumns = ['TAccCashBookReq_Header.CBReq_No', 'First_Name', 'Document_Number', 'Document_Date', 'TAccCashBookReq_Header.Currency_Id', 'Descript', 'CBReq_Status', 'Amount'];

        $fieldMap = [
            'CBReq_No' => 'CBReq_No',
            'Type' => 'Type',
            'Document_Date' => 'Document_Date',
            'Acc_ID' => 'Acc_ID',
            'Descript' => 'Descript',
            'Document_Number' => 'Document_Number',
            'Amount' => 'Amount',
            'baseamount' => 'baseamount',
            'curr_rate' => 'curr_rate',
            'Approval_Status' => 'Approval_Status',
            'CBReq_Status' => 'CBReq_Status',
            'Paid_Status' => 'Paid_Status',
            'Creation_DateTime' => 'Creation_DateTime',
            'Created_By' => 'Created_By',
            'First_Name' => 'Created_By_Name',
            'Last_Update' => 'Last_Update',
            'Update_By' => 'Update_By',
            'Currency_Id' => 'Currency_Id',
            'Approve_Date' => 'Approve_Date',
            'IsAppvStaff' => 'IsAppvStaff',
            'Status_AppvStaff' => 'Status_AppvStaff',
            'AppvStaff_By' => 'AppvStaff_By',
            'AppvStaff_At' => 'AppvStaff_At',
            'IsAppvChief' => 'IsAppvChief',
            'Status_AppvChief' => 'Status_AppvChief',
            'AppvChief_By' => 'AppvChief_By',
            'AppvChief_At' => 'AppvChief_At',
            'IsAppvAsstManager' => 'IsAppvAsstManager',
            'Status_AppvAsstManager' => 'Status_AppvAsstManager',
            'AppvAsstManager_By' => 'AppvAsstManager_By',
            'AppvAsstManager_At' => 'AppvAsstManager_At',
            'IsAppvManager' => 'IsAppvManager',
            'Status_AppvManager' => 'Status_AppvManager',
            'AppvManager_By' => 'AppvManager_By',
            'AppvManager_At' => 'AppvManager_At',
            'IsAppvSeniorManager' => 'IsAppvSeniorManager',
            'Status_AppvSeniorManager' => 'Status_AppvSeniorManager',
            'AppvSeniorManager_By' => 'AppvSeniorManager_By',
            'AppvSeniorManager_At' => 'AppvSeniorManager_At',
            'IsAppvGeneralManager' => 'IsAppvGeneralManager',
            'Status_AppvGeneralManager' => 'Status_AppvGeneralManager',
            'AppvGeneralManager_By' => 'AppvGeneralManager_By',
            'AppvGeneralManager_At' => 'AppvGeneralManager_At',
            'IsAppvDirector' => 'IsAppvDirector',
            'Status_AppvDirector' => 'Status_AppvDirector',
            'AppvDirector_By' => 'AppvDirector_By',
            'AppvDirector_At' => 'AppvDirector_At',
            'IsAppvPresidentDirector' => 'IsAppvPresidentDirector',
            'Status_AppvPresidentDirector' => 'Status_AppvPresidentDirector',
            'AppvPresidentDirector_By' => 'AppvPresidentDirector_By',
            'AppvPresidentDirector_At' => 'AppvPresidentDirector_At',
            'IsAppvFinanceStaff' => 'IsAppvFinanceStaff',
            'Status_AppvFinanceStaff' => 'Status_AppvFinanceStaff',
            'AppvFinanceStaff_By' => 'AppvFinanceStaff_By',
            'AppvFinanceStaff_At' => 'AppvFinanceStaff_At',
            'IsAppvFinanceManager' => 'IsAppvFinanceManager',
            'Status_AppvFinanceManager' => 'Status_AppvFinanceManager',
            'AppvFinanceManager_By' => 'AppvFinanceManager_By',
            'AppvFinanceManager_At' => 'AppvFinanceManager_At',
            'IsAppvFinanceDirector' => 'IsAppvFinanceDirector',
            'Status_AppvFinanceDirector' => 'Status_AppvFinanceDirector',
            'AppvFinanceDirector_By' => 'AppvFinanceDirector_By',
            'AppvFinanceDirector_At' => 'AppvFinanceDirector_At',
            'UserName_User' => 'UserName_User',
            'Rec_Created_At' => 'Rec_Created_At',
            'UserDivision' => 'UserDivision',
        ];

        $baseSql = "SELECT DISTINCT TAccCashBookReq_Header.CBReq_No, Type, Document_Date, Document_Number, TAccCashBookReq_Header.Acc_ID, Descript, Amount, baseamount, curr_rate, Approval_Status, CBReq_Status, Paid_Status, Creation_DateTime, Created_By, First_Name AS Created_By_Name, Last_Update, Update_By, TAccCashBookReq_Header.Currency_Id, TAccCashBookReq_Header.Approve_Date,
            Ttrx_Cbr_Approval.IsAppvStaff, Ttrx_Cbr_Approval.Status_AppvStaff, Ttrx_Cbr_Approval.AppvStaff_By, Ttrx_Cbr_Approval.AppvStaff_At, Ttrx_Cbr_Approval.IsAppvChief, Ttrx_Cbr_Approval.Status_AppvChief, Ttrx_Cbr_Approval.AppvChief_By, Ttrx_Cbr_Approval.AppvChief_At, Ttrx_Cbr_Approval.IsAppvAsstManager, Ttrx_Cbr_Approval.Status_AppvAsstManager, Ttrx_Cbr_Approval.AppvAsstManager_By, Ttrx_Cbr_Approval.AppvAsstManager_At, Ttrx_Cbr_Approval.IsAppvManager, Ttrx_Cbr_Approval.Status_AppvManager, Ttrx_Cbr_Approval.AppvManager_By, Ttrx_Cbr_Approval.AppvManager_At, Ttrx_Cbr_Approval.IsAppvSeniorManager, Ttrx_Cbr_Approval.Status_AppvSeniorManager, Ttrx_Cbr_Approval.AppvSeniorManager_By, Ttrx_Cbr_Approval.AppvSeniorManager_At, Ttrx_Cbr_Approval.IsAppvGeneralManager, Ttrx_Cbr_Approval.Status_AppvGeneralManager, Ttrx_Cbr_Approval.AppvGeneralManager_By, Ttrx_Cbr_Approval.AppvGeneralManager_At, Ttrx_Cbr_Approval.IsAppvDirector, Ttrx_Cbr_Approval.Status_AppvDirector, Ttrx_Cbr_Approval.AppvDirector_By, Ttrx_Cbr_Approval.AppvDirector_At, Ttrx_Cbr_Approval.IsAppvPresidentDirector, Ttrx_Cbr_Approval.Status_AppvPresidentDirector, Ttrx_Cbr_Approval.AppvPresidentDirector_By, Ttrx_Cbr_Approval.AppvPresidentDirector_At, Ttrx_Cbr_Approval.IsAppvFinanceStaff, Ttrx_Cbr_Approval.Status_AppvFinanceStaff, Ttrx_Cbr_Approval.AppvFinanceStaff_By, Ttrx_Cbr_Approval.AppvFinanceStaff_At, Ttrx_Cbr_Approval.IsAppvFinanceManager, Ttrx_Cbr_Approval.Status_AppvFinanceManager, Ttrx_Cbr_Approval.AppvFinanceManager_By, Ttrx_Cbr_Approval.AppvFinanceManager_At, Ttrx_Cbr_Approval.IsAppvFinanceDirector, Ttrx_Cbr_Approval.Status_AppvFinanceDirector, Ttrx_Cbr_Approval.AppvFinanceDirector_By, Ttrx_Cbr_Approval.AppvFinanceDirector_At, Ttrx_Cbr_Approval.UserName_User, Ttrx_Cbr_Approval.Rec_Created_At, Ttrx_Cbr_Approval.UserDivision
            FROM TAccCashBookReq_Header
            INNER JOIN TUserGroupL ON TAccCashBookReq_Header.Created_By = TUserGroupL.User_ID
            INNER JOIN TUserPersonal ON TAccCashBookReq_Header.Created_By = TUserPersonal.User_ID
            LEFT OUTER JOIN Ttrx_Cbr_Approval ON TAccCashBookReq_Header.CBReq_No = Ttrx_Cbr_Approval.CBReq_No
            WHERE TAccCashBookReq_Header.Type = 'D'
            AND TAccCashBookReq_Header.Document_Date >= {d '" . $this->db->escape_str($from) . "'}
            AND TAccCashBookReq_Header.Document_Date <= {d '" . $this->db->escape_str($until) . "'}
            AND TAccCashBookReq_Header.Company_ID = 2
            AND isNull(isSPJ, 0) = 0
            AND Approval_Status = 3
            AND CBReq_Status = 3
            AND Ttrx_Cbr_Approval.CBReq_No IS NOT NULL
            AND Created_By = '" . $this->db->escape_str($username) . "'";

        $response = $this->build_datatable_response($baseSql, $orderColumns, $searchColumns, $fieldMap, $requestData);
        echo json_encode($response);
    }

    public function DT_Monitoring_global()
    {
        $requestData = $_REQUEST;
        $from = $this->input->post('from');
        $until = $this->input->post('until');
        $columnRange = $this->input->post('column_range');
        $createdBy = $this->input->post('employee');
        $sqlCreatedBy = ($createdBy !== 'ALL') ? "AND TAccCashBookReq_Header.Created_By = '" . $this->db->escape_str($createdBy) . "'" : '';

        $orderColumns = [
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
            12 => 'Payment_Status',
            13 => 'Creation_DateTime',
            14 => 'Created_By',
            15 => 'First_Name',
            16 => 'Last_Update',
            17 => 'Update_By',
            18 => 'TAccCashBookReq_Header.Acc_ID',
            19 => 'TAccCashBookReq_Header.Approve_Date',
        ];

        $ftsColumns = ['TAccCashBookReq_Header.CBReq_No', 'TAccCashBookReq_Header.Document_Number', 'TAccCashBookReq_Header.Descript', 'TAccCashBookReq_Header.Payment_Plan_Date'];
        $fieldMap = [
            'CBReq_No' => 'CBReq_No',
            'isClose' => 'isClose',
            'Type' => 'Type',
            'Document_Date' => 'Document_Date',
            'Acc_ID' => 'Acc_ID',
            'Descript' => 'Descript',
            'Document_Number' => 'Document_Number',
            'Amount' => 'Amount',
            'baseamount' => 'baseamount',
            'curr_rate' => 'curr_rate',
            'Approval_Status' => 'Approval_Status',
            'CBReq_Status' => 'CBReq_Status',
            'Paid_Status' => 'Paid_Status',
            'Payment_Status' => 'Payment_Status',
            'Creation_DateTime' => 'Creation_DateTime',
            'Created_By' => 'Created_By',
            'First_Name' => 'Created_By_Name',
            'Last_Update' => 'Last_Update',
            'Update_By' => 'Update_By',
            'Currency_Id' => 'Currency_Id',
            'Approve_Date' => 'Approve_Date',
            'Has_Submitted_Approval' => 'Has_Submitted_Approval',
            'IsAppvStaff' => 'IsAppvStaff',
            'Status_AppvStaff' => 'Status_AppvStaff',
            'AppvStaff_By' => 'AppvStaff_By',
            'AppvStaff_Name' => 'AppvStaff_Name',
            'AppvStaff_At' => 'AppvStaff_At',
            'IsAppvChief' => 'IsAppvChief',
            'Status_AppvChief' => 'Status_AppvChief',
            'AppvChief_By' => 'AppvChief_By',
            'AppvChief_Name' => 'AppvChief_Name',
            'AppvChief_At' => 'AppvChief_At',
            'IsAppvAsstManager' => 'IsAppvAsstManager',
            'Status_AppvAsstManager' => 'Status_AppvAsstManager',
            'AppvAsstManager_By' => 'AppvAsstManager_By',
            'AppvAsstManager_Name' => 'AppvAsstManager_Name',
            'AppvAsstManager_At' => 'AppvAsstManager_At',
            'IsAppvManager' => 'IsAppvManager',
            'Status_AppvManager' => 'Status_AppvManager',
            'AppvManager_By' => 'AppvManager_By',
            'AppvManager_Name' => 'AppvManager_Name',
            'AppvManager_At' => 'AppvManager_At',
            'IsAppvSeniorManager' => 'IsAppvSeniorManager',
            'Status_AppvSeniorManager' => 'Status_AppvSeniorManager',
            'AppvSeniorManager_By' => 'AppvSeniorManager_By',
            'AppvSeniorManager_Name' => 'AppvSeniorManager_Name',
            'AppvSeniorManager_At' => 'AppvSeniorManager_At',
            'IsAppvGeneralManager' => 'IsAppvGeneralManager',
            'Status_AppvGeneralManager' => 'Status_AppvGeneralManager',
            'AppvGeneralManager_By' => 'AppvGeneralManager_By',
            'AppvGeneralManager_Name' => 'AppvGeneralManager_Name',
            'AppvGeneralManager_At' => 'AppvGeneralManager_At',
            'IsAppvAdditional' => 'IsAppvAdditional',
            'Status_AppvAdditional' => 'Status_AppvAdditional',
            'AppvAdditional_By' => 'AppvAdditional_By',
            'AppvAdditional_At' => 'AppvAdditional_At',
            'IsAppvFinancePerson' => 'IsAppvFinancePerson',
            'Status_AppvFinancePerson' => 'Status_AppvFinancePerson',
            'AppvFinancePerson_By' => 'AppvFinancePerson_By',
            'AppvFinancePerson_Name' => 'AppvFinancePerson_Name',
            'AppvFinancePerson_At' => 'AppvFinancePerson_At',
            'IsAppvDirector' => 'IsAppvDirector',
            'Status_AppvDirector' => 'Status_AppvDirector',
            'AppvDirector_By' => 'AppvDirector_By',
            'AppvDirector_Name' => 'AppvDirector_Name',
            'AppvDirector_At' => 'AppvDirector_At',
            'IsAppvPresidentDirector' => 'IsAppvPresidentDirector',
            'Status_AppvPresidentDirector' => 'Status_AppvPresidentDirector',
            'AppvPresidentDirector_By' => 'AppvPresidentDirector_By',
            'AppvPresidentDirector_Name' => 'AppvPresidentDirector_Name',
            'AppvPresidentDirector_At' => 'AppvPresidentDirector_At',
            'IsAppvFinanceDirector' => 'IsAppvFinanceDirector',
            'Status_AppvFinanceDirector' => 'Status_AppvFinanceDirector',
            'AppvFinanceDirector_By' => 'AppvFinanceDirector_By',
            'AppvFinanceDirector_Name' => 'AppvFinanceDirector_Name',
            'AppvFinanceDirector_At' => 'AppvFinanceDirector_At',
            'UserName_User' => 'UserName_User',
            'Rec_Created_At' => 'Rec_Created_At',
            'UserDivision' => 'UserDivision',
            'Legitimate' => 'Legitimate',
        ];

        $transforms = [
            'AppvAsstManager_At' => function ($val) {
                return $this->format_datetime($val);
            },
            'AppvManager_At' => function ($val) {
                return $this->format_datetime($val);
            },
            'AppvSeniorManager_At' => function ($val) {
                return $this->format_datetime($val);
            },
            'AppvGeneralManager_At' => function ($val) {
                return $this->format_datetime($val);
            },
            'AppvAdditional_At' => function ($val) {
                return $this->format_datetime($val);
            },
            'AppvFinancePerson_At' => function ($val) {
                return $this->format_datetime($val);
            },
            'AppvDirector_At' => function ($val) {
                return $this->format_datetime($val);
            },
            'AppvPresidentDirector_At' => function ($val) {
                return $this->format_datetime($val);
            },
            'AppvFinanceDirector_At' => function ($val) {
                return $this->format_datetime($val);
            },
            'AppvStaff_Name' => function ($val) {
                return $val ?? '';
            },
            'AppvChief_Name' => function ($val) {
                return $val ?? '';
            },
            'AppvAsstManager_Name' => function ($val) {
                return $val ?? '';
            },
            'AppvManager_Name' => function ($val) {
                return $val ?? '';
            },
            'AppvSeniorManager_Name' => function ($val) {
                return $val ?? '';
            },
            'AppvGeneralManager_Name' => function ($val) {
                return $val ?? '';
            },
            'AppvDirector_Name' => function ($val) {
                return $val ?? '';
            },
            'AppvPresidentDirector_Name' => function ($val) {
                return $val ?? '';
            },
            'AppvFinanceDirector_Name' => function ($val) {
                return $val ?? '';
            },
            'UserDivision' => function ($val) {
                return $val ?? '-';
            },
        ];

        $baseSql = "SELECT DISTINCT TAccCashBookReq_Header.CBReq_No, TAccCashBookReq_Header.isClose, Type, Document_Date, Document_Number, TAccCashBookReq_Header.Acc_ID, Descript, Amount, baseamount, curr_rate, Approval_Status, CBReq_Status, Paid_Status, Creation_DateTime, Created_By, First_Name AS Created_By_Name, Last_Update, Update_By, TAccCashBookReq_Header.Currency_Id, TAccCashBookReq_Header.Approve_Date,
            CASE WHEN Ttrx_Cbr_Approval.CBReq_No IS NOT NULL OR Ttrx_Cbr_Approval.CBReq_No != '' THEN 1 ELSE 0 END AS Has_Submitted_Approval,
            Ttrx_Cbr_Approval.IsAppvStaff, Ttrx_Cbr_Approval.Status_AppvStaff, Ttrx_Cbr_Approval.AppvStaff_By, Ttrx_Cbr_Approval.AppvStaff_Name, Ttrx_Cbr_Approval.AppvStaff_At, Ttrx_Cbr_Approval.IsAppvChief, Ttrx_Cbr_Approval.Status_AppvChief, Ttrx_Cbr_Approval.AppvChief_By, Ttrx_Cbr_Approval.AppvChief_Name, Ttrx_Cbr_Approval.AppvChief_At, Ttrx_Cbr_Approval.IsAppvAsstManager, Ttrx_Cbr_Approval.Status_AppvAsstManager, Ttrx_Cbr_Approval.AppvAsstManager_By, Ttrx_Cbr_Approval.AppvAsstManager_Name, Ttrx_Cbr_Approval.AppvAsstManager_At, Ttrx_Cbr_Approval.IsAppvManager, Ttrx_Cbr_Approval.Status_AppvManager, Ttrx_Cbr_Approval.AppvManager_By, Ttrx_Cbr_Approval.AppvManager_Name, Ttrx_Cbr_Approval.AppvManager_At, Ttrx_Cbr_Approval.IsAppvSeniorManager, Ttrx_Cbr_Approval.Status_AppvSeniorManager, Ttrx_Cbr_Approval.AppvSeniorManager_By, Ttrx_Cbr_Approval.AppvSeniorManager_Name, Ttrx_Cbr_Approval.AppvSeniorManager_At, Ttrx_Cbr_Approval.IsAppvGeneralManager, Ttrx_Cbr_Approval.Status_AppvGeneralManager, Ttrx_Cbr_Approval.AppvGeneralManager_By, Ttrx_Cbr_Approval.AppvGeneralManager_Name, Ttrx_Cbr_Approval.AppvGeneralManager_At, Ttrx_Cbr_Approval.IsAppvDirector, Ttrx_Cbr_Approval.Status_AppvDirector, Ttrx_Cbr_Approval.AppvDirector_By, Ttrx_Cbr_Approval.AppvDirector_Name, Ttrx_Cbr_Approval.AppvDirector_At, Ttrx_Cbr_Approval.IsAppvPresidentDirector, Ttrx_Cbr_Approval.Status_AppvPresidentDirector, Ttrx_Cbr_Approval.AppvPresidentDirector_By, Ttrx_Cbr_Approval.AppvPresidentDirector_Name, Ttrx_Cbr_Approval.AppvPresidentDirector_At, Ttrx_Cbr_Approval.Legitimate, Ttrx_Cbr_Approval.IsAppvFinanceDirector, Ttrx_Cbr_Approval.Status_AppvFinanceDirector, Ttrx_Cbr_Approval.AppvFinanceDirector_By, Ttrx_Cbr_Approval.AppvFinanceDirector_Name, Ttrx_Cbr_Approval.IsAppvFinancePerson, Ttrx_Cbr_Approval.Status_AppvFinancePerson, Ttrx_Cbr_Approval.AppvFinancePerson_By, Ttrx_Cbr_Approval.AppvFinancePerson_Name, Ttrx_Cbr_Approval.AppvFinancePerson_At, Ttrx_Cbr_Approval.AppvFinanceDirector_At, Ttrx_Cbr_Approval.UserName_User, Ttrx_Cbr_Approval.Rec_Created_At, Ttrx_Cbr_Approval.UserDivision, Ttrx_Cbr_Approval.Payment_Status, Ttrx_Cbr_Approval.IsAppvAdditional, Ttrx_Cbr_Approval.Status_AppvAdditional, Ttrx_Cbr_Approval.AppvAdditional_By, Ttrx_Cbr_Approval.AppvAdditional_At
            FROM TAccCashBookReq_Header
            INNER JOIN TUserGroupL ON TAccCashBookReq_Header.Created_By = TUserGroupL.User_ID
            INNER JOIN TUserPersonal ON TAccCashBookReq_Header.Created_By = TUserPersonal.User_ID
            LEFT OUTER JOIN Ttrx_Cbr_Approval ON TAccCashBookReq_Header.CBReq_No = Ttrx_Cbr_Approval.CBReq_No
            WHERE TAccCashBookReq_Header.Type = 'D'
            AND $columnRange >= {d '" . $this->db->escape_str($from) . "'}
            AND $columnRange <= {d '" . $this->db->escape_str($until) . "'}
            AND TAccCashBookReq_Header.Company_ID = 2
            AND isNull(isSPJ, 0) = 0
            AND Approval_Status = 3
            AND CBReq_Status = 3
            $sqlCreatedBy";

        $response = $this->build_datatable_response($baseSql, $orderColumns, $ftsColumns, $fieldMap, $requestData, true, $transforms);
        echo json_encode($response);
    }

    public function get_detail_cbr()
    {
        $Req_No = $this->input->post('Req_No');
        $Ref_no = $this->input->post('Ref_no');
        $Details = $this->db->query("SELECT *,(SELECT Account_Nameen FROM TAccChartAccount WHERE Acc_ID = TAccCashBookReq_Detail.Acc_ID) AS Account_Name
		FROM TAccCashBookReq_Detail
		WHERE CBReq_No = '$Req_No'");

        $i = 1;
        $data = array();
        $code = 200;
        if ($Details->num_rows() > 0) {
            foreach ($Details->result_array() as $li) {
                $nestedData = array();

                $nestedData['iteration'] = $i;
                $nestedData['CBRDetail_ID'] = $li['CBRDetail_ID'];
                $nestedData['CBReq_No'] = $li['CBReq_No'];
                $nestedData['Acc_ID'] = $li['Acc_ID'];
                $nestedData['Description'] = $li['Description'];
                $nestedData['Amount_Detail'] = number_format($li['Amount_Detail'], 4, '.', ',');
                $nestedData['Base_Amount_Detail'] = $li['Base_Amount_Detail'];
                $nestedData['PaidAmount_Detail'] = $li['PaidAmount_Detail'];
                $nestedData['Base_PaidAmount_Detail'] = $li['Base_PaidAmount_Detail'];
                $nestedData['Tax_Code'] = $li['Tax_Code'];
                $nestedData['CBRDetail_Ref'] = $li['CBRDetail_Ref'];
                $nestedData['isHeader'] = $li['isHeader'];
                $nestedData['remain'] = $li['remain'];
                $nestedData['Request_ID'] = $li['Request_ID'];
                $nestedData['currency_id'] = $li['currency_id'];
                $nestedData['Type'] = $li['Type'];
                $nestedData['costcenter_id'] = $li['costcenter_id'];
                $nestedData['Account_Name'] = $li['Account_Name'];

                $data[] = $nestedData;
                $i++;
            }
        } else {
            $code = 404;
        }

        $dataVins = array();
        $code_having_vin = 200;
        if (empty($Ref_no)) {
            $code_having_vin = 404;
        } else {
            if (substr($Ref_no, 0, 3) === 'PWU') {
                $QPo = $this->db->query("SELECT TAccPO_Header.PO_Number, TAccPO_Header.PO_Date, TAccPO_Header.ETD, TAccPO_Header.SO_NumCustomer, TAccPO_Header.Invoice_Status, TAccPO_Header.isNotActive, TAccPO_Header.isSisterCompany, TAccPO_Header.PO_Status, TAccPO_header.Doc_Status, TAccPO_Header.Approval_Status, Taccount.Account_Name, Taccount.AccountTitle_Code
                FROM TAccPO_header 
                LEFT JOIN TAccount 	ON TAccount.Account_ID = TAccPO_header.Account_ID 
                where PO_Number = '$Ref_no'
                ORDER BY TAccPO_header.PO_Number DESC;
                ");
                if ($QPo->num_rows() > 0) {
                    $i = 1;
                    foreach ($QPo->result_array() as $li) {
                        $nestedData = array();

                        $nestedData['iteration'] = $i;
                        $nestedData['PO_Number'] = $li['PO_Number'];
                        $nestedData['PO_Date'] = date("d-M-Y", strtotime($li['PO_Date']));
                        $nestedData['ETD'] = date("d-M-Y", strtotime($li['ETD']));
                        $nestedData['SO_NumCustomer'] = ($li['SO_NumCustomer'] == NULL) ? 'N/A' : $li['SO_NumCustomer'];
                        $nestedData['Invoice_Status'] = ($li['Invoice_Status'] == 'NI') ? 'No' : 'Yes';
                        $nestedData['isNotActive'] = ($li['isNotActive'] == '1') ? '<i class="fas fa-times text-danger"></i>' : '<i class="fas fa-check text-success"></i>';
                        $nestedData['isSisterCompany'] = $li['isSisterCompany'];
                        $nestedData['PO_Status'] = ($li['PO_Status'] == '1') ? 'New' : (($li['PO_Status'] == '2') ? 'Open' : (($li['PO_Status'] == '3') ? 'Close' : 'Undefined'));
                        $nestedData['Doc_Status'] = ($li['Doc_Status'] == 1) ? 'Open' : (($li['Doc_Status'] == 2) ? 'Confirm' : (($li['Doc_Status'] == 3) ? 'Delivered' : (($li['Doc_Status'] == 4) ? 'Invoiced' : 'Closed')));
                        $nestedData['Approval_Status'] = ($li['Approval_Status'] == 0) ? 'New' : (($li['Approval_Status'] == 2) ? 'Awaiting' : (($li['Approval_Status'] == 3) ? 'Approved' : (($li['Approval_Status'] == 4) ? 'Rejected' : (($li['Approval_Status'] == 5) ? 'Revising' : ''))));
                        $nestedData['Account_Name'] = $li['Account_Name'];
                        $nestedData['AccountTitle_Code'] = $li['AccountTitle_Code'];

                        $dataVins[] = $nestedData;
                        $i++;
                    }
                } else {
                    $code_having_vin = 404;
                }
            } else {
                $vins = $this->db->query("SELECT Taccount.Account_ID, TAccount.AccountTitle_COde, TAccount.Account_Name, TACCVI_Header.Account_ID, TACCVI_Header.Invoice_Number, TACCVI_Header.VenInvoice_Number, TACCVI_Header.Invoice_Date, TACCVI_Header.Due_Date, TACCVI_Header.Invoice_Status, TACCVI_Header.PO_NUMBER,
                TACCVI_Header.Paid_invoiceAmount, TACCVI_Header.isDirect, TACCVI_Header.Paid_FreightAmount, isNull(TAccVI_Header.isVoid,0) as isVoid, TaccVI_header.List_TaxCode, TaccVI_Header.LstCBDoc, TACCVI_Header.is_document_received, TACCVI_Header.document_received_date
                FROM TACCVI_Header
                INNER JOIN TAccount	ON TACCVI_Header.Account_ID = TAccount.Account_ID
                INNER JOIN TUserGroupL ON TAccVI_Header.Created_by = TUserGroupL.User_ID
                WHERE invoice_number = '$Ref_no'
                group by Taccount.Account_ID, TAccount.AccountTitle_COde, TAccount.Account_Name, TACCVI_Header.Account_ID, TACCVI_Header.Invoice_Number, TACCVI_Header.VenInvoice_Number, TACCVI_Header.Invoice_Date, TACCVI_Header.Due_Date, TACCVI_Header.Invoice_Status, TACCVI_Header.PO_NUMBER,
                TACCVI_Header.Paid_invoiceAmount, TACCVI_Header.isDirect, TACCVI_Header.Paid_FreightAmount, isNull(TAccVI_Header.isVoid,0), TaccVI_header.List_TaxCode, TaccVI_Header.LstCBDoc, TACCVI_Header.is_document_received, TACCVI_Header.document_received_date
                ORDER BY TACCVI_Header.Invoice_Date DESC");
                if ($vins->num_rows() > 0) {
                    $i = 1;
                    foreach ($vins->result_array() as $li) {
                        $nestedData = array();

                        $nestedData['iteration'] = $i;
                        $nestedData['Account_ID'] = $li['Account_ID'];
                        $nestedData['AccountTitle_COde'] = $li['AccountTitle_COde'];
                        $nestedData['Account_Name'] = $li['Account_Name'];
                        $nestedData['Account_ID'] = $li['Account_ID'];
                        $nestedData['Invoice_Number'] = $li['Invoice_Number'];
                        $nestedData['VenInvoice_Number'] = $li['VenInvoice_Number'];
                        $nestedData['Invoice_Date'] = date("d-M-Y", strtotime($li['Invoice_Date']));
                        $nestedData['Due_Date'] = date("d-M-Y", strtotime($li['Due_Date']));
                        $nestedData['Invoice_Status'] = ($li['Invoice_Status'] != 'FP') ? '<span class="badge bg-danger">not paid</span>' : '<span class="badge bg-success">full paid</span>';
                        $nestedData['PO_NUMBER'] = $li['PO_NUMBER'];
                        $nestedData['Paid_invoiceAmount'] = $li['Paid_invoiceAmount'];
                        $nestedData['isDirect'] = $li['isDirect'];
                        $nestedData['Paid_FreightAmount'] = $li['Paid_FreightAmount'];
                        $nestedData['isVoid'] = ($li['isVoid'] == '0') ? '<i class="fas fa-times text-success"></i>' : '<i class="fas fa-check text-danger"></i>';
                        $nestedData['List_TaxCode'] = $li['List_TaxCode'];
                        $nestedData['LstCBDoc'] = $li['LstCBDoc'];
                        $nestedData['is_document_received'] = ($li['is_document_received'] == '0') ? '<span class="text-danger">Not Yet Received</span>' : '<span class="text-success">Received</span>';
                        $nestedData['document_received_date'] = (empty($li['document_received_date'])) ? '' : date("d-M-Y", strtotime($li['document_received_date']));

                        $dataVins[] = $nestedData;
                        $i++;
                    }
                } else {
                    $code_having_vin = 404;
                }
            }
        }

        return $this->help->Fn_resulting_response([
            'code' => $code,
            'code_vin' => $code_having_vin,
            'dataVins' => $dataVins,
            'data' => $data,
        ]);
    }

    public function get_detail_purchase_invoice($vin = null)
    {
        $this->data['vin'] = $vin;
        $row_ref_document = $this->db->query("select po_number, rr_number from taccvi_header where invoice_number = '$vin'")->row();
        $this->data['row_ref_document'] = $row_ref_document;

        if (strpos($row_ref_document->po_number, '|') !== false) {
            $splitArrayPO = explode('|', $row_ref_document->po_number);
            $arr_po_number = "'" . implode("','", $splitArrayPO) . "'";
        } else {
            $splitArrayPO = explode(',', $row_ref_document->po_number);
            $arr_po_number = "'" . implode("','", $splitArrayPO) . "'";
        }

        if (strpos($row_ref_document->rr_number, '|') !== false) {
            $splitArrayRR = explode('|', $row_ref_document->rr_number);
            $arr_rr_number = "'" . implode("','", $splitArrayRR) . "'";
        } else {
            $splitArrayRR = explode(',', $row_ref_document->rr_number);
            $arr_rr_number = "'" . implode("','", $splitArrayRR) . "'";
        }

        $this->data['list_po'] = $splitArrayPO;
        $this->data['list_rr'] = $this->db->query("Select rr_number, RR_date From TAccRR_Header where RR_Number in ($arr_rr_number)")->result();
        $this->data['qget_so_numb'] = $this->db->query("select	taccpo_header.so_numcustomer, taccrr_header.rr_number
                                                        from taccpo_header 	
                                                            inner join taccrr_header on taccrr_header.ref_number = taccpo_header.po_number								
                                                        where taccpo_header.po_number in ($arr_po_number)				
                                                        order by taccpo_header.so_numcustomer, taccrr_header.rr_number")->result();

        $qheaderCount = $this->db->query("SELECT count(item_code) as count_item
                                        FROM TACCVI_Header, TACCVI_Detail
                                        WHERE TACCVI_Header.Invoice_Number = '$vin'
                                        AND TACCVI_Detail.Invoice_Number = TACCVI_Header.Invoice_Number")->row();

        $qcategory = $this->db->query("SELECT ItemCategoryType FROM TACCVI_Header WHERE TACCVI_Header.Invoice_Number = '$vin'")->row();

        if ($qheaderCount->count_item == 0) {
            $this->data['qheader'] = $this->db->query("SELECT a.*, b.account_id,  b.account_name,  b.account_address1, b.account_city_id1,  b.account_state_id1, 
                                                            b.account_zipcode1, b.account_phone1, b.account_fax1, b.taxfilenumber,  b.accounttitle_code, c.country_name, 0 AS kawasanberikat
                                                            FROM TAccVI_Header a
                                                            INNER JOIN TAccount b ON a.account_id = b.account_id
                                                            INNER JOIN TCountry c on b.account_country_id1 = c.country_id
                                                            WHERE a.invoice_number = '$vin'")->row();
        } else {
            if ($qcategory->ItemCategoryType == 'AST-M') {
                $this->data['qheader'] = $this->db->query("SELECTTACCVI_Header.*, taccassetmaintenance_header.maintenance_date as etd,
                                                            Taccount.Account_ID, Taccount.Account_Name,Taccount.Account_Address1,
                                                            TAccount.Account_City_ID1,TAccount.Account_State_ID1 ,TCountry.Country_Name,
                                                            Taccount.Account_ZipCode1,Taccount.Account_Phone1,Taccount.Account_Fax1,Taccount.TaxFileNumber,
                                                            thrmemppersonaldata.First_Name as EMPNAme,accounttitle_code
                                                            ,0 as kawasanberikat
                                                            FROM 	TACCVI_Header,Taccount,TCountry,taccassetmaintenance_header,thrmemppersonaldata		
                                                            WHERE 	TACCVI_Header.Invoice_Number  = '$vin'
                                                            AND		TACCVI_Header.PO_Number = taccassetmaintenance_header.doc_no
                                                            AND		Taccount.Account_ID 	= TACCVI_Header.Account_ID
                                                            AND		TAccount.Account_Country_ID1 = TCountry.Country_id
                                                            AND		taccassetmaintenance_header.emp_id = thrmemppersonaldata.emp_id")->row();
            } else {
                $this->data['qheader'] = $this->db->query("SELECT taccvi_header.*, 
                                                                    taccpo_header.etd,
                                                                    taccvi_detail.ref_number, 
                                                                    taccount.account_id, 
                                                                    taccount.account_name, 
                                                                    taccount.account_address1,
                                                                    taccount.account_city_id1, 
                                                                    taccount.account_state_id1,
                                                                    taccount.account_zipcode1,
                                                                    taccount.account_phone1,
                                                                    taccount.account_fax1,
                                                                    taccount.taxfilenumber, 
                                                                    tcountry.country_name,
                                                                    tuserpersonal.first_name as empname,
                                                                    accounttitle_code,
                                                                    0 as kawasanberikat
                                                            from	taccpo_detail
                                                                    inner join taccpo_header on taccpo_header.po_number = taccpo_detail.po_number
                                                                    inner join taccrr_header on taccrr_header.ref_number = taccpo_detail.po_number
                                                                    inner join taccrr_item on taccrr_item.rr_number = taccrr_header.rr_number 
                                                                        and taccpo_detail.item_code = taccrr_item.item_code 
                                                                        and isnull(taccpo_detail.parent_path,0) = isnull(taccrr_item.parent_path,0) 
                                                                        and taccpo_detail.dimension_id = taccrr_item.dimension_id 
                                                                    inner join taccvi_header on taccvi_header.invoice_number = '$vin' 
                                                                        and taccvi_header.po_number = '$row_ref_document->po_number'
                                                                        and	taccpo_header.po_number in ($arr_po_number)
                                                                    left join taccvi_detail on taccvi_detail.invoice_number = taccvi_header.invoice_number
                                                                        and taccvi_detail.item_code = taccpo_detail.item_code
                                                                        and taccvi_detail.dimension_id = taccpo_detail.dimension_id
                                                                        and taccvi_detail.ref_number = taccrr_item.rr_number
                                                                    inner join titemdimension itd on itd.dimension_id = taccpo_detail.dimension_id
                                                                    inner join taccount on taccount.account_id 	= taccvi_header.account_id
                                                                    inner join tcountry on taccount.account_country_id1 = tcountry.country_id
                                                                    left join tuserpersonal on taccpo_header.user_id = tuserpersonal.user_id
                                                            where	1 = 1 
                                                                and TAccRR_Item.RR_Number in ($arr_rr_number)
                                                                and taccrr_item.qty > 0
                                                            order by taccrr_item.detail_id")->row();
            }
        }

        // =====================================================================================================
        $this->data['qDetail'] = $this->db->query("SELECT taccvi_detail.item_code, titem.item_name,taccvi_detail.qty, taccvi_detail.base_unitprice,
                                                taccvi_detail.disc_percentage, taccvi_detail.totalprice, taccvi_detail.tax_code1, taccvi_detail.tax_operator1, taccvi_detail.tax_code2, taccvi_detail.tax_operator2, taccunittype.unit_name, taccpo_header.potype as typeppn, taccvi_header.currency_id
                                                from taccpo_detail
                                                inner join taccpo_header on taccpo_header.po_number = taccpo_detail.po_number
                                                inner join taccrr_header on taccrr_header.ref_number = taccpo_detail.po_number
                                                inner join taccrr_item on taccrr_item.rr_number = taccrr_header.rr_number 
                                                    and taccpo_detail.item_code = taccrr_item.item_code 
                                                    and isnull(taccpo_detail.parent_path,0) = isnull(taccrr_item.parent_path,0) 
                                                    and taccpo_detail.dimension_id = taccrr_item.dimension_id 
                                                inner join titem on taccpo_detail.item_code = titem.item_code 
                                                inner join taccunittype on titem.unit_type_id = taccunittype.unit_type_id
                                                inner join taccvi_header on taccvi_header.po_number = '$row_ref_document->po_number'
                                                    and	taccpo_header.po_number in ('$row_ref_document->po_number')
                                                inner join taccvi_detail on taccvi_detail.invoice_number = taccvi_header.invoice_number
                                                    and taccvi_detail.item_code = taccpo_detail.item_code
                                                    and taccvi_detail.dimension_id = taccpo_detail.dimension_id
                                                    and taccvi_header.invoice_number = '$vin'
                                                    and taccvi_detail.ref_number = taccrr_item.rr_number
                                                inner join titemdimension itd on itd.dimension_id = taccpo_detail.dimension_id 
                                                where	1 = 1 
                                                    and taccrr_item.rr_number in ('$row_ref_document->rr_number')
                                                    and taccrr_item.qty > 0
                                                order by titem.item_name")->row();

        $this->data['QCariJournal'] = $this->db->query("SELECT TaccJournalDetail.*, 
                                                    TaccChartAccount.Account_nameen as acc_Name, Account_Number,
                                                    TAccCostCenter.CostCenter_Code,TAccCostCenter.CostCenter_Name_en AS CostCenter_Name
                                                    From TaccJournalDetail
                                                    inner join TAccChartAccount on TaccJournalDetail.Acc_id = TAccChartAccount.acc_id
                                                    left join TAccCostCenter on TAccCostCenter.CostCenter_ID = TAccJournalDetail.CostCenter
                                                    Where JournalH_Code = '$vin'
                                                    Order by Default_Acc")->result();

        $this->data['Qget_VendorSONumber']  = $this->db->query("SELECT taccpo_header.so_numcustomer, 
                                                    taccrr_header.rr_number
                                                    from taccpo_header 	
                                                    inner join taccrr_header on taccrr_header.ref_number = taccpo_header.po_number								
                                                    where taccpo_header.po_number in ('$row_ref_document->po_number')								
                                                    order by taccpo_header.so_numcustomer, taccrr_header.rr_number")->result();

        $this->load->view('mycbr/rpt_detail_vin', $this->data);
    }

    public function m_f_cbr_attachment()
    {
        $CbrNo = $this->input->get('CbrNo');
        $this->data['CbrNo'] = $CbrNo;
        $this->data['Attachments'] = $this->db->get_where($this->Ttrx_Dtl_Attachment_Cbr, ['CbrNo' => $CbrNo]);

        $this->load->view('mycbr/m_f_cbr_attachment', $this->data);
    }

    public function m_list_cbr_attachment()
    {
        $CbrNo = $this->input->get('CbrNo');
        $this->data['CbrNo'] = $CbrNo;
        $this->data['Attachments'] = $this->db->get_where($this->Ttrx_Dtl_Attachment_Cbr, ['CbrNo' => $CbrNo]);

        $this->load->view('mycbr/m_list_cbr_attachment', $this->data);
    }

    public function store_attachment()
    {
        $attachment_file_name = '';
        $upload_attachment = $_FILES['attachment']['name'];
        $Year = date('Y');
        $folderPath = 'assets/Files/AttachmentCbr/' . $Year;
        if (!is_dir($folderPath)) {
            mkdir($folderPath, 0755, true);
        }


        $ValidateUniqueFile = $this->db->get_where($this->Ttrx_Dtl_Attachment_Cbr, [
            'CbrNo' => $this->input->post('CbrNo'),
            'Attachment_FileName' => $Year . "/" . $this->input->post('CbrNo') . '-' . str_replace(" ", "_", $upload_attachment)
        ]);

        if ($ValidateUniqueFile->num_rows() > 0) {
            return $this->help->Fn_resulting_response([
                "code" => 500,
                "msg" => "File name redundan please choose the other file or rename recent file !"
            ]);
        }

        if ($upload_attachment) {
            $config['allowed_types'] = 'pdf|png|jpg|jpeg';
            $config['max_size']      = '4096';
            $config['upload_path'] = $folderPath;
            $config['file_name'] = $this->input->post('CbrNo') . '-' . str_replace(" ", "_", $upload_attachment);

            $this->load->library('upload', $config);
            $this->upload->initialize($config);

            if ($this->upload->do_upload('attachment')) {
                $attachment_file_name = $Year . "/" . $this->input->post('CbrNo') . '-' . str_replace(" ", "_", $upload_attachment);
            } else {
                $response = [
                    "code" => 500,
                    "msg" => $this->upload->display_errors()
                ];
                return $this->help->Fn_resulting_response($response);
            }
        }

        $this->db->trans_start();

        $this->db->insert($this->Ttrx_Dtl_Attachment_Cbr, [
            'CbrNo' => $this->input->post('CbrNo'),
            'Attachment_FileName' => $attachment_file_name,
            'Note' => $this->input->post('note'),
            'Created_by' => $this->session->userdata('sys_sba_username'),
            'Created_at' => $this->DateTime
        ]);
        $inserted_id = $this->db->insert_id();

        $this->db->trans_complete();
        if ($this->db->trans_status() === FALSE) {
            $this->db->trans_rollback();
            return $this->help->Fn_resulting_response([
                "code" => 500,
                "msg" => "Add cbr attachment Failed !"
            ]);
        }
        $this->db->trans_commit();

        $datas = new stdClass();
        $datas->Attachment_FileName = "<a target='_blank' href='" . base_url() . "assets/Files/AttachmentCbr/$attachment_file_name'>$attachment_file_name</a>";
        $datas->Note = $this->input->post('note');
        $datas->Action = '<button type="button" value="' . $inserted_id . '" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="tooltip-dark" title="Delete" class="btn btn-icon btn-danger btn-sm btn-delete-attachment">
                            <i class="fas fa-trash"></i>
                        </button>';

        return $this->help->Fn_resulting_response([
            "code" => 200,
            "msg" => "Successfully add cbr attachment ! " . $this->input->post('CbrNo'),
            "data" => $datas
        ]);
    }

    public function Delete_Attachment()
    {
        $id = $this->input->post('id');
        $DataAtt = $this->db->get_where($this->Ttrx_Dtl_Attachment_Cbr, ['SysId' => $id])->row();
        $file_path = 'assets/Files/AttachmentCbr/' . $DataAtt->Attachment_FileName;

        $this->db->trans_start();

        unlink($file_path);
        $this->db->delete($this->Ttrx_Dtl_Attachment_Cbr, ['SysId' => $id]);

        $this->db->trans_complete();
        if ($this->db->trans_status() === FALSE) {
            $this->db->trans_rollback();
            return $this->help->Fn_resulting_response([
                "code" => 500,
                "msg" => "Server Busy, Delete Failed !"
            ]);
        } else {
            $this->db->trans_commit();
            return $this->help->Fn_resulting_response([
                "code" => 200,
                "msg" => "Attachment successfully deleted !"
            ]);
        }
    }
}
