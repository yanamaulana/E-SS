<?php
defined('BASEPATH') or exit('No direct script access allowed');

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Worksheet\Drawing;
use PhpOffice\PhpSpreadsheet\Cell\DataType;

class InformasiKaryawan extends CI_Controller
{
    private $HR;
    private $Date;
    private $DateTime;
    private $layout = 'layout';
    private $HRQview_Employee_Detail = 'HRQviewEmployeeDetail';

    public function __construct()
    {
        parent::__construct();
        is_logged_in();
        $this->Date = date("Y-m-d");
        $this->DateTime = date("Y-m-d H:i:s");
        $this->load->model('m_helper', 'help');
        $this->load->model('m_DataTable_Hr', 'M_Datatable_HR');
        $this->HR = $this->load->database('HR', TRUE);
    }

    public function index()
    {
        $this->data['page_title'] = "System Employee Information";
        $this->data['page_content'] = "employee/index";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/employee/index.js?v=' . time() . '"></script>';

        $this->load->view($this->layout, $this->data);
    }

    public function upload_photo()
    {
        $this->data['page_title'] = "Upload Employee Photo";
        $this->data['page_content'] = "employee/employee_photo";
        $this->data['script_page'] =  '<script src="' . base_url() . 'assets/Pages/employee/employee_photo.js?v=' . time() . '"></script>';

        $this->load->view($this->layout, $this->data);
    }

    // -------------------------------- POST FORM ----------------------------------------------//

    public function store_profile_picture()
    {
        $upload_image = $_FILES['fp']['name'];
        $file_name_without_ext = pathinfo($upload_image, PATHINFO_FILENAME);
        $Sql_Emp = $this->HR->get_where($this->HRQview_Employee_Detail, ['Emp_No' => $file_name_without_ext]);

        $source_path = FCPATH . 'assets/Files/photo/' . $upload_image;
        $destination_path = FCPATH . 'assets/Files/replaced_photo/' . date('Ymds') . '_' . $upload_image;
        if (file_exists($source_path)) {
            rename($source_path, $destination_path);
        } else {
            return $this->help->Fn_resulting_response([
                'code' => 505,
                'msg' => "Terjadi kesalahan teknis hubungi MIS !",
            ]);
        }

        if ($Sql_Emp->num_rows() == 0) {
            return $this->help->Fn_resulting_response([
                'code' => 505,
                'msg' => "update photo failed : Nomor induk karyawan → $file_name_without_ext tidak ditemukan !",
            ]);
        }
        if ($upload_image) {
            $config['allowed_types'] = 'jpg';
            $config['max_size']      = '5120';
            $config['upload_path'] = 'assets/Files/photo/';

            $this->load->library('upload', $config);
            if ($this->upload->do_upload('fp')) {
                $Data_Emp = $Sql_Emp->row();
                return $this->help->Fn_resulting_response([
                    'code' => 200,
                    'msg' => "Update profile picture $Data_Emp->First_Name ($file_name_without_ext) success !",
                ]);
            } else {
                return $this->help->Fn_resulting_response([
                    'code' => 505,
                    'msg' => 'update photo failed : ' . $this->upload->display_errors(),
                ]);
            }
        }
    }

    // -------------------------------- DEVIDER Datatable -------------------------------------- //

