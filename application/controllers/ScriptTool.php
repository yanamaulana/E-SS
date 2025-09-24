<?php
defined('BASEPATH') or exit('No direct script access allowed');

class ScriptTool extends CI_Controller
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

    public function update_costcenter()
    {
        $this->data['page_title'] = "Script Tool ERP Sunfish";
        $this->data['page_content'] = "ScriptTool/update_cost_center";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/ScriptTool/update_cost_center.js?v=' . time() . '"></script>';

        $this->data['CostCenterList'] = $this->db->query("SELECT * from TAccCostCenter")->result();

        $this->load->view($this->layout, $this->data);
    }

    public function store_update_costcenter()
    {
        $vin = $this->input->post('vin');
        $CostCenter = $this->input->post('CostCenter');

        $arr_vin = explode(',', $vin);

        $this->db->trans_start();

        foreach ($arr_vin as $inv) {
            // bersihkan dulu $inv dari spasi
            $invoice = trim($inv);
            // $invoice harus mengandung string INV
            if (strpos($invoice, 'VIN') === false) {
                return $this->help->Fn_resulting_response([
                    'code' => 505,
                    'msg' => "$invoice bukan nomor invoice yang valid ! update dibatalkan.",
                ]);
            }
            $sql = $this->db->where('JournalH_Code', $invoice)
                ->where('JournalD_Debet >', 0);

            $cekIfExist = $sql->get('TAccJournalDetail')->row();

            if (!$cekIfExist) {
                return $this->help->Fn_resulting_response([
                    'code' => 505,
                    'msg'  => "Data dengan nomor invoice $invoice tidak ditemukan ! update dibatalkan.",
                ]);
            }

            // Reset query builder supaya where() sebelumnya tidak ikut
            $this->db->reset_query();

            // Update data sesuai kriteria
            $this->db->where('JournalH_Code', $invoice)
                ->where('JournalD_Debet >', 0)
                ->update('TAccJournalDetail', [
                    'CostCenter' => $CostCenter
                ]);
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
                'msg' => 'Update Cost Center Berhasil !',
            ]);
        }
    }
}
