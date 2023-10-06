<?php
class m_helper extends CI_Model
{
    private $tbl_CounterDocNumber = 'tsys_counterdocnumber';
    private $tmst_member_koperasi = 'tmst_member_koperasi';

    public function Fn_resulting_response($responses)
    {
        $response = json_encode($responses);
        echo $response;
    }

    public function format_idr($angka)
    {
        $hasil_rupiah = "Rp " . number_format($angka, 2, ',', '.');
        return $hasil_rupiah;
    }

    public function Gnrt_Identity_Number_PerYear($param, $trxName)
    {
        $rows = $this->db->get_where($this->tbl_CounterDocNumber, array(
            "TrxName" => $trxName,
            "TrxYear" => date('Y'),
            // "month" => date('m'),
        ));
        // TrxName, TrxMonth, TrxYear, TrxDate, CurrDocNumber
        $length = 3;
        if ($rows->num_rows() > 0) {
            $row = $rows->row();
            $newCount = intval($row->CurrDocNumber) + 1;

            $this->db->where('TrxName', $trxName);
            $this->db->where('TrxYear', date('Y'));
            // $this->db->where('TrxMonth', date('m'));
            $this->db->update($this->tbl_CounterDocNumber, [
                'CurrDocNumber' => $newCount,
            ]);

            $string = substr(str_repeat(0, $length) . $newCount, -$length);
            $identity_number = date("y") . date("m") . $string;
        } else {
            $this->db->insert($this->tbl_CounterDocNumber, [
                "TrxName" => $trxName,
                "TrxYear" => date('Y'),
                // "TrxMonth" => date('m'),
                "CurrDocNumber" => 1,
            ]);
            $newCount = 1;
            $string = substr(str_repeat(0, $length) . $newCount, -$length);
            $identity_number = date("y") . date("m") . $string;
        }

        return $param . '-' . $identity_number;
    }

    public function Gnrt_Identity_Number_PerMonth($trxName)
    {
        $rows = $this->db->get_where($this->tbl_CounterDocNumber, array(
            "TrxName" => $trxName,
            "TrxYear" => date('Y'),
            "TrxMonth" => intval(date('m')),
        ));
        // TrxName, TrxMonth, TrxYear, TrxDate, CurrDocNumber
        $length = 3;
        if ($rows->num_rows() > 0) {
            $row = $rows->row();
            $newCount = intval($row->CurrDocNumber) + 1;

            $this->db->where('TrxName', $trxName);
            $this->db->where('TrxYear', date('Y'));
            $this->db->where('TrxMonth', intval(date('m')));
            $this->db->update($this->tbl_CounterDocNumber, [
                'CurrDocNumber' => $newCount,
            ]);

            $string = substr(str_repeat(0, $length) . $newCount, -$length);
            $identity_number = $string;
        } else {
            $this->db->insert($this->tbl_CounterDocNumber, [
                "TrxName" => $trxName,
                "TrxYear" => date('Y'),
                "TrxMonth" => intval(date('m')),
                "CurrDocNumber" => 1,
            ]);
            $newCount = 1;
            $string = substr(str_repeat(0, $length) . $newCount, -$length);
            $identity_number = $string;
        }

        return $identity_number;
    }

    public function Counter_Payroll_Number($trxName)
    {
        $rows = $this->db->get_where($this->tbl_CounterDocNumber, array(
            "TrxName" => $trxName,
            "TrxYear" => date('Y'),
            // "month" => date('m'),
        ));
        // TrxName, TrxMonth, TrxYear, TrxDate, CurrDocNumber
        $length = 3;
        if ($rows->num_rows() > 0) {
            $row = $rows->row();
            $newCount = intval($row->CurrDocNumber) + 1;

            $this->db->where('TrxName', $trxName);
            $this->db->where('TrxYear', date('Y'));
            // $this->db->where('TrxMonth', date('m'));
            $this->db->update($this->tbl_CounterDocNumber, [
                'CurrDocNumber' => $newCount,
            ]);

            $string = substr(str_repeat(0, $length) . $newCount, -$length);
            $identity_number = $string;
        } else {
            $this->db->insert($this->tbl_CounterDocNumber, [
                "TrxName" => $trxName,
                "TrxYear" => date('Y'),
                // "TrxMonth" => date('m'),
                "CurrDocNumber" => 1,
            ]);
            $newCount = 1;
            $string = substr(str_repeat(0, $length) . $newCount, -$length);
            $identity_number = $string;
        }

        return $identity_number;
    }

