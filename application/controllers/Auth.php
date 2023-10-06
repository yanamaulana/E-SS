<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Auth extends CI_Controller
{
    private $ERPQview_User_Employee = 'ERPQview_User_Employee';
    private $HRQview_Employee_Detail = 'HRQview_Employee_Detail';
    public function __construct()
    {
        parent::__construct();
        $this->load->model('m_helper', 'help');
    }

    public function index()
    {
        if ($this->session->userdata("sys_username")) {
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
            $HR = $this->load->database('HR', TRUE);
            $employee = $HR->get_where($this->HRQview_Employee_Detail, [
                'Emp_No' => $login->username,
            ])->row_array();

            $this->delete_cache();

            $session_data = array(
                'sys_nama'                 => $user['First_Name'],
                'sys_NIK'                  => $user['User_Name'],
                'sys_username'             => $user['User_Name'],
                'sys_jabatan'              => $employee['Pos_Name'],
                'sys_email'                => $user['Email_Address']
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
                    "msg" => "User tidak ditemukan !"
                ];
                return $this->help->Fn_resulting_response($response);
            }
            if ($users->num_rows() > 0) {
                $response = [
                    "code" => 505,
                    "msg" => "Password tidak sesuai !"
                ];
                return $this->help->Fn_resulting_response($response);
            } else {
                $response = [
                    "code" => 505,
                    "msg" => "Username & Password tidak terdaftar !"
                ];
                return $this->help->Fn_resulting_response($response);
            }
        }
    }


    private function delete_cache()
    {
        $this->load->helper('file');

        delete_files(APPPATH . 'cache', true);
    }

    public function logout()
    {
        $this->output->delete_cache();
        $array_items = array('impsys_name', 'impsys_nik', 'impsys_initial', 'impsys_jabatan', 'impsys_telp', 'impsys_type_pembayaran');
        $this->session->unset_userdata($array_items);
        session_destroy();
        $this->session->set_flashdata('success', "Silahkan login kembali untuk mengakses" . $this->config->item('app_name'));
        return redirect('Auth');
    }
}
