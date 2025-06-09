<?php

// application/models/Customer_report_model.php
defined('BASEPATH') or exit('No direct script access allowed');

class Customer_report_model extends CI_Model
{

    public function getCurrency()
    {
        return $this->db->get('tcurrency')->result();
    }

    public function getAccounts($cbotype, $rdoView, $selAccount)
    {
        $this->db->distinct();
        $this->db->select('Account_ID, Account_Name, Account_Address1, AccountTitle_Code');
        $this->db->from('TACCOUNT');

        if ($cbotype === 'FG') {
            $this->db->where('Cust_FG', 1);
        }

        if ($rdoView !== 'all' && !empty($selAccount)) {
            $ids = explode(',', $selAccount); // pastikan ini dipisah dengan koma
            $this->db->where_in('Account_ID', $ids);
        }

        return $this->db->get()->result();
    }

    public function getSalesInvoiceTransactions($account_id, $selDocument = '')
    {
        if ($selDocument !== '' && $selDocument !== 'SalesInvoice') return [];

        $sql = "SELECT
                    h.invoice_number,
                    h.invoiceprintnumber,
                    h.invoice_date,
                    h.currency_id,
                    h.invoice_id,
                    so.PO_NumCustomer,
                    d.item_code,
                    ISNULL(d.qty,0) as qty,
                    ISNULL(d.unitprice,0) as unitprice,
                    ISNULL(d.disc_percentage,0) as disc_percentage,
                    ISNULL(d.disc_value,0) as disc_value,
                    d.tax_code1,
                    d.tax_code2,
                    i.item_name,
                    i.customfield1 as item_type,
                    i.item_size as brand,
                    col.color_name,
                    h.so_number,
                    CASE WHEN h.Ori_Invoice_Amount = 0 THEN 0
                         ELSE dbo.fnc_calcsalesreport(d.qty, d.unitprice, h.Ori_Invoice_Amount, h.claimdeduction, 1.0)
                    END as claimdeduction,
                    CASE WHEN h.Ori_Base_Invoice_Amount = 0 THEN 0
                         ELSE dbo.fnc_calcsalesreport(d.qty, d.unitprice, h.Ori_Invoice_Amount, h.claimdeduction, h.base_invoice_amount/h.invoice_amount)
                    END as base_claimdeduction
                FROM taccsi_header h
                JOIN taccsi_detail d ON h.invoice_id = d.invoice_id
                LEFT JOIN taccso_header so ON h.so_id = so.so_id
                LEFT JOIN titem i ON d.item_code = i.item_code
                LEFT JOIN tgscolor col ON i.color_id = col.color_id
                WHERE h.account_id = ?";

        $query = $this->db->query($sql, [$account_id]);
        return $query->result();
    }
}
