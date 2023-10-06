<?php
defined('BASEPATH') or exit('No direct script access allowed');

class CbrApp_Manager extends CI_Controller
{
    private $Date;
    private $DateTime;
    private $layout = 'layout';
    private $TaccCashBookReq_Approval_Manager = 'TaccCashBookReq_Approval_Manager';

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
        $this->data['page_title'] = "CBR Manager Approval";
        $this->data['page_content'] = "CbrApproval/manager";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/CbrApproval/manager.js"></script>';
        $this->data['date'] = date('Y-m-d');

        $this->load->view($this->layout, $this->data);
    }

    public function DT_List_To_Approve()
    {
        $requestData = $_REQUEST;
        // Select distinct
        // CBReq_No,
        // Type,
        // Document_Date,
        // TAccCashBookReq_Header.Acc_ID,
        // Descript,
        // Amount,
        // baseamount,
        // curr_rate,
        // Approval_Status,
        // CBReq_Status,
        // Paid_Status
        // Creation_DateTime,
        // Created_By,
        // Last_Update,
        // Update_By,
        // TAccCashBookReq_Header.Currency_Id,
        // TAccCashBookReq_Header.Approve_Date	
        $columns = array(
            0 => 'CBReq_No',
            1 => 'Type',
            2 => 'Document_Date',
            3 => 'TAccCashBookReq_Header.Acc_ID',
            4 => 'Descript',
            5 => 'Amount',
            6 => 'baseamount',
            7 => 'curr_rate',
            8 => 'Approval_Status',
            9 => 'CBReq_Status',
            10 => 'Paid_Status',
            11 => 'Creation_DateTime',
            12 => 'Created_By',
            13 => 'Last_Update',
            13 => 'Update_By',
            13 => 'Update_By',

        );
        $order = $columns[$requestData['order']['0']['column']];
        $dir = $requestData['order']['0']['dir'];
        $ID = $this->session->userdata('sys_ID');

        $sql = "SELECT * from qview_submission_attendance where SysId is not null ";

        $totalData = $this->db->query($sql)->num_rows();
        if (!empty($requestData['search']['value'])) {
            $sql .= " AND (Date_Att LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Schedule_Number LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Time_Att LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Card LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Day LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Kelas LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Stand_Hour LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Time_Start LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Time_Over LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Mata_Pelajaran LIKE '%" . $requestData['search']['value'] . "%') ";
        }
        //----------------------------------------------------------------------------------
        $totalFiltered = $this->db->query($sql)->num_rows();
        $sql .= " ORDER BY $order $dir LIMIT " . $requestData['start'] . " ," . $requestData['length'] . " ";
        $query = $this->db->query($sql);
        $data = array();
        foreach ($query->result_array() as $row) {
            $nestedData = array();
            $nestedData['SysId'] = $row['SysId'];
            $nestedData['Name'] = $row['Name'];
            $nestedData['Access_ID'] = $row['Access_ID'];
            $nestedData['Card'] = $row['Card'];
            $nestedData['Date_Att'] = $row['Date_Att'];
            $nestedData['Time_Att'] = $row['Time_Att'];
            $nestedData['Schedule_Number'] = $row['Schedule_Number'];
            $nestedData['Day'] = $row['Day'];
            $nestedData['Kelas'] = $row['Kelas'];
            $nestedData['Mata_Pelajaran'] = $row['Mata_Pelajaran'];
            $nestedData['Time_Start'] = $row['Time_Start'];
            $nestedData['Time_Over'] = $row['Time_Over'];
            $nestedData['Stand_Hour'] = floatval($row['Stand_Hour']);
            $nestedData['Status'] = $row['Status'];

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



        // Select distinct
        // CBReq_No,
        // Type,
        // Document_Date,
        // TAccCashBookReq_Header.Acc_ID,
        // Descript,
        // Amount,
        // baseamount,
        // curr_rate,
        // Approval_Status,
        // CBReq_Status,
        // Creation_DateTime,
        // Created_By,
        // Last_Update,
        // Update_By,
        // TAccCashBookReq_Header.Currency_Id,
        // TAccCashBookReq_Header.Approve_Date	
        // FROM TAccCashBookReq_Header
        // INNER JOIN TUserGroupL ON TAccCashBookReq_Header.Created_By = TUserGroupL.User_ID
        // WHERE TAccCashBookReq_Header.Type='D'
        // And TAccCashBookReq_Header.Document_Date >= {d '2023-10-01'}
        // And TAccCashBookReq_Header.Document_Date <= {d '2023-10-31'}
        // AND TAccCashBookReq_Header.Company_ID = 2 
        // AND isNull(isSPJ,0) = 0
        // ORDER BY TAccCashBookReq_Header.Document_Date DESC,TAccCashBookReq_Header.CBReq_No DESC
    }
}
