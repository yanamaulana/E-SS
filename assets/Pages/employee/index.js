$(document).ready(function () {
    function hitungUmur(tanggalLahir) {
        let tanggalLahirDate = new Date(tanggalLahir);
        let tanggalSekarang = new Date();

        let umur = tanggalSekarang.getFullYear() - tanggalLahirDate.getFullYear();
        let bulan = tanggalSekarang.getMonth() - tanggalLahirDate.getMonth();
        let hari = tanggalSekarang.getDate() - tanggalLahirDate.getDate();

        // Jika bulan atau hari kurang dari sekarang, kurangi umur 1 tahun
        if (bulan < 0 || (bulan === 0 && hari < 0)) {
            umur--;
        }

        return umur;
    }

    function hitungUmurKerja(tanggalLahir) {
        let tanggalLahirDate = new Date(tanggalLahir);
        let tanggalSekarang = new Date();

        // Menghitung selisih waktu dalam milidetik
        let timeDiff = tanggalSekarang - tanggalLahirDate;

        // Menghitung jumlah hari dari selisih waktu
        let daysDiff = timeDiff / (1000 * 60 * 60 * 24);

        // Menghitung jumlah tahun desimal (365.25 hari per tahun termasuk tahun kabisat)
        let umur = daysDiff / 365.25;

        return Math.round(umur); // Menghasilkan angka desimal dengan dua tempat desimal
    }

    function cekStatusKontrak(data) {
        let status = '';
        let awalan = data.charAt(0); // Mendapatkan karakter pertama dari variabel data

        if (awalan === '2') {
            status = 'Kontrak';
        } else if (awalan === '9') {
            status = 'HL';
        } else {
            status = 'Tetap';
        }

        return status;
    }

    $('#search').on('click', function () {
        InitDataTable($('#var').val(), $('#param').val());
    })

    $('#param').on('keypress', function (e) {
        if (e.which === 13) { // 13 adalah kode ASCII untuk tombol Enter
            InitDataTable($('#var').val(), $('#param').val());
        }
    });

    function InitDataTable(variabel, parameter) {
        var TableData = $("#DataTable").DataTable({
            destroy: true,
            processing: true,
            serverSide: true,
            dom: '<"row mb-3"<"col-sm-12"B>><"row"<"col-sm-11"f><"col-sm-1"l>>rtip',
            select: true,
            "lengthMenu": [
                [15, 50, 100, 4999],
                [15, 50, 100, 4999]
            ],
            ajax: {
                url: $('meta[name="base_url"]').attr('content') + "InformasiKaryawan/DT_List_Employee",
                dataType: "json",
                type: "POST",
                data: {
                    varr: variabel,
                    param: parameter
                }
            },
            columns: [
                {
                    // 1. No
                    data: "Emp_No",
                    name: "Emp_No",
                    render: function (data, type, row, meta) {
                        return meta.row + meta.settings._iDisplayStart + 1;
                    }
                },
                {
                    // 2. NIP
                    data: "Emp_No",
                    name: "Emp_No",
                },
                {
                    // 3. EMP ID
                    data: "Emp_ID",
                    name: "Emp_ID",
                },
                {
                    // 4. Nama Karyawan
                    data: "FullName",
                    name: "FullName",
                },
                {
                    // 5. Jenis Kelamin
                    data: "Gender",
                    name: "Gender",
                    render: function (data) {
                        return data == 1 ? "Pria" : "Wanita";
                    }
                },
                {
                    // 6. Alamat
                    data: "Address1",
                    name: "Address1",
                },
                {
                    // 7. Tempat Lahir
                    data: "Birth_Place",
                    name: "Birth_Place",
                },
                {
                    // 8. Tanggal Lahir
                    data: "Date_Of_Birth",
                    name: "Date_Of_Birth",
                    render: function (data) {
                        return data ? data : "N/A";
                    }
                },
                {
                    // 9. Umur
                    data: "Date_Of_Birth",
                    name: "Date_Of_Birth",
                    render: function (data) {
                        return data ? hitungUmur(data) : "N/A";
                    }
                },
                {
                    // 10. Tanggal Bergabung
                    data: "Start_Date",
                    name: "Start_Date",
                    render: function (data) {
                        return data ? data : "N/A";
                    }
                },
                {
                    // 11. Masa Kerja
                    data: "Start_Date",
                    name: "Start_Date",
                    render: function (data, type, row) {
                        return data ? hitungUmurKerja(data) : "N/A";
                    }
                },
                {
                    // 12. Tanggal Resign
                    data: "End_Date",
                    name: "End_Date",
                    visible: false,
                },
                {
                    // 13. Jabatan
                    data: "Position_Name_En",
                    name: "Position_Name_En",
                },
                {
                    // 14. Pendidikan
                    data: "Edu_Name",
                    name: "Edu_Name",
                    render: function (data) {
                        return data ? data : "N/A";
                    }
                },
                {
                    // 15. Status Karyawan
                    data: "EmploymentStatus_Name_En",
                    name: "EmploymentStatus_Name_En",
                },
                {
                    // 16. Status Pernikahan
                    data: "Marital_Status",
                    name: "Marital_Status",
                    render: function (data) {
                        return data == 1 ? "Married" : "Single";
                    }
                },
                {
                    // 17. Status Pajak
                    data: "TaxStatus",
                    name: "TaxStatus",
                    render: function (data, type, row) {
                        return data == 0 ? "TK" : "K/" + (row.NumDependent ? row.NumDependent : 0);
                    }
                },
                {
                    // 18. Gaji Pokok
                    data: "Salary",
                    name: "Salary",
                    render: function (data) {
                        return data ? Number(data).toLocaleString('id-ID') : 0;
                    }
                },
                {
                    // 19. Tunjangan Insentif
                    data: "Insentif",
                    name: "Insentif",
                    render: function (data) {
                        return data ? Number(data).toLocaleString('id-ID') : 0;
                    }
                },
                {
                    // 20. Tunjangan Jabatan
                    data: "Tunj_Jabatan",
                    name: "Tunj_Jabatan",
                    render: function (data) {
                        return data ? Number(data).toLocaleString('id-ID') : 0;
                    }
                },
                {
                    // 21. Uang Makan
                    data: "Uang_Makan",
                    name: "Uang_Makan",
                    render: function (data) {
                        return data ? Number(data).toLocaleString('id-ID') : 0;
                    }
                },
                {
                    // 22. Uang Transport
                    data: "Uang_Trans",
                    name: "Uang_Trans",
                    render: function (data) {
                        return data ? Number(data).toLocaleString('id-ID') : 0;
                    }
                },
                {
                    // 23. Cost Center
                    data: "CostCenter_Code",
                    name: "CostCenter_Code",
                    render: function (data, type, row) {
                        return `${row.CostCenter_Code} - ${row.CostCenter_Name_En}`;
                    }
                },
                {
                    // 24. KTP
                    data: "NRIC",
                    name: "NRIC",
                },
                {
                    // 25. No BPJS Kesehatan
                    data: "No_BPJSKES",
                    name: "No_BPJSKES",
                },
                {
                    // 26. No BPJS Ketenagakerjaan
                    data: "No_JAMSOSTEK",
                    name: "No_JAMSOSTEK",
                },
                {
                    // 27. Mobile Phone
                    data: "Mobile_Phone",
                    name: "Mobile_Phone",
                },
                {
                    // 28. Email
                    data: "EMAIL",
                    name: "EMAIL",
                },
                {
                    // 29. Bank Account
                    data: "BANK_ACCOUNT",
                    name: "BANK_ACCOUNT",
                }, {
                    data: "EMP_IMAGE",
                    name: "EMP_IMAGE",
                    render: function (data, type, row, meta) {
                        return `<div class="card shadow">
                            <img class="card-img-top" src="${$('meta[name="base_url"]').attr('content')}assets/Files/photo/${row.Emp_No}.jpg" alt="Employee Photo" style="width: 10vh; object-fit: cover;">
                    </div>`;
                    }
                },
            ],
            order: [[1, "asc"]],
            columnDefs: [
                // Penyesuaian Indeks berdasarkan 29 Kolom
                { className: "text-center", targets: [0, 2, 4, 7, 8, 9, 10, 11, 15, 16, 23, 24, 25, 26, 27, 28] },
                { className: "text-right", targets: [17, 18, 19, 20, 21] }
            ],
            autoWidth: true,
            responsive: false,
            preDrawCallback: function () {
                $("#DataTable tbody td").addClass("blurry");
            },
            language: {
                processing: '<i style="color:#4a4a4a" class="fa fa-spinner fa-spin fa-3x fa-fw"></i><span class="sr-only"></span><p><span style="color:#4a4a4a" class="loading-text"></span> ',
            },
            drawCallback: function () {
                $("#DataTable tbody td").removeClass("blurry");
                $('[data-toggle="tooltip"]').tooltip();
            },
            buttons: [
                {
                    text: `<i class="fas fa-id-card-alt"></i> Upload Photo`,
                    className: "btn btn-light-info",
                    action: function (e, dt, node, config) {
                        window.location.href = $('meta[name="base_url"]').attr('content') + "InformasiKaryawan/upload_photo";
                    }
                },
                {
                    text: `Export to :`,
                    className: "btn disabled text-dark bg-white",
                }, {
                    text: `<i class="far fa-copy text-white"></i>`,
                    extend: 'copy',
                    className: "bg-info",
                }, {
                    text: `<i class="far fa-file-excel"></i>`,
                    extend: 'excelHtml5',
                    title: $('#table-title').text() + '~' + moment().format("YYYY-MM-DD"),
                    className: "btn btn-sm btn-success",
                }, {
                    text: `<i class="far fa-file-pdf"></i>`,
                    extend: 'pdfHtml5',
                    title: $('#table-title').text() + '~' + moment().format("YYYY-MM-DD"),
                    className: "btn btn-sm btn-danger",
                    orientation: "landscape"
                }, {
                    text: `<i class="fas fa-print"></i>`,
                    extend: 'print',
                    className: "btn btn-sm btn-warning",
                }
            ],
        }).buttons().container().appendTo('#TableData_wrapper .col-md-6:eq(0)');
    }



    InitDataTable($('#var').val(), $('#param').val());

})