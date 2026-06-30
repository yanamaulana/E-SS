<?php
defined('BASEPATH') or exit('No direct script access allowed');

class RND extends CI_Controller
{
    private $layout = 'layout';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
    }

    /**
     * Menampilkan halaman utama untuk laporan RND Gitar.
     */
    public function guitar_report()
    {
        $this->data['page_title'] = "RND Guitar Report";
        $this->data['page_content'] = "Report/RND/guitar_report";
        $this->data['script_page'] =  ''; // Tidak ada javascript khusus

        $this->load->view($this->layout, $this->data);
    }

    /**
     * Menangani proses download laporan dalam format CSV.
     * Menggunakan metode chunking (OFFSET/FETCH) untuk menangani dataset besar
     * tanpa menyebabkan memory exhaustion.
     *
     * @param string $type Tipe laporan ('ag' untuk Acoustic, 'eg' untuk Electric).
     */
    public function download_report($type)
    {
        $category_id = 0;
        $filename = 'RND_BOM_Report.csv';

        if ($type == 'ag') {
            $category_id = 8;
            $filename = 'RND_BOM_Report_AG_' . date('Y-m-d') . '.csv';
        } elseif ($type == 'eg') {
            $category_id = 5;
            $filename = 'RND_BOM_Report_EG_' . date('Y-m-d') . '.csv';
        } else {
            show_error('Tipe laporan tidak valid.', 400);
            return;
        }

        // Set header untuk download CSV
        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename="' . $filename . '"');

        $base_sql = "
            SELECT 
                h.BOM_ID, h.BOM_CODE, h.ITEM_CODE, h.ITEM_NAME, h.UPDATED_BY, h.LAST_UPDATE, h.Company_ID, h.Dimension_Id, h.bom_type, h.total_work_day, h.currency_id, h.cost, h.loss_percentage, h.salary_curr, h.salary, h.prod_curr, h.prod_cost, h.umr_salary, h.prod_cost_percentage, h.total_loss, h.inactive, h.Approve_Date, h.Approval_Status,
                d.BOMDETAIL_ID, d.RM_CODE, d.RM_QTY, d.RM_UNITTYPEID, d.section_id, d.dimension_id as RM_Dimension_ID, d.currency_id as RM_Currency_ID, d.cost as RM_Cost, d.[group] as RM_Group, d.account_id as RM_Account_ID, d.item_convertion, d.is_accessories, d.is_expensive_parts, d.loss_percentage as RM_Loss_Percentage, d.comp_loss_percentage,
                i.Item_size as Brand, 
                cl.Color_Name, 
                i.CustomField1 as Header_Item_Type, 
                i.item_length, 
                i.item_width, 
                i.item_height, 
                i.Item_Name as Header_Item_Name, 
                ii.Item_Name as RM_Item_Name, 
                ii.CustomField1 as RM_Item_Type 
            FROM TPPICITEMBOM_DETAIL d 
            INNER JOIN TPPICITEMBOM h ON d.BOM_CODE = h.BOM_CODE 
            INNER JOIN Titem i ON i.Item_Code = h.ITEM_CODE 
            INNER JOIN Titem ii ON ii.Item_Code = d.rm_code 
            LEFT JOIN TGSColor cl ON i.Item_color = cl.Color_Code 
            LEFT JOIN TItemCompany C ON C.item_code = i.Item_Code 
            LEFT JOIN TItemCategory CT ON C.ItemCategory_Id = ct.ItemCategory_id 
            WHERE CT.ItemCategory_id = ?
            ORDER BY h.BOM_CODE, d.BOMDETAIL_ID
        ";

        $handle = fopen('php://output', 'w');
        $header_written = false;
        $offset = 0;
        $limit = 2000; // Proses 2000 baris data per iterasi

        while (true) {
            $chunk_sql = $base_sql . " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
            $query = $this->db->query($chunk_sql, [$category_id, $offset, $limit]);

            if ($query->num_rows() == 0) {
                break; // Berhenti jika tidak ada data lagi
            }

            $results = $query->result_array();

            if (!$header_written && !empty($results)) {
                fputcsv($handle, array_keys($results[0]));
                $header_written = true;
            }

            foreach ($results as $row) {
                fputcsv($handle, $row);
            }

            $query->free_result();

            if (count($results) < $limit) {
                break; // Halaman terakhir
            }

            $offset += $limit;
        }

        fclose($handle);
        exit;
    }
}
