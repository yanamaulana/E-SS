<?php
defined('BASEPATH') or exit('No direct script access allowed');

use PhpOffice\PhpSpreadsheet\Cell\DataType;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

class ReportPemakaianCuti extends CI_Controller
{
    private $HR;
    private $Date;
    private $DateTime;
    private $layout = 'layout';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->Date = date("Y-m-d");
        $this->DateTime = date("Y-m-d H:i:s");
        $this->load->model('m_helper', 'help');
        $this->load->model('m_DataTable', 'M_Datatables');
        $this->HR = $this->load->database('HR', TRUE);
    }

    public function index()
    {
        $this->data['page_title'] = "Report Pemakaian Cuti Seluruh Karyawan";
        $this->data['page_content'] = "report_hr/pemakaian_cuti";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/report_hr/pemakaian_cuti.js"></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function export_excel()
    {
        $year = (int) $this->input->get('year', TRUE);
        $currentYear = (int) date('Y');
        if ($year < 2014 || $year > $currentYear) {
            show_error('Tahun annual date tidak valid.', 400);
        }

        // Satu query set-based menggantikan query per karyawan pada view lama.
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
                    WHERE A.Company_ID = 73 AND D.Company_ID = 73
                      AND D.Attend_Code = 'ANL'
                      AND D.Shift_Start >= ?
                      AND D.Shift_Start < ?
                      AND P.User_ID IN (SELECT DISTINCT User_ID FROM TAppGroupData WHERE AppGroup_ID = 716)
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
            $periodKey = $row['EMP_ID'];
            if (!isset($employees[$periodKey])) {
                $employees[$periodKey] = ['data' => $row, 'dates' => [], 'count' => (int) $row['Leave_Count']];
            }
            if ($row['Leave_No'] !== null) {
                $employees[$periodKey]['dates'][(int) $row['Leave_No']] = substr($row['Shift_Start'], 0, 10);
            }
        }

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
                $sheet->setCellValue($column . $excelRow, isset($employee['dates'][$i]) ? $employee['dates'][$i] : '-');
            }
            $sheet->setCellValue('V' . $excelRow, $employee['count']);
            $excelRow++;
        }

        $lastRow = max(2, $excelRow - 1);
        $sheet->freezePane('A3');
        $sheet->setAutoFilter('A2:V2');
        $sheet->getStyle('A2:V' . $lastRow)->getBorders()->getAllBorders()->setBorderStyle(Border::BORDER_THIN);
        foreach (range('A', 'V') as $column) $sheet->getColumnDimension($column)->setAutoSize(true);

        $filename = 'Report_Pemakaian_Cuti_' . $year . '_' . date('Ymd_His') . '.xlsx';
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment;filename="' . $filename . '"');
        header('Cache-Control: max-age=0');
        (new Xlsx($spreadsheet))->save('php://output');
        $spreadsheet->disconnectWorksheets();
        exit;
    }
}
