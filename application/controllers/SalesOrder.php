<?php
defined('BASEPATH') or exit('No direct script access allowed');

class SalesOrder extends CI_Controller
{
    private $Date;
    private $DateTime;
    private $layout = 'layout';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->HR = $this->load->database('HR', TRUE);
        $this->Date = date("Y-m-d");
        $this->DateTime = date("Y-m-d H:i:s");
        $this->load->model('m_helper', 'help');
        $this->load->model('m_DataTable', 'M_Datatables');
    }

    public function index()
    {
        $this->data['page_title'] = "Sales Order";
        $this->data['page_content'] = "SalesOrder/index";

        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/salesorder/index.js?v=' . time() . '""></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function add()
    {
        $this->data['page_title'] = "Add Sales Order";
        $this->data['page_content'] = "SalesOrder/add";
        $this->data['rdoAllocate'] = $this->input->post('rdoAllocate') ?? 1;
        $this->data['rbTypedoc'] = $this->input->post('rbTypedoc') ?? 0;

        // 2. Cukup tangkap nilai Quotation
        $selQuotation = $this->input->post('selQuotation');
        $this->data['selQuotation'] = $selQuotation;

        // 3. Ambil Source Date HANYA untuk Quotation
        $sourceDate = "";
        if (!empty($selQuotation)) {
            // Ambil data dari tabel Quotation
            $q = $this->db->get_where('TACCQUOTATION_HEADER', [
                'quotation_number' => $selQuotation
            ])->row();

            // Format tanggal jika data ditemukan
            $sourceDate = $q ? date('d M Y', strtotime($q->Quotation_Date)) : "";
        }

        $this->data['SourceDate'] = $sourceDate;

        // Step Proforma (Step 4) dibuang karena tidak akan pernah terpakai
        $this->data['selProforma'] = "";
        $this->data['ddlSalesContract'] = "";
        $this->data['txtExpDelDate'] = "";


        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/salesorder/add.js?v=' . time() . '""></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function pickitem()
    {
        // Tidak ada olah data di sini, langsung lempar ke view
        $this->load->view('SalesOrder/pickitem_view');
    }

    public function DT_list_sales_order()
    {
        $requestData = $_REQUEST;
        $columns = array(
            0 => 'SO_Number',
            1 => 'SO_Number',
            2 => 'Account_Name',
            3 => 'PO_NumCustomer',
            4 => 'SO_Date',
            5 => 'Doc_Status',
            6 => 'SO_Status',
            7 => 'Approval_Status',
            8 => 'Invoice_Status',
            9 => 'isNotActive',
            10 => 'PO_NumCustomer',
            11 => 'isClose',
            12 => 'Doc_Status'
        );
        $order  = $columns[$requestData['order']['0']['column']];
        $dir    = $requestData['order']['0']['dir'];
        $from   = $this->input->post('from');
        $until  = $this->input->post('until');

        $sql = "SELECT 	TAccSO_Header.SO_Number,
			TAccSO_Header.SO_Date,
			TAccSO_Header.Approval_Status,
			TAccSO_Header.Invoice_Status,
			TAccSO_Header.SO_Status,
			TAccSO_Header.SN_Status,
			TAccSO_Header.isNotActive,
			TAccount.AccountTitle_Code,
			TAccount.Account_Name,
			isnull(TAccSO_Header.ReviseCounter,0) as ReviseCounter,
			TAccSO_Header.PO_NumCustomer,
            isClose, Doc_Status
            FROM 	TAccSO_Header, TAccount
            WHERE	TAccSO_Header.Account_ID = TAccount.Account_ID 
            AND 	TAccSO_Header.Company_ID = 2
            And 	TAccSO_Header.SO_Date >= {ts '$from 00:00:00'}
            And 	TAccSO_Header.SO_Date <= {ts '$until 23:59:59'} ";

        $totalData = $this->db->query($sql)->num_rows();
        if (!empty($requestData['search']['value'])) {
            $sql .= " AND (TAccSO_Header.SO_Number LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR TAccount.Account_Name LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR TAccSO_Header.PO_NumCustomer LIKE '%" . $requestData['search']['value'] . "%') ";
        }
        //----------------------------------------------------------------------------------
        $totalFiltered = $this->db->query($sql)->num_rows();
        $sql .= " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";
        $query = $this->db->query($sql);
        $data = array();
        foreach ($query->result_array() as $row) {
            $nestedData = array();
            $nestedData['SO_Number'] = $row['SO_Number'];
            $nestedData['SO_Date'] = $row['SO_Date'];
            $nestedData['Approval_Status'] = $row['Approval_Status'];
            $nestedData['Invoice_Status'] = $row['Invoice_Status'];
            $nestedData['SO_Status'] = $row['SO_Status'];
            $nestedData['SN_Status'] = $row['SN_Status'];
            $nestedData['isNotActive'] = $row['isNotActive'];
            $nestedData['AccountTitle_Code'] = $row['AccountTitle_Code'];
            $nestedData['Account_Name'] = $row['Account_Name'];
            $nestedData['ReviseCounter'] = $row['ReviseCounter'];
            $nestedData['PO_NumCustomer'] = $row['PO_NumCustomer'];
            $nestedData['isClose'] = $row['isClose'];
            $nestedData['Doc_Status'] = $row['Doc_Status'];

            $data[] = $nestedData;
        }
        //----------------------------------------------------------------------------------
        $json_data = array(
            "draw" => intval($requestData['draw']),
            "recordsTotal" => intval($totalData),
            "recordsFiltered" => intval($totalFiltered),
            "data" => $data,
        );
        //----------------------------------------------------------------------------------
        echo json_encode($json_data);
    }

    public function get_currency_rate()
    {
        // Ambil data dari input AJAX
        $selectedCurr = $this->input->get('curr'); // Misal: USD
        $baseCurrency = $this->input->cookie('currencyid') ?? 'IDR';
        $companyId    = 2; // Sesuai data uat Anda

        if ($selectedCurr == $baseCurrency) {
            echo "";
            return;
        }

        // Query MSSQL 2014
        // Kita ambil 'scale' sebagai rate-nya
        $this->db->select('scale');
        $this->db->from('TCurrencyConverter');
        $this->db->where('currency_id_1', $selectedCurr);
        $this->db->where('currency_id_2', $baseCurrency);
        $this->db->where('status', 1);
        $this->db->where('company_id', $companyId);

        // Logic Tanggal: Hari ini harus di antara start dan end date
        $today = date('Y-m-d H:i:s');
        $this->db->where("'$today' BETWEEN start_date AND end_date");

        // Ambil yang paling update
        $this->db->order_by('last_update', 'DESC');
        $this->db->limit(1);

        $query = $this->db->get();
        $data  = $query->row();

        if ($data) {
            $rate = $data->scale;

            // Format string untuk add.js Anda: 
            // Type|Currency|Rate;Type|Currency|Rate
            // Biasanya Rate Tax dan Amount sama, jika berbeda silakan sesuaikan logic-nya
            echo "Amount|$selectedCurr|$rate;Tax|$selectedCurr|$rate";
        } else {
            // Jika tidak ada rate yang ditemukan
            echo "";
        }
    }

    public function get_tax_list()
    {
        $sql = "SELECT DISTINCT Tax_ID, Tax_Code, Tax_Name, Tax_Rate, Tax_operator 
            FROM TaccTax 
            ORDER BY Tax_Name";
        $data = $this->db->query($sql)->result();
        return $this->output
            ->set_content_type('application/json')
            ->set_output(json_encode($data));
    }

    public function get_cc_list()
    {
        $companyID = 2; // Sesuai query Mas Yana
        $sql = "SELECT CostCenter_ID AS Comp_ID, CostCenter_Name_en AS Comp_Name 
            FROM TAccCostCenter 
            WHERE Company_ID = $companyID 
            AND CC_Type = 'CC'
            ORDER BY CostCenter_Name_en ASC";

        $data = $this->db->query($sql)->result();
        return $this->output
            ->set_content_type('application/json')
            ->set_output(json_encode($data));
    }

    public function store()
    {
        $this->db->trans_begin(); // Sesuai <cftransaction> di CF10

        $SoNum = $this->help->generate_so_number('TAccPattern', 'salesJournal', 'SONum', 'value', 2, 9, 'Trans'); // Panggil fungsi generate_so_number() dari M_helper
        var_dump($SoNum); // Debug: Tampilkan nomor SO yang dihasilkan
        die;

        try {
            $sonum = $this->input->post('SONum');
            $isConfirm = $this->input->post('txtconfirm'); // 'YES' atau 'NO'
            $task = $this->input->post('task'); // 'Add' atau 'Edit'

            // 1. Logika Revision (Jika Edit & Ada Revisi)
            if ($task == 'Edit' && $this->input->post('HIDREVISION') > 0) {
                // INSERT ke TAccSOHistory_Header (Select dari table aslinya)
                // INSERT ke TAccSOHistory_Detail (Select dari table aslinya)
            }

            // 2. Persiapkan Data Header
            $dataHeader = [
                'SO_Number'       => $sonum,
                'SO_Date'         => date('Y-m-d H:i:s', strtotime($this->input->post('txtSODate'))),
                'Account_ID'      => $this->input->post('txtCustCode'),
                'SO_Status'       => ($isConfirm == 'YES') ? 2 : 1,
                'Currency_ID'     => $this->input->post('SelCurrency'),
                'Invoice_Amount'  => str_replace(',', '', $this->input->post('txtTotAmount')),
                'Base_Invoice_Amount' => str_replace(',', '', $this->input->post('hidBaseTotAmount')),
                'Created_By'      => $this->session->userdata('CKSATRIADEVID'),
                'Update_By'       => $this->session->userdata('CKSATRIADEVID'),
                'Last_Update'     => date('Y-m-d H:i:s'),
                // Tambahkan field lainnya sesuai qadd.cfm
            ];

            if ($task == 'Edit') {
                $this->db->where('SO_Number', $sonum)->update('TAccSO_Header', $dataHeader);
                $this->db->where('SO_Number', $sonum)->delete('TAccSO_Detail'); // Bersihkan detail lama
            } else {
                $this->db->insert('TAccSO_Header', $dataHeader);
            }

            // 3. Logika Detail (Looping item)
            $rowCount = $this->input->post('rowCount');
            for ($i = 1; $i <= $rowCount; $i++) {
                if ($this->input->post("TXTPARTNO_$i")) {
                    $unitPrice = str_replace(',', '', $this->input->post("txtConvertedUnitPrice_$i"));
                    $qty = $this->input->post("txtQty_$i");

                    $dataDetail = [
                        'SO_Number'        => $sonum,
                        'Item_Code'        => $this->input->post("TXTPARTNO_$i"),
                        'Qty'              => $qty,
                        'UnitPrice'        => $unitPrice,
                        'Base_UnitPrice'   => $unitPrice * $this->input->post('rate'), // Contoh rate
                        'TotalPrice'       => str_replace(',', '', $this->input->post("txtConvertedAmount_$i")),
                        // ... sisanya samakan dengan qadd.cfm
                    ];
                    $this->db->insert('TAccSO_Detail', $dataDetail);
                }
            }

            // 4. Inventory Reservation (Jika Confirm)
            if ($isConfirm == 'YES') {
                // $this->reserve_inventory($sonum); // Buat fungsi private di bawah
            }

            if ($this->db->trans_status() === FALSE) {
                $this->db->trans_rollback();
                echo json_encode(["code" => 500, "msg" => "Gagal simpan database"]);
            } else {
                $this->db->trans_commit();
                echo json_encode(["code" => 200, "msg" => "Sales Order $sonum berhasil disimpan!"]);
            }
        } catch (Exception $e) {
            $this->db->trans_rollback();
            echo json_encode(["code" => 500, "msg" => $e->getMessage()]);
        }
    }
}
