<?php
defined('BASEPATH') or exit('No direct script access allowed');

use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Spreadsheet;

class SalesOrder extends CI_Controller
{
    private $Date;
    private $DateTime;
    private $companyID = 2;
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

    public function add($task, $so_number = null) // Tambahkan parameter $so_number
    {
        $this->data['page_title'] = ($task == 'edit') ? "Edit Sales Order" : "Add Sales Order";
        $this->data['page_content'] = "SalesOrder/add";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/salesorder/add.js?v=' . time() . '""></script>';
        $this->data['task'] = $task;
        $this->data['so_number'] = $so_number;
        $companyID = 2;

        if ($task == 'edit' && !empty($so_number)) {
            $this->data['header'] = $this->db->query("SELECT isNULL(TAccSO_Header.Revision_Number,0) as Revision_Number,
                                                    TAccSO_Header.SO_Number,TAccSO_Header.Tax_Code AS VAT_Tax_Code,
                                                    TAccSO_Header.Quotation_Number,
                                                    TAccSO_Header.project_code, 	
                                                    TAccSO_Header.PO_NumCustomer,
                                                    TAccSO_Header.PO_DateCustomer,			
                                                    TAccSO_Header.SO_Date,
                                                    TAccSO_Header.automaticsn,				
                                                    TAccSO_Header.SO_Notes, 			
                                                    TAccSO_Header.Account_ID, 		
                                                    TAccSO_Header.Payment_Type, 					                                     
                                                    TAccSO_Header.Company_ID, 			
                                                    TAccSO_Header.Currency_ID,
                                                    TAccSO_Header.Tax_Currency_ID, 
                                                    TAccSO_Header.Approval_Status, 	
                                                    TAccSO_Header.SO_Status, 	
                                                    TAccSO_Header.SN_Status,
                                                    TAccSO_Header.Invoice_Status,
                                                    TAccSO_Header.Invoice_Amount,
                                                    TAccSO_Header.Base_Invoice_Amount,   
                                                    TAccSO_Header.Tax_Amount,
                                                    TAccSO_Header.Base_Tax_Amount,
                                                    TAccSO_Header.Due_Date,
                                                    TAccSO_Header.Emp_ID,
                                                    TAccSO_Header.Contact_ID,
                                                    TAccSO_Header.SOType,  				
                                                    TAccSO_Header.Terms,
                                                    TAccSO_Header.DeliveryTerms,
                                                    TAccSO_Header.Proforma_Number,
                                                    isnull(TAccSO_Header.isSisterCompany,0) as isSisterCompany,
                                                    isnull(TAccSO_Header.SisterCompany,0) as SisterCompany,
                                                    Taccount.AccountTitle_Code,
                                                    isnull(TAccSO_Header.ReviseCounter,0) as ReviseCounter,
                                                    TAccount.Account_Name, 
                                                    TAccSO_Header.sn_account_id,
                                                    TAccSO_Header.si_account_id,
                                                    isnull(TAccount.GroupID,0) as GroupID,
                                                    TAccount.account_address1,
                                                    TAccount.TaxFileNumber,
                                                    TContact.Contact_FirstName, 
                                                    TContact.Contact_HomeAddress,
                                                    TAccSO_Header.KawasanBerikat as KawasanBerikat,
                                                    TAccSO_Header.CurrencyRateList,
                                                    TAccSO_Header.Tax_CurrencyRateList,
                                                    TAccSO_Header.Project_ID,
                                                    TAccSO_Header.AllocateTo,
                                                    isnull(TAccSO_Header.isOutlet,0) as isOutlet,
                                                    isnull(TAccSO_Header.outlet_wh,0) as outlet_wh,
                                                    isnull(Taccount.GroupID,0) as GroupID,	
                                                    isNull(THRMEmpPersonalData.First_Name,'') + ' ' + isNull(.THRMEmpPersonalData.Middle_Name,'') + ' ' + isNull(THRMEmpPersonalData.Last_Name,'') AS Emp_name,
                                                    CONVERT(varchar(50),TAccSO_Header.Creation_DateTime) AS Creation_DateTime_Display,
                                                    CONVERT(varchar(50),TAccSO_Header.Last_Update) AS Last_Update_Display,
                                                    (SELECT isNull(Emp.First_Name,'') + ' ' + isNull(Emp.Middle_Name,'') + ' ' + isNull(Emp.Last_Name,'') FROM THRMEmpPersonalData AS Emp WHERE Emp.User_ID=TAccSO_Header.Created_By) AS Created_By_Name,
                                                    (SELECT isNull(Emp.First_Name,'') + ' ' + isNull(Emp.Middle_Name,'') + ' ' + isNull(Emp.Last_Name,'') FROM THRMEmpPersonalData AS Emp WHERE Emp.User_ID=TAccSO_Header.Update_By) AS Update_By_Name,
                                                    TAccSO_Header.TransactionDiscountRate,
                                                    TAccSO_Header.TransactionDiscountAmount ,
                                                    TAccSO_Header.TransactionDiscountBaseAmount,
                                                    TAccSO_Header.directpo,
                                                    TAccSO_Header.isDonation,
                                                    TAccSO_Header.isDP, 
                                                    TAccSO_Header.SC_Number,
                                                    TAccSO_Header.paymentterm_code,
                                                    TAccSO_Header.PriceType,
                                                    TAccSO_Header.reason_revision,
                                                    isNull(TAccSO_Header.claim_deduction_amount, 0.00) as claim_deduction_amount,
                                                    TAccSO_Header.claim_deduction_desc,
                                                    TAccSO_Header.pi_number,
                                                    TAccSO_Header.Production_month,
                                                    TAccSO_Header.Production_year
                                            FROM 	TAccSO_Header
                                                Left Join TAccount On TAccount.Account_ID = TAccSO_Header.Account_ID
                                                Left Join TContact On TContact.Contact_ID = TAccSO_Header.Contact_ID
                                                Left Join THRMEmpPersonalData On THRMEmpPersonalData.Emp_ID = TAccSO_Header.Emp_ID 
                                            WHERE 	TAccSO_Header.Company_id = ?
                                            AND 	SO_Number = ?", [$companyID, $so_number])->row();


            $this->data['details'] = $this->db->query("SELECT TAccSO_Detail.*, 
                                                    (SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TAccSO_Detail.Unit_Type) AS Unit_Desc,
                                                    (SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TAccSO_Detail.Unit_Type2) AS Unit_Desc2,
                                                    (SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TAccSO_Detail.Unit_Type) AS UnitType,
                                                    (SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TAccSO_Detail.Unit_Type2) AS UnitType2,
                                                    TItem.Item_Name,Titem.pricetype,
                                                    TItem.Item_Code, ISNULL(itd.Dimension_Name, '') AS Dimension_Name,
                                                    TItem.customfield1 AS Type,
                                                    TItem.Item_Color,
                                                    TItem.Item_Size
                                                    FROM  TAccSO_Detail
                                                    INNER JOIN 	TItem 	ON 	TAccSO_Detail.Item_Code = TItem.Item_Code
                                                    INNER JOIN 	TAccSO_Header ON TAccSO_Header.SO_Number = TAccSO_Detail.SO_Number AND TAccSO_Header.Company_ID = ?
                                                    LEFT JOIN TITEMDIMENSION itd ON itd.Dimension_ID = TAccSO_Detail.Dimension_ID 
                                                    WHERE 		TAccSO_Detail.SO_Number = ?
                                                    AND TAccSO_Detail.IsFreeItem = 0
                                                    ORDER BY 	TAccSO_Detail.SODetail_ID", [$companyID, $so_number])->result();

            $this->data['tax_list'] = $this->db->query("SELECT DISTINCT Tax_ID, Tax_Code, Tax_Name, Tax_Rate, Tax_operator 
                                                        FROM TaccTax 
                                                        ORDER BY Tax_Name")->result();
            $this->data['cc_list'] = $this->db->query("SELECT CostCenter_ID AS Comp_ID, CostCenter_Name_en AS Comp_Name 
                                                    FROM TAccCostCenter 
                                                    WHERE Company_ID = $companyID 
                                                    AND CC_Type = 'CC'
                                                    ORDER BY CostCenter_Name_en ASC")->result();

            $AccountID = $this->data['header']->Account_ID;
            $this->data['sales_person'] = $this->db->query("select account_ID,account_name,GroupID from taccount where account_id = $AccountID")->row();
            //query get free item
            $this->data['get_freeitem'] = $this->db->query("SELECT TAccSO_Detail.*, TItem.Item_Name,Titem.pricetype,TItem.Item_Code, 
                                                            ISNULL(itd.Dimension_Name, '') AS Dimension_Name FROM TAccSO_Detail
                                                            INNER JOIN TItem ON TAccSO_Detail.Item_Code = TItem.Item_Code
                                                            INNER JOIN TAccSO_Header ON TAccSO_Header.SO_Number = TAccSO_Detail.SO_Number AND TAccSO_Header.Company_ID = 2 
                                                            LEFT JOIN TITEMDIMENSION itd ON itd.Dimension_ID = TAccSO_Detail.Dimension_ID 
                                                            WHERE TAccSO_Detail.SO_Number = '$so_number'
                                                            AND TAccSO_Detail.IsFreeItem = 1
                                                            ORDER BY TAccSO_Detail.SODetail_ID")->result();

            //MENDAPATKAN TOTAL QTY 1 detail SO            
            $this->data['qGetTotalQty'] = $this->db->query("SELECT sum(Qty) as TotQty from TAccSO_Detail where SO_Number = '$so_number'")->row();
            // 1. qGetCreditLimit
            $this->data['qGetCreditLimit'] = $this->db->query("SELECT Credit_Limit
                                                FROM TAccTermsDefault
                                                WHERE TAccTermsDefault.Company_ID = ?
                                                AND TAccTermsDefault.Account_ID = ?
                                            ", [$companyID, $AccountID])->row();

            // 2. qGetNotPaidSalInvoice
            $this->data['qGetNotPaidSalInvoice'] = $this->db->query("SELECT sum(base_invoice_amount + dbo.func_calculateByDelimiter(List_Base_TaxAmount)) - 
                                                            sum(base_dp_Amount + dbo.func_calculateByDelimiter(List_Base_DP_TaxAmount)) as TotalInvoiceNotPaid
                                                        FROM TAccSI_Header
                                                        WHERE invoice_status != 'FP'
                                                        AND isvoid = 0
                                                        AND account_id = ?
                                                    ", [$AccountID])->row();

            // 3. qGetNotPaidProInvoice
            $this->data['qGetNotPaidProInvoice'] = $this->db->query("SELECT sum(base_invoice_amount + dbo.func_calculateByDelimiter(List_Base_TaxAmount)) - 
                                                    sum(base_dp_Amount + dbo.func_calculateByDelimiter(List_Base_DP_TaxAmount)) as TotalInvoiceNotPaid
                                                        FROM TAccProjectInvoice_Header
                                                        WHERE invoice_status != 'FP'
                                                        AND isvoid = 0
                                                        AND account_id = ?
                                                    ", [$AccountID])->row();

            // 4. qGetSOSalApproved
            $this->data['qGetSOSalApproved'] = $this->db->query("SELECT sum(Base_Invoice_Amount + Base_Tax_Amount) as TotalAmountSOApproved
                                                    FROM TAccSO_Header
                                                    WHERE approval_status = 3
                                                    AND isclose = 0 
                                                    AND isnull(isnotactive, 0) = 0
                                                    AND NOT EXISTS (
                                                        SELECT 1 FROM TAccSI_Header 
                                                        WHERE SO_Number = TAccSO_Header.SO_Number 
                                                        AND TAccSI_Header.IsVoid = 0
                                                    )
                                                    AND Account_ID = ?
                                                ", [$AccountID])->row();

            // 5. qGetSOProApproved
            // Note: Query ini menggunakan GROUP BY, jika Mas ingin total keseluruhan, 
            // pastikan mengolah hasil array-nya atau hapus GROUP BY jika hanya untuk 1 SO.
            $this->data['qGetSOProApproved'] = $this->db->query("SELECT sum(Stage_BaseAmount + Tax_Amount1 * (Base_Tax_Amount/CASE Tax_Amount WHEN 0 THEN 1 ELSE Tax_Amount END) + 
                                                    Tax_Amount2 * (Base_Tax_Amount/CASE Tax_Amount WHEN 0 THEN 1 ELSE Tax_Amount END))
                                                    - (SELECT sum(Base_Invoice_Amount + dbo.func_calculateByDelimiter(list_base_taxamount))
                                                        FROM TAccProjectInvoice_Header 
                                                        WHERE SO_Number = TAccSOProject_Header.SO_Number 
                                                        AND (TAccProjectInvoice_Header.IsVoid = 0 OR TAccProjectInvoice_Header.IsVoid IS NULL)) as qGetSOApproved 
                                                FROM TAccSOProject_Header, TAccSOProject_Detail, TAccProjectStageHeader
                                                WHERE approval_status = 3
                                                AND Account_ID = ? 
                                                AND isnull(isnotactive,0) = 0
                                                AND TAccSOProject_Header.SO_Number = TAccSOProject_Detail.SO_Number
                                                AND TAccProjectStageHeader.StageCode = TAccSOProject_Detail.Stage_Code
                                                AND TAccProjectStageHeader.CompanyID = ?
                                                AND TAccProjectStageHeader.IsMilestone = 1
                                                GROUP BY TAccSOProject_Header.SO_Number
                                            ", [$AccountID, $companyID])->result();
        }


        $this->data['sales_person'] = $this->db->query("SELECT T1.Emp_ID, ISNULL(T1.First_Name, '') + ' ' + ISNULL(T1.Middle_Name, '') + ' ' + ISNULL(T1.Last_Name, '') AS name 
                                                        FROM THRMEmpPersonalData AS T1 
                                                        WHERE EXISTS (SELECT 1 FROM thrmEmpCompany AS T2 
                                                        WHERE T2.Emp_ID = T1.Emp_ID AND T2.Company_ID = 2) 
                                                        AND (T1.Terminate_Date >= GETDATE() OR T1.Terminate_Date IS NULL) 
                                                        AND isnull(T1.isSalesPerson,0) = 1
                                                        ORDER BY T1.First_Name ASC")->result();



        //---- batas Query --------------//

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
            $sourceDate = $q ? date('d M Y', strtotime($q->Quotation_Date)) : "";
        }

        $this->data['SourceDate'] = $sourceDate;

        // Step Proforma (Step 4) dibuang karena tidak akan pernah terpakai
        $this->data['selProforma'] = "";
        $this->data['ddlSalesContract'] = "";
        $this->data['txtExpDelDate'] = "";

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
        $SOdate = $this->input->get('sodate'); // rate di drive ole SO date, format: YYYY-MM-DD
        $baseCurrency = $this->input->cookie('currencyid') ?? 'IDR';
        $companyId    = 2; // Sesuai data uat Anda

        // Query MSSQL 2014
        // Kita ambil 'scale' sebagai rate-nya
        $this->db->select('scale');
        $this->db->from('TCurrencyConverter');
        $this->db->where('currency_id_1', $selectedCurr);
        $this->db->where('currency_id_2', $baseCurrency);
        $this->db->where('status', 1);
        $this->db->where('company_id', $companyId);

        // Logic Tanggal: Hari ini harus di antara start dan end date

        $this->db->where("'$SOdate' BETWEEN start_date AND end_date");

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
            $SelCurr = 'txtCurr_' . $this->input->post('selCurrency');
            $rate = str_replace(',', '', $this->input->post($SelCurr) ?? 1);
            $userId = $this->session->userdata('sys_sba_userid');

            // Ambil nilai Tax dari form (Nilai dalam IDR/Base)
            $taxBase = (float)str_replace(',', '', $this->input->post('txtTotTaxConv') ?? 0);

            // Hitung Tax dalam Currency Document (Misal USD)
            // Jika IDR, maka $rate adalah 1, hasilnya tetap sama.
            $taxAmount = ($rate > 0) ? ($taxBase / $rate) : 0;

            // 2. PREPARE DATA HEADER (TAccSO_Header)
            $dataHeader = [
                'SO_Number'           => $SoNum,
                'TrxNo'               => $SoNum,
                'SO_Date'             => date('Y-m-d', strtotime($this->input->post('txtSODate'))) . ' ' . date('H:i:s'), // Gabungkan dengan waktu saat submit
                'SO_Notes'            => $this->input->post('txtMemo'),
                'Account_ID'          => $this->input->post('txtCustCode'),
                'Payment_Type'        => 'Credit',
                'Contact_ID'          => $this->input->post('txtCPCode'),
                'PO_NumCustomer'      => $this->input->post('txtPONum'),
                'PO_DateCustomer'     => !empty($this->input->post('txtPODate')) ? date('Y-m-d', strtotime($this->input->post('txtPODate'))) : NULL,
                'Project_ID'          => $this->input->post('selProject') ?: 0,
                'SO_Status'           => ($this->input->post('txtconfirm') == 'YES') ? 2 : 1,
                'Approval_Status'     => '0',
                'Company_ID'          => 2,
                'WH_ID'               => 9,
                'Currency_ID'         => $this->input->post('selCurrency'),
                'Tax_Currency_ID'     => $this->input->post('selTaxCurrency'),
                'Tax_Amount'          => $taxAmount,      // Nilai Pajak dalam Currency Document (USD/EUR dll)
                'Base_Tax_Amount'     => $taxBase,
                'SN_Status'           => 'ND',
                'Emp_ID'              => $this->input->post('txtSPCode'),
                'Invoice_Status'      => 'NI',
                'Invoice_Amount'      => str_replace(',', '', $this->input->post('txtTotAmount')),
                'Due_date'            => $this->input->post('txtInvDueDate'),
                'SOType'              => $this->input->post('txtSOtype') ?: '1',
                'Base_Invoice_Amount' => (float)str_replace(',', '', $this->input->post('txtTotAmount')) * (float)$rate,
                'ItemCategoryType'    => 'FG',
                'Production_month'    => $this->input->post('txtProMonth'),
                'Production_year'     => $this->input->post('txtProYear'),
                'PriceType'           => $this->input->post('cboPriceType'),
                'pi_number'           => $this->input->post('txtPiNumber'), // 'SG260108-01' masuk sini
                'SC_Number'           => NULL, // Sesuai info Mas, ini selalu NULL
                'terms'               => $this->input->post('cboTerms'),
                'Deliveryterms'       => $this->input->post('txtDeliveryTerms'),
                'isClose'             => 0,
                'close_reason' => NULL,
                'project_code' => 0,
                'Proforma_Number' => 0,
                'isSisterCompany' => 0,
                'SisterCompany' => 0,
                'CurrencyRateList' => $this->input->post('CurrencyRateList'),
                'Tax_CurrencyRateList' => 'IDR|1',
                'AllocateTo' => $this->input->post('rdoAllocate'),
                'TransactionDiscountRate' => $this->input->post('txtDisctotal') ?? 0,
                'TransactionDiscountAmount' => $this->input->post('txtTotDisc') ?? 0,
                'TransactionDiscountBaseAmount' => floatval($this->input->post('txtTotDisc')) * (float)$rate,
                'include_do' => 1,
                'paymentterm_code' => $this->input->post('cboTermsNew'),
                'Revision_Number' => 0,
                'isExport' => 1,
                'reason_revision' => $this->input->post('txtRevisionReason'),
                'claim_deduction_amount' => $this->input->post('txt_cd_amount'),
                'claim_deduction_desc' => $this->input->post('txt_cd_desc'),
                'SN_Account_ID' => $this->input->post('selSNGroup'),
                'SI_Account_ID' => $this->input->post('selSIGroup'),
                'disc_id' => 0,
                'KawasanBerikat'      => ($this->input->post('chkKawasan') == '1') ? 1 : 0,
                'isTaxAble'           => 0,
                'Production_month' => $this->input->post('txtProMonth'),
                'Production_year' => $this->input->post('txtProYear'),
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

                    // 1. Ambil Item Code (Pastikan index-nya sesuai)
                    $itemCode = $this->input->post('item_code')[$i] ?? $this->input->post('TXTPARTNO')[$i];

                    // Jika baris ini kosong, lewati
                    if (empty($itemCode)) continue;

                    // 2. Pembersihan & Perhitungan Angka
                    $qty        = (float)str_replace(',', '', $val);
                    $qty2       = (float)str_replace(',', '', $this->input->post('qty2')[$i] ?? 0);
                    $unitPrice  = (float)str_replace(',', '', $this->input->post('price')[$i] ?? 0);
                    $discVal    = (float)str_replace(',', '', $this->input->post('disc_val')[$i] ?? 0);
                    $totalPrice = ($qty * $unitPrice) - $discVal;

                    // Rate (Asumsi variabel $rate sudah didefinisikan sebelumnya)
                    $currentRate = (float)($rate ?? 1);

                    // 3. Logic Pajak 1
                    $tax1_raw = $this->input->post('tax1')[$i] ?? '';
                    $t1_code = 0;
                    $t1_rate = 0;
                    $t1_op = '0';
                    $t1_amt = 0;

                    if (!empty($tax1_raw) && strpos($tax1_raw, '|') !== false) {
                        $t1_parts = explode('|', $tax1_raw);
                        $t1_code  = $t1_parts[0];
                        $t1_rate  = (float)$t1_parts[1];
                        $t1_op    = $t1_parts[2];
                        $t1_amt   = ($totalPrice * $t1_rate) / 100;
                    }

                    // 4. Logic Pajak 2
                    $tax2_raw = $this->input->post('tax2')[$i] ?? '';
                    $t2_code = 0;
                    $t2_rate = 0;
                    $t2_op = '0';
                    $t2_amt = 0;

                    if (!empty($tax2_raw) && strpos($tax2_raw, '|') !== false) {
                        $t2_parts = explode('|', $tax2_raw);
                        $t2_code  = $t2_parts[0];
                        $t2_rate  = (float)$t2_parts[1];
                        $t2_op    = $t2_parts[2];
                        $t2_amt   = ($totalPrice * $t2_rate) / 100;
                    }

                    // 5. Prepare Data Detail
                    $dataDetail = [
                        'SO_Number'        => $SoNum, // Pastikan $SoNum sudah ada
                        'Item_Code'        => $itemCode,
                        'Item_description' => $this->input->post('item_name')[$i] ?? '',
                        'Qty'              => $qty,
                        'Qty2'             => $qty2,
                        'Unit_Type'        => $this->input->post('unit_id')[$i] ?: 0,
                        'Unit_Type2'       => $this->input->post('unit_id2')[$i] ?: 0,
                        'UnitPrice'        => $unitPrice,
                        'Base_UnitPrice'   => $unitPrice * $currentRate,
                        'Disc_Percentage'  => (float)str_replace(',', '', $this->input->post('disc_pct')[$i] ?? 0),
                        'Disc_Value'       => $discVal,
                        'Tax_Code1'        => $t1_code,
                        'Tax_Percentage1'  => $t1_rate,
                        'Tax_Operator1'    => $t1_op,
                        'Tax_Amount1'      => $t1_amt,
                        'Tax_Code2'        => $t2_code,
                        'Tax_Percentage2'  => $t2_rate,
                        'Tax_Operator2'    => $t2_op,
                        'Tax_Amount2'      => $t2_amt,
                        'TotalPrice'       => $totalPrice,
                        'Base_TotalPrice'  => $totalPrice * $currentRate,
                        'Include_DO'       => 1,
                        'Others'           => $this->input->post('others')[$i] ?? '',
                        'CS_Number'        => $this->input->post('cs_number')[$i] ?? '',
                        'ExtraPrice'       => (float)str_replace(',', '', $this->input->post('extra_price')[$i] ?? 0),
                        'EstimateDate'     => !empty($this->input->post('est_date')[$i]) ? $this->input->post('est_date')[$i] : $this->input->post('txtSODate'),
                        'generate_flag'    => $this->input->post('gen_flag')[$i] ?? '0',
                        'parent_item'      => $this->input->post('parent_item')[$i] ?? '0',
                        'parent_path'      => $this->input->post('parent_path')[$i] ?? '0',
                        'Comp_ID'          => $this->input->post('cc')[$i] ?: 0,
                        'config_level'     => $this->input->post('level')[$i] ?? 0,
                        'config_ratio'     => $this->input->post('ratio')[$i] ?? 1,
                        'config_order'     => $i + 1,
                        'Dimension_ID'     => $this->input->post('dim_id')[$i] ?: 3,
                        'isFreeItem'       => '0',
                        'Notes'            => $this->input->post('notes')[$i] ?? ''
                    ];

                    if ($this->input->post('rbTypeDoc') == 3) {
                        $dataDetail['ref_id'] = $this->input->post('hdnSCDetailID')[$i];
                    }

                    // Simpan per baris
                    $this->db->insert('TAccSO_Detail', $dataDetail);
                }
            }

            $dataInsCust = [
                'TRX_NUMBER'     => $SoNum,
                'DOC_TYPE'       => 'SO',
                'COMPANY_ID'     => $this->companyID, // Mengambil dari cookie atau default
                'PAYMENT_PERIOD' => 1,
                'INVOICE_DATE'   => date('Y-m-d', strtotime($this->input->post('txtInvoiceDate1'))),
                'DUE_DATE'       => date('Y-m-d', strtotime($this->input->post('txtDueDate1'))),
                'AMOUNT'         => (float) str_replace(',', '', $this->input->post('txtAmount1')),
                'UPDATED_BY'     => $this->session->userdata('sys_sba_userid'), // Biasanya CKSATRIADEVID di CF itu UserID
                'LAST_UPDATE'    => date('Y-m-d H:i:s'),
                'TOP_CODE'       => $this->input->post('cboTerms')
            ];
            $this->db->insert('TACCCUSTOMERPAYMENT', $dataInsCust);

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


    public function process_excel_import()
    {
        // 1. Validasi File Upload
        if (!isset($_FILES['file_excel']['name']) || $_FILES['file_excel']['name'] == "") {
            echo json_encode(["status" => "error", "msg" => "File tidak ditemukan"]);
            return;
        }

        $file_path = $_FILES['file_excel']['tmp_name'];
        $companyID = 2; // Ambil Company ID dari session

        try {
            // 2. Load Spreadsheet
            $spreadsheet = IOFactory::load($file_path);
            $sheet = $spreadsheet->getActiveSheet();

            /** * toArray parameters:
             * null: value if cell is empty
             * true: calculate formulas
             * true: format data (returns strings as seen in excel)
             * false: return indexed array (0, 1, 2...) bukan (A, B, C...)
             */
            $dataArray = $sheet->toArray(null, true, true, false);

            $responseItems = [];
            $seen_codes    = []; // Tracker untuk deteksi duplikat
            $duplicate_errors = []; // Penampung list kode yang duplikat

            // 3. Loop Data Excel (Mulai Baris ke-2 / Index 1)
            foreach ($dataArray as $index => $row) {
                if ($index == 0) continue; // Lewati Header

                // Mapping Kolom Excel
                // Index: 0=A, 1=B, 2=C, 3=D, 4=E, 5=F, 6=G, 7=H, 8=I
                $itemCode = trim($row[0] ?? '');
                if (empty($itemCode)) continue; // Jika Item Code kosong, lewati baris

                // --- VALIDASI DUPLIKAT ---
                if (isset($seen_codes[$itemCode])) {
                    // Jika sudah pernah ada, tambahkan ke list error (biar user tahu baris mana yang dobel)
                    $duplicate_errors[] = "Baris " . ($index + 1) . ": Item Code [$itemCode] duplikat.";
                    continue; // Skip baris ini, jangan diproses ke DB
                }

                // Tandai bahwa kode ini sudah diproses
                $seen_codes[$itemCode] = true;

                $qty      = (float)str_replace(',', '', $row[1] ?? 0);
                $price    = (float)str_replace(',', '', $row[2] ?? 0);
                $discPct  = (float)str_replace(',', '', $row[3] ?? 0);
                $tax1     = trim($row[4] ?? '0');
                $tax2     = trim($row[5] ?? '0');
                $estDate  = trim($row[6] ?? date('Y-m-d'));
                $ccCode   = trim($row[7] ?? '');
                $notes    = trim($row[8] ?? '');

                // 4. Query Database (Sinkron dengan qitem pick item manual)
                $item = $this->db->query("
                    SELECT 
                        TITEM.item_code, 
                        TITEM.Item_name, 
                        tgscolor.Color_Name as Color, 
                        TITEM.Item_Size as Brand, 
                        CAST(ISNULL(TITEM.Item_Length,0) AS VARCHAR) + ' x ' + CAST(ISNULL(TITEM.Item_Width,0) AS VARCHAR) + ' x ' + CAST(ISNULL(TITEM.Item_Height,0) AS VARCHAR) + ' mm' as Size, 
                        TITEM.customfield1 AS Type,
                        TITEM.unit_type_id,
                        (SELECT unit_name FROM taccunittype WHERE unit_type_id = TITEM.unit_type_id) AS unit_name,
                        TItemCompany.Dimension_ID
                    FROM TITEM 
                    INNER JOIN TItemCompany ON TItemCompany.item_code = TItem.item_code 
                    LEFT JOIN tgscolor ON tgscolor.color_code = TITEM.item_color 
                    WHERE TITEM.item_code = ? 
                    AND TItemCompany.Company_ID = ?
                    AND (TItem.InActive is NULL Or TItem.InActive = 0)
                ", [$itemCode, $companyID])->row();

                //berikan validasi apabila salah satu baris berisi item code yang tidak ditemukan, maka proses import akan dihentikan dan memberikan pesan error
                if (empty($item)) {
                    header('Content-Type: application/json');
                    echo json_encode(["status" => "error", "msg" => "Item Code '$itemCode' tidak ditemukan di database. Proses import dihentikan."]);
                    return;
                }

                if ($item) {
                    // 5. Kalkulasi Amount (Netto)
                    $gross  = $qty * $price;
                    $amount = $gross - ($gross * ($discPct / 100));

                    // 6. Siapkan Data untuk Response JSON
                    $responseItems[] = [
                        'item_code'    => $item->item_code,
                        'item_name'    => $item->Item_name,
                        'unit_id'      => $item->unit_type_id,
                        'unit_name'    => $item->unit_name,
                        'dim_id'       => $item->Dimension_ID,
                        'size'         => $item->Size,
                        'color'        => $item->Color,
                        'brand'        => $item->Brand,
                        'type'         => $item->Type,
                        // Data mentah dari Excel
                        'qty'          => $qty,
                        'price'        => $price,
                        'disc_pct'     => $discPct,
                        'tax1'         => $tax1,
                        'tax2'         => $tax2,
                        'est_date'     => $estDate,
                        'cc'           => $ccCode,
                        'notes'        => $notes,
                        'total_amount' => number_format($amount, 2, '.', '') // Format 0.00
                    ];
                }
            }

            if (!empty($duplicate_errors)) {
                echo json_encode([
                    "status" => "error",
                    "msg"    => "Terdeteksi duplikasi item dalam file Excel:<br>" . implode("<br>", $duplicate_errors)
                ]);
                return;
            }

            // 7. Output Final
            header('Content-Type: application/json');
            echo json_encode($responseItems);
        } catch (Exception $e) {
            header('Content-Type: application/json');
            echo json_encode(["status" => "error", "msg" => "Error loading file: " . $e->getMessage()]);
        }
    }
}
