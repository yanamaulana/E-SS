<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Sales extends CI_Controller
{
    private $Date;
    private $DateTime;
    private $layout = 'layout';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->Date = date("Y-m-d");
        $this->DateTime = date("Y-m-d H:i:s");
        $this->load->model('m_helper', 'help');
        $this->load->model('m_DataTable', 'M_Datatables');
    }

    public function OstSO_v_Bom_v_StokMtrl()
    {
        $this->data['page_title'] = "Outstanding SO vs BOM vs Stok Material";
        $this->data['page_content'] = "Report/Sales/OstSO_v_Bom_v_StokMtrl";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Report/Sales/OstSO_v_Bom_v_StokMtrl.js"></script>';

        $this->data['qAccount'] =  $this->db->query("
        SELECT TAccount.Account_Id,
        TAccount.Account_Name
        FROM TAccount WHERE
        (TAccount.Cust_FG = 1
        OR TAccount.Cust_RM = 1
        OR TAccount.Cust_Ast = 1
        OR TAccount.Cust_SP = 1
        OR TAccount.Cust_SF = 1)
        AND	TAccount.Category_ID IN (SELECT DISTINCT CATEGORY_ID FROM TDATAGROUPACCOUNT WHERE DATAGROUP_ID IN (20,86))
        AND TAccount.Company_ID = 2
        ORDER BY TAccount.Account_Name");

        $this->data['qCurrency'] = $this->db->query("SELECT Currency_ID,currency_symbol
        FROM TCurrency
        WHERE status = 1");

        $this->data['SelCurr'] = $this->input->get('SelCurr');


        $this->load->view($this->layout, $this->data);
    }

    public function Rpt_OstSO_v_Bom_v_StokMtrl()
    {
        var_dump($this->input->get());
        die;
    }
}
