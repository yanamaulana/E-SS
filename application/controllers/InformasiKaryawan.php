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
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/employee/index.js?v=' . time() . '"></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function upload_photo()
    {
        $this->data['page_title'] = "Upload Employee Photo";
        $this->data['page_content'] = "employee/employee_photo";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/employee/employee_photo.js?v=' . time() . '"></script>';

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
        $query = "select * from $this->HRQview_Employee_Detail WHERE Emp_No NOT in ('09466',
'09460',
'29319',
'09188',
'08218',
'09433',
'09438',
'09499',
'05202',
'04628',
'09008',
'09085',
'09243',
'30194',
'30358',
'09073',
'09465',
'09510',
'29475',
'07826',
'09422') AND Emp_No In ('09466',
'09460',
'29319',
'09188',
'08218',
'09433',
'09438',
'09499',
'05202',
'04628',
'09008',
'09085',
'09243',
'30194',
'30358',
'09073',
'09465',
'09510',
'29475',
'07826',
'09422',
'04566',
'07980',
'08752',
'09093',
'08803',
'09412',
'09175',
'09291',
'29555',
'29557',
'09434',
'09436',
'30357',
'09429',
'09075',
'04412',
'09442',
'00032',
'04796',
'09331',
'09279',
'05671',
'09518',
'03085',
'07094');";
        $search = [];

        $isWhere = null;

        $where  = null;

        header('Content-Type: application/json');
        echo $this->M_Datatable_HR->get_tables_query($query, $search, $where, $isWhere);
        // if (!empty($this->input->post('param'))) {
        // } else {
        //     header('Content-Type: application/json');
        //     echo $this->M_Datatable_HR->get_tables_query($query, $where, $search, $isWhere);
        // }

        // $query  = "SELECT A.*, B.Account_Name AS supplier " .
        //     "FROM ttrx_hdr_payment_purchase A " .
        //     "INNER JOIN tmst_account B ON A.id_supplier = B.SysId";
        // $search = array('A.doc_number', 'A.keterangan', 'B.Account_Name');
        // $where  = null;
        // $isWhere = null;

        // header('Content-Type: application/json');
        // echo $this->M_Datatables->get_tables_query($query, $search, $where, $isWhere);
    }
}
