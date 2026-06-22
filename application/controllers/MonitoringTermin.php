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
}
