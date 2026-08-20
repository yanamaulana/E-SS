<?php
defined('BASEPATH') or exit('No direct script access allowed');

class CbrPaymentStatus extends CI_Controller
{
    private $Date;
    private $DateTime;
    private $layout = 'layout';
    private $TmstTrxSettingSteppApprovalCbr = 'TmstTrxSettingSteppApprovalCbr';
    private $HRQview_Employee_Detail = 'HRQviewEmployeeDetail';
    private $Tmst_User_NonHR = 'Tmst_User_NonHR';
    private $QviewSettingStepApproval = 'QviewSettingStepApproval';
    private $ERPQview_User_Employee = 'ERPQview_User_Employee';
    private $Ttrx_Cbr_Approval = 'Ttrx_Cbr_Approval';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->HR = $this->load->database('HR', TRUE);
        $this->Date = date("Y-m-d");
        $this->DateTime = date("Y-m-d H:i:s");
        $this->load->model('m_helper', 'help');
        $this->load->model('m_DataTable', 'M_Datatables');

        $username = $this->session->userdata('sys_sba_username');
        $has_permission = $this->db->where('UserName', $username)
            ->count_all_results('tmst_user_check_payment_permission') > 0;
        if (!$has_permission) {
            show_error('You are not authorized to manage CBR payment status.', 403, 'Forbidden');
        }
    }

    public function index()
    {
        $this->data['page_title'] = "CBR Payment Status";
        $this->data['page_content'] = "cbr_app/payment_status";

        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/cbr_app/payment_status.js?v=' . time() . '""></script>
        <script src="' . base_url() . 'assets/Pages/cbr_app/payment_status_history.js?v=' . time() . '"></script>';

        $this->load->view($this->layout, $this->data);
    }

    private function Sync_Header_Status($cbreq_no, $last_reason = NULL)
    {
        // Ambil data user dan waktu saat ini
        $change_by = $this->session->userdata('sys_sba_nama');
        $time_change = $this->DateTime;

        // 1. Ambil nilai total nominal CBR dari Header
        $cbr_header = $this->db->select('Amount')->get_where('TAccCashBookReq_Header', ['CBReq_No' => $cbreq_no])->row_array();
        $total_cbr_amount = (float)($cbr_header['Amount'] ?? 0);

        // Payment hanya dihitung dari termin yang sudah disetujui Presdir.
        $sum_paid = $this->db->select_sum('Amount_Termin', 'total')
            ->get_where('Ttrx_Cbr_Approval_Termin', ['CBReq_No' => $cbreq_no, 'Status_AppvPresdir' => 1, 'Termin_Payment_status' => 1])
            ->row_array();
        $total_paid_termin = (float)($sum_paid['total'] ?? 0);

        // 4. Hitung akumulasi dari Termin yang DI-REJECT Bank (Payment Status = 2)
        $sum_rejected_payment = $this->db->select_sum('Amount_Termin', 'total')
            ->get_where('Ttrx_Cbr_Approval_Termin', ['CBReq_No' => $cbreq_no, 'Status_AppvPresdir' => 1, 'Termin_Payment_status' => 2])
            ->row_array();
        $total_rejected_payment_termin = (float)($sum_rejected_payment['total'] ?? 0);

        $is_any_payment_rejected = $this->db->where([
            'CBReq_No' => $cbreq_no,
            'Status_AppvPresdir' => 1,
            'Termin_Payment_status' => 2
        ])->count_all_results('Ttrx_Cbr_Approval_Termin') > 0;

        // --- UPDATE STATUS PAYMENT (BANK) ---
        if (abs($total_paid_termin - $total_cbr_amount) < 0.01) {
            // Fully Paid
            $this->db->where('CBReq_No', $cbreq_no)->update($this->Ttrx_Cbr_Approval, [
                'Payment_Status' => 1,
                'Payment_Status_Time_Change' => $time_change,
                'Payment_Status_Change_By' => $change_by
            ]);
        } elseif ($is_any_payment_rejected > 0) {
            // Siapkan data update dasar untuk kondisi penolakan
            $update_payment_data = [
                'Payment_Status' => 2, // Payment Rejected
                'Payment_Status_Time_Change' => $time_change,
                'Payment_Status_Change_By' => $change_by
            ];

            // LOGIKA BARU: Gunakan abs() bawaan PHP, bukan Math.abs()
            if (abs($total_rejected_payment_termin - $total_cbr_amount) < 0.01 && !empty($last_reason)) {
                $update_payment_data['Reject_Payment_Reason'] = $last_reason;
            }

            $this->db->where('CBReq_No', $cbreq_no)->update($this->Ttrx_Cbr_Approval, $update_payment_data);
        } elseif ($total_paid_termin > 0 && $total_paid_termin < $total_cbr_amount) {
            // Partially Paid
            $this->db->where('CBReq_No', $cbreq_no)->update($this->Ttrx_Cbr_Approval, [
                'Payment_Status' => 3,
                'Payment_Status_Time_Change' => $time_change,
                'Payment_Status_Change_By' => $change_by
            ]);
        } else {
            // Semua keputusan pembayaran telah dikembalikan ke waiting.
            $this->db->where('CBReq_No', $cbreq_no)->update($this->Ttrx_Cbr_Approval, [
                'Payment_Status' => 0,
                'Payment_Status_Time_Change' => $time_change,
                'Payment_Status_Change_By' => $change_by,
                'Reject_Payment_Reason' => NULL
            ]);
        }
    }

    private function is_cbr_open($cbreq_no)
    {
        return $this->db->where('CBReq_No', $cbreq_no)
            ->group_start()->where('isClose IS NULL', NULL, FALSE)->or_where('isClose', 0)->group_end()
            ->count_all_results('TAccCashBookReq_Header') === 1;
    }


    public function approve_submission()
    {
        $Inputs = $this->input->post('Termin_SysID');
        if (empty($Inputs) || !is_array($Inputs)) {
            return $this->help->Fn_resulting_response(['code' => 400, 'msg' => 'No termin selected.']);
        }
        $Inputs = array_values(array_unique(array_filter(array_map('intval', $Inputs))));
        $unique_cbr = [];

        $this->db->trans_start();
        foreach ($Inputs as $sysId) {
            $termin = $this->db->get_where('Ttrx_Cbr_Approval_Termin', [
                'SysID' => $sysId,
                'Status_AppvPresdir' => 1,
                'Termin_Payment_status' => 0
            ])->row();
            if (!$termin) {
                $this->db->trans_rollback();
                return $this->help->Fn_resulting_response(['code' => 409, 'msg' => "Termin ID {$sysId} is invalid or no longer waiting for payment."]);
            }
            if (!$this->is_cbr_open($termin->CBReq_No)) {
                $this->db->trans_rollback();
                return $this->help->Fn_resulting_response(['code' => 409, 'msg' => "CBR {$termin->CBReq_No} is closed or invalid."]);
            }
            $CBReq_No = $termin->CBReq_No;
            $unique_cbr[$CBReq_No] = true; // Simpan CBR untuk di-sync nanti

            $this->db->where('SysID', $sysId)
                ->where('Status_AppvPresdir', 1)
                ->where('Termin_Payment_status', 0)
                ->update('Ttrx_Cbr_Approval_Termin', [
                    'Termin_Payment_status' => 1,
                    'Termin_Payment_status_by' => $this->session->userdata('sys_sba_nama'),
                    'Termin_Payment_status_at' => $this->DateTime,
                    'Reject_Payment_Reason' => NULL,
                ]);
            if ($this->db->affected_rows() !== 1) {
                $this->db->trans_rollback();
                return $this->help->Fn_resulting_response(['code' => 409, 'msg' => "Termin ID {$sysId} was already processed."]);
            }
        }

        // Sinkronisasi Header
        foreach (array_keys($unique_cbr) as $cbr) {
            $this->Sync_Header_Status($cbr);
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
                'msg' => 'Cash Book Requisition Payment successfully Approved !',
            ]);
        }
    }

    public function reject_submission()
    {
        $Inputs = $this->input->post('Termin_SysID');
        $rejection_reason = trim((string)$this->input->post('rejection_reason'));
        if (empty($Inputs) || !is_array($Inputs) || $rejection_reason === '') {
            return $this->help->Fn_resulting_response(['code' => 400, 'msg' => 'Termin selection and rejection reason are required.']);
        }
        $Inputs = array_values(array_unique(array_filter(array_map('intval', $Inputs))));
        $unique_cbr = [];

        $this->db->trans_start();
        foreach ($Inputs as $sysId) {
            $termin = $this->db->get_where('Ttrx_Cbr_Approval_Termin', [
                'SysID' => $sysId,
                'Status_AppvPresdir' => 1,
                'Termin_Payment_status' => 0
            ])->row();
            if (!$termin) {
                $this->db->trans_rollback();
                return $this->help->Fn_resulting_response(['code' => 409, 'msg' => "Termin ID {$sysId} is invalid or no longer waiting for payment."]);
            }
            if (!$this->is_cbr_open($termin->CBReq_No)) {
                $this->db->trans_rollback();
                return $this->help->Fn_resulting_response(['code' => 409, 'msg' => "CBR {$termin->CBReq_No} is closed or invalid."]);
            }
            $CBReq_No = $termin->CBReq_No;
            $Termin_Ke = $termin->Termin_Ke;
            $unique_cbr[$CBReq_No] = true;

            // UPDATE SEKARANG MENYIMPAN ALASAN REJECT PER TERMIN
            $this->db->where('SysID', $sysId)
                ->where('Status_AppvPresdir', 1)
                ->where('Termin_Payment_status', 0)
                ->update('Ttrx_Cbr_Approval_Termin', [
                    'Termin_Payment_status' => 2,
                    'Termin_Payment_status_by' => $this->session->userdata('sys_sba_nama'),
                    'Termin_Payment_status_at' => $this->DateTime,
                    'Reject_Payment_Reason' => $rejection_reason, // <-- SEKARANG SUDAH AKTIF bray!
                ]);
            if ($this->db->affected_rows() !== 1) {
                $this->db->trans_rollback();
                return $this->help->Fn_resulting_response(['code' => 409, 'msg' => "Termin ID {$sysId} was already processed."]);
            }

            // Tetap catat ke history approval global sebagai audit trail tambahan
            $this->help->record_history_approval($CBReq_No, "Termin $Termin_Ke: " . $rejection_reason);
        }

        foreach (array_keys($unique_cbr) as $cbr) {
            $this->Sync_Header_Status($cbr, $rejection_reason);
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
                'msg' => 'Cash Book Requisition Payment successfully Rejected !',
            ]);
        }
    }

    public function revoke_approval()
    {
        $TerminIdx = $this->input->post('TerminIdx'); // Assuming an array of SysIDs
        if (empty($TerminIdx)) {
            return $this->help->Fn_resulting_response(['code' => 400, 'msg' => 'No items selected for revocation.']);
        }

        $validation_errors = [];
        $items_to_process = []; // Stores validated termin data

        // --- PRE-VALIDATE ALL ITEMS BEFORE STARTING TRANSACTION ---
        foreach ($TerminIdx as $SysID) {
            $termin = $this->db->get_where('Ttrx_Cbr_Approval_Termin', ['SysID' => $SysID])->row();

            if (!$termin) {
                $validation_errors[] = "Termin with SysID $SysID not found.";
                continue;
            }

            // Revoke hanya berlaku untuk keputusan "tidak jadi bayar".
            if ($termin->Status_AppvPresdir != 1 || $termin->Termin_Payment_status != 2) {
                $validation_errors[] = "Termin #{$termin->Termin_Ke} from CBR {$termin->CBReq_No} is not an approved-Presdir rejected payment.";
                continue;
            }

            $items_to_process[] = $termin;
        }

        if (!empty($validation_errors)) {
            return $this->help->Fn_resulting_response([
                'code' => 400,
                'msg'  => 'Revoke Approval Failed:',
                'details' => $validation_errors
            ]);
        }

        $unique_cbr_to_sync = [];
        $revoked_items_count = 0;

        $this->db->trans_start();

        foreach ($items_to_process as $termin) {
            // 1. Record history
            $max_sub_q = $this->db->select_max('SubmissionCount', 'max_count')
                ->where('CBReq_No', $termin->CBReq_No)
                ->get('Thst_Trx_Cbr_Approval_Termin')
                ->row();

            $submission_count = ($max_sub_q && $max_sub_q->max_count !== null) ? (int)$max_sub_q->max_count + 1 : 1;

            $history_data = [
                'SubmissionCount'       => $submission_count,
                'SysID'                 => $termin->SysID,
                'CBReq_No'              => $termin->CBReq_No,
                'Termin_Ke'             => $termin->Termin_Ke,
                'Amount_Termin'         => $termin->Amount_Termin,
                'Payment_Plan_Date'     => $termin->Payment_Plan_Date,
                'Status_AppvPresdir'    => $termin->Status_AppvPresdir,
                'Termin_Payment_status' => $termin->Termin_Payment_status,
                'Reject_Payment_Reason' => 'Revoked Payment Status, Old : ' . $termin->Termin_Payment_status_by . '--' . $termin->Termin_Payment_status_at,
                'Created_By'            => $this->session->userdata('sys_sba_username'),
                'Created_at'            => $this->DateTime
            ];
            $this->db->insert('Thst_Trx_Cbr_Approval_Termin', $history_data);

            // 2. Rollback payment status in Ttrx_Cbr_Approval_Termin
            $this->db->where('SysID', $termin->SysID)
                ->where('Status_AppvPresdir', 1)
                ->where('Termin_Payment_status', 2)
                ->update('Ttrx_Cbr_Approval_Termin', [
                    'Termin_Payment_status'      => 0, // Set back to Pending
                    'Termin_Payment_status_by'   => NULL,
                    'Termin_Payment_status_at'   => NULL,
                    'Reject_Payment_Reason'      => NULL // Clear rejection reason
                ]);
            if ($this->db->affected_rows() !== 1) {
                $this->db->trans_rollback();
                return $this->help->Fn_resulting_response(['code' => 409, 'msg' => "Termin ID {$termin->SysID} was changed by another process."]);
            }

            $unique_cbr_to_sync[$termin->CBReq_No] = true;
            $revoked_items_count++;
        }

        // 3. Synchronize header status for affected CBRs
        foreach (array_keys($unique_cbr_to_sync) as $cbr_no) {
            $this->Sync_Header_Status($cbr_no);
        }

        $this->db->trans_complete();

        if ($this->db->trans_status() === FALSE) {
            $this->db->trans_rollback();
            return $this->help->Fn_resulting_response([
                'code' => 505,
                'msg'  => 'Database transaction failed during revocation. All changes have been rolled back.',
            ]);
        } else {
            $this->db->trans_commit();
            return $this->help->Fn_resulting_response([
                'code' => 200,
                'msg' => $revoked_items_count . " item(s) payment status successfully revoked.",
            ]);
        }
    }

    public function Proses_Excel()
    {
        // 1. Pastikan request berasal dari AJAX
        if (!$this->input->is_ajax_request()) {
            exit('No direct script access allowed');
        }

        // 2. Validasi apakah ada file yang diunggah
        if (!isset($_FILES['file_excel']['name']) || empty($_FILES['file_excel']['name'])) {
            echo json_encode(['code' => 500, 'msg' => 'Pilih file Excel terlebih dahulu!']);
            return;
        }

        $file_tmp = $_FILES['file_excel']['tmp_name'];
        $file_ext = pathinfo($_FILES['file_excel']['name'], PATHINFO_EXTENSION);

        // 3. Validasi Ekstensi File
        $allowed_ext = ['xls', 'xlsx'];
        if (!in_array(strtolower($file_ext), $allowed_ext)) {
            echo json_encode(['code' => 500, 'msg' => 'Format file tidak didukung! Gunakan .xls atau .xlsx']);
            return;
        }

        try {
            $reader = \PhpOffice\PhpSpreadsheet\IOFactory::createReaderForFile($file_tmp);
            $reader->setReadDataOnly(true); // Membaca data saja agar lebih cepat
            $spreadsheet = $reader->load($file_tmp);

            $sheetData = $spreadsheet->getActiveSheet()->toArray(null, true, true, true);

            $selected_cbr = [];
            $cbr_rejection_reasons = []; // Untuk menyimpan alasan penolakan per CBR jika ada

            foreach ($sheetData as $rowIndex => $row) {
                if ($rowIndex == 1) continue; // Skip baris pertama (header)

                $cbr_no = trim($row['A'] ?? '');
                $action = trim($row['B'] ?? '');
                $termin_ke = trim($row['C'] ?? ''); // BACA KOLOM C UNTUK TERMIN KE

                // Pastikan ketiga kolom (CBR, Action, dan Termin) tidak kosong
                if (!empty($cbr_no) && $action !== '' && $termin_ke !== '') {
                    $selected_cbr[] = [
                        'CBR_NUMBER' => $cbr_no,
                        'ACTION'     => (int)$action,
                        'TERMIN_KE'  => (int)$termin_ke // Simpan Termin Ke
                    ];
                    if ((int)$action == 2) {
                        $cbr_rejection_reasons[$cbr_no] = "Rejected via Excel bulk upload"; // Tetapkan alasan generik jika ditolak
                    }
                }
            }

            if (empty($selected_cbr)) {
                echo json_encode(['code' => 500, 'msg' => 'Data Excel kosong atau format tidak sesuai. Pastikan Kolom CBR, Action, dan Termin terisi.']);
                return;
            }

            $username = $this->session->userdata('sys_sba_username');
            $generic_rejection_reason = "Rejected via Excel bulk upload"; // Alasan generik untuk penolakan massal
            $unique_cbr = []; // Array untuk menampung CBR unik agar sinkronisasi lebih efisien
            $seen_rows = [];

            $this->db->trans_start();

            foreach ($selected_cbr as $data) {
                $action_flag = $data['ACTION']; // Angka 1 (Approve) atau 2 (Reject) dari Excel

                if ($action_flag == 1) {
                    $status_update = 1; // 1 untuk Approved
                } else if ($action_flag == 2) {
                    $status_update = 2; // 2 untuk Rejected
                } else {
                    $this->db->trans_rollback();
                    echo json_encode(['code' => 400, 'msg' => "Invalid ACTION for CBR {$data['CBR_NUMBER']} termin {$data['TERMIN_KE']}. Use 1 or 2."]);
                    return;
                }

                $row_key = $data['CBR_NUMBER'] . '|' . $data['TERMIN_KE'];
                if (isset($seen_rows[$row_key])) {
                    $this->db->trans_rollback();
                    echo json_encode(['code' => 400, 'msg' => "Duplicate Excel row: {$row_key}."]);
                    return;
                }
                $seen_rows[$row_key] = true;

                // SysID tetap internal: resolve dari tiga kolom Excel yang diketahui user.
                $matches = $this->db->get_where('Ttrx_Cbr_Approval_Termin', [
                    'CBReq_No' => $data['CBR_NUMBER'],
                    'Termin_Ke' => $data['TERMIN_KE'],
                    'Status_AppvPresdir' => 1,
                    'Termin_Payment_status' => 0,
                ]);
                if ($matches->num_rows() !== 1) {
                    $this->db->trans_rollback();
                    echo json_encode(['code' => 409, 'msg' => "CBR {$data['CBR_NUMBER']} termin {$data['TERMIN_KE']} was not found uniquely or is no longer waiting."]);
                    return;
                }
                $termin = $matches->row();
                if (!$this->is_cbr_open($termin->CBReq_No)) {
                    $this->db->trans_rollback();
                    echo json_encode(['code' => 409, 'msg' => "CBR {$termin->CBReq_No} is closed or invalid."]);
                    return;
                }

                $update_data_termin = [
                    'Termin_Payment_status' => $status_update,
                    'Termin_Payment_status_at' => $this->DateTime,
                    'Termin_Payment_status_by' => $username
                ];

                if ($action_flag == 2) { // Jika ini adalah penolakan
                    $update_data_termin['Reject_Payment_Reason'] = $generic_rejection_reason;
                    // Catat riwayat penolakan untuk setiap termin yang ditolak
                    $this->help->record_history_approval($data['CBR_NUMBER'], "Termin " . $data['TERMIN_KE'] . ": " . $generic_rejection_reason);
                }

                // Kumpulkan CBR_NUMBER unik
                $unique_cbr[$data['CBR_NUMBER']] = true;

                // UPDATE KE TABEL TERMIN
                $this->db->where('SysID', $termin->SysID)
                    ->where('Status_AppvPresdir', 1)
                    ->where('Termin_Payment_status', 0)
                    ->update('Ttrx_Cbr_Approval_Termin', $update_data_termin);
                if ($this->db->affected_rows() !== 1) {
                    $this->db->trans_rollback();
                    echo json_encode(['code' => 409, 'msg' => "CBR {$data['CBR_NUMBER']} termin {$data['TERMIN_KE']} was already processed."]);
                    return;
                }
            }

            // JALANKAN SINKRONISASI HEADER
            foreach (array_keys($unique_cbr) as $cbr) {
                $this->Sync_Header_Status($cbr);
            }

            // Pindahkan trans_complete() ke sini agar mencakup semua update
            $this->db->trans_complete();

            if ($this->db->trans_status() === FALSE) {
                echo json_encode([
                    'code' => 500,
                    'msg' => 'Gagal memproses data. Terjadi kesalahan pada database dan transaksi telah dibatalkan.'
                ]);
                return; // Tambahkan return agar tidak lanjut ke echo sukses
            }

            $total_processed = count($selected_cbr);
            echo json_encode([
                'code' => 200,
                'msg' => "Berhasil memproses $total_processed dokumen termin CBR dari Excel!"
            ]);
        } catch (\PhpOffice\PhpSpreadsheet\Reader\Exception $e) {
            echo json_encode([
                'code' => 500,
                'msg' => 'Gagal membaca file Excel: ' . $e->getMessage()
            ]);
        } catch (Exception $e) {
            echo json_encode([
                'code' => 500,
                'msg' => 'Terjadi kesalahan sistem: ' . $e->getMessage()
            ]);
        }
    }


    public function DT_List_To_Approve()
    {
        $requestData = $_REQUEST;
        $columns = array(
            0 => 'H.CBReq_No',
            1 => 'H.CBReq_No',
            2 => 'TM.Termin_Ke', // Tambahan Termin
            3 => 'H.Type',
            4 => 'H.Document_Date',
            5 => 'H.Currency_Id',
            6 => 'TM.Amount_Termin', // Amount dari termin
            7 => 'H.Document_Number',
            8 => 'H.Descript',
            9 => 'TM.Termin_Payment_status', // Status dari termin
            10 => 'TA.UserDivision',
            11 => 'U.First_Name',
            12 => 'TM.Payment_Plan_Date' // Plan date dari termin
        );
        $order  = $columns[$requestData['order']['0']['column']] ?? 'H.Document_Date';
        $dir    = $requestData['order']['0']['dir'] ?? 'DESC';

        // Hanya tarik Termin yang sudah di-Approve Presdir (1) dan Belum Dibayar (0)
        $sql = "SELECT DISTINCT 
                TM.SysID AS Termin_SysID, H.CBReq_No, TM.Termin_Ke, H.Type, H.Document_Date, H.Document_Number, 
                H.Descript, TM.Amount_Termin AS Amount, H.Currency_Id, 
                TA.UserDivision, U.First_Name, TM.Termin_Payment_status AS Payment_Status, 
                TM.Payment_Plan_Date, TA.Legitimate,
                H.baseamount, H.curr_rate, H.Approval_Status, H.Creation_DateTime, 
                H.Created_By, H.Last_Update, H.Acc_ID, H.Approve_Date
                FROM Ttrx_Cbr_Approval_Termin TM
                INNER JOIN TAccCashBookReq_Header H ON TM.CBReq_No = H.CBReq_No
                INNER JOIN Ttrx_Cbr_Approval TA ON TM.CBReq_No = TA.CBReq_No
                INNER JOIN TUserPersonal U ON H.Created_By = U.User_ID
                WHERE H.Type='D' AND H.Company_ID = 2 AND ISNULL(H.isSPJ,0) = 0
                AND H.Approval_Status = 3
                AND H.CBReq_Status = 3
                AND (H.isClose IS NULL OR H.isClose = 0)
                AND TM.Status_AppvPresdir = 1 
                AND TM.Termin_Payment_status = 0 ";

        $totalData = $this->db->query($sql)->num_rows();

        if (!empty($requestData['search']['value'])) {
            $searchValue = $this->db->escape_like_str($requestData['search']['value']);
            $sql .= " AND (H.CBReq_No LIKE '%$searchValue%' ESCAPE '!'
                      OR U.First_Name LIKE '%$searchValue%' ESCAPE '!'
                      OR H.Document_Number LIKE '%$searchValue%' ESCAPE '!'
                      OR H.Descript LIKE '%$searchValue%' ESCAPE '!') ";
        }

        // var_dump($sql); // Debug: Tampilkan query sebelum eksekusi
        // die;

        $totalFiltered = $this->db->query($sql)->num_rows();
        $sql .= " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";
        $query = $this->db->query($sql);

        $data = array();
        foreach ($query->result_array() as $row) {
            $nestedData = array();

            $nestedData['Termin_SysID'] = $row['Termin_SysID'];
            $nestedData['CBReq_No'] = $row['CBReq_No'];
            $nestedData['Termin_Ke'] = $row['Termin_Ke'];
            $nestedData['Type'] = $row['Type'];
            $nestedData['Document_Date'] = $row['Document_Date'];
            $nestedData['Currency_Id'] = $row['Currency_Id'];
            $nestedData['Amount'] = $row['Amount'];
            $nestedData['Document_Number'] = $row['Document_Number'];
            $nestedData['Descript'] = $row['Descript'];
            $nestedData['baseamount'] = $row['baseamount'];
            $nestedData['curr_rate'] = $row['curr_rate'];
            $nestedData['Approval_Status'] = $row['Approval_Status'];
            $nestedData['Legitimate'] = $row['Legitimate'];
            $nestedData['Payment_Status'] = $row['Payment_Status'];
            $nestedData['Creation_DateTime'] = $row['Creation_DateTime'];
            $nestedData['Created_By'] = $row['Created_By'];
            $nestedData['UserDivision'] = $row['UserDivision'];
            $nestedData['First_Name'] = $row['First_Name'];
            $nestedData['Last_Update'] = $row['Last_Update'];
            $nestedData['Acc_ID'] = $row['Acc_ID'];
            $nestedData['Approve_Date'] = $row['Approve_Date'];
            $nestedData['Payment_Plan_Date'] = !empty($row['Payment_Plan_Date']) ? date('Y-m-d', strtotime($row['Payment_Plan_Date'])) : '';

            $data[] = $nestedData;
        }

        echo json_encode([
            "draw" => intval($requestData['draw']),
            "recordsTotal" => intval($totalData),
            "recordsFiltered" => intval($totalFiltered),
            "data" => $data,
        ]);
    }

    public function DT_List_History_Approval()
    {
        $requestData = $_REQUEST;
        $columns = array(
            0 => 'H.CBReq_No',
            1 => 'H.CBReq_No',
            2 => 'TM.Termin_Ke',
            3 => 'H.Document_Date',
            4 => 'H.Currency_Id',
            5 => 'TM.Amount_Termin',
            6 => 'H.Document_Number',
            7 => 'H.Descript',
            8 => 'TA.Status_AppvPresidentDirector',
            9 => 'TM.Termin_Payment_status',
            10 => 'TA.UserDivision',
            11 => 'U.First_Name',
        );
        $order = $columns[$requestData['order'][0]['column']] ?? 'H.Document_Date';
        $dir = $requestData['order'][0]['dir'] ?? 'DESC';
        $from = $this->input->post('from');
        $until = $this->input->post('until');
        $column_range = $this->input->post('column_range');

        $sql = "SELECT DISTINCT
                    TM.SysID AS SysID_Termin,
                    H.CBReq_No,
                    TM.Termin_Ke,
                    H.Type,
                    H.Document_Date,
                    H.Document_Number,
                    H.Acc_ID,
                    H.Descript,
                    TM.Amount_Termin AS Amount,
                    H.baseamount,
                    H.curr_rate,
                    H.Approval_Status,
                    H.CBReq_Status,
                    H.Paid_Status,
                    H.Creation_DateTime,
                    H.Created_By,
                    U.First_Name AS Created_By_Name,
                    H.Last_Update,
                    H.Update_By,
                    H.Currency_Id,
                    H.Approve_Date,
                    TA.IsAppvStaff, TA.Status_AppvStaff, TA.AppvStaff_By, TA.AppvStaff_Name, TA.AppvStaff_At,
                    TA.IsAppvChief, TA.Status_AppvChief, TA.AppvChief_By, TA.AppvChief_Name, TA.AppvChief_At,
                    TA.IsAppvAsstManager, TA.Status_AppvAsstManager, TA.AppvAsstManager_By, TA.AppvAsstManager_Name, TA.AppvAsstManager_At,
                    TA.IsAppvManager, TA.Status_AppvManager, TA.AppvManager_By, TA.AppvManager_Name, TA.AppvManager_At,
                    TA.IsAppvSeniorManager, TA.Status_AppvSeniorManager, TA.AppvSeniorManager_By, TA.AppvSeniorManager_Name, TA.AppvSeniorManager_At,
                    TA.IsAppvGeneralManager, TA.Status_AppvGeneralManager, TA.AppvGeneralManager_By, TA.AppvGeneralManager_Name, TA.AppvGeneralManager_At,
                    TA.IsAppvAdditional, TA.Status_AppvAdditional, TA.AppvAdditional_By, TA.AppvAdditional_Name, TA.AppvAdditional_At,
                    TA.IsAppvDirector, TA.Status_AppvDirector, TA.AppvDirector_By, TA.AppvDirector_Name, TA.AppvDirector_At,
                    TA.IsAppvPresidentDirector, TA.Status_AppvPresidentDirector, TA.AppvPresidentDirector_By, TA.AppvPresidentDirector_Name, TA.AppvPresidentDirector_At,
                    TA.IsAppvFinanceDirector, TA.Status_AppvFinanceDirector, TA.AppvFinanceDirector_By, TA.AppvFinanceDirector_Name, TA.AppvFinanceDirector_At,
                    TA.UserName_User, TA.Rec_Created_At, TA.Legitimate,
                    TA.IsAppvFinancePerson, TA.Status_AppvFinancePerson, TA.AppvFinancePerson_By, TA.AppvFinancePerson_Name, TA.AppvFinancePerson_At,
                    TM.Termin_Payment_status AS Payment_Status,
                    TM.Termin_Payment_status_at AS Payment_Status_Time_Change,
                    TM.Termin_Payment_status_by AS Payment_Status_Change_By,
                    TA.UserDivision
                FROM
                    Ttrx_Cbr_Approval_Termin TM
                INNER JOIN TAccCashBookReq_Header H ON TM.CBReq_No = H.CBReq_No
                INNER JOIN Ttrx_Cbr_Approval TA ON TM.CBReq_No = TA.CBReq_No
                INNER JOIN TUserPersonal U ON H.Created_By = U.User_ID
                WHERE
                    H.Type = 'D'
                    AND H.Company_ID = 2
                    AND ISNULL(H.isSPJ, 0) = 0
                    AND H.Approval_Status = 3
                    AND H.CBReq_Status = 3
                    AND (H.isClose IS NULL OR H.isClose = 0)
                    AND TA.CBReq_No IS NOT NULL
                    AND TM.Termin_Payment_status <> 0
                    AND $column_range >= {d '$from'}
                    AND $column_range <= {d '$until'}";

        $totalData = $this->db->query($sql)->num_rows();
        if (!empty($requestData['search']['value'])) {
            $searchValue = $this->db->escape_like_str($requestData['search']['value']);
            $sql .= " AND (H.CBReq_No LIKE '%$searchValue%' ESCAPE '!'
                      OR U.First_Name LIKE '%$searchValue%' ESCAPE '!'
                      OR H.Document_Number LIKE '%$searchValue%' ESCAPE '!'
                      OR H.Descript LIKE '%$searchValue%' ESCAPE '!') ";
        }
        //----------------------------------------------------------------------------------
        $totalFiltered = $this->db->query($sql)->num_rows();
        $sql .= " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";
        $query = $this->db->query($sql);
        $data = array();
        foreach ($query->result_array() as $row) {
            $nestedData = array();
            $nestedData['SysID_Termin'] = $row['SysID_Termin'];
            $nestedData['CBReq_No'] = $row['CBReq_No'];
            $nestedData['Termin_Ke'] = $row['Termin_Ke'];
            $nestedData['Type'] = $row['Type'];
            $nestedData['Document_Date'] = $row['Document_Date'];
            $nestedData['Acc_ID'] = $row['Acc_ID'];
            $nestedData['Descript'] = $row['Descript'];
            $nestedData['Document_Number'] = $row['Document_Number'];
            $nestedData['Amount'] = $row['Amount'];
            $nestedData['baseamount'] = $row['baseamount'];
            $nestedData['curr_rate'] = $row['curr_rate'];
            $nestedData['Approval_Status'] = $row['Approval_Status'];
            $nestedData['Paid_Status'] = $row['Paid_Status'];
            $nestedData['Creation_DateTime'] = $row['Creation_DateTime'];
            $nestedData['Created_By'] = $row['Created_By'];
            $nestedData['First_Name'] = $row['Created_By_Name'];
            $nestedData['Last_Update'] = $row['Last_Update'];
            $nestedData['Update_By'] = $row['Update_By'];
            $nestedData['Currency_Id'] = $row['Currency_Id'];
            $nestedData['Approve_Date'] = $row['Approve_Date'];
            $nestedData['IsAppvStaff'] = $row['IsAppvStaff'];
            $nestedData['Status_AppvStaff'] = $row['Status_AppvStaff'];
            $nestedData['AppvStaff_By'] = $row['AppvStaff_By'];
            $nestedData['AppvStaff_At'] = $row['AppvStaff_At'];
            $nestedData['IsAppvChief'] = $row['IsAppvChief'];
            $nestedData['Status_AppvChief'] = $row['Status_AppvChief'];
            $nestedData['AppvChief_By'] = $row['AppvChief_By'];
            $nestedData['AppvChief_Name'] = $row['AppvChief_Name'] ?? '';
            $nestedData['AppvChief_At'] = $row['AppvChief_At'];
            $nestedData['IsAppvAsstManager'] = $row['IsAppvAsstManager'];
            $nestedData['Status_AppvAsstManager'] = $row['Status_AppvAsstManager'];
            $nestedData['AppvAsstManager_By'] = $row['AppvAsstManager_By'];
            $nestedData['AppvAsstManager_Name'] = $row['AppvAsstManager_Name'] ?? '';
            $nestedData['AppvAsstManager_At'] = $row['AppvAsstManager_At'];
            $nestedData['IsAppvManager'] = $row['IsAppvManager'];
            $nestedData['Status_AppvManager'] = $row['Status_AppvManager'];
            $nestedData['AppvManager_By'] = $row['AppvManager_By'];
            $nestedData['AppvManager_Name'] = $row['AppvManager_Name'] ?? '';
            $nestedData['AppvManager_At'] = $row['AppvManager_At'];
            $nestedData['IsAppvSeniorManager'] = $row['IsAppvSeniorManager'];
            $nestedData['Status_AppvSeniorManager'] = $row['Status_AppvSeniorManager'];
            $nestedData['AppvSeniorManager_By'] = $row['AppvSeniorManager_By'];
            $nestedData['AppvSeniorManager_Name'] = $row['AppvSeniorManager_Name'] ?? '';
            $nestedData['AppvSeniorManager_At'] = $row['AppvSeniorManager_At'];
            $nestedData['IsAppvGeneralManager'] = $row['IsAppvGeneralManager'];
            $nestedData['Status_AppvGeneralManager'] = $row['Status_AppvGeneralManager'];
            $nestedData['AppvGeneralManager_By'] = $row['AppvGeneralManager_By'];
            $nestedData['AppvGeneralManager_Name'] = $row['AppvGeneralManager_Name'] ?? '';
            $nestedData['AppvGeneralManager_At'] = $row['AppvGeneralManager_At'];

            $nestedData['IsAppvAdditional'] = $row['IsAppvAdditional'];
            $nestedData['Status_AppvAdditional'] = $row['Status_AppvAdditional'];
            $nestedData['AppvAdditional_By'] = $row['AppvAdditional_By'];
            $nestedData['AppvAdditional_Name'] = $row['AppvAdditional_Name'] ?? '';
            $nestedData['AppvAdditional_At'] = $row['AppvAdditional_At'];

            $nestedData['IsAppvFinancePerson'] = $row['IsAppvFinancePerson'];
            $nestedData['Status_AppvFinancePerson'] = $row['Status_AppvFinancePerson'];
            $nestedData['AppvFinancePerson_By'] = $row['AppvFinancePerson_By'];
            $nestedData['AppvFinancePerson_Name'] = $row['AppvFinancePerson_Name'] ?? '';
            $nestedData['AppvFinancePerson_At'] = $row['AppvFinancePerson_At'];

            $nestedData['IsAppvDirector'] = $row['IsAppvDirector'];
            $nestedData['CBReq_Status'] = $row['CBReq_Status'];
            $nestedData['Status_AppvDirector'] = $row['Status_AppvDirector'];
            $nestedData['AppvDirector_By'] = $row['AppvDirector_By'];
            $nestedData['AppvDirector_Name'] = $row['AppvDirector_Name'] ?? '';
            $nestedData['AppvDirector_At'] = $row['AppvDirector_At'];
            $nestedData['IsAppvPresidentDirector'] = $row['IsAppvPresidentDirector'];
            $nestedData['Status_AppvPresidentDirector'] = $row['Status_AppvPresidentDirector'];
            $nestedData['AppvPresidentDirector_By'] = $row['AppvPresidentDirector_By'];
            $nestedData['AppvPresidentDirector_Name'] = $row['AppvPresidentDirector_Name'] ?? '';
            $nestedData['AppvPresidentDirector_At'] = $row['AppvPresidentDirector_At'];
            // $nestedData['IsAppvFinanceStaff'] = $row['IsAppvFinanceStaff'];
            // $nestedData['Status_AppvFinanceStaff'] = $row['Status_AppvFinanceStaff'];
            // $nestedData['AppvFinanceStaff_By'] = $row['AppvFinanceStaff_By'];
            // $nestedData['AppvFinanceStaff_At'] = $row['AppvFinanceStaff_At'];
            // $nestedData['IsAppvFinanceManager'] = $row['IsAppvFinanceManager'];
            // $nestedData['Status_AppvFinanceManager'] = $row['Status_AppvFinanceManager'];
            // $nestedData['AppvFinanceManager_By'] = $row['AppvFinanceManager_By'];
            // $nestedData['AppvFinanceManager_At'] = $row['AppvFinanceManager_At'];
            $nestedData['IsAppvFinanceDirector'] = $row['IsAppvFinanceDirector'];
            $nestedData['Status_AppvFinanceDirector'] = $row['Status_AppvFinanceDirector'];
            $nestedData['AppvFinanceDirector_By'] = $row['AppvFinanceDirector_By'];
            $nestedData['AppvFinanceDirector_Name'] = $row['AppvFinanceDirector_Name'] ?? '';
            $nestedData['AppvFinanceDirector_At'] = $row['AppvFinanceDirector_At'];
            $nestedData['UserName_User'] = $row['UserName_User'];
            $nestedData['Rec_Created_At'] = $row['Rec_Created_At'];
            $nestedData['UserDivision'] = $row['UserDivision'];
            $nestedData['Legitimate'] = $row['Legitimate'];
            $nestedData['Payment_Status'] = $row['Payment_Status'];
            $nestedData['Payment_Status_Time_Change'] = $row['Payment_Status_Time_Change'];
            $nestedData['Payment_Status_Change_By'] = $row['Payment_Status_Change_By'];

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
}
