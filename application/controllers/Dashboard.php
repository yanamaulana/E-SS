<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Dashboard extends CI_Controller
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
        $this->data['page_title'] = "Dashboard";
        $this->data['page_content'] = "Dashboard/index";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/Dashboard/index.js"></script>';
        $this->data['date'] = date('Y-m-d');

        $this->load->view($this->layout, $this->data);
    }
}
