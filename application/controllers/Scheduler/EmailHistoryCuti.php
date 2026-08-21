<?php
defined('BASEPATH') or exit('No direct script access allowed');

use PHPMailer\PHPMailer\Exception;
use PHPMailer\PHPMailer\PHPMailer;
use PhpOffice\PhpSpreadsheet\Cell\DataType;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

class EmailHistoryCuti extends CI_Controller
{
    private $HR;

    public function __construct()
    {
        parent::__construct();
        $this->HR = $this->load->database('HR', TRUE);
    }

    /**
     * Endpoint Windows Task Scheduler:
     * /Scheduler/EmailHistoryCuti/send
     *
     * Aman dipanggil setiap hari. Email hanya dikirim tanggal 1 pada
     * Januari-November dan tanggal 31 pada Desember.
     */
    public function send()
    {
        $today = new DateTimeImmutable('today');
        $day = (int) $today->format('j');
        $month = (int) $today->format('n');
        $isScheduleDate = ($month !== 12 && $day === 1) || ($month === 12 && $day === 31);

        if (!$isScheduleDate) {
            return $this->respond('Tidak ada jadwal pengiriman pada ' . $today->format('Y-m-d') . '.', 200);
        }

        $tempDir = FCPATH . 'temp_excel';
        if (!is_dir($tempDir) && !mkdir($tempDir, 0777, true)) {
            return $this->respond('Direktori temporary Excel tidak dapat dibuat.', 500);
        }

        $period = $today->format('Y-F');
        $lockPath = $tempDir . DIRECTORY_SEPARATOR . 'email_history_cuti_' . $today->format('Ymd') . '.lock';
        $lockHandle = fopen($lockPath, 'c+');
        if ($lockHandle === false || !flock($lockHandle, LOCK_EX | LOCK_NB)) {
            if (is_resource($lockHandle)) fclose($lockHandle);
            return $this->respond('Proses pengiriman sedang berjalan.', 409);
        }

        $status = trim(stream_get_contents($lockHandle));
        if ($status === 'SENT') {
            flock($lockHandle, LOCK_UN);
            fclose($lockHandle);
            return $this->respond('Email periode ' . $period . ' sudah pernah dikirim.', 200);
        }

        $year = (int) $today->format('Y');
        $filename = 'Data_History_Cuti_' . $period . '.xlsx';
        $filepath = $tempDir . DIRECTORY_SEPARATOR . $filename;
        $spreadsheet = null;

        try {
            $employees = $this->getLeaveData($year);
            $spreadsheet = $this->createSpreadsheet($employees, $year);
            (new Xlsx($spreadsheet))->save($filepath);

            $this->sendEmail($filepath, $filename, $period);

            ftruncate($lockHandle, 0);
            rewind($lockHandle);
            fwrite($lockHandle, 'SENT');
            fflush($lockHandle);

            return $this->respond('Email Data History Cuti periode ' . $period . ' berhasil dikirim.', 200);
        } catch (Throwable $e) {
            log_message('error', 'Scheduler EmailHistoryCuti: ' . $e->getMessage());
            return $this->respond('Email Data History Cuti gagal dikirim: ' . $e->getMessage(), 500);
        } finally {
            if ($spreadsheet instanceof Spreadsheet) $spreadsheet->disconnectWorksheets();
            if (is_file($filepath)) unlink($filepath);
            flock($lockHandle, LOCK_UN);
            fclose($lockHandle);
        }
    }

    private function getLeaveData($year)
    {
        $sql = "WITH Employees AS (
                    SELECT DISTINCT P.EMP_ID, C.Emp_No, P.FIRST_NAME,
                        CC.COSTCENTER_NAME_EN AS Cost_Center, P.HIRE_DATE
                    FROM tHRMEmpPersonalData P
                    INNER JOIN tHRMEmpCompany C ON C.Emp_ID = P.Emp_ID
                    LEFT JOIN tHRMPosition POS ON C.Position_ID = POS.Position_ID
                    LEFT JOIN tHRMCostCenter CC ON POS.Cost_Center = CC.CostCenter_Code
                    WHERE (C.End_Date > GETDATE() OR C.End_Date IS NULL)
                      AND P.Employee_Status = 'ACTIVE'
                ), AnnualLeaveRaw AS (
                    SELECT DISTINCT E.EMP_ID, D.Shift_Start
                    FROM Employees E
                    INNER JOIN tHRMAttendance A ON A.Emp_ID = E.EMP_ID
                    INNER JOIN tHRMAttendanceDetail D
                        ON D.Emp_ID = A.Emp_ID AND D.Shift_Start = A.Shift_Start
                    INNER JOIN tHRMEmpPersonalData P ON P.Emp_ID = E.EMP_ID
                    WHERE A.Company_ID = 73
                      AND D.Company_ID = 73
                      AND D.Attend_Code = 'ANL'
                      AND D.Shift_Start >= ?
                      AND D.Shift_Start < ?
                      AND P.User_ID IN (
                          SELECT DISTINCT User_ID FROM TAppGroupData WHERE AppGroup_ID = 716
                      )
                ), AnnualLeave AS (
                    SELECT EMP_ID, Shift_Start,
                        ROW_NUMBER() OVER (PARTITION BY EMP_ID ORDER BY Shift_Start) AS Leave_No,
                        COUNT(*) OVER (PARTITION BY EMP_ID) AS Leave_Count
                    FROM AnnualLeaveRaw
                )
                SELECT E.EMP_ID, E.Emp_No, E.FIRST_NAME, E.Cost_Center,
                    E.HIRE_DATE, L.Shift_Start, L.Leave_No, L.Leave_Count
                FROM Employees E
                LEFT JOIN AnnualLeave L
                    ON L.EMP_ID = E.EMP_ID AND L.Leave_No <= 16
                ORDER BY E.Cost_Center, E.FIRST_NAME, L.Leave_No";

