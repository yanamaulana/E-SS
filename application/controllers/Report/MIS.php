<?php
defined('BASEPATH') or exit('No direct script access allowed');

class MIS extends CI_Controller
{
    private $layout = 'layout';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        // Load m_DataTable model
        $this->load->model('m_DataTable', 'M_Datatables');
    }

    public function ERP_AccessPermission()
    {
        $this->data['page_title'] = "ERP Access Permission";
        $this->data['page_content'] = "Report/MIS/erp_access_permission";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/MIS/Erp_AccessPermission.js?v=' . time() . '"></script>';

        // Mengambil data untuk filter dropdown
        $this->data['user_groups'] = $this->db->query("SELECT DISTINCT Tug.UserGroup_ID, Tug.UserGroup_Name 
            FROM TUserGroupFuncL Tgf 
            JOIN TUserGroup Tug ON Tug.UserGroup_ID = Tgf.UserGroup_ID
            WHERE Tgf.UserGroup_ID IN (27, 31, 34, 44, 46, 49, 66, 72, 87, 104)
            ORDER BY Tug.UserGroup_Name")->result();

        $this->data['functions'] = $this->db->query("SELECT DISTINCT Tgf.sf_ufunc_id, Tuf.SF_UFUNC_NAME_EN
            FROM TUserGroupFuncL Tgf
            JOIN TSF_USERFUNCTION Tuf ON Tgf.sf_ufunc_id = Tuf.SF_UFUNC_ID
            WHERE Tgf.sf_ufunc_id IN ('ERSTD07854', 'ERSTD08128', 'ERSTD07148', 'ERSTD07142')
            ORDER BY Tuf.SF_UFUNC_NAME_EN")->result();

        $this->load->view($this->layout, $this->data);
    }

    public function DT_ERP_AccessPermission()
    {
        $usergroup_id = $this->input->post('usergroup_id');
        $function_id = $this->input->post('function_id');

        $where = null;
        $iswhere = "Tgf.UserGroup_ID in (27, 31, 34, 44, 46, 49, 66, 72, 87, 104) 
            and Tgf.sf_ufunc_id in ('ERSTD07854', 'ERSTD08128', 'ERSTD07148', 'ERSTD07142')";

        // Menambahkan kondisi filter jika ada
        if ($usergroup_id != 'ALL' && !empty($usergroup_id)) {
            $where['Tgf.UserGroup_ID'] = $usergroup_id;
        }
        if ($function_id != 'ALL' && !empty($function_id)) {
            $where['Tgf.sf_ufunc_id'] = $function_id;
        }

        $query = "
            SELECT Tgf.UserGroupFuncL_ID, Tgf.UserGroup_ID, Tug.UserGroup_Name, Tgf.isLog, Tgf.sf_ufunc_id, Tuf.SF_UFUNC_NAME_EN, Tgf.sf_ufunc_access
            FROM TUserGroupFuncL Tgf 
            join TUserGroup Tug on Tug.UserGroup_ID = Tgf.UserGroup_ID
            join TSF_USERFUNCTION Tuf on Tgf.sf_ufunc_id = Tuf.SF_UFUNC_ID
        ";

        $cari = array('Tug.UserGroup_Name', 'Tuf.SF_UFUNC_NAME_EN');

        echo $this->M_Datatables->get_tables_query($query, $cari, $where, $iswhere);
    }

    public function update_access_permission()
    {
        if (!$this->input->is_ajax_request()) {
            show_404();
            return;
        }

        $id = $this->input->post('id');
        $access = $this->input->post('access'); // 'true' atau 'false'

        if (empty($id)) {
            echo json_encode(['status' => 'error', 'message' => 'ID tidak valid.']);
            return;
        }

        // Memulai transaksi untuk memastikan integritas data
        $this->db->trans_start();

        // Ambil status akses saat ini sebelum diubah
        $current_access_row = $this->db->select('sf_ufunc_access')
            ->where('UserGroupFuncL_ID', $id)
            ->get('TUserGroupFuncL')
            ->row();
        $previous_access = $current_access_row ? strtolower(trim($current_access_row->sf_ufunc_access)) : 'read';

        $new_access_level = ($access === 'true') ? 'delete' : 'read';
        $new_access_text = ($access === 'true') ? 'Full Access (delete)' : 'View Only (read)';

        // Lakukan update pada tabel utama
        $data = ['sf_ufunc_access' => $new_access_level];
        $this->db->where('UserGroupFuncL_ID', $id);
        $this->db->update('TUserGroupFuncL', $data);

        $is_temporary = false;
        // LOGIKA: Hanya catat log jika hak akses dinaikkan dari 'read' ke 'delete'
        if ($access === 'true' && $previous_access === 'read') {
            $is_temporary = true;
            $revert_duration = '+4 hours'; // Durasi akses sementara sesuai contoh Anda
            $log_data = [
                'UserGroupFuncL_ID' => $id,
                'Previous_Access'   => 'read',
                'New_Access'        => 'delete',
                'Changed_By'        => $this->session->userdata('sys_sba_userid'),
                'Changed_At'        => date('Y-m-d H:i:s'),
                'Revert_At'         => date('Y-m-d H:i:s', strtotime($revert_duration)),
                'Is_Reverted'       => 0
            ];
            $this->db->insert('TblTemporaryAccessLog', $log_data);
        }

        // Selesaikan transaksi
        $this->db->trans_complete();

        if ($this->db->trans_status() === FALSE) {
            $this->db->trans_rollback();
            $message = ['status' => 'error', 'message' => 'Gagal memperbarui hak akses karena kesalahan database.'];
        } else {
            $this->db->trans_commit();
            $success_message = 'Hak akses diubah menjadi ' . $new_access_text . '.';
            if ($is_temporary) {
                $success_message = 'Hak akses sementara diubah menjadi ' . $new_access_text . '. Akan kembali otomatis dalam 8 jam.';
            }
            $message = ['status' => 'success', 'message' => $success_message];
        }

        echo json_encode($message);
    }
}
