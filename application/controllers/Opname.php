<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Opname extends CI_Controller
{
    private $Day;
    private $Date;
    private $layout = 'layout';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->Day = date("l");
        $this->Date = date("Y-m-d");
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
        if (!empty($item_code)) {
            $sqlItem = " AND ((UPPER(TItem.Item_Code) LIKE UPPER('$item_code'))) ";
        }

        $SqlOpname = "SELECT TItem.Item_Code, TItemCompany.ItemCategory_ID, TItemCategory.ItemCategory_NAme, Item_Name, TItemWHBin.Item_Qty,
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
        AND TItemCompany.Itemcategory_ID in ('$Category') $sqlItem
        AND TItem.item_code in(SELECT DISTINCT ITEM_CODE FROM TDATAGROUPITEM WHERE DATAGROUP_ID IN (20,86)) 
        ORDER BY TItemWHBin.Item_Qty DESC";

        $this->data['qOpname'] = $this->db->query($SqlOpname);
        $this->data['DateOpname'] = $DatePeriod;

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
