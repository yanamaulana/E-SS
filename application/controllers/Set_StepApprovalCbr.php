<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Set_StepApprovalCbr extends CI_Controller
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
        $this->data['page_title'] = "Setting Approval Step Cash Book Requisition";
        $this->data['page_content'] = "setting/step_approval_cbr";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/setting/step_approval_cbr.js"></script>';
        $this->data['approvals'] = $this->db->get_where($this->TmstTrxSettingSteppApprovalCbr, ['UserName_User' => $this->session->userdata('sys_sba_username')]);

        $this->load->view($this->layout, $this->data);
    }

    public function store()
    {
        $data = [
            'Staff' => $this->input->post('Staff'),
            'Chief' => $this->input->post('Chief'),
            'AsstManager' => $this->input->post('AsstManager'),
            'Manager' => $this->input->post('Manager'),
            'SeniorManager' => $this->input->post('SeniorManager'),
            'GeneralManager' => $this->input->post('GeneralManager'),
            'Director' => $this->input->post('Director'),
            'UserName_User' => $this->session->userdata('sys_sba_username'),
            'LastUpdated_at' => $this->DateTime
        ];
        $haveData = $this->db->get_where($this->TmstTrxSettingSteppApprovalCbr, ['UserName_User' => $this->session->userdata('sys_sba_username')]);
        $this->db->trans_start();

        if ($haveData->num_rows() == 0) {
            $this->db->insert($this->TmstTrxSettingSteppApprovalCbr, $data);
        } else {
            $this->db->where('UserName_User', $this->session->userdata('sys_sba_username'))->update($this->TmstTrxSettingSteppApprovalCbr, $data);
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
                'msg' => "The approval step has been successfully saved!",
            ]);
        }
    }
}
