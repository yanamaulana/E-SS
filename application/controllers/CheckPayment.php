<?php
defined('BASEPATH') or exit('No direct script access allowed');

class CheckPayment extends CI_Controller
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
        $this->HR       = $this->load->database('HR', TRUE);
        $this->Date     = date("Y-m-d");
        $this->DateTime = date("Y-m-d H:i:s");
        $this->load->model('m_helper', 'help');
        $this->load->model('m_DataTable', 'M_Datatables');
    }

    public function index()
    {
        $this->data['page_title']   = "Approval Check Payment User Permissions";
        $this->data['page_content'] = "setting/check_payment_permission";

        $this->data['script_page']  =  '<script src="' . base_url() . 'assets/Pages/setting/check_payment_permission.js?v=' . time() . '""></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function store()
    {
        $ValidateUser = $this->db->get_where('ERPQview_User_Employee', ['User_Name' => $this->input->post('username')])->num_rows();
        if ($ValidateUser <= 0) {
            return $this->help->Fn_resulting_response([
                'code' => 505,
                'msg'  => 'The NIK/User Name You Entered Is Not Valid In The System!',
            ]);
        }

        $username = $this->input->post('username');
        $this->db->trans_start();

        $data = array(
            'UserName'    => $username,
            'inserted_by' => $this->session->userdata('sys_sba_username'),
            'inserted_at' => $this->DateTime
        );
        $this->db->insert('tmst_user_check_payment_permission', $data);
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
                'code'  => 200,
                'msg'   => 'Permission Has Been Granted Successfully!',
            ]);
        }
    }

    public function destroy()
    {
        //----- beri validasi is ajax
        if (!$this->input->is_ajax_request()) {
            return $this->help->Fn_resulting_response([
                'code' => 505,
                'msg'  => 'Request must be an Ajax request',
            ]);
        }

        $sysid      = $this->input->post('SysId');
        $deleted_by = $this->session->userdata('sys_sba_username');

        $sql_history = "INSERT INTO thist_user_check_payment_permission (SysId, UserName, inserted_at, inserted_by, deleted_by)
                    SELECT SysId, UserName, inserted_at, inserted_by, ?
                    FROM tmst_user_check_payment_permission
                    WHERE SysId = ?";

        $this->db->trans_start();

        $this->db->query($sql_history, [$deleted_by, $sysid]);
        $this->db->where('SysId', $sysid)->delete('tmst_user_check_payment_permission');

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
                'code'  => 200,
                'msg'   => 'Permission Has Been Revoked Successfully!',
            ]);
        }
    }

    public function DT_list_user_permissions()
    {
        $requestData = $_REQUEST;
        $columns = array(
            0 => 'mst.SysId',
            1 => 'mst.UserName',
            2 => 'mst.First_Name',
            3 => 'mst.inserted_at',
            4 => 'mst.inserted_by'

        );
        $order  = $columns[$requestData['order']['0']['column']];
        $dir    = $requestData['order']['0']['dir'];;

        $sql = "SELECT mst.SysId, mst.UserName, emp.First_Name, mst.inserted_at, mst.inserted_by
                FROM tmst_user_check_payment_permission mst
                JOIN ERPQview_User_Employee emp ON mst.UserName = emp.User_Name
                WHERE 1=1 ";

        $totalData = $this->db->query($sql)->num_rows();
        if (!empty($requestData['search']['value'])) {
            $sql .= " AND (mst.UserName LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR mst.First_Name LIKE '%" . $requestData['search']['value'] . "%') ";
        }
        //----------------------------------------------------------------------------------
        $totalFiltered = $this->db->query($sql)->num_rows();
        $sql .= " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";
        $query = $this->db->query($sql);
        $data = array();
        foreach ($query->result_array() as $row) {
            $nestedData = array();
            $nestedData['SysId']        = $row['SysId'];
            $nestedData['UserName']     = $row['UserName'];
            $nestedData['First_Name']   = $row['First_Name'];
            $nestedData['inserted_at']  = $row['inserted_at'];
            $nestedData['inserted_by']  = $row['inserted_by'];

            $data[] = $nestedData;
        }
        //----------------------------------------------------------------------------------
        $json_data = array(
            "draw"              => intval($requestData['draw']),
            "recordsTotal"      => intval($totalData),
            "recordsFiltered"   => intval($totalFiltered),
            "data"              => $data,
        );
        //----------------------------------------------------------------------------------
        echo json_encode($json_data);
    }
}