    public function DT_List_Employee()
    {
        $requestData = $_REQUEST;

        // Pemetaan 29 Kolom untuk Order By DataTables
        $columns = array(
            0 => 'EmpComp.Emp_No',
            1 => 'EmpComp.Emp_No',
            2 => 'EmpData.Emp_ID',
            3 => 'EmpData.First_Name',
            4 => 'EmpData.Gender',
            5 => 'EmpData.Address1',
            6 => 'EmpData.Birth_Place',
            7 => 'EmpData.Date_Of_Birth',
            8 => 'EmpData.Date_Of_Birth',
            9 => 'EmpComp.Start_Date',
            10 => 'EmpComp.Start_Date',
            11 => 'EmpComp.End_Date',
            12 => 'EmpPos.Position_Name_En',
            13 => 'EmpEdu.Edu_Name',
            14 => 'EmpStatus.EmploymentStatus_Name_En',
            15 => 'EmpData.Marital_Status',
            16 => 'EmpSal.TaxStatus',
            17 => 'EmpSal.Salary',
            18 => 'EmpSal.PayrollField1',
            19 => 'EmpSal.PayrollField2',
            20 => 'EmpSal.PayrollField6',
            21 => 'EmpSal.Payrollfield5',
            22 => 'EmpCost.CostCenter_Code',
            23 => 'EmpData.NRIC',
            24 => 'No_BPJSKES',
            25 => 'No_JAMSOSTEK',
            26 => 'EmpData.Mobile_Phone',
            27 => 'EmpData.EMAIL',
            28 => 'EmpComp.BANK_ACCOUNT',
            29 => 'EmpData.EMP_IMAGE'
        );

        $order  = $columns[$requestData['order']['0']['column']];
        $dir    = $requestData['order']['0']['dir'];
        // $from   = $this->input->post('from');
        // $until  = $this->input->post('until');

        $sql = "SELECT EmpComp.Emp_No AS Emp_No, 
            EmpData.Emp_ID, 
            EmpData.First_Name+' '+EmpData.Middle_Name+' '+EmpData.Last_Name AS FullName, 
            EmpData.Gender AS Gender, 
            EmpData.Address1, 
            EmpData.Birth_Place AS Birth_Place, 
            EmpData.Date_Of_Birth AS Date_Of_Birth,
            EmpComp.Start_Date AS Start_Date,
            EmpComp.End_Date AS End_Date,
            EmpPos.Position_Name_En,
            EmpEdu.Edu_Name AS Edu_Name,
            EmpStatus.EmploymentStatus_Name_En AS EmploymentStatus_Name_En,
            EmpData.Marital_Status AS Marital_Status,
            EmpSal.TaxStatus AS TaxStatus,
            EmpSal.NumDependent AS NumDependent,
            dbo.SF131412(EmpSal.Salary, 'muliaditinawellystif', '10001010101001010010') AS Salary,
            ISNULL(NULLIF(EmpSal.PayrollField1, ''), '0') AS Insentif,
            ISNULL(NULLIF(EmpSal.PayrollField2, ''), '0') AS Tunj_Jabatan,
            ISNULL(NULLIF(EmpSal.PayrollField5, ''), '0') AS Uang_Makan,
            ISNULL(NULLIF(EmpSal.PayrollField6, ''), '0') AS Uang_Trans,
            EmpCost.CostCenter_Code AS CostCenter_Code,
            EmpCost.CostCenter_Name_En AS CostCenter_Name_En,
            EmpData.NRIC, 
            (Select Insurance_No from THRMEmpInsurance EmpInsurance1 where EmpInsurance1.Insurance_Institution = 'BPJSKES' and EmpInsurance1.Emp_ID = EmpComp.EMP_ID) as No_BPJSKES,
            (Select Insurance_No from THRMEmpInsurance EmpInsurance2 where EmpInsurance2.Insurance_Institution = 'JAMSOSTEK' and EmpInsurance2.Emp_ID = EmpComp.EMP_ID) as No_JAMSOSTEK,
            EmpData.Phone, 
            EmpData.Mobile_Phone, 
            EmpData.Phone1, 
            EmpData.EMAIL,  
            EmpComp.BANK_ACCOUNT,
            EmpData.EMP_IMAGE
        FROM THRMEmpPersonalData EmpData
        LEFT JOIN THRMEmpCompany EmpComp ON EmpData.Emp_ID = EmpComp.Emp_ID
        LEFT JOIN THRMEmpSalaryParam EmpSal ON EmpComp.EMP_ID = EmpSal.Emp_ID
        LEFT JOIN THRMEmpEducation EmpEdu ON EmpComp.Emp_ID = EmpEdu.Emp_ID
        LEFT JOIN THRMEmploymentStatus EmpStatus ON EmpComp.Employment_Code = EmpStatus.EmploymentStatus_Code
        LEFT JOIN THRMPosition EmpPos ON EmpComp.Position_ID = EmpPos.Position_ID
        LEFT JOIN THRMCostCenter EmpCost ON EmpComp.Cost_Center = EmpCost.CostCenter_Code
        WHERE EmpComp.Start_Date <= '$this->DateTime'
        AND (EmpComp.End_Date IS NULL OR EmpComp.End_Date = '' OR EmpComp.End_Date >= '$this->DateTime')";

        $totalData = $this->HR->query($sql)->num_rows();

        // Benarkan Logika Search berdasarkan atribut Employee
        if (!empty($requestData['search']['value'])) {
            $searchVal = $requestData['search']['value'];
            $sql .= " AND (EmpComp.Emp_No LIKE '%$searchVal%' ";
            $sql .= " OR EmpData.Emp_ID LIKE '%$searchVal%' ";
            $sql .= " OR EmpData.First_Name LIKE '%$searchVal%' ";
            $sql .= " OR EmpPos.Position_Name_En LIKE '%$searchVal%' ";
            $sql .= " OR EmpData.Address1 LIKE '%$searchVal%' ";
            $sql .= " OR EmpData.Mobile_Phone LIKE '%$searchVal%') ";
        }

        $totalFiltered = $this->HR->query($sql)->num_rows();
        $sql .= " ORDER BY $order $dir OFFSET " . $requestData['start'] . " ROWS FETCH NEXT " . $requestData['length'] . " ROWS ONLY ";
        $query = $this->HR->query($sql);

        $data = array();
        foreach ($query->result_array() as $row) {
            $nestedData = array();

            // Return 29 kolom ke DataTables
            $nestedData['Emp_No'] = $row['Emp_No'];
            $nestedData['Emp_ID'] = $row['Emp_ID'];
            $nestedData['FullName'] = $row['FullName'];
            $nestedData['Gender'] = $row['Gender'];
            $nestedData['Address1'] = $row['Address1'];
            $nestedData['Birth_Place'] = $row['Birth_Place'];
            $nestedData['Date_Of_Birth'] = !empty($row['Date_Of_Birth']) ? substr($row['Date_Of_Birth'], 0, 10) : null;
            $nestedData['Start_Date'] = !empty($row['Start_Date']) ? substr($row['Start_Date'], 0, 10) : null;
            $nestedData['End_Date'] = $row['End_Date'];
            $nestedData['Position_Name_En'] = $row['Position_Name_En'];
            $nestedData['Edu_Name'] = $row['Edu_Name'];
            $nestedData['EmploymentStatus_Name_En'] = $row['EmploymentStatus_Name_En'];
            $nestedData['Marital_Status'] = $row['Marital_Status'];
            $nestedData['TaxStatus'] = $row['TaxStatus'];
            $nestedData['NumDependent'] = $row['NumDependent'];
            $nestedData['Salary'] = $row['Salary'];
            $nestedData['Insentif'] = $row['Insentif'];
            $nestedData['Tunj_Jabatan'] = $row['Tunj_Jabatan'];
            $nestedData['Uang_Makan'] = $row['Uang_Makan'];
            $nestedData['Uang_Trans'] = $row['Uang_Trans'];
            $nestedData['CostCenter_Code'] = $row['CostCenter_Code'];
            $nestedData['CostCenter_Name_En'] = $row['CostCenter_Name_En'];
            $nestedData['NRIC'] = $row['NRIC'];
            $nestedData['No_BPJSKES'] = $row['No_BPJSKES'];
            $nestedData['No_JAMSOSTEK'] = $row['No_JAMSOSTEK'];
            $nestedData['Mobile_Phone'] = $row['Mobile_Phone'];
            $nestedData['EMAIL'] = $row['EMAIL'];
            $nestedData['BANK_ACCOUNT'] = $row['BANK_ACCOUNT'];
            $nestedData['EMP_IMAGE'] = $row['EMP_IMAGE'];

            $data[] = $nestedData;
        }

        $json_data = array(
            "draw" => intval($requestData['draw']),
            "recordsTotal" => intval($totalData),
            "recordsFiltered" => intval($totalFiltered),
            "data" => $data,
        );

        echo json_encode($json_data);
    }

