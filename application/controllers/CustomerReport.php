<?php
defined('BASEPATH') or exit('No direct script access allowed');

class CustomerReport extends CI_Controller
{

    public function index()
    {
        $this->load->view('Report/Sales/customer_report_view');
    }
}
