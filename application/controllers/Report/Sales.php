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

    public function sales_order_report()
    {
        $this->data['page_title'] = "Sales Order Report";
        $this->data['page_content'] = "Report/Sales/sales_order_report";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Report/Sales/sales_order_report.js"></script>';

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

    public function Rpt_sales_order()
    {
        $until = $this->input->get("until");;
        $newUntil = date('Y-m-d', strtotime($until . ' +1 day'));

        $this->data['customer'] = $this->input->get("customer");
        $this->data['sales_type'] = $this->input->get("sales_type");
        $this->data['from'] = $this->input->get("from");
        $this->data['until'] = $newUntil;
        $this->data['rdocurrency'] = $this->input->get("rdocurrency");
        $this->data['selCurrency'] = $this->input->get("selCurrency");
        $this->data['TxtUSD'] = $this->input->get("TxtUSD");
        $this->data['TxtEUR'] = $this->input->get("TxtEUR");
        $this->data['TxtAUD'] = $this->input->get("TxtAUD");
        $this->data['TxtSGD'] = $this->input->get("TxtSGD");
        $this->data['TxtKRW'] = $this->input->get("TxtKRW");
        $this->data['TxtJPY'] = $this->input->get("TxtJPY");
        $this->data['TxtGBP'] = $this->input->get("TxtGBP");
        $this->data['report_type'] = $this->input->get("report_type");

        $this->load->view('Report/Sales/Rpt_sales_order', $this->data);
    }

    public function ostpo_rawmaterial()
    {
        $this->data['page_title'] = "Report Raw Material vs Outstanding PO";
        $this->data['page_content'] = "Report/Sales/ostpo_rawmaterial";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Report/Sales/ostpo_rawmaterial.js"></script>';

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

        $this->load->view($this->layout, $this->data);
    }

    public function Rpt_ostpo_rawmaterial()
    {
        $until = $this->input->get("until");;
        $newUntil = date('Y-m-d', strtotime($until . ' +1 day'));

        $this->data['customer'] = $this->input->get("customer");
        $this->data['sales_type'] = $this->input->get("sales_type");
        $this->data['from'] = $this->input->get("from");
        $this->data['until'] = $newUntil;
        $this->data['report_type'] = $this->input->get("report_type");

        $this->db->query("SELECT TAccount.Account_Name, SOHDR.SO_Number, Item_Code, Qty, 
        ISNULL((SELECT SUM(taccSN_Item.Qty) FROM taccSN_Header INNER JOIN taccSN_Item ON taccSN_Item.SN_number = taccSN_Header.SN_number
        WHERE	TAccSN_Item.SO_number = SOHDR.SO_Number
        AND isNull(TAccSN_Header.isVoid,0) = 0 AND taccSN_Item.Item_code = SODTL.item_code 
        AND taccSN_Item.dimension_id = SODTL.dimension_id
        AND taccSN_Header.Approval_Status = 3),0) AS qtyDeliver,
            (SODTL.Qty - ISNULL(
                (
                    SELECT SUM(taccSN_Item.Qty) 
                    FROM taccSN_Header 
                    INNER JOIN taccSN_Item ON taccSN_Item.SN_number = taccSN_Header.SN_number
                    WHERE	
                        TAccSN_Item.SO_number = SOHDR.SO_Number
                        AND ISNULL(TAccSN_Header.isVoid, 0) = 0 
                        AND taccSN_Item.Item_code = SODTL.item_code 
                        AND taccSN_Item.dimension_id = SODTL.dimension_id
                        AND taccSN_Header.Approval_Status = 3
                ), 
                0
            )) AS RemainingQty
        FROM dbsai_erp_uat.dbo.TAccSO_Header AS SOHDR
        INNER JOIN TAccSO_Detail AS SODTL ON SODTL.SO_Number = SOHDR.SO_Number
        INNER JOIN TAccount ON TAccount.Account_ID = SOHDR.Account_ID 
        WHERE SOHDR.SO_Date >= {d '2023-10-01'}
        AND SOHDR.SO_Date < {d '2023-11-01'} 
        ");

        $this->load->view('Report/Sales/Rpt_ostpo_rawmaterial', $this->data);
    }
}


// -- HDR
// --SOHDR.SO_Number, TrxNo, SO_Date, SO_Notes, SOHDR.Account_ID,
// -- ACcount
// --TAccount.Cust_FG, TAccount.Cust_RM,TAccount.Cust_Ast,TAccount.Cust_SP,TAccount.AccountTitle_Code,TAccount.Account_Name,
// -- Detail
// --Item_Code, Item_Description, Qty, Qty_DO, UnitPrice, Base_UnitPrice, Disc_percentage, ExtraPrice,
// --Tax_Code1, Tax_Percentage1, Tax_Operator1, Tax_Amount1, Tax_Code2, Tax_Percentage2, Tax_Operator2, Tax_Amount2, TotalPrice, Base_TotalPrice