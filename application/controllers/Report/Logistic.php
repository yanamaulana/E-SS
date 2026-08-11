<?php
defined('BASEPATH') or exit('No direct script access allowed');

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Style\NumberFormat;

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
        $this->data['page_title'] = "Comparison Price Last Year";
        $this->data['page_content'] = "Report/Logistic/price_compare_year";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Report/Logistic/price_compare_year.js"></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function rpt_comparison_price_last_year()
    {
        $Year = $this->input->get('year');
        // $Month = $this->input->get('month');
        $thisMonth = date('m');

        $this->data['Year'] = $Year;
        $this->data['Year_Minus'] = floatval($Year) - 1;
        // $this->data['Month'] = $Month;
        $this->data['thisMonth'] = $thisMonth;
        $this->data['DataSql'] = $this->db->query("
        Select Item_Code, Item_Name, ItemCategory_Name, Item_Type, Item_Color, Color_Name, Item_Size, Item_Length, Item_Width, Item_Height, Unit_Name,
		RR_Number, RR_Date, Qty, Currency_ID, CurrencyRateList, UnitPrice, (Qty * UnitPrice) as total_price , WhBin, Bin_Name
        FROM (
            SELECT 
                TAccRR_Item.Item_Code, 
                TItem.Item_Name, 
                TItemCategory.ItemCategory_Name,
                TItem.CustomField1 AS Item_Type, 
                TItem.Item_Color, 
                TItemColor.Color_Name, 
                TItem.Item_Size, 
                TItem.Item_Length, 
                TItem.Item_Width, 
                TItem.Item_Height,
                TAccUnitType.Unit_Name, 
                TAccPO_Header.Currency_ID, 
                TAccPO_Header.CurrencyRateList,
                TAccRR_Header.RR_Number, 
                TAccRR_Header.RR_Date, 
                TAccRR_Item.Qty, 
                TAccPO_Detail.UnitPrice,
                CASE 
                    WHEN CHARINDEX('|', TAccRR_Item.LstBinQty) > 0 THEN LEFT(TAccRR_Item.LstBinQty, CHARINDEX('|', TAccRR_Item.LstBinQty) - 1)
                    ELSE TAccRR_Item.LstBinQty
                END AS WhBin,
                ROW_NUMBER() OVER (PARTITION BY TAccRR_Item.Item_Code ORDER BY TAccRR_Header.RR_Date DESC) AS rn
            FROM TAccRR_Item
            JOIN TAccRR_Header ON TAccRR_Item.RR_Number = TAccRR_Header.RR_Number
            JOIN TItem ON TAccRR_Item.Item_Code = TItem.Item_Code
            LEFT JOIN TItemCompany ON TItem.Item_Code = TItemCompany.item_code 
            LEFT JOIN TItemCategory ON TITEMCompany.ItemCategory_ID = TItemCategory.ItemCategory_ID
            LEFT JOIN TAccUnitType ON TAccRR_Item.Unit_Type_ID = TAccUnitType.Unit_Type_ID 
            LEFT JOIN TItemDimension ON TItemDimension.Dimension_ID = TAccRR_Item.Dimension_ID	
            LEFT JOIN TItemColor ON TItemColor.Color_ID = TItemDimension.Color_ID
            LEFT JOIN TAccPO_Detail ON TAccRR_Header.Ref_Number = TAccPO_Detail.PO_Number AND TAccRR_Item.Item_Code = TAccPO_Detail.Item_Code
            LEFT JOIN TAccPO_Header ON TAccPO_Detail.PO_Number  = TAccPO_Header.PO_Number
            WHERE TAccRR_Item.Qty > 0 
            AND YEAR(TAccRR_Header.RR_Date) = '$Year' 
            AND Month(TAccRR_Header.RR_Date) <> '$thisMonth'
            AND TAccRR_Header.isVoid = 0 
            AND TAccRR_Header.Approval_Status = 3 
            AND TAccRR_Header.RR_Status = 3
            AND TAccPO_Header.Approval_Status = 3
            AND TAccPO_Header.PO_Status = 3
        ) Qview_Summary_Pembelian_Perbulan
        left join TAccWHBin on Qview_Summary_Pembelian_Perbulan.WhBin = TAccWHBin.Bin_ID
        where WhBin not in (79,80,81,82,83,84,117,101,102,103,104,105,46,9,85,90,91,92,93,94,106,116,26,37,86,53,58,63,68,87,88,89,95,96,'')
        order by Item_Code , RR_Date;
        ")->result();

        $this->load->view('Report/Logistic/Rpt_item_price_comparison', $this->data);
    }

    public function upload_tax_invoice()
    {
        $this->data['page_title'] = "Upload Faktur Pajak";
        $this->data['page_content'] = "Report/Logistic/upload_tax_invoice_view";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Report/Logistic/upload_tax_invoice.js"></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function template_faktur_pajak()
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();

        // 1. Set Judul Kolom
        $sheet->setCellValue('A1', 'Invoice_Number');
        $sheet->setCellValue('B1', 'TaxDocNumber');
        $sheet->setCellValue('C1', 'TaxDate');
        $sheet->setCellValue('D1', 'Notes');

        // 2. Mengatur Format Kolom menjadi Teks
        // Ini penting agar nomor faktur yang panjang atau tanggal tidak otomatis diubah formatnya oleh Excel.
        $sheet->getStyle('A:A')->getNumberFormat()->setFormatCode(NumberFormat::FORMAT_TEXT);
        $sheet->getStyle('B:B')->getNumberFormat()->setFormatCode(NumberFormat::FORMAT_TEXT);
        $sheet->getStyle('C:C')->getNumberFormat()->setFormatCode(NumberFormat::FORMAT_TEXT);
        $sheet->getStyle('D:D')->getNumberFormat()->setFormatCode(NumberFormat::FORMAT_TEXT);

        // 3. Mengatur Lebar Kolom secara Otomatis
        $sheet->getColumnDimension('A')->setAutoSize(true);
        $sheet->getColumnDimension('B')->setAutoSize(true);
        $sheet->getColumnDimension('C')->setAutoSize(true);
        $sheet->getColumnDimension('D')->setAutoSize(true);

        // 4. Menyiapkan file untuk di-download
        $filename = 'template_upload_faktur_pajak.xlsx';
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment;filename="' . $filename . '"');
        header('Cache-Control: max-age=0');

        $writer = new Xlsx($spreadsheet);
        $writer->save('php://output');
        exit;
    }

    public function process_upload_tax_invoice()
    {
        // 1. Pastikan request berasal dari AJAX
        if (!$this->input->is_ajax_request()) {
            echo json_encode(['status' => 'error', 'message' => 'Akses tidak sah.']);
            return;
        }

        // 2. Validasi apakah ada file yang diunggah
        if (empty($_FILES['file_excel']['name'])) {
            echo json_encode(['status' => 'error', 'message' => 'Pilih file Excel terlebih dahulu!']);
            return;
        }

        $file_tmp = $_FILES['file_excel']['tmp_name'];
        $file_ext = pathinfo($_FILES['file_excel']['name'], PATHINFO_EXTENSION);

        // 3. Validasi Ekstensi File
        $allowed_ext = ['xls', 'xlsx'];
        if (!in_array(strtolower($file_ext), $allowed_ext)) {
            echo json_encode(['status' => 'error', 'message' => 'Format file tidak didukung! Gunakan .xls atau .xlsx']);
            return;
        }

        $this->db->trans_start(); // Mulai transaksi database

        try {
            $reader = IOFactory::createReaderForFile($file_tmp);
            $reader->setReadDataOnly(true); // Membaca data saja agar lebih cepat
            $spreadsheet = $reader->load($file_tmp);
            $sheetData = $spreadsheet->getActiveSheet()->toArray(null, true, true, true);

            $data_to_insert = [];
            $errors = [];
            $row_num = 1; // Untuk pelacakan baris di Excel

            $datetime = $this->DateTime; // Gunakan satu variabel datetime untuk semua record
            $created_by = $this->session->userdata('sys_sba_userid');

            // --- OPTIMASI VALIDASI INVOICE ---
            // 1. Kumpulkan semua nomor invoice dari Excel terlebih dahulu.
            $invoice_numbers_from_excel = [];
            foreach ($sheetData as $index => $row) {
                if ($index === 1) continue; // Lewati header
                $invoice_number = trim($row['A'] ?? '');
                if (!empty($invoice_number)) {
                    $invoice_numbers_from_excel[] = $invoice_number;
                }
            }

            // 2. Lakukan satu query 'WHERE IN' untuk mendapatkan invoice yang valid dari database.
            $validated_invoices_map = [];
            if (!empty($invoice_numbers_from_excel)) {
                $unique_invoices = array_unique($invoice_numbers_from_excel);
                $query = $this->db->select('Invoice_Number')->where_in('Invoice_Number', $unique_invoices)->get('TAccVI_Header');
                $validated_invoices = $query->result_array();
                // Buat map untuk pencarian cepat (O(1) lookup)
                $validated_invoices_map = array_flip(array_column($validated_invoices, 'Invoice_Number'));
            }
            // --- AKHIR OPTIMASI ---

            foreach ($sheetData as $index => $row) {
                if ($index === 1) { // Skip header row (assuming header is in row 1)
                    $row_num++;
                    continue;
                }

                $invoice_number = trim($row['A'] ?? ''); // Kolom A
                $tax_doc_number = trim($row['B'] ?? ''); // Kolom B
                $tax_date_str = trim($row['C'] ?? '');   // Kolom C
                $notes = trim($row['D'] ?? '');          // Kolom D

                // Skip empty rows
                if (empty($invoice_number) && empty($tax_doc_number) && empty($tax_date_str)) {
                    $row_num++;
                    continue;
                }

                // Validation 1: Invoice_Number must exist in TAccVI_Header
                if (empty($invoice_number)) {
                    $errors[] = "Baris {$row_num}: Kolom 'Invoice_Number' tidak boleh kosong.";
                } elseif (!isset($validated_invoices_map[$invoice_number])) { // Cek ke map yang sudah divalidasi
                    $errors[] = "Baris {$row_num}: 'Invoice_Number' ({$invoice_number}) tidak ditemukan di TAccVI_Header.";
                }

                // Validation 2: TaxDocNumber must not contain letters
                if (empty($tax_doc_number)) {
                    $errors[] = "Baris {$row_num}: 'TaxDocNumber' tidak boleh kosong.";
                } elseif (preg_match('/[a-zA-Z]/', $tax_doc_number)) {
                    $errors[] = "Baris {$row_num}: 'TaxDocNumber' ({$tax_doc_number}) mengandung huruf. Hanya angka yang diizinkan.";
                }

                // Validation 3: TaxDate format (YYYY-MM-DD)
                if (empty($tax_date_str)) {
                    $errors[] = "Baris {$row_num}: 'TaxDate' tidak boleh kosong.";
                } else {
                    $date_obj = DateTime::createFromFormat('Y-m-d', $tax_date_str);
                    if ($date_obj === false || $date_obj->format('Y-m-d') !== $tax_date_str) {
                        $errors[] = "Baris {$row_num}: 'TaxDate' ({$tax_date_str}) tidak dalam format YYYY-MM-DD yang benar.";
                    }
                }

                // Validation 4: Notes must not contain special characters that need escaping
                if (preg_match('/[\'"]|\\\\/', $notes)) {
                    $errors[] = "Baris {$row_num}: Kolom 'Notes' mengandung karakter terlarang (seperti ', \", \\). Harap hapus karakter tersebut.";
                }

                // If no errors for this row, prepare for insertion
                if (empty($errors)) {
                    $data_to_insert[] = [
                        'Invoice_Number' => $invoice_number,
                        'TaxDocNumber' => $tax_doc_number,
                        'TaxDate' => $tax_date_str,
                        'Notes' => $notes, // Menggunakan nilai dari kolom D
                        'Created_By' => $created_by,
                        'Created_At' => $datetime
                    ];
                }
                $row_num++;
            }

            // If any errors occurred, rollback and return all errors
            if (!empty($errors)) {
                $this->db->trans_rollback();
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Validasi data gagal. Semua transaksi dibatalkan.',
                    'details' => $errors
                ]);
                return;
            }

            // If no data to insert (e.g., only header or empty rows)
            if (empty($data_to_insert)) {
                $this->db->trans_rollback(); // Still rollback if transaction was started
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Tidak ada data valid yang ditemukan di file Excel untuk diunggah.'
                ]);
                return;
            }

            // Perform batch insert
            $this->db->insert_batch('TAccVI_TaxDetail', $data_to_insert);

            $this->db->trans_complete(); // Selesaikan transaksi

            if ($this->db->trans_status() === FALSE) {
                // Transaction failed
                $error_message = $this->db->error()['message'] ?? 'Terjadi kesalahan database yang tidak diketahui.';
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Gagal menyimpan data ke database. Transaksi dibatalkan.',
                    'details' => $error_message
                ]);
            } else {
                // Transaction successful
                echo json_encode([
                    'status' => 'success',
                    'message' => count($data_to_insert) . ' nomor faktur pajak berhasil diunggah dan disimpan!'
                ]);
            }
        } catch (\PhpOffice\PhpSpreadsheet\Reader\Exception $e) {
            $this->db->trans_rollback(); // Rollback in case of spreadsheet reading error
            echo json_encode([
                'status' => 'error',
                'message' => 'Gagal membaca file Excel: ' . $e->getMessage()
            ]);
        } catch (Exception $e) {
            $this->db->trans_rollback(); // Rollback for any other unexpected errors
            echo json_encode([
                'status' => 'error',
                'message' => 'Terjadi kesalahan sistem: ' . $e->getMessage()
            ]);
        }
    }
}
// ---------------------------- query lama
// Select Item_Code, Item_Name, ItemCategory_Name, Item_Type, Item_Color, Color_Name, Item_Size,
//                     Item_Length, Item_Width, Item_Height, Unit_Name, Currency_ID, SUM(Qty) as Sum_Qty_RR, UnitPrice, (SUM(Qty) * UnitPrice) as total_price , WhBin, Bin_Name
//                     from (
//                     select TAccRR_Item.Item_Code, TItem.Item_Name, TItemCategory.ItemCategory_Name,
//                     TItem.CustomField1 AS Item_Type, TItem.Item_Color, TItemColor.Color_Name, TItem.Item_Size, TItem.Item_Length, TItem.Item_Width, TItem.Item_Height,
//                     TAccUnitType.Unit_Name, TAccPO_Header.Currency_ID, TAccRR_Item.Qty, TAccPO_Detail.UnitPrice,
//                     CASE 
//                         WHEN CHARINDEX('|', TAccRR_Item.LstBinQty) > 0 THEN LEFT(TAccRR_Item.LstBinQty, CHARINDEX('|', TAccRR_Item.LstBinQty) - 1)
//                         ELSE LstBinQty
//                     END AS WhBin
//                     from TAccRR_Item
//                     join TAccRR_Header on TAccRR_Item.RR_Number = TAccRR_Header.RR_Number
//                     join TItem on TAccRR_Item.Item_Code = TItem.Item_Code
//                     left join TItemCompany on TItem.Item_Code = TItemCompany.item_code 
//                     left join TItemCategory on TITEMCompany.ItemCategory_ID = TItemCategory.ItemCategory_ID
//                     left join TAccUnitType on TAccRR_Item.Unit_Type_ID = TAccUnitType.Unit_Type_ID 
//                     left JOIN TItemDimension ON TItemDimension.Dimension_ID = TAccRR_Item.Dimension_ID	
//                     left JOIN TItemColor ON TItemColor.Color_ID = TItemDimension.Color_ID
//                     left join TAccPO_Detail on TAccRR_Header.Ref_Number = TAccPO_Detail.PO_Number and TAccRR_Item.Item_Code = TAccPO_Detail.Item_Code
//                     left join TAccPO_Header on TAccPO_Detail.PO_Number  = TAccPO_Header.PO_Number
//                     where TAccRR_Item.Qty > 0 
//                     and YEAR(TAccRR_Header.RR_Date) = '$Year' 
//                     and Month(TAccRR_Header.RR_Date) <> '$thisMonth'
//                     and TAccRR_Header.isVoid = 0 
//                     and TAccRR_Header.Approval_Status = 3 
//                     and TAccRR_Header.RR_Status = 3
//                     and TAccPO_Header.Approval_Status = 3
// 					and TAccPO_Header.PO_Status = 3
//                     ) as Qview_Summary_Pembelian_Perbulan
//                     left join TAccWHBin on Qview_Summary_Pembelian_Perbulan.WhBin = TAccWHBin.Bin_ID
//                     where WhBin not in (79,80,81,82,83,84,117,101,102,103,104,105,46,9,85,90,91,92,93,94,106,116,26,37,86,53,58,63,68,87,88,89,95,96,'',NULL)
//                     group by Item_Code, Item_Name, ItemCategory_Name, Item_Type, Item_Color, Color_Name, Item_Size,
//                     Item_Length, Item_Width, Item_Height, Unit_Name, Currency_ID, UnitPrice , WhBin, Bin_Name
//                     order by Item_Code
