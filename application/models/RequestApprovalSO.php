<?php
defined('BASEPATH') or exit('No direct script access allowed');

class RequestApprovalSO extends CI_Model
{

    public function __construct()
    {
        parent::__construct();
        // Pastikan library database sudah di-load (bisa juga di autoload.php)
        $this->load->database();
    }

    /**
     * FUNGSI 1: GENERATE NEW ROUTE (Pengganti Action="NewTransaction")
     * Dipanggil saat Insert SO baru. Berfungsi untuk membuat antrean Approval.
     * * @param array $data 
     * @return array ['valid', 'message', 'auto_approval']
     */
    public function generate_new_route($data)
    {
        $reqApprovalID   = $data['ReqApproval_ID'] ?? '';
        $reqApprovalName = $data['RequestApproval_Name'] ?? 'eACCSalesOrder';
        $empID           = $data['Employee_ID'] ?? $this->session->userdata('sys_sba_username');
        $companyID       = $data['Company_ID'] ?? $this->input->cookie('companyid'); // Sesuaikan nama cookie/session
        $amount          = (float) str_replace(',', '', $data['Amount'] ?? 0);

        if (empty($reqApprovalID) || empty($reqApprovalName)) {
            return ['valid' => false, 'message' => 'ReqApproval_ID dan RequestApproval_Name tidak boleh kosong.', 'auto_approval' => false];
        }

        // 1. Dapatkan Data User & Posisi saat ini
        $sqlUser = "SELECT E.Emp_ID, P.Position_ID 
                    FROM THRMEmpPersonalData E
                    INNER JOIN ThrmEmpPosition P ON P.Emp_ID = E.Emp_ID
                    WHERE E.Emp_ID = ? AND P.Company_ID = ?";
        $userPos = $this->db->query($sqlUser, [$empID, $companyID])->result();

        if (empty($userPos)) {
            return ['valid' => false, 'message' => 'Data User atau Posisi tidak ditemukan di database.', 'auto_approval' => false];
        }

        // Ekstrak list Position_ID user (karena bisa rangkap jabatan)
        $positionIDs = array_map(function ($item) {
            return $item->Position_ID;
        }, $userPos);
        $firstPosID  = $positionIDs[0]; // Ambil jabatan utama

        // 2. Dapatkan Step Approval dari Setting Master berdasarkan Range Amount
        $this->db->select('A.RequestApproval_ID, B.SettingApproval_ID, C.SettingApproval_Step, C.ApprovedBy_PosID, C.is_required, A.AppOrder_Type, A.AutoSelf_Approver');
        $this->db->from('THRMSettingApprovalDetail C');
        $this->db->join('THRMSettingApproval B', 'C.SettingApproval_ID = B.SettingApproval_ID');
        $this->db->join('THRMRequestApproval A', 'A.RequestApproval_ID = B.RequestApproval_ID');
        $this->db->where_in('B.RequestBy_PosID', $positionIDs);
        $this->db->where('A.RequestApproval_Name', $reqApprovalName);
        $this->db->where('C.From_Amount <=', $amount);
        $this->db->where('C.To_Amount >=', $amount);
        $this->db->where("LTRIM(RTRIM(ISNULL(C.ApprovedBy_PosID, ''))) !=", '');
        $this->db->group_by('A.RequestApproval_ID, B.SettingApproval_ID, C.SettingApproval_Step, C.ApprovedBy_PosID, C.is_required, A.AppOrder_Type, A.AutoSelf_Approver');
        $this->db->order_by('C.SettingApproval_Step', 'ASC');

        $steps = $this->db->get()->result();

        if (empty($steps)) {
            return ['valid' => false, 'message' => "Setting approval belum diatur untuk nominal " . number_format($amount, 2), 'auto_approval' => false];
        }

        $this->db->trans_begin();

        // 3. Hapus rute lama jika ada (Reset)
        $this->db->where('ReqApproval_ID', $reqApprovalID)->delete('THRMApprovedBy');

        // 4. Siapkan Data Insert & Cek Auto Approval
        $insertData    = [];
        $firstReqFound = false;
        $isAutoApprove = false;

        foreach ($steps as $step) {
            $flagTurn     = 0;
            $appOrderType = (int) $step->AppOrder_Type;

            // Cek apakah transaksinya auto approve
            if ($step->AutoSelf_Approver == 1) {
                $isAutoApprove = true;
            }

            // Logika Turn (Giliran Approve bertingkat)
            if ($appOrderType == 1) { // Order By Step
                if (!$firstReqFound && $step->is_required == 1) {
                    $firstReqFound = true;
                    $flagTurn = 1;
                }
            } else { // Free Order (Bebas)
                $flagTurn = 1;
            }
            $insertData[] = [
                'ReqApproval_ID'           => $reqApprovalID,
                'Employee_ID'              => $empID,
                'Position_ID'              => $firstPosID,
                'LstApprovedBy'            => $step->ApprovedBy_PosID, // Target Posisi Approver
                'Approve_Status'           => 0,
                'LastApprove_Status'       => 0,
                'RequestApproval_ID'       => $step->RequestApproval_ID,
                'SettingApproval_StepData' => $step->SettingApproval_ID . '|' . $step->SettingApproval_Step,
                'is_required'              => $step->is_required,
                'Flag_Turn'                => $flagTurn,
                'appOrder_Type'            => $appOrderType
            ];
        }

        // Insert Batch
        if (!empty($insertData)) {
            $this->db->insert_batch('THRMApprovedBy', $insertData);
        }

        // Cek Transaksi Database
        if ($this->db->trans_status() === FALSE) {
            $this->db->trans_rollback();
            return ['valid' => false, 'message' => 'Gagal menyimpan rute approval ke database.', 'auto_approval' => false];
        } else {
            $this->db->trans_commit();
            return ['valid' => true, 'message' => 'Rute approval berhasil di-generate.', 'auto_approval' => $isAutoApprove];
        }
    }


