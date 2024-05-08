<?php
defined('BASEPATH') or exit('No direct script access allowed');

class InformasiKaryawan extends CI_Controller
{
    private $HR;
    private $Date;
    private $DateTime;
    private $layout = 'layout';
    private $HRQview_Employee_Detail = 'HRQviewEmployeeDetail';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->Date = date("Y-m-d");
        $this->DateTime = date("Y-m-d H:i:s");
        $this->load->model('m_helper', 'help');
        $this->load->model('m_DataTable_Hr', 'M_Datatable_HR');
        $this->HR = $this->load->database('HR', TRUE);
    }

    public function index()
    {
        $this->data['page_title'] = "System Employee Information";
        $this->data['page_content'] = "employee/index";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/employee/index.js"></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function DT_List_Employee()
    {
        $tables = $this->HRQview_Employee_Detail;
        $search = [
            'Emp_No', 'First_Name', 'Pos_Name', 'Division_Name', 'costcenter_name', 'Date_Of_Birth', 'Start_Date', 'End_Date', 'EMPLOYMENTSTATUS_NAME', 'Email', 'EMP_IMAGE'
        ];
        $isWhere = null;
        header('Content-Type: application/json');
        echo $this->M_Datatable_HR->get_tables($tables, $search, $isWhere);
    }
}
