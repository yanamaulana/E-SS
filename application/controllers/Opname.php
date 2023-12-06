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
