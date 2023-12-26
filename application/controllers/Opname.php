<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Opname extends CI_Controller
{
    private $Day;
    private $Date;
    protected $ItemCategoryType;
    private $layout = 'layout';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->Day = date("l");
        $this->Date = date("Y-m-d");
        $this->ItemCategoryType = ['RM' => 'Raw Material', 'FG' => 'Finished Goods or Services', 'SP' => 'Supplies', 'SF' => 'Semi-Finished Goods', 'WIP' => 'Working In Process'];
        $this->load->model('m_helper', 'help');
    }

    public function index()
    {
        $this->data['page_title'] = "Stock Opname";
        $this->data['page_content'] = "Opname/index";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/opname/index.js"></script>';
        $this->data['date'] = $this->Date;

        $this->load->view($this->layout, $this->data);
    }

    public function GenerateDataOpname()
    {
        $SelLocation = $this->input->get('SelLocation');
        $DatePeriod = $this->input->get('DatePeriod');
        $selCatType = $this->input->get('selCatType');
        $item_code = $this->input->get('item_code');
        $Category = $this->input->get('Category');
        $Gudang = $this->input->get('Gudang');

        $sqlItem = "";
        $sqlItemCode = "";
        if (!empty($item_code)) {
            $sqlItem = " AND ((UPPER(TItem.Item_Code) LIKE UPPER('$item_code'))) ";
            $sqlItemCode = " AND TCOUNTITEM.ITEM_CODE = '$item_code' ";
        }
        $sqlCategory = "";
        $SqlBinCountItem = "";
        $this->data['Category'] = $Category;
        if ($Category != 'ALL') {
            $sqlCategory = " AND TItemCompany.Itemcategory_ID in ('$Category') ";
            $SqlBinCountItem = " AND TCOUNTITEM.Bin_ID = '$Gudang' ";
            $RowCategory = $this->db->get_where('TItemCategory', ['ItemCategory_id' => $Category])->row();
            $this->data['TxtCategory'] = $RowCategory->ItemCategory_name;
        } else {
            $this->data['TxtCategory'] = 'ALL';
            $SqlBinCountItem = " AND TCOUNTITEM.Bin_ID = '$Gudang' ";
        }

        $SqlOpname = "SELECT TItem.Item_Code, TItemCompany.ItemCategory_ID, TItemCategory.ItemCategory_NAme, Item_Name, ISNULL(TItemWHBin.Item_Qty,0) as Item_Qty,
        Item_size, TitemCompany.Asset_Account, ViewCategory, currency_id, TitemCompany.AVG_VALUE, CostingMethod, selling_currency_id,
        TItem.Habis, Option_code, InActive, generate_flag, TItem.Unit_Type_ID, Unit_Name, TItemCompany.Dimension_ID, 
        ISNULL(itd.Dimension_Name, '') AS Dimension_Name 
        FROM TItemWHBin
        INNER JOIN  TItem ON TItem.item_Code = TItemWHBin.Item_Code
        INNER JOIN 	TItemCompany ON TItem.item_Code = TItemCompany.Item_Code
        INNER JOIN	TItemCategory ON TItemCompany.ItemCategory_ID = TItemCategory.ItemCategory_ID
        INNER JOIN TItemDimension itd ON itd.Dimension_ID = TItemCompany.Dimension_ID 
        INNER JOIN	TAccUnitType ON TITEM.Unit_Type_ID = TAccUnitType.Unit_Type_ID 
        WHERE TITEM.status = 1 
        AND TItemWHBin.wh_id = '$SelLocation'
        AND	TItemWHBin.bin_id = '$Gudang'
        AND TItemWHBin.ItemCategoryType = '$selCatType'
        AND TItemCompany.company_id = 2 
        AND TItem.habis = 1
        AND ( InActive is NULL OR InActive = 0)
        $sqlCategory $sqlItem
        AND TItem.item_code in(SELECT DISTINCT ITEM_CODE FROM TDATAGROUPITEM WHERE DATAGROUP_ID IN (20,86)) 
        ORDER BY TItemWHBin.Item_Qty DESC";

        $SqlValidateOpname = "SELECT TCOUNTITEM.COUNTITEM_ID, 
        TCOUNTITEM.COUNTITEM_CATEGORY_TYPE, 
        TCOUNTITEM.ITEM_CODE, 
        TItem.Item_Name,
        TAccUnitType.Unit_Name,
        TCOUNTITEM.QTY_ONHAND, 
        TCOUNTITEM.STOCK_OPNAME, 
        TCOUNTITEM.BALANCE_OPNAME, 
        TCOUNTITEM.COMPANY_ID, 
        TCOUNTITEM.WH_ID,
        TCOUNTITEM.Bin_ID,
        TCOUNTITEM.LAST_UPDATE,
        TCOUNTITEM.UPDATED_BY, 
        TCOUNTITEM.Dimension_ID,
        ISNULL(TItemDimension.Dimension_Name, '') AS Dimension_Name 
        FROM dbsai_erp_uat.dbo.TCOUNTITEM
        INNER JOIN  TItem ON TItem.item_Code = TCOUNTITEM.ITEM_CODE
        INNER JOIN	TAccUnitType ON TITEM.Unit_Type_ID = TAccUnitType.Unit_Type_ID 
        LEFT JOIN TItemDimension ON TItemDimension.Dimension_ID = TCOUNTITEM.Dimension_ID
        WHERE TCOUNTITEM.COUNTITEM_CATEGORY_TYPE = '$selCatType' 
        AND TCOUNTITEM.COMPANY_ID = 2
        AND TCOUNTITEM.WH_ID = $SelLocation
        $SqlBinCountItem
        $sqlItem
        AND TCOUNTITEM.LAST_UPDATE = '$DatePeriod' ORDER BY TCOUNTITEM.QTY_ONHAND DESC";

        $SqlDestroyOpname = "DELETE FROM TCOUNTITEM WHERE COUNTITEM_CATEGORY_TYPE = '$selCatType' 
        AND COMPANY_ID = 2
        AND WH_ID = $SelLocation
        $SqlBinCountItem
        $sqlItemCode
        AND LAST_UPDATE = '$DatePeriod'";

        $this->data['page_title'] = 'Generate Qty Stock Opname';
        $this->data['qOpname'] = $this->db->query($SqlOpname);
        $this->data['qValidateOpname'] = $this->db->query($SqlValidateOpname);
        $this->data['qDeleteOpname'] = $SqlDestroyOpname;
        $this->data['DateOpname'] = $DatePeriod;
        $this->data['SelLocation'] = $SelLocation;
        $this->data['RowLocation'] = $this->db->get_where('TAccWHLocation', ['wh_id' => $SelLocation])->row();
        $this->data['selCatType'] = $selCatType;
        $this->data['ItemCategoryTypeTxt'] = $this->ItemCategoryType[$selCatType];
        $this->data['Gudang'] = $Gudang;
        $this->data['RowGudang'] = $this->db->get_where('taccwhbin', ['bin_id' => $Gudang])->row();
        $this->data['item_code'] = $item_code;

        $this->load->view('Opname/generateopname', $this->data);
    }

    public function select2_category()
    {
        $selCatType = $this->input->get('selCatType');
        $search = $this->input->get('search');
        $sqlSearch = "";
        if (!empty($search)) {
            $sqlSearch = " AND ItemCategory_name like '%$search%' ";
        }

        $query = $this->db->query("SELECT *
        FROM TItemCategory 
        WHERE ItemCategoryType = '$selCatType'
        $sqlSearch
        AND Depth = 0
        AND ItemCategory_Status = 1
        AND Company_ID = 2 
        ORDER BY ItemCategory_name ASC");

        if ($query->num_rows() > 0) {
            $list = array();
            $list[1]['id'] = 'ALL';
            $list[1]['text'] = 'ALL Category';
            $key = 2;
            foreach ($query->result_array() as $row) {
                $list[$key]['id'] = $row['ItemCategory_id'];
                $list[$key]['text'] = $row['ItemCategory_name'];
                $key++;
            }
            echo json_encode($list);
        } else {
            echo "hasil kosong";
        }
    }

    public function select2_bin()
    {
        $location = $this->input->get('location');
        $search = $this->input->get('search');
        $sqlSearch = "";
        if (!empty($search)) {
            $sqlSearch = " AND bin_name like '%$search%' ";
        }

        $query = $this->db->query("SELECT bin_id, bin_name from taccwhbin 
        where wh_id IN ($location) 
        $sqlSearch
        order by bin_name");

        if ($query->num_rows() > 0) {
            $list = array();
            $key = 1;
            foreach ($query->result_array() as $row) {
                $list[$key]['id'] = $row['bin_id'];
                $list[$key]['text'] = $row['bin_name'];
                $key++;
            }
            echo json_encode($list);
        } else {
            echo "hasil kosong";
        }
    }
}
