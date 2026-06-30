<?php
defined('BASEPATH') or exit('No direct script access allowed');

class RND extends CI_Controller
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
        $this->load->helper('download');
    }

    /**
     * AG Report - BOM Detail AG
     */
    public function bom_ag()
    {
        $this->data['page_title'] = "RND Report - BOM Detail AG";
        $this->data['page_content'] = "Report/RND/bom_report";
        $this->data['report_type'] = 'AG';
        $this->data['script_page'] = '<script src="' . base_url() . 'assets/Report/RND/bom_report.js"></script>';

        $this->load->view($this->layout, $this->data);
    }

    /**
     * EG Report - BOM Detail EG
     */
    public function bom_eg()
    {
        $this->data['page_title'] = "RND Report - BOM Detail EG";
        $this->data['page_content'] = "Report/RND/bom_report";
        $this->data['report_type'] = 'EG';
        $this->data['script_page'] = '<script src="' . base_url() . 'assets/Report/RND/bom_report.js"></script>';

        $this->load->view($this->layout, $this->data);
    }

    /**
     * Guitar Report Page
     */
    public function guitar_report()
    {
        $this->data['page_title'] = "RND Guitar Report - BOM Detail";
        $this->data['page_content'] = "Report/RND/guitar_report";
        $this->data['script_page'] = '';

        $this->load->view($this->layout, $this->data);
    }

    /**
     * Download Report as XLSX
     */
    public function download_xlsx()
    {
        $report_type = $this->input->get('type'); // 'AG' or 'EG'

        if (!in_array($report_type, ['AG', 'EG'])) {
            show_404();
        }

        // Get data based on report type
        $data = $this->get_report_data($report_type);

        // Load PHPExcel library
        $this->load->library('PHPExcel');

        $objPHPExcel = new PHPExcel();
        $objPHPExcel->setActiveSheetIndex(0);
        $objSheet = $objPHPExcel->getActiveSheet();

        // Set column headers
        $headers = [
            'BOM_CODE',
            'ITEM_CODE',
            'Item_size (Brand)',
            'Color_Name',
            'CustomField1',
            'item_length',
            'item_width',
            'item_height',
            'Item_Name',
            'RM_CODE',
            'RM_Name',
            'RM_CustomField1',
            'LINE'
        ];

        $col = 'A';
        foreach ($headers as $header) {
            $objSheet->setCellValue($col . '1', $header);
            $col++;
        }

        // Add data rows
        $row = 2;
        foreach ($data as $item) {
            $col = 'A';
            $objSheet->setCellValue($col . $row, $item->BOM_CODE);
            $col++;
            $objSheet->setCellValue($col . $row, $item->ITEM_CODE);
            $col++;
            $objSheet->setCellValue($col . $row, $item->Brand);
            $col++;
            $objSheet->setCellValue($col . $row, $item->Color_Name);
            $col++;
            $objSheet->setCellValue($col . $row, $item->CustomField1);
            $col++;
            $objSheet->setCellValue($col . $row, $item->item_length);
            $col++;
            $objSheet->setCellValue($col . $row, $item->item_width);
            $col++;
            $objSheet->setCellValue($col . $row, $item->item_height);
            $col++;
            $objSheet->setCellValue($col . $row, $item->Item_Name);
            $col++;
            $objSheet->setCellValue($col . $row, $item->rm_code);
            $col++;
            $objSheet->setCellValue($col . $row, $item->Item_Name);
            $col++;
            $objSheet->setCellValue($col . $row, $item->CustomField1);
            $col++;
            $objSheet->setCellValue($col . $row, $item->LINE);
            $row++;
        }

        // Auto-size columns
        for ($col = 'A'; $col !== 'N'; $col++) {
            $objSheet->getColumnDimension($col)->setAutoSize(true);
        }

        // Set filename
        $filename = 'BOM_Report_' . $report_type . '_' . date('Y-m-d_His') . '.xlsx';

        // Output the file
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment;filename="' . $filename . '"');
        header('Cache-Control: max-age=0');
        header('Cache-Control: max-age=1');
        header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
        header('Last-Modified: ' . gmdate('D, d M Y H:i:s') . ' GMT');
        header('Cache-Control: cache, must-revalidate');
        header('Pragma: public');

        $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
        $objWriter->save('php://output');
    }

    /**
     * Download Report as CSV
     */
    public function download_csv()
    {
        $report_type = $this->input->get('type'); // 'AG' or 'EG'

        if (!in_array($report_type, ['AG', 'EG'])) {
            show_404();
        }

        // Get data based on report type
        $data = $this->get_report_data($report_type);

        // Create CSV content
        $csv_content = '';
        $headers = [
            'BOM_CODE',
            'ITEM_CODE',
            'Item_size (Brand)',
            'Color_Name',
            'CustomField1',
            'item_length',
            'item_width',
            'item_height',
            'Item_Name',
            'RM_CODE',
            'RM_Name',
            'RM_CustomField1',
            'LINE'
        ];

        $csv_content .= implode(',', $headers) . "\n";

        foreach ($data as $item) {
            $row = [
                $this->escape_csv($item->BOM_CODE),
                $this->escape_csv($item->ITEM_CODE),
                $this->escape_csv($item->Brand),
                $this->escape_csv($item->Color_Name),
                $this->escape_csv($item->CustomField1),
                $this->escape_csv($item->item_length),
                $this->escape_csv($item->item_width),
                $this->escape_csv($item->item_height),
                $this->escape_csv($item->Item_Name),
                $this->escape_csv($item->rm_code),
                $this->escape_csv($item->Item_Name),
                $this->escape_csv($item->CustomField1),
                $this->escape_csv($item->LINE)
            ];
            $csv_content .= implode(',', $row) . "\n";
        }

        // Set filename
        $filename = 'BOM_Report_' . $report_type . '_' . date('Y-m-d_His') . '.csv';

        // Output the file
        $this->output
            ->set_content_type('text/csv; charset=utf-8')
            ->set_header('Content-Disposition: attachment; filename="' . $filename . '"')
            ->set_output($csv_content);
    }

    /**
     * Get report data based on type
     */
    private function get_report_data($type)
    {
        $category_id = ($type == 'AG') ? 8 : 5;

        $query = "SELECT 
                    h.*, 
                    d.*, 
                    i.Item_size as Brand, 
                    cl.Color_Name, 
                    i.CustomField1, 
                    i.item_length, 
                    i.item_width, 
                    i.item_height, 
                    i.Item_Name, 
                    ii.Item_Name, 
                    ii.CustomField1
                FROM 
                    TPPICITEMBOM_DETAIL d
                INNER JOIN TPPICITEMBOM h ON d.BOM_CODE = h.BOM_CODE
                INNER JOIN Titem i ON i.Item_Code = h.ITEM_CODE
                INNER JOIN Titem ii ON ii.Item_Code = d.rm_code
                LEFT JOIN TGSColor cl ON i.Item_color = cl.Color_Code
                LEFT JOIN TItemCompany C ON C.item_code = i.Item_Code
                LEFT JOIN TItemCategory CT ON C.ItemCategory_Id = ct.ItemCategory_id
                WHERE 
                    CT.ItemCategory_id IN (" . $category_id . ")
                ORDER BY CT.ItemCategory_id ASC";

        $result = $this->db->query($query);
        return $result->result();
    }

    /**
     * Escape CSV field
     */
    private function escape_csv($field)
    {
        if (strpos($field, ',') !== false || strpos($field, '"') !== false || strpos($field, "\n") !== false) {
            $field = '"' . str_replace('"', '""', $field) . '"';
        }
        return $field;
    }
}
