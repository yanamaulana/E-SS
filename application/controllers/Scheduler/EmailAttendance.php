<?php
defined('BASEPATH') or exit('No direct script access allowed');

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

class EmailAttendance extends CI_Controller
{
    private $HR;
    private $Date;
    private $DateTime;

    public function __construct()
    {
        parent::__construct();
        $this->Date = date("Y-m-d");
        $this->DateTime = date("Y-m-d H:i:s");
        $this->HR = $this->load->database('HR', TRUE);
    }

    public function SendMailAttendance() // This function can be triggered by a POST request or cron job
    {
        // 1. Tangkap inputan dari datepicker (Format: YYYY-MM-DD)
        $attendance_date = $this->input->get('attendance_date'); // Changed to GET for easier cron job access

        // Validasi: Jika kosong, gunakan tanggal hari ini sebagai default
        if (empty($attendance_date)) {
            $attendance_date = date('Y-m-d');
        }

        // 2. Hitung logika tanggal untuk keperluan pivot kolom dan rentang WHERE SARGable
        $date_h        = $attendance_date; // Hari H (Contoh: 2026-07-28)
        $date_h_min_1  = date('Y-m-d', strtotime('-1 day', strtotime($date_h))); // Hari H-1 (Contoh: 2026-07-27)
        $date_h_plus_1 = date('Y-m-d', strtotime('+1 day', strtotime($date_h))); // Hari H+1 untuk batas akhir (Contoh: 2026-07-29)

        // 3. Susun Query (Menggunakan Binding Parameter '?' agar aman dari SQL Injection)
        $sql = "
            SELECT 
                C.Emp_No AS NIP, 
                LTRIM(RTRIM(
                    ISNULL(P.First_Name + ' ', '') + 
                    ISNULL(P.Middle_Name + ' ', '') + 
                    ISNULL(P.Last_Name, '')
                )) AS NAMA,
                Pos.Position_Name_en AS JABATAN,
                
                -- --- DATA ABSENSI H-1 ---
                MAX(CASE WHEN A.SHIFT_START >= ? AND A.SHIFT_START < ? 
                         THEN CONVERT(VARCHAR(5), A.START_TIME, 108) END) AS MASUK_H_MIN_1,
                MAX(CASE WHEN A.SHIFT_START >= ? AND A.SHIFT_START < ? 
                         THEN CONVERT(VARCHAR(5), A.END_TIME, 108) END) AS KELUAR_H_MIN_1,
                         
                -- --- DATA ABSENSI HARI H ---
                MAX(CASE WHEN A.SHIFT_START >= ? AND A.SHIFT_START < ? 
                         THEN CONVERT(VARCHAR(5), A.START_TIME, 108) END) AS MASUK_H,
                MAX(CASE WHEN A.SHIFT_START >= ? AND A.SHIFT_START < ? 
                         THEN CONVERT(VARCHAR(5), A.END_TIME, 108) END) AS KELUAR_H,
                
                ISNULL(C.Cost_Center, '') + ' - ' + ISNULL(CC.CostCenter_Name_en, '') AS BAGIAN,
                TDiv.Position_Name_en AS Divisi

            FROM 
                THRMEmpPersonalData P
            INNER JOIN 
                THRMEmpCompany C ON C.Emp_ID = P.Emp_ID
            LEFT OUTER JOIN 
                THRMPosition Pos ON C.Position_ID = Pos.Position_ID
            LEFT OUTER JOIN 
                THRMPosition TDiv ON Pos.Division_Id = TDiv.Position_Id
            LEFT OUTER JOIN 
                THRMCostCenter CC ON CC.CostCenter_Code = C.Cost_Center AND CC.COMPANY_ID = C.COMPANY_ID
                
            -- Join SARGable condition dinamis
            LEFT OUTER JOIN 
                THRMAttendance A ON A.EMP_ID = P.Emp_ID 
                                 AND A.SHIFT_START >= ? 
                                 AND A.SHIFT_START < ?
            WHERE 
                C.Company_ID = 73 
                AND (C.End_Date > GETDATE() OR C.End_Date IS NULL)
                
            GROUP BY 
                C.Emp_No,
                P.First_Name,
                P.Middle_Name,
                P.Last_Name,
                Pos.Position_Name_en,
                C.Cost_Center,
                CC.CostCenter_Name_en,
                TDiv.Position_Name_en
                
            ORDER BY 
                C.Cost_Center, C.Emp_No
        ";

        // 4. Siapkan array parameter berurutan sesuai tanda '?' pada query
        $bindings = [
            // Parameter untuk kolom H-1
            $date_h_min_1,
            $date_h,
            $date_h_min_1,
            $date_h,

            // Parameter untuk kolom Hari H
            $date_h,
            $date_h_plus_1,
            $date_h,
            $date_h_plus_1,

            // Parameter untuk kondisi JOIN A.SHIFT_START
            $date_h_min_1,
            $date_h_plus_1
        ];

        // 5. Eksekusi menggunakan $this->HR
        $result = $this->HR->query($sql, $bindings)->result_array();

        // 6. Siapkan data untuk dikirim ke View
        $data = [
            'tanggal_h_min_1' => $date_h_min_1,
            'tanggal_h'       => $date_h,
            'report_data'     => $result
        ];

        // --- START: GENERATE EXCEL ---
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle('Absensi ' . $date_h);

        // Set Headers
        $headers = [
            'NO',
            'NIP',
            'NAMA',
            'JABATAN',
            'MASUK (' . date('d-M-Y', strtotime($date_h_min_1)) . ')',
            'KELUAR (' . date('d-M-Y', strtotime($date_h_min_1)) . ')',
            'MASUK (' . date('d-M-Y', strtotime($date_h)) . ')',
            'KELUAR (' . date('d-M-Y', strtotime($date_h)) . ')',
            'BAGIAN',
            'DIVISI'
        ];
        $sheet->fromArray($headers, NULL, 'A1');
        $sheet->getStyle('A1:K1')->getFont()->setBold(true);

        // Populate data
        $rowNum = 2;
        $no = 1;
        foreach ($result as $row) {
            $sheet->setCellValue('A' . $rowNum, $no++);
            $sheet->setCellValueExplicit('B' . $rowNum, $row['NIP'], \PhpOffice\PhpSpreadsheet\Cell\DataType::TYPE_STRING);
            $sheet->setCellValue('C' . $rowNum, $row['NAMA']);
            $sheet->setCellValue('D' . $rowNum, $row['JABATAN']);
            $sheet->setCellValue('E' . $rowNum, $row['MASUK_H_MIN_1'] ?? '-');
            $sheet->setCellValue('F' . $rowNum, $row['KELUAR_H_MIN_1'] ?? '-');
            $sheet->setCellValue('G' . $rowNum, $row['MASUK_H'] ?? '-');
            $sheet->setCellValue('H' . $rowNum, $row['KELUAR_H'] ?? '-');
            $sheet->setCellValue('I' . $rowNum, $row['BAGIAN']);
            $sheet->setCellValue('J' . $rowNum, $row['Divisi']);
            $rowNum++;
        }

        // Auto-size columns
        foreach (range('A', 'K') as $col) {
            $sheet->getColumnDimension($col)->setAutoSize(true);
        }

        // Save the file temporarily
        $temp_dir = FCPATH . 'temp_excel';
        if (!is_dir($temp_dir)) {
            mkdir($temp_dir, 0777, true);
        }
        $filename = 'Laporan_Absensi_' . $date_h . '.xlsx';
        $filepath = $temp_dir . '/' . $filename;

        $writer = new Xlsx($spreadsheet);
        $writer->save($filepath);
        // --- END: GENERATE EXCEL ---

        // --- START: SEND EMAIL WITH PHPMailer ---
        $mail = new PHPMailer(true);

        try {
            // Load email config
            $this->config->load('email', TRUE);
            $smtp_user = $this->config->item('smtp_user', 'email');
            $smtp_pass = $this->config->item('smtp_pass', 'email');

            // Server settings
            // $mail->SMTPDebug = SMTP::DEBUG_SERVER; // Aktifkan untuk debug
            $mail->isSMTP();
            $mail->Host       = 'mail.samick.co.id';
            $mail->SMTPAuth   = true;
            $mail->Username   = $smtp_user;
            $mail->Password   = $smtp_pass;
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
            $mail->Port       = 465;

            // WORKAROUND untuk error SSL/TLS pada lingkungan development (XAMPP).
            $mail->SMTPOptions = [
                'ssl' => [
                    'verify_peer' => false,
                    'verify_peer_name' => false,
                    'allow_self_signed' => true
                ]
            ];

            // Recipients
            $mail->setFrom('personalia@samick.co.id', 'System HR');

            $toList = ['irul.personalia@samick.co.id'];
            foreach ($toList as $recipient) {
                $mail->addAddress($recipient);
            }

            $ccList = [
                'novita@samick.co.id',
                'yana.mis@samick.co.id'
            ];
            foreach ($ccList as $recipient) {
                $mail->addCC($recipient);
            }

            // Attachments
            $mail->addAttachment($filepath, $filename);

            // Content
            $mail->isHTML(true);

            $dayName = date('l', strtotime($date_h_min_1));
            $dayNameId = strtolower($dayName);
            $dayNames = [
                'monday'    => 'SENIN',
                'tuesday'   => 'SELASA',
                'wednesday' => 'RABU',
                'thursday'  => 'KAMIS',
                'friday'    => 'JUMAT',
                'saturday'  => 'SABTU',
                'sunday'    => 'MINGGU'
            ];
            $subjectDay = $dayNames[$dayNameId] ?? strtoupper($dayName);
            $subjectDate = date('d F Y', strtotime($date_h_min_1));
            $mail->Subject = 'ACTUAL JAM KERJA ' . $subjectDay . ' ' . $subjectDate;

            $body = "Dear All Admin/Staff Bagian Divisi PT. Samick,<br><br>" .
                "Sesuai dengan rencana yang di lakukan di tahun 2012 tentang perhitungan MAINHOUR MAXIMUM,<br>" .
                "Berikut saya laporkan data actual jam pulang karyawan tanggal <b>" . date('d F Y', strtotime($date_h_min_1)) . "</b> yang terinput di system PAYROLL per tanggal <b>" . date('d F Y', strtotime($date_h)) . "</b>." .
                "<br><br>Terimakasih<br><b>**Email ini dikirim otomatis dari system HR.</b>";
            $mail->Body    = $body;
            $mail->AltBody = strip_tags($body);

            $mail->send();
            echo 'Email laporan absensi berhasil dikirim.';
        } catch (Exception $e) {
            echo "Email tidak terkirim. Mailer Error: {$mail->ErrorInfo}";
        }

        // Clean up the temporary file
        if (file_exists($filepath)) {
            unlink($filepath);
        }
        // --- END: SEND EMAIL ---
    }