    public function ExportExcelFoto()
    {
        // 1. Eksekusi Query (Sama seperti DT_List_Employee tapi tanpa batasan pagination)
        $sql = "SELECT EmpComp.Emp_No AS Emp_No, 
        EmpData.Emp_ID, 
        EmpData.First_Name+' '+EmpData.Middle_Name+' '+EmpData.Last_Name AS FullName, 
        EmpData.Gender AS Gender, 
        EmpData.Address1, 
        EmpData.Birth_Place AS Birth_Place, 
        EmpData.Date_Of_Birth AS Date_Of_Birth,
        EmpComp.Start_Date AS Start_Date,
        EmpComp.End_Date AS End_Date,
        EmpPos.Position_Name_En,
        EmpEdu.Edu_Name AS Edu_Name,
        EmpStatus.EmploymentStatus_Name_En AS EmploymentStatus_Name_En,
        EmpData.Marital_Status AS Marital_Status,
        EmpSal.TaxStatus AS TaxStatus,
        EmpSal.NumDependent AS NumDependent,
        dbo.SF131412(EmpSal.Salary, 'muliaditinawellystif', '10001010101001010010') AS Salary,
        ISNULL(NULLIF(EmpSal.PayrollField1, ''), '0') AS Insentif,
        ISNULL(NULLIF(EmpSal.PayrollField2, ''), '0') AS Tunj_Jabatan,
        ISNULL(NULLIF(EmpSal.PayrollField5, ''), '0') AS Uang_Makan,
        ISNULL(NULLIF(EmpSal.PayrollField6, ''), '0') AS Uang_Trans,
        EmpCost.CostCenter_Code AS CostCenter_Code,
        EmpCost.CostCenter_Name_En AS CostCenter_Name_En,
        EmpData.NRIC, 
        (Select Insurance_No from THRMEmpInsurance EmpInsurance1 where EmpInsurance1.Insurance_Institution = 'BPJSKES' and EmpInsurance1.Emp_ID = EmpComp.EMP_ID) as No_BPJSKES,
        (Select Insurance_No from THRMEmpInsurance EmpInsurance2 where EmpInsurance2.Insurance_Institution = 'JAMSOSTEK' and EmpInsurance2.Emp_ID = EmpComp.EMP_ID) as No_JAMSOSTEK,
        EmpData.Phone, 
        EmpData.Mobile_Phone, 
        EmpData.Phone1, 
        EmpData.EMAIL,  
        EmpComp.BANK_ACCOUNT,
        EmpData.EMP_IMAGE
    FROM THRMEmpPersonalData EmpData
    LEFT JOIN THRMEmpCompany EmpComp ON EmpData.Emp_ID = EmpComp.Emp_ID
    LEFT JOIN THRMEmpSalaryParam EmpSal ON EmpComp.EMP_ID = EmpSal.Emp_ID
    LEFT JOIN THRMEmpEducation EmpEdu ON EmpComp.Emp_ID = EmpEdu.Emp_ID
    LEFT JOIN THRMEmploymentStatus EmpStatus ON EmpComp.Employment_Code = EmpStatus.EmploymentStatus_Code
    LEFT JOIN THRMPosition EmpPos ON EmpComp.Position_ID = EmpPos.Position_ID
    LEFT JOIN THRMCostCenter EmpCost ON EmpComp.Cost_Center = EmpCost.CostCenter_Code
    WHERE EmpComp.Start_Date <= '$this->DateTime'
    AND (EmpComp.End_Date IS NULL OR EmpComp.End_Date = '' OR EmpComp.End_Date >= '$this->DateTime') 
    ORDER BY EmpComp.Emp_No ASC"; // Mengurutkan berdasarkan Emp_No

        $query = $this->HR->query($sql);
        $karyawan = $query->result_array();

        // 2. Inisialisasi PhpSpreadsheet
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle('Data Karyawan');

        // 3. Menyiapkan Header Tabel (Baris 1)
        $headers = [
            'A' => 'No',
            'B' => 'NIP',
            'C' => 'EMP ID',
            'D' => 'Nama Karyawan',
            'E' => 'Jenis Kelamin',
            'F' => 'Alamat',
            'G' => 'Tempat Lahir',
            'H' => 'Tanggal Lahir',
            'I' => 'Tanggal Bergabung',
            'J' => 'Tanggal Resign',
            'K' => 'Jabatan',
            'L' => 'Pendidikan',
            'M' => 'Status Karyawan',
            'N' => 'Status Pernikahan',
            'O' => 'Status Pajak',
            'P' => 'Gaji Pokok',
            'Q' => 'Tunjangan Insentif',
            'R' => 'Tunjangan Jabatan',
            'S' => 'Uang Makan',
            'T' => 'Uang Transport',
            'U' => 'Cost Center',
            'V' => 'KTP',
            'W' => 'No BPJS Kesehatan',
            'X' => 'No BPJS Ketenagakerjaan',
            'Y' => 'Mobile Phone',
            'Z' => 'Email',
            'AA' => 'Bank Account',
            'AB' => 'Photo'
        ];

        foreach ($headers as $col => $headerTitle) {
            $sheet->setCellValue($col . '1', $headerTitle);
            // Memiringkan dan menebalkan teks header
            $sheet->getStyle($col . '1')->getFont()->setBold(true);
        }

        // 4. Proses Looping Data ke dalam Sel
        $rowNum = 2; // Mulai dari baris ke-2
        $no = 1;

        foreach ($karyawan as $row) {
            $sheet->setCellValue('A' . $rowNum, $no++);

            // Gunakan setCellValueExplicit agar format angka nol di depan tidak hilang
            $sheet->setCellValueExplicit('B' . $rowNum, $row['Emp_No'], DataType::TYPE_STRING);
            $sheet->setCellValueExplicit('C' . $rowNum, $row['Emp_ID'], DataType::TYPE_STRING);
            $sheet->setCellValue('D' . $rowNum, $row['FullName']);

            $sheet->setCellValue('E' . $rowNum, ($row['Gender'] == 1 ? 'Pria' : 'Wanita'));
            $sheet->setCellValue('F' . $rowNum, $row['Address1']);
            $sheet->setCellValue('G' . $rowNum, $row['Birth_Place']);

            $sheet->setCellValue('H' . $rowNum, !empty($row['Date_Of_Birth']) ? substr($row['Date_Of_Birth'], 0, 10) : '');
            $sheet->setCellValue('I' . $rowNum, !empty($row['Start_Date']) ? substr($row['Start_Date'], 0, 10) : '');
            $sheet->setCellValue('J' . $rowNum, !empty($row['End_Date']) ? substr($row['End_Date'], 0, 10) : '');

            $sheet->setCellValue('K' . $rowNum, $row['Position_Name_En']);
            $sheet->setCellValue('L' . $rowNum, $row['Edu_Name']);
            $sheet->setCellValue('M' . $rowNum, $row['EmploymentStatus_Name_En']);
            $sheet->setCellValue('N' . $rowNum, ($row['Marital_Status'] == 1 ? 'Married' : 'Single'));
            $sheet->setCellValue('O' . $rowNum, ($row['TaxStatus'] == 0 ? 'TK' : 'K/' . ($row['NumDependent'] ?: 0)));

            $sheet->setCellValue('P' . $rowNum, $row['Salary']);
            $sheet->setCellValue('Q' . $rowNum, $row['Insentif']);
            $sheet->setCellValue('R' . $rowNum, $row['Tunj_Jabatan']);
            $sheet->setCellValue('S' . $rowNum, $row['Uang_Makan']);
            $sheet->setCellValue('T' . $rowNum, $row['Uang_Trans']);

            $sheet->setCellValue('U' . $rowNum, $row['CostCenter_Code'] . ' - ' . $row['CostCenter_Name_En']);

            // Data nomor panjang yang rentan berubah jadi rumus/eksponensial di Excel
            $sheet->setCellValueExplicit('V' . $rowNum, $row['NRIC'], DataType::TYPE_STRING);
            $sheet->setCellValueExplicit('W' . $rowNum, $row['No_BPJSKES'], DataType::TYPE_STRING);
            $sheet->setCellValueExplicit('X' . $rowNum, $row['No_JAMSOSTEK'], DataType::TYPE_STRING);
            $sheet->setCellValueExplicit('Y' . $rowNum, $row['Mobile_Phone'], DataType::TYPE_STRING);

            $sheet->setCellValue('Z' . $rowNum, $row['EMAIL']);
            $sheet->setCellValueExplicit('AA' . $rowNum, $row['BANK_ACCOUNT'], DataType::TYPE_STRING);

            // 5. Menyisipkan Gambar di Kolom AB
            $photoPath = FCPATH . 'assets/Files/photo/' . $row['Emp_No'] . '.jpg';

            if (file_exists($photoPath)) {
                $drawing = new Drawing();
                $drawing->setName('Foto Karyawan');
                $drawing->setDescription('Foto ' . $row['FullName']);
                $drawing->setPath($photoPath);
                $drawing->setCoordinates('AB' . $rowNum);
                $drawing->setOffsetX(5);
                $drawing->setOffsetY(5);
                $drawing->setHeight(60);
                $drawing->setWorksheet($sheet);

                // Melebarkan ukuran baris agar foto tidak tumpang tindih
                $sheet->getRowDimension($rowNum)->setRowHeight(55);
            } else {
                // Beri penanda teks jika foto fisik tidak ada di server
                $sheet->setCellValue('AB' . $rowNum, 'Tidak Ada Foto');
            }

            $rowNum++;
        }

        // Mengatur lebar kolom foto
        $sheet->getColumnDimension('AB')->setWidth(15);

        // 6. Output Download Excel
        $filename = 'Laporan_Data_Karyawan_' . date('Y-m-d') . '.xlsx';

        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment;filename="' . $filename . '"');
        header('Cache-Control: max-age=0');
        // Mencegah error cache di IE9
        header('Cache-Control: max-age=1');
        header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
        header('Last-Modified: ' . gmdate('D, d M Y H:i:s') . ' GMT');
        header('Cache-Control: cache, must-revalidate');
        header('Pragma: public');

        $writer = new Xlsx($spreadsheet);
        $writer->save('php://output');
        exit;
    }
}