    public function terbilangRupiah($nilai)
    {
        $nilai = abs($nilai);
        $huruf = array("", "satu", "dua", "tiga", "empat", "lima", "enam", "tujuh", "delapan", "sembilan", "sepuluh", "sebelas");
        $temp = "";
        if ($nilai < 12) {
            $temp = " " . $huruf[$nilai];
        } else if ($nilai < 20) {
            $temp = $this->terbilangRupiah($nilai - 10) . " belas";
        } else if ($nilai < 100) {
            $temp = $this->terbilangRupiah($nilai / 10) . " puluh" . $this->terbilangRupiah($nilai % 10);
        } else if ($nilai < 200) {
            $temp = " seratus" . $this->terbilangRupiah($nilai - 100);
        } else if ($nilai < 1000) {
            $temp = $this->terbilangRupiah($nilai / 100) . " ratus" . $this->terbilangRupiah($nilai % 100);
        } else if ($nilai < 2000) {
            $temp = " seribu" . $this->terbilangRupiah($nilai - 1000);
        } else if ($nilai < 1000000) {
            $temp = $this->terbilangRupiah($nilai / 1000) . "ribu" . $this->terbilangRupiah($nilai % 1000);
        } else if ($nilai < 1000000000) {
            $temp = $this->terbilangRupiah($nilai / 1000000) . " juta" . $this->terbilangRupiah($nilai % 1000000);
        } else if ($nilai < 1000000000000) {
            $temp = $this->terbilangRupiah($nilai / 1000000000) . " milyar" . $this->terbilangRupiah(fmod($nilai, 1000000000));
        } else if ($nilai < 1000000000000000) {
            $temp = $this->terbilangRupiah($nilai / 1000000000000) . " triliun" . $this->terbilangRupiah(fmod($nilai, 1000000000000));
        }
        return $temp;
    }

    public function konversiHari($englishDay)
    {
        $englishDays = array(
            'Sunday'    => 'Minggu',
            'Monday'    => 'Senin',
            'Tuesday'   => 'Selasa',
            'Wednesday' => 'Rabu',
            'Thursday'  => 'Kamis',
            'Friday'    => 'Jumat',
            'Saturday'  => 'Sabtu'
        );

        if (isset($englishDays[$englishDay])) {
            return $englishDays[$englishDay];
        } else {
            return 'Hari tidak valid';
        }
    }

    public function Fn_Get_Nominal_Simpanan_SukaRela($nik)
    {
        $Is_Member = $this->db->get_where($this->tmst_member_koperasi, ['ID_Access' => $nik]);
        if ($Is_Member->num_rows() > 0) {
            $Row_Member = $Is_Member->row();
            $nominal = $Row_Member->Deposito_Perbulan;
        } else {
            $nominal = 0;
        }

        return floatval($nominal);
    }

    public function Fn_Get_Nominal_Iuran_Bpjstk($nik)
    {
        $SqlBpjstk = $this->db->get_where('qview_mst_iuran_bpjskt', ['ID_Access' => $nik]);
        if ($SqlBpjstk->num_rows() > 0) {
            $RowBpjstk = $SqlBpjstk->row();
            return [
                'nominal' => floatval($RowBpjstk->Nominal),
                'kode' => $RowBpjstk->Kode_Potongan
            ];
        } else {
            return [
                'nominal' => 0,
                'kode' => 'BPJS_NOL'
            ];
        }
    }

    function translateMonth($englishMonth)
    {
        $months = array(
            'January' => 'Januari',
            'February' => 'Februari',
            'March' => 'Maret',
            'April' => 'April',
            'May' => 'Mei',
            'June' => 'Juni',
            'July' => 'Juli',
            'August' => 'Agustus',
            'September' => 'September',
            'October' => 'Oktober',
            'November' => 'November',
            'December' => 'Desember'
        );

        return $months[$englishMonth];
    }
}
