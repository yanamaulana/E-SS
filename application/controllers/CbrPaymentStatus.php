<?php
defined('BASEPATH') or exit('No direct script access allowed');

class CbrPaymentStatus extends CI_Controller
{
    private $Date;
    private $DateTime;
    private $layout = 'layout';
    private $TmstTrxSettingSteppApprovalCbr = 'TmstTrxSettingSteppApprovalCbr';
    private $HRQview_Employee_Detail = 'HRQviewEmployeeDetail';
    private $Tmst_User_NonHR = 'Tmst_User_NonHR';
    private $QviewSettingStepApproval = 'QviewSettingStepApproval';
    private $ERPQview_User_Employee = 'ERPQview_User_Employee';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->HR = $this->load->database('HR', TRUE);
        $this->Date = date("Y-m-d");
        $this->DateTime = date("Y-m-d H:i:s");
        $this->load->model('m_helper', 'help');
        $this->load->model('m_DataTable', 'M_Datatables');
    }

    public function index()
    {
        $this->data['page_title'] = "Approval Check Payment User Permissions";
        $this->data['page_content'] = "setting/check_payment_permission";

        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/setting/check_payment_permission.js?v=' . time() . '""></script>';

        $this->load->view($this->layout, $this->data);
    }
}
