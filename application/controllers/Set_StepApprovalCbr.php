<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Set_StepApprovalCbr extends CI_Controller
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
        $this->data['page_title'] = "Setting Approval Step Cash Book Requisition";
        $this->data['page_content'] = "setting/step_approval_cbr";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/setting/step_approval_cbr.js"></script>';
        $this->data['date'] = date('Y-m-d');

        $this->load->view($this->layout, $this->data);
    }
}
