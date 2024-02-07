<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Logistic extends CI_Controller
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

    public function eta_purchase_order()
    {
        $this->data['page_title'] = "ETA Purchase Order";
        $this->data['page_content'] = "Report/Logistic/eta_purchase_order";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Report/Logistic/eta_purchase_order.js"></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function Rpt_eta_purchase_order()
    {
        // $SelLocation = $this->input->get('SelLocation');
        // $selCatType = $this->input->get('selCatType');
        $from = $this->input->get('from');
        $until = $this->input->get('until');
        // ----------------------------------------------
        // $this->data['SelLocation'] = $SelLocation;
        // $this->data['selCatType'] = $selCatType;
        $this->data['from'] = $from;
        $this->data['until'] = $until;

        $this->data['query'] = $this->db->query("SELECT TAccPO_Detail.PODetail_ID, TAccPO_Detail.Po_number, TAccPO_header.PO_Date, TAccPO_Header.Currency_ID,TAccPO_header.EstTimeArrival, TAccPO_Detail.Item_Code, TAccPO_Detail.Qty, TAccPO_Detail.Qty_RR, TAccPO_Detail.UnitPrice, TAccPO_Detail.Base_UnitPrice, TAccPO_Detail.Disc_percentage, TAccPO_Detail.Tax_Code1, TAccPO_Detail.Tax_Percentage1, TAccPO_Detail.Tax_Operator1, isnull(TAccPO_Detail.Tax_Amount1, 0) as Tax_Amount1, TAccPO_Detail.Tax_Code2, TAccPO_Detail.Tax_Percentage2, TAccPO_Detail.Tax_Operator2, isnull(TAccPO_Detail.Tax_Amount2, 0) as Tax_Amount2, TAccPO_Detail.TotalPrice, TAccPO_Detail.Base_TotalPrice, TAccPO_Detail.Others, TAccPO_Detail.Include_RR, TAccPO_Detail.EstimateDate, TAccPO_Detail.Comp_ID, TAccPO_Detail.Parent_Item, TAccPO_Detail.Parent_Path, TAccPO_Detail.Generate_Flag, TAccPO_Detail.config_level, TAccPO_Detail.config_ratio, TAccPO_Detail.config_order, TAccPO_Detail.preq_id, TAccPO_Detail.Dimension_ID, TAccPO_Header.POType,  Titem.Item_name, tgscolor.color_name, titem.customfield1 AS item_type,  titem.item_size AS brand,  titem.item_length, titem.item_width, titem.item_height, TAccPO_Header.Account_ID, TAccount.Account_Name, TAccount.Account_Address1,  Titem.PriceType,  TAccPO_Header.Tax_Code AS VAT_Tax_Code, TItemDimension.Dimension_Name,  ISNULL(MOQ, 0) MOQ
        FROM TAccPO_Detail
        INNER JOIN	TItem	ON TAccPO_Detail.Item_code = Titem.Item_Code
        INNER JOIN	TAccPO_Header ON TAccPO_Header.PO_Number = TAccPO_Detail.PO_Number AND TAccPO_Header.Company_ID = 2
        INNER JOIN	TAccount ON TAccount.Account_ID = TAccPO_Header.Account_Id 
        LEFT  JOIN 	TItemDimension ON TItemDimension.Dimension_ID = TAccPO_Detail.Dimension_ID 
        LEFT JOIN tgscolor ON tgscolor.color_code = titem.item_color
        WHERE  
        -- TAccPO_header.WH_ID = 'SelLocation' AND
        -- TAccPO_header.ItemCategoryType = 'selCatType' AND
         TAccPO_Header.isNotActive = 0
        AND TAccPO_header.Approval_Status not in (4)
        AND TAccPO_Detail.EstimateDate >= '$from 00:00:00'
        AND TAccPO_Detail.EstimateDate <= '$until 23:59:59'
        ORDER BY TAccPO_Detail.EstimateDate, TAccPO_Detail.Item_Code");

        $this->load->view('Report/Logistic/Rpt_eta_po', $this->data);
    }

    public function index_price_comparison_last_v_this_year()
    {
        $this->data['page_title'] = "Comparison Price Last Year vs This Year";
        $this->data['page_content'] = "Report/Logistic/price_compare_year";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Report/Logistic/price_compare_year.js"></script>';

        $this->load->view($this->layout, $this->data);
    }
}
