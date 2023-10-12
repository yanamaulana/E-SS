<?php
defined('BASEPATH') or exit('No direct script access allowed');

class CbrAppStaff extends CI_Controller
{
    private $Date;
    private $DateTime;
    private $layout = 'layout';
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
        $this->data['page_title'] = "Staff Approval-Cash Book Requisition";
        $this->data['page_content'] = "cbr_app/staff";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/cbr_app/staff.js"></script>';

        $this->load->view($this->layout, $this->data);
    }
}