        $reportStartDate = $year . '-01-01';
        $reportEndDate = ($year + 1) . '-01-01';
        $rows = $this->HR->query($sql, [$reportStartDate, $reportEndDate])->result_array();
        $employees = [];
        foreach ($rows as $row) {
            $key = $row['EMP_ID'];
            if (!isset($employees[$key])) {
                $employees[$key] = [
                    'data' => $row,
                    'dates' => [],
                    'count' => (int) $row['Leave_Count'],
                ];
            }
            if ($row['Leave_No'] !== null) {
                $employees[$key]['dates'][(int) $row['Leave_No']] = substr($row['Shift_Start'], 0, 10);
            }
        }

        return $employees;
    }

    private function createSpreadsheet(array $employees, $year)
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle('Pemakaian Cuti ' . $year);
        $sheet->setCellValue('A1', 'REPORT PEMAKAIAN CUTI - TAHUN ' . $year);
        $sheet->mergeCells('A1:V1');
        $sheet->getStyle('A1')->getFont()->setBold(true)->setSize(14);
        $sheet->getStyle('A1')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

        $headers = ['ID', 'NIK', 'NAME', 'DEPARTMENT', 'HIRE DATE'];
        for ($i = 1; $i <= 16; $i++) $headers[] = 'ANL-' . $i;
        $headers[] = 'COUNT ANL';
        $sheet->fromArray($headers, null, 'A2');
        $sheet->getStyle('A2:V2')->getFont()->setBold(true)->getColor()->setARGB('FFFFFFFF');
        $sheet->getStyle('A2:V2')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setARGB('FF3B6D8C');
        $sheet->getStyle('A2:V2')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

        $excelRow = 3;
        foreach ($employees as $employee) {
            $data = $employee['data'];
            $sheet->setCellValue('A' . $excelRow, $data['EMP_ID']);
            $sheet->setCellValueExplicit('B' . $excelRow, (string) $data['Emp_No'], DataType::TYPE_STRING);
            $sheet->setCellValue('C' . $excelRow, $data['FIRST_NAME']);
            $sheet->setCellValue('D' . $excelRow, $data['Cost_Center']);
            $sheet->setCellValue('E' . $excelRow, substr($data['HIRE_DATE'], 0, 10));
            for ($i = 1; $i <= 16; $i++) {
                $column = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex(5 + $i);
                $sheet->setCellValue($column . $excelRow, $employee['dates'][$i] ?? '-');
            }
            $sheet->setCellValue('V' . $excelRow, $employee['count']);
            $excelRow++;
        }

        $lastRow = max(2, $excelRow - 1);
        $sheet->freezePane('A3');
        $sheet->setAutoFilter('A2:V2');
        $sheet->getStyle('A2:V' . $lastRow)->getBorders()->getAllBorders()->setBorderStyle(Border::BORDER_THIN);
        foreach (range('A', 'V') as $column) $sheet->getColumnDimension($column)->setAutoSize(true);

        return $spreadsheet;
    }

    private function sendEmail($filepath, $filename, $period)
    {
        $this->config->load('email', TRUE);
        $mail = new PHPMailer(true);
        $mail->isSMTP();
        $mail->Host = $this->config->item('smtp_host', 'email') ?: 'mail.samick.co.id';
        $mail->SMTPAuth = true;
        $mail->Username = $this->config->item('smtp_user', 'email');
        $mail->Password = $this->config->item('smtp_pass', 'email');
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        $mail->Port = (int) ($this->config->item('smtp_port', 'email') ?: 465);
        $mail->SMTPOptions = [
            'ssl' => [
                'verify_peer' => false,
                'verify_peer_name' => false,
                'allow_self_signed' => true,
            ],
        ];

        $mail->setFrom('personalia@samick.co.id', 'System HR');
        foreach (['irul.personalia@samick.co.id', 'novita@samick.co.id', 'yana.mis@samick.co.id'] as $recipient) {
            $mail->addAddress($recipient);
        }
        $mail->addAttachment($filepath, $filename);
        $mail->isHTML(true);
        $mail->Subject = 'Data History cuti karyawan periode ' . $period;
        $mail->Body = 'Yth. Bapak/Ibu,<br><br>'
            . 'Terlampir Data History cuti karyawan periode <b>' . html_escape($period) . '</b>.'
            . '<br><br>Terima kasih.<br><b>Email ini dikirim otomatis dari System HR.</b>';
        $mail->AltBody = 'Terlampir Data History cuti karyawan periode ' . $period
            . '. Email ini dikirim otomatis dari System HR.';
        $mail->send();
    }

    private function respond($message, $statusCode)
    {
        $this->output->set_status_header($statusCode);
        $this->output->set_content_type('text/plain', 'utf-8');
        $this->output->set_output($message);
    }
}