    /**
     * Function to test email sending using PHPMailer library.
     * Sends an email from personalia@samick.co.id to mis@samick.co.id.
     * 
     * Note: This assumes PHPMailer is installed via Composer.
     * Run `composer require phpmailer/phpmailer` in your project root if you haven't already.
     */
    public function test_email_phpmailer()
    {
        // Create an instance; passing `true` enables exceptions
        $mail = new PHPMailer(true);

        try {
            // Server settings
            // For better security, it's recommended to load these from a config file
            // instead of hardcoding them.
            $this->config->load('email', TRUE);
            $smtp_user = $this->config->item('smtp_user', 'email');
            $smtp_pass = $this->config->item('smtp_pass', 'email');

            // $mail->SMTPDebug = SMTP::DEBUG_SERVER; // Uncomment for verbose debug output
            $mail->isSMTP();
            $mail->Host       = 'mail.samick.co.id';
            $mail->SMTPAuth   = true;
            $mail->Username   = $smtp_user; // Use from config
            $mail->Password   = $smtp_pass; // Use from config
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
            $mail->Port       = 465;

            // WORKAROUND for local development (XAMPP) SSL/TLS issues.
            // This disables certificate verification.
            // IMPORTANT: Do NOT use this in a production environment.
            $mail->SMTPOptions = array(
                'ssl' => array(
                    'verify_peer' => false,
                    'verify_peer_name' => false,
                    'allow_self_signed' => true
                )
            );

            // Recipients
            $mail->setFrom('personalia@samick.co.id', 'System HR (Test PHPMailer)');
            $mail->addAddress('mis@samick.co.id', 'MIS Department');

            // Content
            $mail->isHTML(true);
            $mail->Subject = 'Test Email from PHPMailer';
            $mail->Body    = 'This is a test email sent using <b>PHPMailer</b> from a CodeIgniter application. <br>If you can read this, the configuration is correct.';
            $mail->AltBody = 'This is a test email sent using PHPMailer from a CodeIgniter application. If you can read this, the configuration is correct.';

            $mail->send();
            echo 'Message has been sent successfully!';
        } catch (Exception $e) {
            echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
        }
    }
}
