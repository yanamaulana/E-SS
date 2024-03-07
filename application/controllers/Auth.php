<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Auth extends CI_Controller
{
    private $HR;
    private $mis = 'Management Information System';
    private $Tmst_User_NonHR = 'Tmst_User_NonHR';
    private $ERPQview_User_Employee = 'ERPQview_User_Employee';
    private $Taccess_Approval_Cbr   = 'Taccess_Approval_Cbr';
    private $HRQview_Employee_Detail = 'HRQviewEmployeeDetail';
    public function __construct()
    {
        parent::__construct();
        $this->load->model('m_helper', 'help');
        $this->HR = $this->load->database('HR', TRUE);
    }

    public function index()
    {
        if ($this->session->userdata("sys_sba_username")) {
            return redirect("Dashboard");
        }
        $this->data['page_title'] = "Login";

        $this->load->view('Auth/index', $this->data);
    }


    public function post_login()
    {
        if (!$this->input->is_ajax_request()) {
            $response = [
                "code" => 404,
                "msg" => "The technical error occurred, Request denied!"
            ];
            return $this->help->Fn_resulting_response($response);
        }
        $login = $this->input->post(null, true);
        $login = (object) $login;
        $login->username = $login->u;
        $login->password = $login->p;

        if (empty($login->username) || empty($login->password)) {
            $response = [
                "code" => 404,
                "msg" => "Username & Password must be filled in!"
            ];
            return $this->help->Fn_resulting_response($response);
        }

        $users = $this->db->get_where($this->ERPQview_User_Employee, [
            'User_Name' => $login->username,
            'User_Pass_Txt' => $login->password
        ]);

        if ($users->num_rows() > 0) {
            $user = $users->row_array();
            if ($user['is_Passive'] == 1) {
                $response = [
                    "code" => 404,
                    "msg" => "The user has been disabled!"
                ];
                return $this->help->Fn_resulting_response($response);
            }

            $sqlemployee = $this->HR->get_where($this->HRQview_Employee_Detail, [
                'Emp_No' => $login->username,
            ]);
            $SqlIsBod = $this->db->get_where($this->Tmst_User_NonHR, [
                'UserID' => $user['User_ID'],
            ]);
            $is_dir = 0;
            if ($sqlemployee->num_rows() > 0) {
                $employee = $sqlemployee->row_array();
            } elseif ($SqlIsBod->num_rows() > 0) {
                $employee = $SqlIsBod->row_array();
                if ($employe['Division'] = 'Board Of Directors') {
                    $is_dir = 1;
                }
            } else {
                $response = [
                    "code" => 404,
                    "msg" => "Your job position data was not found in the HR system. !"
                ];
                return $this->help->Fn_resulting_response($response);
            }

            $is_admin = false;
            if ($employee['Division_Name'] == $this->mis) {
                $is_admin = true;
            }

            $this->delete_cache();

            $Cbr_Depts = $this->get_arr_dept($employee['Division_Name'], $login->username);

            $session_data = array(
                'sys_sba_isDir'                => $is_dir,
                'sys_sba_isAdm'                => $is_admin,
                'sys_cbr_divs'                 => $Cbr_Depts,
                'sys_sba_userid'               => $user['User_ID'],
                'sys_sba_username'             => $user['User_Name'],
                'sys_sba_NIK'                  => $user['User_Name'],
                'sys_sba_nama'                 => $user['First_Name'],
                'sys_sba_jabatan'              => $employee['Pos_Name'],
                'sys_sba_email'                => $user['Email_Address'],
                'sys_sba_department'           => $employee['Division_Name'],
            );
            $this->session->set_userdata($session_data);
            $response = [
                "code" => 200,
                "msg" => "Successfully login into " . $this->config->item('init_app_name') . " !"
            ];
            return $this->help->Fn_resulting_response($response);
        } else {
            $users = $this->db->get_where($this->ERPQview_User_Employee, [
                'User_Name' => $login->username,
            ]);
            if ($users->num_rows() == 0) {
                $response = [
                    "code" => 404,
                    "msg" => "User not found !"
                ];
                return $this->help->Fn_resulting_response($response);
            }
            if ($users->num_rows() > 0) {
                $response = [
                    "code" => 505,
                    "msg" => "Password not match !"
                ];
                return $this->help->Fn_resulting_response($response);
            } else {
                $response = [
                    "code" => 505,
                    "msg" => "Username & Password not registered!"
                ];
                return $this->help->Fn_resulting_response($response);
            }
        }
    }

    private function get_arr_dept($div_personal, $username)
    {
        $depts = [];

        $sql_depts = $this->db->get_where($this->Taccess_Approval_Cbr, [
            'UserName' => $username
        ]);

        if ($sql_depts->num_rows() > 0) {
            foreach ($sql_depts->result() as $dpt) {
                $depts[] = $dpt->Additional_Div;
            }
        }
        $depts[] = $div_personal;
        $divisions = implode(",", $depts);
        return $divisions;
    }

    private function delete_cache()
    {
        $this->load->helper('file');

        delete_files(APPPATH . 'cache', true);
    }

    public function logout()
    {
        $this->output->delete_cache();
        $array_items = array(
            'sys_sba_nama',
            'sys_sba_NIK',
            'sys_sba_username',
            'sys_sba_jabatan',
            'sys_sba_department',
            'sys_sba_email',
            'sys_sba_isDir',
            'sys_sba_isAdm',
            'sys_cbr_divs',
        );
        $this->session->unset_userdata($array_items);
        session_destroy();
        $this->session->set_flashdata('success', "Please log in again to access " . $this->config->item('app_name'));
        return redirect('Auth');
    }
}