    /**
     * FUNGSI 2: PROCESS APPROVAL (Pengganti Action="Save")
     * Dipanggil saat Approver menekan tombol Approve / Reject / Revising.
     * * @param array $data 
     * @return array ['valid', 'message', 'last_status']
     */
    public function process_approval($data)
    {
        $reqApprovalID = $data['ReqApproval_ID'] ?? '';
        $empID         = $data['Employee_ID'] ?? $this->session->userdata('sys_sba_userid');
        $approvedByID  = $data['ApprovedBy_ID'] ?? ''; // Primary Key dari THRMApprovedBy
        $status        = (int) ($data['ApprovalStatus'] ?? 0); // 3=Approve, 4=Reject, 5=Revising
        $reason        = $data['ApprovalReason'] ?? '';

        if (empty($reqApprovalID) || empty($approvedByID) || $status == 0) {
            return ['valid' => false, 'message' => 'Data tidak lengkap. Gagal memproses approval.', 'last_status' => 0];
        }

        // 1. Cek Data Approval Saat ini
        $approvalData = $this->db->get_where('THRMApprovedBy', [
            'ReqApproval_ID' => $reqApprovalID,
            'ApprovedBy_ID'  => $approvedByID
        ])->row();

        if (!$approvalData) {
            return ['valid' => false, 'message' => 'Data approval tidak ditemukan.', 'last_status' => 0];
        }

        // 2. Validasi Konkurensi (Mencegah double approve oleh orang lain di step yang sama)
        if (!empty($approvalData->Approved_EmpID) && trim($approvalData->Approved_EmpID) != trim($empID) && $approvalData->Approve_Status != 2) {
            $empInfo = $this->db->get_where('THRMEmpPersonalData', ['Emp_ID' => trim($approvalData->Approved_EmpID)])->row();
            $empName = $empInfo ? ($empInfo->First_Name . ' ' . $empInfo->Last_Name) : 'Approver Lain';
            return ['valid' => false, 'message' => "Step ini sudah dikonfirmasi lebih dulu oleh {$empName}.", 'last_status' => 0];
        }

        // Tentukan Last_Status sementara
        $lastAppSts = 2; // Default Awaiting
        if ($status == 4) $lastAppSts = 4; // Rejected
        if ($status == 5) $lastAppSts = 5; // Revising

        $this->db->trans_begin();

        // 3. Update Record THRMApprovedBy
        $updateData = [
            'Approve_Status'     => $status,
            'Approve_Date'       => date('Y-m-d H:i:s'),
            'Approved_EmpID'     => $empID,
            'Approval_Note'      => $reason,
            'LastApprove_Status' => $lastAppSts // Akan diupdate lagi jika ternyata ini final step
        ];

        $this->db->where('ApprovedBy_ID', $approvedByID)->update('THRMApprovedBy', $updateData);

        // 4. Logika Pindah Giliran (Turn) jika AppOrder_Type = 1 (Order By Step) dan di-Approve (3)
        if ($approvalData->appOrder_Type == 1 && $status >= 3) {
            // Cari approver selanjutnya yang belum approve
            $nextTurn = $this->db->query("
                SELECT ApprovedBy_ID FROM THRMApprovedBy 
                WHERE ReqApproval_ID = ? AND ApprovedBy_ID != ? AND Approve_Status < 3 
                ORDER BY ApprovedBy_ID ASC LIMIT 1
            ", [$reqApprovalID, $approvedByID])->row();

            if ($nextTurn) {
                // Berikan giliran ke approver selanjutnya
                $this->db->where('ApprovedBy_ID', $nextTurn->ApprovedBy_ID)->update('THRMApprovedBy', ['Flag_Turn' => 1]);
            } else {
                // Jika tidak ada next turn, berarti ini FINAL APPROVAL
                $lastAppSts = 3;
                $this->db->where('ReqApproval_ID', $reqApprovalID)->update('THRMApprovedBy', ['LastApprove_Status' => 3]);
            }
        }

        // Jika tipe Free Order (0), kita cek apakah semua Required sudah approve
        if ($approvalData->appOrder_Type == 0 && $status >= 3) {
            $cekUnapprovedRequired = $this->db->query("
                SELECT 1 FROM THRMApprovedBy 
                WHERE ReqApproval_ID = ? AND is_required = 1 AND Approve_Status < 3
             ", [$reqApprovalID])->row();

            if (!$cekUnapprovedRequired) {
                // Semua yang wajib sudah approve, set final
                $lastAppSts = 3;
                $this->db->where('ReqApproval_ID', $reqApprovalID)->update('THRMApprovedBy', ['LastApprove_Status' => 3]);
            }
        }

        // 5. Simpan History Jika Revising (Status = 5)
        if ($lastAppSts == 5) {
            $sqlHistory = "INSERT INTO THRMApprovedByHistory 
                          (ApprovedBy_ID, ReqApproval_ID, Employee_ID, Position_id, Approved_By, Approve_Status, 
                           LastApprove_Status, Approve_Date, Approved_EmpID, Approve_Value, Approve_Leave, 
                           RequestApproval_id, Must_Approved, Approval_Note)
                          SELECT ApprovedBy_ID, ReqApproval_ID, Employee_ID, Position_id, Approved_By, Approve_Status, 
                           LastApprove_Status, Approve_Date, Approved_EmpID, Approve_Value, Approve_Leave, 
                           RequestApproval_id, Must_Approved, Approval_Note 
                          FROM THRMApprovedBy WHERE ApprovedBy_ID = ?";
            $this->db->query($sqlHistory, [$approvedByID]);
        }

        if ($this->db->trans_status() === FALSE) {
            $this->db->trans_rollback();
            return ['valid' => false, 'message' => 'Terjadi kesalahan sistem saat menyimpan data approval.', 'last_status' => 0];
        } else {
            $this->db->trans_commit();
            $statusText = ($status == 3) ? 'Approved' : (($status == 4) ? 'Rejected' : 'Revising');
            return ['valid' => true, 'message' => "Dokumen berhasil di {$statusText}.", 'last_status' => $lastAppSts];
        }
    }


    /**
     * FUNGSI 3: GET APPROVAL LIST (Pengganti Action="Form")
     * Menarik daftar antrean approval untuk di-looping di tampilan HTML (View).
     * * @param string $reqApprovalID (Contoh: Nomor SO)
     * @return array of objects
     */
    public function get_approval_list($reqApprovalID)
    {
        $sql = "SELECT A.ApprovedBy_ID, A.ReqApproval_ID, A.Employee_ID, A.Position_ID, 
                       ISNULL(CONVERT(VARCHAR, A.Approved_By), A.LstApprovedBy) as Approved_By,
                       A.Approved_EmpID, A.Approve_Date, A.Approve_Status, A.Approval_Note, 
                       ISNULL(A.SettingApproval_StepData, '') as SettingApproval_StepData, 
                       A.Is_Required, A.Flag_Turn
                FROM THRMApprovedBy A
                WHERE A.ReqApproval_ID = ?
                ORDER BY A.SettingApproval_StepData ASC, A.ApprovedBy_ID ASC";

        return $this->db->query($sql, [$reqApprovalID])->result();
    }

    /**
     * Fungsi private untuk mem-backup data SO Header & Detail ke tabel History saat terjadi Revisi
     */
    public function _backup_revision_history($SoNum, $hidRevision, $userId)
    {
        // 1. BACKUP HEADER KE HISTORY
        $sqlHistoryHeader = "
        INSERT INTO TAccSOHistory_Header (
            Revision_Number, Base_Invoice_Amount, close_reason, outlet_wh,
            SO_Number, SN_Status, project_code, TransactionDiscountRate,
            TrxNo, Emp_ID, Proforma_Number, TransactionDiscountAmount,
            SO_Date, FreightTax_Code, KawasanBerikat, TransactionDiscountBaseAmount,
            SO_Notes, FreightTax_Percentage, INVOICE_PERCENTAGE, isDonation,
            Account_ID, Invoice_Status, REMARK_NOTACTIVE, directpo,
            Contact_ID, Due_date, isDirect, isDP,
            Payment_Type, Approve_Date, SN_Account_ID, tax_code,
            PO_NumCustomer, FOC_number, SI_Account_ID, SC_Number,
            PO_DateCustomer, ETD, Creation_DateTime, ExtCom_Status,
            Project_ID, ETA, Created_By, IntCom_Status,
            ExternalSales_Commision, quotation_number, Last_Update, isTaxAble,
            Base_ExternalSales_Commision, ItemCategoryType, Update_By, isFOC,
            InternalSales_Commision, DisplayNumber, CurrencyRateList, isDisplay,
            Base_InternalSales_Commision, JO_Code, Tax_CurrencyRateList, isNotActive,
            Approval_Status, created_date, isSisterCompany, ReviseCounter,
            SO_Status, SOType, SisterCompany, include_do,
            Company_ID, terms, SisterCompanyDocument, invoicedirect,
            Tax_Currency_ID, Deliveryterms, AllocateTo, Doc_Status,
            Tax_Amount, WH_ID, BudgetPeriod_ID, paymentterm_code,
            Base_Tax_Amount, disc_id, SI_SisterCompany, TaxDocNumPPN,
            Currency_ID, automaticsn, TaxCodeInclude, TaxDocNumPPh,
            Invoice_Amount, isClose, isOutlet, PPNNumberGenerated,
            PriceType, claim_deduction_amount, claim_deduction_desc, reason_revision,
            pi_number, Production_month, Production_year
        )
        SELECT 
            Revision_Number, Base_Invoice_Amount, close_reason, outlet_wh,
            SO_Number, SN_Status, project_code, TransactionDiscountRate,
            TrxNo, Emp_ID, Proforma_Number, TransactionDiscountAmount,
            SO_Date, FreightTax_Code, KawasanBerikat, TransactionDiscountBaseAmount,
            SO_Notes, FreightTax_Percentage, INVOICE_PERCENTAGE, isDonation,
            Account_ID, Invoice_Status, REMARK_NOTACTIVE, directpo,
            Contact_ID, Due_date, isDirect, isDP,
            Payment_Type, Approve_Date, SN_Account_ID, tax_code,
            PO_NumCustomer, FOC_number, SI_Account_ID, SC_Number,
            PO_DateCustomer, ETD, Creation_DateTime, ExtCom_Status,
            Project_ID, ETA, Created_By, IntCom_Status,
            ExternalSales_Commision, quotation_number, Last_Update, isTaxAble,
            Base_ExternalSales_Commision, ItemCategoryType, Update_By, isFOC,
            InternalSales_Commision, DisplayNumber, CurrencyRateList, isDisplay,
            Base_InternalSales_Commision, JO_Code, Tax_CurrencyRateList, isNotActive,
            Approval_Status, created_date, isSisterCompany, ReviseCounter,
            SO_Status, SOType, SisterCompany, include_do,
            Company_ID, terms, SisterCompanyDocument, invoicedirect,
            Tax_Currency_ID, Deliveryterms, AllocateTo, Doc_Status,
            Tax_Amount, WH_ID, BudgetPeriod_ID, paymentterm_code,
            Base_Tax_Amount, disc_id, SI_SisterCompany, TaxDocNumPPN,
            Currency_ID, automaticsn, TaxCodeInclude, TaxDocNumPPh,
            Invoice_Amount, isClose, isOutlet, PPNNumberGenerated,
            PriceType, claim_deduction_amount, claim_deduction_desc, reason_revision,
            pi_number, Production_month, Production_year
        FROM TAccSO_Header
        WHERE SO_Number = ?
    ";
        $this->db->query($sqlHistoryHeader, [$SoNum]);

        // 2. DAPATKAN REVISION NUMBER SAAT INI
        $qRev = $this->db->query("SELECT ISNULL(Revision_Number, 0) as revNumber FROM TAccSO_Header WHERE SO_Number = ?", [$SoNum])->row();
        $currentRevNumber = $qRev ? $qRev->revNumber : 0;

        // 3. BACKUP DETAIL KE HISTORY DETAIL
        $sqlHistoryDetail = "
        INSERT INTO TAccSOHistory_Detail (
            SO_Number, Tax_Percentage1, Others, is_install,
            Item_Code, Tax_Operator1, CS_Number, config_level,
            Item_Description, Tax_Amount1, EstimateDate, config_ratio,
            Qty, Tax_Code2, parent_item, config_order,
            Qty_DO, Tax_Percentage2, parent_path, disc_type,
            UnitPrice, Tax_Operator2, generate_flag, SODetail_ID,
            Base_UnitPrice, Tax_Amount2, Comp_ID, ref_id,
            Disc_percentage, TotalPrice, Qty2, Dimension_ID,
            ExtraPrice, Base_TotalPrice, Unit_Type, Disc_Value,
            Tax_Code1, Include_DO, Unit_Type2, isFreeItem,
            Notes, Revision_Number
        )
        SELECT 
            SO_Number, Tax_Percentage1, Others, is_install,
            Item_Code, Tax_Operator1, CS_Number, config_level,
            Item_Description, Tax_Amount1, EstimateDate, config_ratio,
            Qty, Tax_Code2, parent_item, config_order,
            Qty_DO, Tax_Percentage2, parent_path, disc_type,
            UnitPrice, Tax_Operator2, generate_flag, SODetail_ID,
            Base_UnitPrice, Tax_Amount2, Comp_ID, ref_id,
            Disc_percentage, TotalPrice, Qty2, Dimension_ID,
            ExtraPrice, Base_TotalPrice, Unit_Type, Disc_Value,
            Tax_Code1, Include_DO, Unit_Type2, isFreeItem,
            Notes, ? 
        FROM TAccSO_Detail
        WHERE SO_Number = ?
    ";
        $this->db->query($sqlHistoryDetail, [$currentRevNumber, $SoNum]);

        // 4. INSERT LOG KE TAccDocumentRevision
        $logData = [
            'Doc_type'         => 'SO',
            'Doc_No'           => $SoNum,
            'LastRevisionNo'   => $hidRevision,
            'USER_ID'          => $userId,
            'Created_datetime' => date('Y-m-d H:i:s')
        ];
        $this->db->insert('TAccDocumentRevision', $logData);
    }
}
