<?php
defined('BASEPATH') or exit('No direct script access allowed');

class HistoryApproval extends CI_Controller
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

    public function index() {}

    public function DT_List_History_Approval()
    {
        $requestData = $_REQUEST;
        $columns = array(
            0 => 'TAccCashBookReq_Header.CBReq_No',
            1 => 'TAccCashBookReq_Header.CBReq_No',
            2 => 'Type',
            3 => 'TAccCashBookReq_Header.Document_Date',
            4 => 'TAccCashBookReq_Header.Currency_Id',
            5 => 'Amount',
            6 => 'Document_Number',
            7 => 'Descript',
            8 => 'baseamount',
            9 => 'curr_rate',
            10 => 'Approval_Status',
            11 => 'isClose',
            12 => 'Paid_Status',
            13 => 'Creation_DateTime',
            14 => 'Created_By',
            15 => 'UserDivision',
            16 => 'First_Name',
            17 => 'Last_Update',
            18 => 'Acc_ID',
            19 => 'Approve_Date',
            20 => 'IsAppvStaff',
            21 => 'IsAppvChief',
            22 => 'IsAppvAsstManager ',
            23 => 'IsAppvManager',
            24 => 'IsAppvSeniorManager',
            25 => 'IsAppvGeneralManager',
            26 => 'IsAppvAdditional',
            27 => 'IsAppvFinancePerson',
            28 => 'IsAppvDirector',
            29 => 'IsAppvFinanceDirector',
            30 => 'IsAppvPresidentDirector',
            31 => 'Payment_Plan_Date',

        );
        $order  = $columns[$requestData['order']['0']['column']];
        $dir    = $requestData['order']['0']['dir'];
        $from   = $this->input->post('from');
        $until  = $this->input->post('until');
        $column_range  = $this->input->post('column_range');
        $username = $this->session->userdata('sys_sba_username');

        $sql = $this->help->generate_sql_spesific_history_approval($username, $column_range, $from, $until);

        $totalData = $this->db->query($sql)->num_rows();
        if (!empty($requestData['search']['value'])) {
            $sql .= " AND (TAccCashBookReq_Header.CBReq_No LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Document_Number LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR Payment_Plan_Date LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR UserDivision LIKE '%" . $requestData['search']['value'] . "%' ";
            $sql .= " OR First_Name LIKE '%" . $requestData['search']['value'] . "%') ";
        }
        //----------------------------------------------------------------------------------
        $totalFiltered = $this->db->query($sql)->num_rows();
        $sql .= " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";

        // var_dump($sql);
        // die;
        $query = $this->db->query($sql);
        $data = array();
        foreach ($query->result_array() as $row) {
            $nestedData = array();
            $nestedData['CBReq_No'] = $row['CBReq_No'];
            $nestedData['isClose'] = $row['isClose'];
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
            $nestedData['AppvAsstManager_At'] = !empty($row['AppvAsstManager_At']) ? date('Y-m-d H:i', strtotime($row['AppvAsstManager_At'])) : '-';
            $nestedData['IsAppvManager'] = $row['IsAppvManager'];
            $nestedData['Status_AppvManager'] = $row['Status_AppvManager'];
            $nestedData['AppvManager_By'] = $row['AppvManager_By'];
            $nestedData['AppvManager_Name'] = $row['AppvManager_Name'] ?? '';
            $nestedData['AppvManager_At'] = !empty($row['AppvManager_At']) ? date('Y-m-d H:i', strtotime($row['AppvManager_At'])) : '-';
            $nestedData['IsAppvSeniorManager'] = $row['IsAppvSeniorManager'];
            $nestedData['Status_AppvSeniorManager'] = $row['Status_AppvSeniorManager'];
            $nestedData['AppvSeniorManager_By'] = $row['AppvSeniorManager_By'];
            $nestedData['AppvSeniorManager_Name'] = $row['AppvSeniorManager_Name'] ?? '';
            $nestedData['AppvSeniorManager_At'] = !empty($row['AppvSeniorManager_At']) ? date('Y-m-d H:i', strtotime($row['AppvSeniorManager_At'])) : '-';
            $nestedData['IsAppvGeneralManager'] = $row['IsAppvGeneralManager'];
            $nestedData['Status_AppvGeneralManager'] = $row['Status_AppvGeneralManager'];
            $nestedData['AppvGeneralManager_By'] = $row['AppvGeneralManager_By'];
            $nestedData['AppvGeneralManager_Name'] = $row['AppvGeneralManager_Name'] ?? '';
            $nestedData['AppvGeneralManager_At'] = !empty($row['AppvGeneralManager_At']) ? date('Y-m-d H:i', strtotime($row['AppvGeneralManager_At'])) : '-';

            $nestedData['IsAppvAdditional'] = $row['IsAppvAdditional'];
            $nestedData['Status_AppvAdditional'] = $row['Status_AppvAdditional'];
            $nestedData['AppvAdditional_By'] = $row['AppvAdditional_By'];
            $nestedData['AppvAdditional_Name'] = $row['AppvAdditional_Name'] ?? '';
            $nestedData['AppvAdditional_At'] = !empty($row['AppvAdditional_At']) ? date('Y-m-d H:i', strtotime($row['AppvAdditional_At'])) : '-';

            $nestedData['IsAppvFinancePerson'] = $row['IsAppvFinancePerson'];
            $nestedData['Status_AppvFinancePerson'] = $row['Status_AppvFinancePerson'];
            $nestedData['AppvFinancePerson_By'] = $row['AppvFinancePerson_By'];
            $nestedData['AppvFinancePerson_Name'] = $row['AppvFinancePerson_Name'] ?? '';
            $nestedData['AppvFinancePerson_At'] = !empty($row['AppvFinancePerson_At']) ? date('Y-m-d H:i', strtotime($row['AppvFinancePerson_At'])) : '-';

            $nestedData['IsAppvDirector'] = $row['IsAppvDirector'];
            $nestedData['Status_AppvDirector'] = $row['Status_AppvDirector'];
            $nestedData['AppvDirector_By'] = $row['AppvDirector_By'];
            $nestedData['AppvDirector_Name'] = $row['AppvDirector_Name'] ?? '';
            $nestedData['AppvDirector_At'] = !empty($row['AppvDirector_At']) ? date('Y-m-d H:i', strtotime($row['AppvDirector_At'])) : '-';
            $nestedData['IsAppvPresidentDirector'] = $row['IsAppvPresidentDirector'];
            $nestedData['Status_AppvPresidentDirector'] = $row['Status_AppvPresidentDirector'];
            $nestedData['AppvPresidentDirector_By'] = $row['AppvPresidentDirector_By'];
            $nestedData['AppvPresidentDirector_Name'] = $row['AppvPresidentDirector_Name'] ?? '';
            $nestedData['AppvPresidentDirector_At'] = !empty($row['AppvPresidentDirector_At']) ? date('Y-m-d H:i', strtotime($row['AppvPresidentDirector_At'])) : '-';
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
            $nestedData['AppvFinanceDirector_At'] = !empty($row['AppvFinanceDirector_At']) ? date('Y-m-d H:i', strtotime($row['AppvFinanceDirector_At'])) : '-';
            $nestedData['UserName_User'] = $row['UserName_User'];
            $nestedData['Rec_Created_At'] = $row['Rec_Created_At'];
            $nestedData['UserDivision'] = $row['UserDivision'];
            $nestedData['Legitimate'] = $row['Legitimate'];
            $nestedData['Payment_Status'] = $row['Payment_Status'];
            $nestedData['Payment_Plan_Date'] = $row['Payment_Plan_Date'];
            $nestedData['Payment_Status_Time_Change'] = !empty($row['Payment_Status_Time_Change']) ? date('Y-m-d H:i', strtotime($row['Payment_Status_Time_Change'])) : '-';

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

    public function export_excel()
    {
        // Load the PhpSpreadsheet library
        require 'vendor/autoload.php';

        $from   = $this->input->get('from');
        $until  = $this->input->get('until');
        $column_range  = $this->input->get('column_range');
        $username = $this->session->userdata('sys_sba_username');

        $sql = $this->help->generate_sql_spesific_history_approval($username, $column_range, $from, $until);
        $query = $this->db->query($sql);
        $data = $query->result_array();

        $currencySummary = array();
        foreach ($data as $row) {
            $currency = trim((string) ($row['Currency_Id'] ?? ''));
            if ($currency === '') {
                $currency = 'N/A';
            }

            $amount = (float) ($row['Amount'] ?? 0);
            if (!isset($currencySummary[$currency])) {
                $currencySummary[$currency] = 0;
            }
            $currencySummary[$currency] += $amount;
        }

        $spreadsheet = new \PhpOffice\PhpSpreadsheet\Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();

        $sheet->setCellValue('A1', 'ESBA: History Approval Report (' . $from . ' to ' . $until . ') downloaded at ' . date('Y-m-d H:i'));
        $sheet->mergeCells('A1:U1');
        $sheet->getStyle('A1:U1')->getFont()->setBold(true)->setSize(14);
        $sheet->getStyle('A1:U1')->getAlignment()->setHorizontal(\PhpOffice\PhpSpreadsheet\Style\Alignment::HORIZONTAL_CENTER);
        $sheet->getStyle('A1:U1')->getFill()
            ->setFillType(\PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID)
            ->getStartColor()
            ->setARGB('DDEBF7');

        // Set Header
        $headers = ['A2' => 'No', 'B2' => 'CBReq No', 'C2' => 'Document Date', 'D2' => 'Currency', 'E2' => 'Amount', 'F2' => 'Document Number', 'G2' => 'Description', 'H2' => 'Status', 'I2' => 'Paid Status', 'J2' => 'Division', 'K2' => 'Created By', 'L2' => 'Asst. Manager', 'M2' => 'Manager', 'N2' => 'Senior Manager', 'O2' => 'General Manager', 'P2' => 'Additional', 'Q2' => 'Finance Person', 'R2' => 'Director', 'S2' => 'Finance Director', 'T2' => 'President Director', 'U2' => 'Payment Plan Date'];
        foreach ($headers as $cell => $value) {
            $sheet->setCellValue($cell, $value);
        }

        $sheet->getStyle('A2:U2')->getFont()->setBold(true);
        $sheet->getStyle('A2:U2')->getFill()
            ->setFillType(\PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID)
            ->getStartColor()
            ->setARGB('D9EAF7');
        $sheet->getStyle('A2:U2')->getAlignment()->setHorizontal(\PhpOffice\PhpSpreadsheet\Style\Alignment::HORIZONTAL_CENTER);
        $sheet->getStyle('A2:U2')->getBorders()->getAllBorders()->setBorderStyle(\PhpOffice\PhpSpreadsheet\Style\Border::BORDER_THIN);

        // Set Data
        $rowNum = 3;
        foreach ($data as $key => $row) {
            $sheet->setCellValue('A' . $rowNum, $key + 1);
            $sheet->setCellValue('B' . $rowNum, $row['CBReq_No']);
            $sheet->setCellValue('C' . $rowNum, $row['Document_Date'] ? date('Y-m-d', strtotime($row['Document_Date'])) : '-');
            $sheet->setCellValue('D' . $rowNum, $row['Currency_Id']);
            $sheet->setCellValue('E' . $rowNum, $row['Amount']);
            $sheet->setCellValue('F' . $rowNum, $row['Document_Number']);
            $sheet->setCellValue('G' . $rowNum, $row['Descript']);
            $sheet->setCellValue('H' . $rowNum, ($row['isClose'] == 0 || $row['isClose'] == '' || $row['isClose'] == null) ? 'Open' : 'VOID');
            $paid_status = '';
            if ($row['Paid_Status'] == 'NP') {
                $paid_status = 'Not Paid';
            } else if ($row['Paid_Status'] == 'HP') {
                $paid_status = 'Half Paid';
            } else if ($row['Paid_Status'] == 'FP') {
                $paid_status = 'Full Paid';
            }
            $sheet->setCellValue('I' . $rowNum, $paid_status);
            $sheet->setCellValue('J' . $rowNum, $row['UserDivision']);
            $sheet->setCellValue('K' . $rowNum, $row['Created_By_Name']);

            $sheet->setCellValue('L' . $rowNum, $this->getApprovalStatus($row['IsAppvAsstManager'], $row['Status_AppvAsstManager']));
            $sheet->setCellValue('M' . $rowNum, $this->getApprovalStatus($row['IsAppvManager'], $row['Status_AppvManager']));
            $sheet->setCellValue('N' . $rowNum, $this->getApprovalStatus($row['IsAppvSeniorManager'], $row['Status_AppvSeniorManager']));
            $sheet->setCellValue('O' . $rowNum, $this->getApprovalStatus($row['IsAppvGeneralManager'], $row['Status_AppvGeneralManager']));
            $sheet->setCellValue('P' . $rowNum, $this->getApprovalStatus($row['IsAppvAdditional'], $row['Status_AppvAdditional']));
            $sheet->setCellValue('Q' . $rowNum, $this->getApprovalStatus($row['IsAppvFinancePerson'], $row['Status_AppvFinancePerson']));
            $sheet->setCellValue('R' . $rowNum, $this->getApprovalStatus($row['IsAppvDirector'], $row['Status_AppvDirector']));
            $sheet->setCellValue('S' . $rowNum, $this->getApprovalStatus($row['IsAppvFinanceDirector'], $row['Status_AppvFinanceDirector']));
            $sheet->setCellValue('T' . $rowNum, $this->getApprovalStatus($row['IsAppvPresidentDirector'], $row['Status_AppvPresidentDirector']));
            $sheet->setCellValue('U' . $rowNum, $row['Payment_Plan_Date']);

            if ((int) ($row['Status_AppvPresidentDirector'] ?? 0) === 1) {
                $sheet->getStyle('A' . $rowNum . ':U' . $rowNum)->getFill()
                    ->setFillType(\PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID)
                    ->getStartColor()
                    ->setARGB('D9EAF7');
            }

            $rowNum++;
        }

        $summaryStartRow = $rowNum + 2;
        $sheet->setCellValue('A' . $summaryStartRow, 'Summary Per Currency');
        $sheet->setCellValue('B' . $summaryStartRow, 'Currency');
        $sheet->setCellValue('C' . $summaryStartRow, 'Total Amount');
        $sheet->getStyle('A' . $summaryStartRow . ':C' . $summaryStartRow)->getFont()->setBold(true);
        $sheet->getStyle('A' . $summaryStartRow . ':C' . $summaryStartRow)->getFill()
            ->setFillType(\PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID)
            ->getStartColor()
            ->setARGB('E9ECEF');
        $sheet->getStyle('A' . $summaryStartRow . ':C' . $summaryStartRow)->getBorders()->getAllBorders()->setBorderStyle(\PhpOffice\PhpSpreadsheet\Style\Border::BORDER_THIN);
        $sheet->getStyle('A' . $summaryStartRow . ':C' . $summaryStartRow)->getAlignment()->setHorizontal(\PhpOffice\PhpSpreadsheet\Style\Alignment::HORIZONTAL_CENTER);

        $summaryRow = $summaryStartRow + 1;
        foreach ($currencySummary as $currency => $total) {
            $sheet->setCellValue('B' . $summaryRow, $currency);
            $sheet->setCellValue('C' . $summaryRow, $total);
            $sheet->getStyle('B' . $summaryRow . ':C' . $summaryRow)->getNumberFormat()->setFormatCode('#,##0.00');
            $summaryRow++;
        }

        $writer = new \PhpOffice\PhpSpreadsheet\Writer\Xlsx($spreadsheet);
        $filename = 'History_Approval-' . date('YmdHis') . '.xlsx';

        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment; filename="' . $filename . '"');
        header('Cache-Control: max-age=0');

        $writer->save('php://output');
    }

    private function getApprovalStatus($isAppv, $status)
    {
        if ($isAppv == 1) {
            if ($status == 0) {
                return 'Pending';
            } else if ($status == 1) {
                return 'Approved';
            } else if ($status == 2) {
                return 'Rejected';
            }
        }
        return " -";
    }
}
