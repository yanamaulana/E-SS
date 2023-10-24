<?php
defined('BASEPATH') or exit('No direct script access allowed');

class ReportPemakaianCuti extends CI_Controller
{
    private $HR;
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
        $this->HR = $this->load->database('HR', TRUE);
    }

    public function index()
    {
        $this->data['page_title'] = "Report Pemakaian Cuti Seluruh Karyawan";
        $this->data['page_content'] = "report_hr/pemakaian_cuti";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/report_hr/pemakaian_cuti.js"></script>';

        $this->load->view($this->layout, $this->data);
    }
}
