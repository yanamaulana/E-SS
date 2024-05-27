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

    public function upload_photo()
    {
        $this->data['page_title'] = "Upload Employee Photo";
        $this->data['page_content'] = "employee/employee_photo";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/employee/employee_photo.js"></script>';

        $this->load->view($this->layout, $this->data);
    }

    // -------------------------------- POST FORM ----------------------------------------------//

    public function store_profile_picture()
    {
        $upload_image = $_FILES['fp']['name'];
        $file_name_without_ext = pathinfo($upload_image, PATHINFO_FILENAME);
        $Sql_Emp = $this->HR->get_where($this->HRQview_Employee_Detail, ['Emp_No' => $file_name_without_ext]);

        $source_path = FCPATH . 'assets/Files/photo/' . $upload_image;
        $destination_path = FCPATH . 'assets/Files/replaced_photo/' . date('Ymds') . '_' . $upload_image;
        if (file_exists($source_path)) {
            rename($source_path, $destination_path);
        } else {
            return $this->help->Fn_resulting_response([
                'code' => 505,
                'msg' => "Terjadi kesalahan teknis hubungi MIS !",
            ]);
        }

        if ($Sql_Emp->num_rows() == 0) {
            return $this->help->Fn_resulting_response([
                'code' => 505,
                'msg' => "update photo failed : Nomor induk karyawan → $file_name_without_ext tidak ditemukan !",
            ]);
        }
        if ($upload_image) {
            $config['allowed_types'] = 'jpg';
            $config['max_size']      = '5120';
            $config['upload_path'] = 'assets/Files/photo/';

            $this->load->library('upload', $config);
            if ($this->upload->do_upload('fp')) {
                $Data_Emp = $Sql_Emp->row();
                return $this->help->Fn_resulting_response([
                    'code' => 200,
                    'msg' => "Update profile picture $Data_Emp->First_Name ($file_name_without_ext) success !",
                ]);
            } else {
                return $this->help->Fn_resulting_response([
                    'code' => 505,
                    'msg' => 'update photo failed : ' . $this->upload->display_errors(),
                ]);
            }
        }
    }

    // -------------------------------- DEVIDER Datatable -------------------------------------- //

    public function DT_List_Employee()
    {
        $tables = $this->HRQview_Employee_Detail;
        $search = [
            'Emp_No', 'First_Name', 'Pos_Name', 'Division_Name', 'costcenter_name', 'Date_Of_Birth', 'Start_Date', 'End_Date', 'EMPLOYMENTSTATUS_NAME', 'Email', 'EMP_IMAGE'
        ];
        $isWhere = null;
        if (!empty($this->input->post('param'))) {
            $where  = array($this->input->post('varr') => $this->input->post('param'));
            header('Content-Type: application/json');
            echo $this->M_Datatable_HR->get_tables_where($tables, $search, $where, $isWhere);
        } else {
            header('Content-Type: application/json');
            echo $this->M_Datatable_HR->get_tables($tables, $search, $isWhere);
        }
    }
}
