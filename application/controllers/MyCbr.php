<?php
defined('BASEPATH') or exit('No direct script access allowed');

class MyCbr extends CI_Controller
{
    private $Date;
    private $DateTime;
    private $layout = 'layout';
    private $Ttrx_Cbr_Approval = 'Ttrx_Cbr_Approval';
    private $TmstTrxSettingSteppApprovalCbr = 'TmstTrxSettingSteppApprovalCbr';

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
        $this->data['page_title'] = "My Cash Book Requisition";
        $this->data['page_content'] = "mycbr/index";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/mycbr/index.js"></script>';

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
            $this->db->insert('Ttrx_Cbr_Approval', [
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
                "IsAppvPresidentDirector" => $RulesApproval->Director,
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
            18 => 'TAccCashBookReq_Header.Acc_ID ',
            19 => 'TAccCashBookReq_Header.Approve_Date',

        );
        $order  = $columns[$requestData['order']['0']['column']];
        $dir    = $requestData['order']['0']['dir'];
        $from   = $this->input->post('from');
        $until  = $this->input->post('until');

        $sql = "Select  distinct TAccCashBookReq_Header.CBReq_No, Type, Document_Date, Document_Number, TAccCashBookReq_Header.Acc_ID, Descript, Amount, baseamount, curr_rate, Approval_Status, CBReq_Status, Paid_Status, Creation_DateTime, Created_By, First_Name AS Created_By_Name, Last_Update, Update_By, TAccCashBookReq_Header.Currency_Id, TAccCashBookReq_Header.Approve_Date
        FROM TAccCashBookReq_Header
        INNER JOIN TUserGroupL ON TAccCashBookReq_Header.Created_By = TUserGroupL.User_ID
        INNER JOIN TUserPersonal ON TAccCashBookReq_Header.Created_By = TUserPersonal.User_ID
        LEFT OUTER JOIN Ttrx_Cbr_Approval ON TAccCashBookReq_Header.CBReq_No = Ttrx_Cbr_Approval.CBReq_No
        WHERE TAccCashBookReq_Header.Type='D'
        And TAccCashBookReq_Header.Document_Date >= {d '2023-10-01'}
        And TAccCashBookReq_Header.Document_Date <= {d '2023-10-31'}
        AND TAccCashBookReq_Header.Company_ID = 2 
        AND isNull(isSPJ,0) = 0
        AND Approval_Status  = 3
        AND CBReq_Status = 3
        AND Ttrx_Cbr_Approval.CBReq_No IS NULL
        AND Created_By = '" . $this->session->userdata('sys_sba_userid') . "' ";
        // ORDER BY TAccCashBookReq_Header.Document_Date DESC,TAccCashBookReq_Header.CBReq_No DESC 

        $totalData = $this->db->query($sql)->num_rows();
        if (!empty($requestData['search']['value'])) {
            $sql .= " AND (TAccCashBookReq_Header.CBReq_No LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR First_Name LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Document_Number LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Document_Date LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR TAccCashBookReq_Header.Currency_Id LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Descript LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR CBReq_Status LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Amount LIKE '%" . $requestData['search']['value'] . "%') ";
        }
        //----------------------------------------------------------------------------------
        $totalFiltered = $this->db->query($sql)->num_rows();
        $sql .= " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";
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

    public function DT_List_History_Submission()
    {
        $requestData = $_REQUEST;
        $columns = array(
            // 0 => 'TAccCashBookReq_Header.CBReq_No',
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
            18 => 'TAccCashBookReq_Header.Acc_ID ',
            19 => 'TAccCashBookReq_Header.Approve_Date',

        );
        $order  = $columns[$requestData['order']['0']['column']];
        $dir    = $requestData['order']['0']['dir'];
        $from   = $this->input->post('from');
        $until  = $this->input->post('until');

        $sql = "Select  distinct TAccCashBookReq_Header.CBReq_No, Type, Document_Date, Document_Number, TAccCashBookReq_Header.Acc_ID, Descript, Amount, baseamount, curr_rate, Approval_Status, CBReq_Status, Paid_Status, Creation_DateTime, Created_By, First_Name AS Created_By_Name, Last_Update, Update_By, TAccCashBookReq_Header.Currency_Id, TAccCashBookReq_Header.Approve_Date,
        Ttrx_Cbr_Approval.IsAppvStaff, Ttrx_Cbr_Approval.Status_AppvStaff, Ttrx_Cbr_Approval.AppvStaff_By, Ttrx_Cbr_Approval.AppvStaff_At, Ttrx_Cbr_Approval.IsAppvChief, Ttrx_Cbr_Approval.Status_AppvChief, Ttrx_Cbr_Approval.AppvChief_By, Ttrx_Cbr_Approval.AppvChief_At, Ttrx_Cbr_Approval.IsAppvAsstManager, Ttrx_Cbr_Approval.Status_AppvAsstManager, Ttrx_Cbr_Approval.AppvAsstManager_By, Ttrx_Cbr_Approval.AppvAsstManager_At, Ttrx_Cbr_Approval.IsAppvManager, Ttrx_Cbr_Approval.Status_AppvManager, Ttrx_Cbr_Approval.AppvManager_By, Ttrx_Cbr_Approval.AppvManager_At, Ttrx_Cbr_Approval.IsAppvSeniorManager, Ttrx_Cbr_Approval.Status_AppvSeniorManager, Ttrx_Cbr_Approval.AppvSeniorManager_By, Ttrx_Cbr_Approval.AppvSeniorManager_At, Ttrx_Cbr_Approval.IsAppvGeneralManager, Ttrx_Cbr_Approval.Status_AppvGeneralManager, Ttrx_Cbr_Approval.AppvGeneralManager_By, Ttrx_Cbr_Approval.AppvGeneralManager_At, Ttrx_Cbr_Approval.IsAppvDirector, Ttrx_Cbr_Approval.Status_AppvDirector, Ttrx_Cbr_Approval.AppvDirector_By, Ttrx_Cbr_Approval.AppvDirector_At, Ttrx_Cbr_Approval.IsAppvPresidentDirector, Ttrx_Cbr_Approval.Status_AppvPresidentDirector, Ttrx_Cbr_Approval.AppvPresidentDirector_By, Ttrx_Cbr_Approval.AppvPresidentDirector_At, Ttrx_Cbr_Approval.IsAppvFinanceStaff, Ttrx_Cbr_Approval.Status_AppvFinanceStaff, Ttrx_Cbr_Approval.AppvFinanceStaff_By, Ttrx_Cbr_Approval.AppvFinanceStaff_At, Ttrx_Cbr_Approval.IsAppvFinanceManager, Ttrx_Cbr_Approval.Status_AppvFinanceManager, Ttrx_Cbr_Approval.AppvFinanceManager_By, Ttrx_Cbr_Approval.AppvFinanceManager_At, Ttrx_Cbr_Approval.IsAppvFinanceDirector, Ttrx_Cbr_Approval.Status_AppvFinanceDirector, Ttrx_Cbr_Approval.AppvFinanceDirector_By, Ttrx_Cbr_Approval.AppvFinanceDirector_At, Ttrx_Cbr_Approval.UserName_User, Ttrx_Cbr_Approval.Rec_Created_At, Ttrx_Cbr_Approval.UserDivision
        FROM TAccCashBookReq_Header
        INNER JOIN TUserGroupL ON TAccCashBookReq_Header.Created_By = TUserGroupL.User_ID
        INNER JOIN TUserPersonal ON TAccCashBookReq_Header.Created_By = TUserPersonal.User_ID
        LEFT OUTER JOIN Ttrx_Cbr_Approval ON TAccCashBookReq_Header.CBReq_No = Ttrx_Cbr_Approval.CBReq_No
        WHERE TAccCashBookReq_Header.Type='D'
        And TAccCashBookReq_Header.Document_Date >= {d '2023-10-01'}
        And TAccCashBookReq_Header.Document_Date <= {d '2023-10-31'}
        AND TAccCashBookReq_Header.Company_ID = 2 
        AND isNull(isSPJ,0) = 0
        AND Approval_Status  = 3
        AND CBReq_Status = 3
        AND Ttrx_Cbr_Approval.CBReq_No IS NOT NULL
        AND Created_By = '" . $this->session->userdata('sys_sba_userid') . "' ";
        // ORDER BY TAccCashBookReq_Header.Document_Date DESC,TAccCashBookReq_Header.CBReq_No DESC 

        $totalData = $this->db->query($sql)->num_rows();
        if (!empty($requestData['search']['value'])) {
            $sql .= " AND (TAccCashBookReq_Header.CBReq_No LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR First_Name LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Document_Number LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Document_Date LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR TAccCashBookReq_Header.Currency_Id LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Descript LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR CBReq_Status LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Amount LIKE '%" . $requestData['search']['value'] . "%') ";
        }
        //----------------------------------------------------------------------------------
        $totalFiltered = $this->db->query($sql)->num_rows();
        $sql .= " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";
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
                ORDER BY TACCVI_Header.Invoice_Date DESC");
                if ($vins->num_rows() > 0) {
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
}
