<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Dashboard extends CI_Controller
{
    private $Day;
    private $Date;
    private $layout = 'layout';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->Day = date("l");
        $this->Date = date("Y-m-d");
        $this->load->model('m_helper', 'help');
    }

    public function index()
    {
        $this->data['page_title'] = "Dashboard";
        $this->data['page_content'] = "Dashboard/index";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/Dashboard/index.js"></script>';
        $this->data['date'] = date('Y-m-d');

        $this->load->view($this->layout, $this->data);
    }

    public function Access_log()
    {
        $this->data['page_title'] = "Access Log";
        $this->data['page_content'] = "Dashboard/Access_log";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/Dashboard/Access_log.js"></script>';
        $this->data['date'] = date('Y-m-d');

        $this->load->view($this->layout, $this->data);
    }

    public function DT_list_Access_Log()
    {
        $requestData = $_REQUEST;
        $columns = array(
            0 => 'UserLog_ID',
            1 => 'User_Name',
            2 => 'First_Name',
            3 => 'Remote_IP',
            4 => 'Log_Date',
            5 => 'Log_Action'
        );
        $order  = $columns[$requestData['order']['0']['column']];
        $dir    = $requestData['order']['0']['dir'];
        $from   = $this->input->post('from');
        $until  = $this->input->post('until');

        $sql = "SELECT Eslog.UserLog_ID, TUserPersonal.First_Name, Eslog.User_Name, Eslog.Remote_IP, Eslog.Log_Date, Eslog.Log_Action
            FROM EsbaUserLog Eslog 
            JOIN tuser on Eslog.User_Name = tuser.User_Name
            JOIN TUserPersonal on tuser.User_ID = TUserPersonal.User_ID
            WHERE Eslog.User_Name = '" . $this->session->userdata('sys_sba_username') . "'
            AND Eslog.Log_Date >= {ts '$from 00:00:00'}
            AND Eslog.Log_Date <= {ts '$until 23:59:59'} ";

        $totalData = $this->db->query($sql)->num_rows();
        if (!empty($requestData['search']['value'])) {
            $sql .= " AND (Remote_IP LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Log_Date LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Log_Action LIKE '%" . $requestData['search']['value'] . "%') ";
        }
        //----------------------------------------------------------------------------------
        $totalFiltered = $this->db->query($sql)->num_rows();
        $sql .= " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";
        $query = $this->db->query($sql);
        $data = array();
        foreach ($query->result_array() as $row) {
            $nestedData = array();
            $nestedData['UserLog_ID'] = $row['UserLog_ID'];
            $nestedData['User_Name'] = $row['User_Name'];
            $nestedData['First_Name'] = $row['First_Name'];
            $nestedData['Remote_IP'] = $row['Remote_IP'];
            $nestedData['Log_Date'] = $row['Log_Date'];
            $nestedData['Log_Action'] = $row['Log_Action'];

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
}
