<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Navigation extends CI_Controller
{
    private $layout = 'layout';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
    }

    public function index()
    {
        $this->data['page_title'] = "Samick Report Navigation";
        $this->data['page_content'] = "Report/navigation";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Report/navigation.js"></script>';

        $this->load->view($this->layout, $this->data);
    }
}
