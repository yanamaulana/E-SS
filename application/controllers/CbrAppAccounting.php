<?php
defined('BASEPATH') or exit('No direct script access allowed');

class CbrAppAccounting extends CI_Controller
{
    private $Date;
    private $DateTime;
    private $layout = 'layout';
    private $Ttrx_Cbr_Approval = 'Ttrx_Cbr_Approval';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->Date = date("Y-m-d");
        $this->DateTime = date("Y-m-d H:i:s");
        $this->load->model('m_helper', 'help');
        $this->load->model('m_DataTable', 'M_Datatables');
    }

    public function index()
    {
        $this->data['page_title'] = "Accounting Approval-Cash Book Requisition";
        $this->data['page_content'] = "cbr_app/approval_accounting";

        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/cbr_app/accounting.js?v=' . time() . '"></script>
                                       <script src="' . base_url() . 'assets/Pages/cbr_app/history_approval_accounting.js?v=' . time() . '"></script>
                                       <script src="' . base_url() . 'assets/Pages/cbr_app/termin_monitoring.js?v=' . time() . '"></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function approve_submission()
    {
        $Cbrs = $this->input->post('CBReq_No');

        $this->db->trans_start();
        foreach ($Cbrs as $CBReq_No) {
            // 1. Update Status Approval Finance
            $this->db->where('CBReq_No', $CBReq_No)->update($this->Ttrx_Cbr_Approval, [
                'Status_AppvFinancePerson' => 1,
                'AppvFinancePerson_Name' => $this->session->userdata('sys_sba_nama'),
                'AppvFinancePerson_By' => $this->session->userdata('sys_sba_username'),
                'AppvFinancePerson_At' => $this->DateTime,
            ]);

            // 2. Ambil data Header untuk keperluan Termin
            $header = $this->db->where('CBReq_No', $CBReq_No)->get('TaccCashBookReq_Header')->row();
            $trx = $this->db->where('CBReq_No', $CBReq_No)->get('Ttrx_Cbr_Approval')->row();

            if ($header) {
                // Cek apakah data termin sudah ada (mencegah duplikasi jika tombol diklik berkali-kali)
                $check_termin = $this->db->where('CBReq_No', $CBReq_No)->count_all_results('Ttrx_Cbr_Approval_Termin');

                if ($check_termin == 0) {
                    // 3. Insert ke Tabel Termin (Status 0 = Awaiting)
                    $data = [
                        'CBReq_No'           => $CBReq_No,
                        'Termin_Ke'          => 1,
                        'Currency_ID'        => $header->Currency_ID,
                        'Amount_Termin'      => (float)$header->Amount,
                        'Payment_Plan_Date'  => $this->DateTime, // Default tanggal sekarang, bisa disesuaikan jika ada logika khusus
                        'Amount_Type'        => 'AP',
                        'Status_AppvPresdir' => 0, // Awaiting
                        'AppvPresdir_By'     => $trx->AppvPresidentDirector_By,
                        'Rec_Created_At'     => $this->DateTime,
                        'Created_By'         => $this->session->userdata('sys_sba_username'),
                        'Last_Updated_By'    => $this->session->userdata('sys_sba_username'),
                        'Last_Updated_At'    => $this->DateTime
                    ];

                    $this->db->insert('Ttrx_Cbr_Approval_Termin', $data);
                }
            }
        }

        $error_msg = $this->db->error()["message"];
        $this->db->trans_complete();
        if ($this->db->trans_status() === FALSE) {
            $this->db->trans_rollback();
            return $this->help->Fn_resulting_response([
                'code' => 505,
                'msg'  => $error_msg,
            ]);
        } else {
            $this->db->trans_commit();
            return $this->help->Fn_resulting_response([
                'code' => 200,
                'msg' => 'Cash Book Requisition successfully approved by accounting person!',
            ]);
        }
    }

    public function reject_submission()
    {
        $Cbrs = $this->input->post('CBReq_No');
        $rejection_reason = $this->input->post('rejection_reason');

        $this->db->trans_start();
        foreach ($Cbrs as $CBReq_No) {
            $this->db->where('CBReq_No', $CBReq_No)->update($this->Ttrx_Cbr_Approval, [
                'Status_AppvFinancePerson' => 2,
                'AppvFinancePerson_Name' => $this->session->userdata('sys_sba_nama'),
                'AppvFinancePerson_By' => $this->session->userdata('sys_sba_username'),
                'AppvFinancePerson_At' => $this->DateTime,
            ]);
            $this->help->record_history_approval($CBReq_No, $rejection_reason);
        }

        $error_msg = $this->db->error()["message"];
        $this->db->trans_complete();
        if ($this->db->trans_status() === FALSE) {
            $this->db->trans_rollback();
            return $this->help->Fn_resulting_response([
                'code' => 505,
                'msg'  => $error_msg,
            ]);
        } else {
            $this->db->trans_commit();
            return $this->help->Fn_resulting_response([
                'code' => 200,
                'msg' => 'Cash Book Requisition successfully Rejected by accouting person!',
            ]);
        }
    }

    // ========================================== DATATABLE 

    public function DT_List_To_Approve()
    {
        $requestData = $_REQUEST;
        $columns = array(
            0 => 'TAccCashBookReq_Header.CBReq_No',
            1 => 'TAccCashBookReq_Header.CBReq_No',
            2 => 'Type',
            3 => 'Document_Date',
            4 => 'TAccCashBookReq_Header.Currency_Id',
            5 => 'Amount',
            6 => 'Document_Number',
            7 => 'Descript',
            8 => 'baseamount',
            9 => 'curr_rate',
            10 => 'Approval_Status',
            11 => 'CBReq_Status',
            12 => 'Paid_Status',
            13 => 'Creation_DateTime',
            14 => 'Created_By',
            15 => 'UserDivision',
            16 => 'First_Name',
            17 => 'Update_By',
            18 => 'TAccCashBookReq_Header.Acc_ID ',
            19 => 'TAccCashBookReq_Header.Approve_Date',
            20 => 'TAccCashBookReq_Header.Payment_Plan_Date',
        );

        $order  = $columns[$requestData['order']['0']['column']];
        $dir    = $requestData['order']['0']['dir'];
        $username = $this->session->userdata('sys_sba_username');

        $sql = "SELECT  distinct TAccCashBookReq_Header.CBReq_No, Type, Document_Date, Document_Number, TAccCashBookReq_Header.Acc_ID, Descript, Amount, baseamount, curr_rate, Approval_Status, CBReq_Status, Paid_Status, Creation_DateTime, Created_By, First_Name AS Created_By_Name, Last_Update, Update_By, TAccCashBookReq_Header.Currency_Id, TAccCashBookReq_Header.Approve_Date, UserDivision, Payment_Plan_Date
        FROM TAccCashBookReq_Header
        INNER JOIN TUserGroupL ON TAccCashBookReq_Header.Created_By = TUserGroupL.User_ID
        INNER JOIN TUserPersonal ON TAccCashBookReq_Header.Created_By = TUserPersonal.User_ID
        LEFT OUTER JOIN Ttrx_Cbr_Approval ON TAccCashBookReq_Header.CBReq_No = Ttrx_Cbr_Approval.CBReq_No
        WHERE TAccCashBookReq_Header.Type='D'
        AND TAccCashBookReq_Header.Company_ID = 2 
        AND isNull(isSPJ,0) = 0
        AND Approval_Status  = 3
        AND CBReq_Status = 3
        AND Ttrx_Cbr_Approval.CBReq_No IS NOT NULL
        AND IsAppvFinancePerson = 1 
        AND Status_AppvFinancePerson = 0
        AND ((IsAppvStaff = 0)          or (IsAppvStaff = 1 and Status_AppvStaff = 1))
        AND ((IsAppvChief = 0)          or (IsAppvChief = 1 and Status_AppvChief = 1))
        AND ((IsAppvAsstManager = 0)    or (IsAppvAsstManager = 1 and Status_AppvAsstManager = 1))
        AND ((IsAppvManager = 0)        or (IsAppvManager = 1 and Status_AppvManager = 1))
        AND ((IsAppvSeniorManager = 0)  or (IsAppvSeniorManager = 1 and Status_AppvSeniorManager = 1))
        AND ((IsAppvGeneralManager = 0) or (IsAppvGeneralManager = 1 and Status_AppvGeneralManager = 1))
        AND ((IsAppvAdditional = 0)     or (IsAppvAdditional = 1 and Status_AppvAdditional = 1)) ";
        // ORDER BY TAccCashBookReq_Header.Document_Date DESC,TAccCashBookReq_Header.CBReq_No DESC 

        $totalData = $this->db->query($sql)->num_rows();
        if (!empty($requestData['search']['value'])) {
            $searchValue = $requestData['search']['value'];
            $sql .= " AND (
                    Ttrx_Cbr_Approval.CBReq_No LIKE '%$searchValue%' 
                    OR TUserPersonal.First_Name LIKE '%$searchValue%' 
                    OR TAccCashBookReq_Header.Document_Number LIKE '%$searchValue%' 
                    OR TAccCashBookReq_Header.Currency_Id LIKE '%$searchValue%' 
                    OR TAccCashBookReq_Header.Descript LIKE '%$searchValue%' 
                    OR Ttrx_Cbr_Approval.UserDivision LIKE '%$searchValue%'
                    -- Kolom Date dikonversi ke String
                    OR CAST(TAccCashBookReq_Header.Document_Date AS VARCHAR) LIKE '%$searchValue%' 
                    OR CAST(TAccCashBookReq_Header.Payment_Plan_Date AS VARCHAR) LIKE '%$searchValue%' 
                    OR CAST(TAccCashBookReq_Header.Amount AS VARCHAR) LIKE '%$searchValue%'
                )";
        }
        //----------------------------------------------------------------------------------
        $totalFiltered = $this->db->query($sql)->num_rows();
        $sql .= " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";
        $query = $this->db->query($sql);
        $data = array();
        foreach ($query->result_array() as $row) {
            $nestedData = array();
            $nestedData['CBReq_No'] = $row['CBReq_No'];
            $nestedData['Type'] = $row['Type'];
            $nestedData['Document_Date'] = $row['Document_Date'];
            $nestedData['Acc_ID'] = $row['Acc_ID'];
            $nestedData['Descript'] = $row['Descript'];
            $nestedData['Document_Number'] = $row['Document_Number'];
            $nestedData['Amount'] = $row['Amount'];
            $nestedData['baseamount'] = $row['baseamount'];
            $nestedData['curr_rate'] = $row['curr_rate'];
            $nestedData['Approval_Status'] = $row['Approval_Status'];
            $nestedData['CBReq_Status'] = $row['CBReq_Status'];
            $nestedData['Paid_Status'] = $row['Paid_Status'];
            $nestedData['Creation_DateTime'] = $row['Creation_DateTime'];
            $nestedData['Created_By'] = $row['Created_By'];
            $nestedData['First_Name'] = $row['Created_By_Name'];
            $nestedData['Last_Update'] = $row['Last_Update'];
            $nestedData['Update_By'] = $row['Update_By'];
            $nestedData['Currency_Id'] = $row['Currency_Id'];
            $nestedData['Approve_Date'] = $row['Approve_Date'];
            $nestedData['UserDivision'] = $row['UserDivision'];
            $nestedData['Payment_Plan_Date'] = $row['Payment_Plan_Date'];

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

    // 1. PENGAMBILAN DATA UNTUK AJAX JENDELA MODAL
    public function get_termin_data($cbreq_no)
    {
        $cbreq_no = urldecode($cbreq_no);

        $this->db->where('CBReq_No', $cbreq_no);
        $this->db->order_by('Termin_Ke', 'ASC');
        $this->db->order_by('SysID', 'ASC');
        $query = $this->db->get('Ttrx_Cbr_Approval_Termin');

        echo json_encode($query->result());
    }

    private function normalize_amount_type($value)
    {
        $normalized = strtolower(trim((string) $value));

        if (in_array($normalized, ['pph', 'pph21', 'pph22', 'pph23', 'withholding', 'withholdingtax'], true)) {
            return 'PPH';
        }

        if (in_array($normalized, ['ppn', 'vat', 'pajak', 'tax', 'taxes', 'pajakpertambahannilai', 'pajak-pertambahan-nilai'], true)) {
            return 'PPN';
        }

        if (in_array($normalized, ['dpp', 'ap', 'base', 'utama', 'main'], true)) {
            return 'AP';
        }

        return NULL;
    }

    public function save_termin()
    {
        $cbreq_no = $this->input->post('cbreq_no');
        $amounts = $this->input->post('amount_termin');
        $dates = $this->input->post('payment_plan_date');
        $amount_types = $this->input->post('amount_type');
        $row_statuses = $this->input->post('row_status');

        if (
            empty($cbreq_no) || !is_array($amounts) || !is_array($dates) ||
            !is_array($amount_types) || !is_array($row_statuses) ||
            count($amounts) !== count($dates) || count($amounts) !== count($amount_types) ||
            count($amounts) !== count($row_statuses)
        ) {
            echo json_encode(
                [
                    "code" => 400,
                    "msg" => "Data inputan tidak lengkap atau tanggal/jenis nominal belum dipilih!"
                ]
            );
            return;
        }

        // 1. AMBIL NILAI MAXIMUM AMOUNT CBR DARI DATABASE
        $this->db->select('Amount, Currency_ID');
        $this->db->where('CBReq_No', $cbreq_no);
        $header = $this->db->get('TaccCashBookReq_Header')->row();

        if (empty($header)) {
            echo json_encode(["code" => 400, "msg" => "Nomor CBR tidak valid!"]);
            return;
        }

        $total_cbr_amount = (float) $header->Amount;
        $currency_id = $header->Currency_ID;

        // 2. VALIDASI INPUT ARRAY (REQUIRED, TIDAK BOLEH 0, & TOTAL HITUNG)
        $pending_rows = [];
        $total_input_amount = 0;
        $locked_total = (float) ($this->db->select_sum('Amount_Termin', 'total')
            ->where('CBReq_No', $cbreq_no)
            ->where('Status_AppvPresdir !=', 0)
            ->get('Ttrx_Cbr_Approval_Termin')->row()->total ?? 0);
        $available_amount = round($total_cbr_amount - $locked_total, 4);

        if ($available_amount < -0.01) {
            echo json_encode(["code" => 409, "msg" => "Gagal! Total termin yang sudah diputuskan melebihi nominal CBR. Hubungi administrator."]);
            return;
        }
        $existing_type_counts = ['PPN' => 0, 'PPH' => 0];
        $pending_type_counts = ['PPN' => 0, 'PPH' => 0];

        foreach (['PPN', 'PPH'] as $type) {
            $this->db->where('CBReq_No', $cbreq_no);
            $this->db->where('Amount_Type', $type);
            $this->db->where('Status_AppvPresdir !=', 0);
            $existing_type_counts[$type] = $this->db->count_all_results('Ttrx_Cbr_Approval_Termin');
        }

        foreach ($amounts as $index => $amount) {
            $row_status = isset($row_statuses[$index]) ? trim($row_statuses[$index]) : 'draft';
            if (in_array($row_status, ['1', '2', 1, 2], true)) {
                continue;
            }

            $clean_amount = (float) $amount;
            $clean_date = isset($dates[$index]) ? trim($dates[$index]) : '';
            $clean_amount_type = $this->normalize_amount_type(isset($amount_types[$index]) ? $amount_types[$index] : '');

            if ($clean_amount <= 0) {
                echo json_encode(["code" => 400, "msg" => "Gagal! Nominal pembayaran termin pada baris ke-" . ($index + 1) . " tidak boleh 0 atau kosong."]);
                return;
            }

            if (empty($clean_date)) {
                echo json_encode(["code" => 400, "msg" => "Gagal! Rencana tanggal bayar pada baris ke-" . ($index + 1) . " wajib diisi."]);
                return;
            }

            if (empty($clean_amount_type)) {
                echo json_encode(["code" => 400, "msg" => "Gagal! Jenis nominal pada baris ke-" . ($index + 1) . " wajib dipilih (AP, PPH, atau PPN)."]);
                return;
            }

            if (in_array($clean_amount_type, ['PPN', 'PPH'], true)) {
                $pending_type_counts[$clean_amount_type]++;
                if ($existing_type_counts[$clean_amount_type] + $pending_type_counts[$clean_amount_type] > 1) {
                    echo json_encode(["code" => 400, "msg" => "Gagal! " . $clean_amount_type . " hanya boleh ada 1 baris termin."]);
                    return;
                }
            }

            $pending_rows[] = [
                'amount' => $clean_amount,
                'date' => $clean_date,
                'amount_type' => $clean_amount_type,
            ];

            $total_input_amount += $clean_amount;
        }

        if (($total_input_amount - $available_amount) > 0.01) {
            echo json_encode(["code" => 400, "msg" => "Gagal! Total termin aktif melebihi sisa nominal CBR setelah dikurangi termin yang sudah diputuskan."]);
            return;
        }

        $remaining_amount = round($available_amount - $total_input_amount, 4);
        $final_rows = [];

        foreach ($pending_rows as $row) {
            $final_rows[] = [
                'amount' => $row['amount'],
                'date' => $row['date'],
                'amount_type' => $row['amount_type'],
            ];
        }

        if ($remaining_amount > 0.01) {
            $final_rows[] = [
                'amount' => $remaining_amount,
                'date' => '',
                'amount_type' => 'AP',
            ];
        }

        if ($remaining_amount < -0.01) {
            echo json_encode(["code" => 400, "msg" => "Gagal! Akumulasi nominal termin melebihi total batas anggaran CBR asli."]);
            return;
        }

        // --- PROSES TRANSAKSI SIMPAN KE DATABASE (Lolos Validasi) ---
        $this->db->trans_start();

        // Hindari race: Presdir mungkin memproses termin setelah modal Accounting dibuka.
        $current_locked_total = (float) ($this->db->select_sum('Amount_Termin', 'total')
            ->where('CBReq_No', $cbreq_no)
            ->where('Status_AppvPresdir !=', 0)
            ->get('Ttrx_Cbr_Approval_Termin')->row()->total ?? 0);
        if (abs($current_locked_total - $locked_total) > 0.01) {
            $this->db->trans_rollback();
            echo json_encode(["code" => 409, "msg" => "Data termin berubah karena baru saja diproses President Director. Tutup modal lalu buka kembali."]);
            return;
        }

        // Bersihkan baris lama yang masih berstatus 0 (Awaiting)
        $this->db->where('CBReq_No', $cbreq_no);
        $this->db->where('Status_AppvPresdir', 0);
        $this->db->delete('Ttrx_Cbr_Approval_Termin');

        $max_locked_termin = (int) ($this->db->select_max('Termin_Ke', 'max_termin')
            ->where('CBReq_No', $cbreq_no)
            ->where('Status_AppvPresdir !=', 0)
            ->get('Ttrx_Cbr_Approval_Termin')->row()->max_termin ?? 0);
        $inserted_pending = $max_locked_termin;
        $trx = $this->db->where('CBReq_No', $cbreq_no)->get('Ttrx_Cbr_Approval')->row();

        foreach ($final_rows as $row) {
            $termin_data = [
                'CBReq_No'           => $cbreq_no,
                'Termin_Ke'          => ++$inserted_pending,
                'Amount_Termin'      => (float) $row['amount'],
                'Currency_ID'        => $currency_id,
                'Payment_Plan_Date'  => $row['date'],
                'Amount_Type'        => $row['amount_type'],
                'Status_AppvPresdir' => 0,
                'AppvPresdir_By'     => $trx->AppvPresidentDirector_By,
                'Rec_Created_At'     => date('Y-m-d H:i:s'),
                'Created_By'         => $this->session->userdata('sys_sba_username'),
                'Last_Updated_By'    => $this->session->userdata('sys_sba_username'),
                'Last_Updated_At'    => date('Y-m-d H:i:s')
            ];

            $this->db->insert('Ttrx_Cbr_Approval_Termin', $termin_data);
        }

        $this->db->trans_complete();

        if ($this->db->trans_status() === FALSE) {
            $response = ["code" => 500, "msg" => "Gagal menyimpan data ke database server."];
        } else {
            $response = ["code" => 200, "msg" => "Susunan termin pembayaran berhasil disimpan!"];
        }

        echo json_encode($response);
    }
}
