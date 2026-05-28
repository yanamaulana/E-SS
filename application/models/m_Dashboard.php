<?php
class m_Dashboard extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
    }

    public function get_Count_Awaiting_Approvals($username)
    {
        $query = $this->db->query("SELECT COUNT(1) as Awaiting_Approvals
                                    FROM TAccCashBookReq_Header H
                                    JOIN Ttrx_Cbr_Approval A ON H.CBReq_No = A.CBReq_No
                                    WHERE H.Type = 'D'
                                    AND H.Company_ID = 2 
                                    AND (H.isSPJ IS NULL OR H.isSPJ = 0) 
                                    AND H.Approval_Status = 3 
                                    AND H.CBReq_Status = 3
                                    AND (H.isClose IS NULL OR H.isClose = 0)
                                    AND A.IsAppvPresidentDirector = 1
                                    AND A.Status_AppvPresidentDirector = 0
                                    AND A.AppvPresidentDirector_By = '$username'
                                    AND (A.IsAppvStaff = 0          OR A.Status_AppvStaff = 1)
                                    AND (A.IsAppvChief = 0          OR A.Status_AppvChief = 1)
                                    AND (A.IsAppvAsstManager = 0    OR A.Status_AppvAsstManager = 1)
                                    AND (A.IsAppvManager = 0        OR A.Status_AppvManager = 1)
                                    AND (A.IsAppvSeniorManager = 0  OR A.Status_AppvSeniorManager = 1)
                                    AND (A.IsAppvGeneralManager = 0 OR A.Status_AppvGeneralManager = 1)
                                    AND (A.IsAppvAdditional = 0     OR A.Status_AppvAdditional = 1)
                                    AND (A.IsAppvDirector = 0       OR A.Status_AppvDirector = 1)
                                    AND (A.IsAppvFinancePerson = 0  OR A.Status_AppvFinancePerson = 1) 
                                    AND (A.IsAppvFinanceDirector = 0 OR A.Status_AppvFinanceDirector = 1)");
        return $query->row()->Awaiting_Approvals;
    }

    public function get_Count_After_Approvals($username, $status)
    {
        // 1. Siapkan format tanggal dan waktu secara penuh dari PHP
        $first_date_on_month = date('Y-m-01 00:00:00');
        $last_date_on_month = date('Y-m-t 23:59:59');

        // 2. Gunakan tanda tanya (?) untuk tempat variabel
        $sql = "SELECT COUNT(1) as After_Approvals
                FROM TAccCashBookReq_Header H
                JOIN Ttrx_Cbr_Approval A ON H.CBReq_No = A.CBReq_No
                WHERE H.Type = 'D'
                AND H.Company_ID = 2 
                AND (H.isSPJ IS NULL OR H.isSPJ = 0) 
                AND H.Approval_Status = 3 
                AND H.CBReq_Status = 3
                AND (H.isClose IS NULL OR H.isClose = 0)
                AND A.IsAppvPresidentDirector = 1
                AND A.Status_AppvPresidentDirector = ?
                AND A.AppvPresidentDirector_At >= ?
                AND A.AppvPresidentDirector_At <= ?
                AND A.AppvPresidentDirector_By = ?
                AND (A.IsAppvStaff = 0          OR A.Status_AppvStaff = 1)
                AND (A.IsAppvChief = 0          OR A.Status_AppvChief = 1)
                AND (A.IsAppvAsstManager = 0    OR A.Status_AppvAsstManager = 1)
                AND (A.IsAppvManager = 0        OR A.Status_AppvManager = 1)
                AND (A.IsAppvSeniorManager = 0  OR A.Status_AppvSeniorManager = 1)
                AND (A.IsAppvGeneralManager = 0 OR A.Status_AppvGeneralManager = 1)
                AND (A.IsAppvAdditional = 0     OR A.Status_AppvAdditional = 1)
                AND (A.IsAppvDirector = 0       OR A.Status_AppvDirector = 1)
                AND (A.IsAppvFinancePerson = 0  OR A.Status_AppvFinancePerson = 1) 
                AND (A.IsAppvFinanceDirector = 0 OR A.Status_AppvFinanceDirector = 1)";

        // 3. Masukkan variabel ke dalam array sebagai argumen kedua $this->db->query()
        // Urutan array HARUS sama dengan urutan tanda tanya (?) di query atas
        $query = $this->db->query($sql, array(
            $status,
            $first_date_on_month,
            $last_date_on_month,
            $username
        ));

        return $query->row()->After_Approvals;
    }

    public function get_Amount_Approved($username)
    {
        // 1. Siapkan format tanggal dan waktu secara penuh dari PHP
        $first_date_on_month = date('Y-m-01 00:00:00');
        $last_date_on_month = date('Y-m-t 23:59:59');
        $status = 1;

        // 2. Gunakan tanda tanya (?) untuk tempat variabel (Query Binding)
        // Tambahkan fungsi SUM() dan GROUP BY untuk mengelompokkan per mata uang
        $sql = "SELECT H.Currency_Id, SUM(H.Amount) as Total_Amount
                FROM TAccCashBookReq_Header H
                JOIN Ttrx_Cbr_Approval A ON H.CBReq_No = A.CBReq_No
                WHERE H.Type = 'D'
                AND H.Company_ID = 2 
                AND (H.isSPJ IS NULL OR H.isSPJ = 0) 
                AND H.Approval_Status = 3 
                AND H.CBReq_Status = 3
                AND (H.isClose IS NULL OR H.isClose = 0)
                AND A.IsAppvPresidentDirector = 1
                AND A.Status_AppvPresidentDirector = ?
                AND A.AppvPresidentDirector_At >= ?
                AND A.AppvPresidentDirector_At <= ?
                AND A.AppvPresidentDirector_By = ?
                AND (A.IsAppvStaff = 0          OR A.Status_AppvStaff = 1)
                AND (A.IsAppvChief = 0          OR A.Status_AppvChief = 1)
                AND (A.IsAppvAsstManager = 0    OR A.Status_AppvAsstManager = 1)
                AND (A.IsAppvManager = 0        OR A.Status_AppvManager = 1)
                AND (A.IsAppvSeniorManager = 0  OR A.Status_AppvSeniorManager = 1)
                AND (A.IsAppvGeneralManager = 0 OR A.Status_AppvGeneralManager = 1)
                AND (A.IsAppvAdditional = 0     OR A.Status_AppvAdditional = 1)
                AND (A.IsAppvDirector = 0       OR A.Status_AppvDirector = 1)
                AND (A.IsAppvFinancePerson = 0  OR A.Status_AppvFinancePerson = 1) 
                AND (A.IsAppvFinanceDirector = 0 OR A.Status_AppvFinanceDirector = 1)
                GROUP BY H.Currency_Id";

        // 3. Eksekusi query dengan memasukkan variabel ke dalam array
        $query = $this->db->query($sql, array(
            $status,
            $first_date_on_month,
            $last_date_on_month,
            $username
        ));

        // 4. Siapkan array kosong untuk menampung mata uang secara dinamis
        $totals = [];

        // 5. Looping hasil query
        foreach ($query->result() as $row) {
            // Bersihkan dan jadikan huruf kapital agar seragam (misal ' idr ' jadi 'IDR')
            $currency = strtoupper(trim($row->Currency_Id));

            // Masukkan ke array jika mata uangnya ada isinya
            if (!empty($currency)) {
                $totals[$currency] = (float) $row->Total_Amount;
            }
        }

        // Kembalikan array berisi total masing-masing mata uang (dinamis)
        return $totals;
    }

    public function get_Division_Summary($status, $username, $year, $month)
    {
        // karena month = 5 bukan 05 kita harus ubah dahulu formatnya agar bisa dibandingkan dengan format bulan di database yang biasanya 2 digit
        $month = str_pad($month, 2, '0', STR_PAD_LEFT);
        $first_date = "$year-$month-01 00:00:00";
        $last_date = date("Y-m-t", strtotime($first_date)) . " 23:59:59";

        $sql_range =  "";
        if ($status == 1) {
            $sql_range =  "AND A.AppvPresidentDirector_At >= ?
                           AND A.AppvPresidentDirector_At <= ? ";
        }


        $sql = "SELECT 
                A.UserDivision, 
                H.Currency_ID,
                COUNT(H.CBReq_No) AS Total_CBRs,
                SUM(H.Amount) AS Total_Amount
            FROM TAccCashBookReq_Header H
            JOIN Ttrx_Cbr_Approval A ON H.CBReq_No = A.CBReq_No
            WHERE H.Type = 'D'
            AND H.Company_ID = 2 
            AND (H.isSPJ IS NULL OR H.isSPJ = 0) 
            AND H.Approval_Status = 3 
            AND H.CBReq_Status = 3
            AND (H.isClose IS NULL OR H.isClose = 0)
            AND A.IsAppvPresidentDirector = 1
            AND A.Status_AppvPresidentDirector = ?
            AND A.AppvPresidentDirector_By = ?
            $sql_range
            AND (A.IsAppvStaff = 0          OR A.Status_AppvStaff = 1)
            AND (A.IsAppvChief = 0          OR A.Status_AppvChief = 1)
            AND (A.IsAppvAsstManager = 0    OR A.Status_AppvAsstManager = 1)
            AND (A.IsAppvManager = 0        OR A.Status_AppvManager = 1)
            AND (A.IsAppvSeniorManager = 0  OR A.Status_AppvSeniorManager = 1)
            AND (A.IsAppvGeneralManager = 0 OR A.Status_AppvGeneralManager = 1)
            AND (A.IsAppvAdditional = 0     OR A.Status_AppvAdditional = 1)
            AND (A.IsAppvDirector = 0       OR A.Status_AppvDirector = 1)
            AND (A.IsAppvFinancePerson = 0  OR A.Status_AppvFinancePerson = 1) 
            AND (A.IsAppvFinanceDirector = 0 OR A.Status_AppvFinanceDirector = 1)
            GROUP BY A.UserDivision, H.Currency_ID";

        if ($status == 1) {
            $query = $this->db->query($sql, array($status, $username, $first_date, $last_date));
        } else {
            $query = $this->db->query($sql, array($status, $username));
        }

        // Pindahkan ke fungsi penyusunan array
        return $this->format_dynamic_table($query->result_array());
    }

    private function format_dynamic_table($raw_data)
    {
        $divisions = [];
        $currencies = []; // Array untuk menyimpan daftar mata uang apa saja yang muncul

        foreach ($raw_data as $row) {
            $div = $row['UserDivision'];
            $curr = strtoupper(trim($row['Currency_ID']));

            // Simpan mata uang ke daftar jika belum ada (Biar dinamis)
            if (!empty($curr) && !in_array($curr, $currencies)) {
                $currencies[] = $curr;
            }

            // Jika divisi belum ada di array, buat format dasarnya
            if (!isset($divisions[$div])) {
                $divisions[$div] = [
                    'Total_CBRs' => 0,
                    'Amounts' => []
                ];
            }

            // Tambahkan jumlah CBR ke total divisi tersebut
            $divisions[$div]['Total_CBRs'] += $row['Total_CBRs'];

            // Masukkan nominal ke mata uang masing-masing
            $divisions[$div]['Amounts'][$curr] = $row['Total_Amount'];
        }

        // Kembalikan dua data: Daftar Divisi & Daftar Mata Uang (untuk Header Kolom)
        return [
            'currencies' => $currencies,
            'divisions'  => $divisions
        ];
    }
}
