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

    public function add($task)
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
        $this->data['task'] = $task;


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
        // Pastikan transaksi dimulai sebelum panggil helper generate nomor
        $this->db->trans_begin();

        try {
            $task      = $this->input->post('task'); // 'new' atau 'edit'
            $isConfirm = $this->input->post('txtconfirm'); // 'YES' atau 'NO'

            // 1. GENERATE SO NUMBER (Hanya jika task 'new')
            if ($task == 'new') {
                $SoNum = $this->help->generate_so_number('TAccPattern', 'salesJournal', 'SONum', 'value', 2, 9, 'Trans');
            } else {
                $SoNum = $this->input->post('SO_NUMBER');
            }

            // Ambil Rate Kurs (Default 1 jika IDR/tidak ada)
            // Masih pake str_replace buat jaga-jaga kalau ada koma nyelip
            $rate = str_replace(',', '', $this->input->post('txtCurr_IDR') ?? 1);
            $userId = $this->session->userdata('sys_sba_userid');

            // 2. PREPARE DATA HEADER (TAccSO_Header)
            $dataHeader = [
                'SO_Number'           => $SoNum,
                'TrxNo'               => $SoNum,
                'SO_Date'             => date('Y-m-d H:i:s', strtotime($this->input->post('txtSODate'))),
                'SO_Notes'            => $this->input->post('txtMemo'),
                'Account_ID'          => $this->input->post('txtCustCode'),
                'Contact_ID'          => $this->input->post('txtCPCode'),
                'PO_NumCustomer'      => $this->input->post('txtPONum'),
                'PO_DateCustomer'     => !empty($this->input->post('txtPODate')) ? date('Y-m-d', strtotime($this->input->post('txtPODate'))) : NULL,
                'SO_Status'           => ($isConfirm == 'YES') ? 3 : 1, // Status 3 biasanya Confirm/Approved
                'Company_ID'          => 2,
                'WH_ID'               => 9,
                'Currency_ID'         => $this->input->post('selCurrency'),
                'Tax_Currency_ID'     => $this->input->post('selTaxCurrency'),
                'Invoice_Amount'      => str_replace(',', '', $this->input->post('txtTotAmount')),
                'Base_Invoice_Amount' => (float)str_replace(',', '', $this->input->post('txtTotAmount')) * (float)$rate,
                'Production_month'    => $this->input->post('txtProMonth'),
                'Production_year'     => $this->input->post('txtProYear'),
                'PriceType'           => $this->input->post('cboPriceType'),
                'pi_number'           => $this->input->post('txtPiNumber'), // 'SG260108-01' masuk sini
                'SC_Number'           => NULL, // Sesuai info Mas, ini selalu NULL
                'KawasanBerikat'      => ($this->input->post('chkKawasan') == '1') ? 1 : 0,
                'isTaxAble'           => ($this->input->post('txtSOtype') == '1') ? 1 : 0,
                'Update_By'           => $userId,
                'Last_Update'         => date('Y-m-d H:i:s')
            ];

            if ($task == 'new') {
                $dataHeader['Created_By']        = $userId;
                $dataHeader['Creation_DateTime'] = date('Y-m-d H:i:s');
                $this->db->insert('TAccSO_Header', $dataHeader);
            } else {
                $this->db->where('SO_Number', $SoNum)->update('TAccSO_Header', $dataHeader);
                // Jika edit, hapus detail lama dulu (Wipe and Replace)
                $this->db->where('SO_Number', $SoNum)->delete('TAccSO_Detail');
            }

            // 3. PREPARE DATA DETAIL (Looping Array [])
            $qtyArray = $this->input->post('qty');

            if (!empty($qtyArray) && is_array($qtyArray)) {
                foreach ($qtyArray as $i => $val) {
                    // Pastikan item_code[] ada di baris HTML Mas
                    $itemCode = $this->input->post('item_code')[$i] ?? $this->input->post('TXTPARTNO')[$i];

                    if (!empty($itemCode)) {
                        $qty       = (float)str_replace(',', '', $val);
                        $unitPrice = (float)str_replace(',', '', $this->input->post('price')[$i]);
                        $discVal   = (float)str_replace(',', '', $this->input->post('disc_val')[$i] ?? 0);

                        // Hitung Total (Netto)
                        $totalPrice = ($qty * $unitPrice) - $discVal;

                        $dataDetail = [
                            'SO_Number'        => $SoNum,
                            'Item_Code'        => $itemCode,
                            'Item_Description' => $this->input->post('item_desc')[$i] ?? '',
                            'Qty'              => $qty,
                            'UnitPrice'        => $unitPrice,
                            'Base_UnitPrice'   => $unitPrice * (float)$rate,
                            'Disc_percentage'  => str_replace(',', '', $this->input->post('disc_pct')[$i] ?? 0),
                            'Disc_Value'       => $discVal,
                            'TotalPrice'       => $totalPrice,
                            'Base_TotalPrice'  => $totalPrice * (float)$rate,
                            'Tax_Code1'        => $this->input->post('tax1')[$i],
                            'Tax_Code2'        => $this->input->post('tax2')[$i],
                            'EstimateDate'     => !empty($this->input->post('est_date')[$i]) ? $this->input->post('est_date')[$i] : NULL,
                            'Comp_ID'          => $this->input->post('cc')[$i], // Cost Center
                            'config_order'     => $i + 1,
                            'Dimension_ID'     => 3, // Sesuai sampel data Mas Yana
                            'Notes'            => $this->input->post('notes')[$i],
                            'Include_DO'       => 1
                        ];
                        $this->db->insert('TAccSO_Detail', $dataDetail);
                    }
                }
            }

            // 4. SELESAIKAN TRANSAKSI
            if ($this->db->trans_status() === FALSE) {
                $this->db->trans_rollback();
                echo json_encode(["code" => 500, "msg" => "Error Database: Gagal menyimpan data."]);
            } else {
                $this->db->trans_commit();
                echo json_encode([
                    "code" => 200,
                    "msg"  => "Sales Order $SoNum berhasil disimpan!",
                    "so_number" => $SoNum
                ]);
            }
        } catch (Exception $e) {
            $this->db->trans_rollback();
            echo json_encode(["code" => 500, "msg" => "Fatal Error: " . $e->getMessage()]);
        }
    }
}
