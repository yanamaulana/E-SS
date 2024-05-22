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

        return umur.toFixed(1); // Menghasilkan angka desimal dengan dua tempat desimal
    }

    $('#search').on('click', function () {
        InitDataTable($('#var').val(), $('#param').val());
    })

    function InitDataTable(variabel, parameter) {
        var TableData = $("#DataTable").DataTable({
            destroy: true,
            processing: true,
            serverSide: true,
            dom: '<"row"<"col-md-6"><"col-md-6">><"row"<"col-md-8"l><"col-md-4"B>>rtip',
            select: true,
            lengthMenu: [
                [10, 25, 50, 10000],
                [10, 25, 50, 'All']
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
            columns: [{
                data: "Emp_No",
                name: "Emp_No",
                visible: true,
                render: function (data, type, row, meta) {
                    return meta.row + meta.settings._iDisplayStart + 1;
                }
            },
            {
                data: "Emp_No",
                name: "Emp_No",
            },
            {
                data: "First_Name",
                name: "First_Name",
            },
            {
                data: "Pos_Name",
                name: "Pos_Name",
            },
            {
                data: "Division_Name",
                name: "Division_Name",
            },
            {
                data: "costcenter_name",
                name: "costcenter_name",
            },
            {
                data: "Date_Of_Birth",
                name: "Date_Of_Birth",
                render: function (data) {
                    return hitungUmur(data)
                }
            },
            {
                data: "Start_Date",
                name: "Start_Date",
                render: function (data) {
                    return hitungUmurKerja(data)
                }
            },
            {
                data: "EMPLOYMENTSTATUS_NAME",
                name: "EMPLOYMENTSTATUS_NAME",
            },
            {
                data: "Email",
                name: "Email",
            },
            {
                data: "EMP_IMAGE",
                name: "EMP_IMAGE",
                render: function (data, type, row, meta) {
                    return `<div class="card shadow">
                            <img class="card-img-top" src="${$('meta[name="base_url"]').attr('content')}assets/Files/photo/${row.Emp_No}.jpg" alt="Employee Photo" style="width: 10vh; object-fit: cover;">
                    </div>`;
                }
            },
            ],
            order: [[2, "asc"]],
            columnDefs: [
                { className: "text-center", targets: [0, 10], },
                { className: "text-left", targets: [] }
            ],
            autoWidth: true,
            responsive: true,
            rowCallback: function (row, data) {
                // console.log(row.Is_Close)
                // if (data.Is_NotActive == 1) {
                //     $('td', row).css('background-color', 'grey');
                // }
            },
            preDrawCallback: function () {
                $("#DataTable tbody td").addClass("blurry");
            },
            language: {
                processing: '<i style="color:#4a4a4a" class="fa fa-spinner fa-spin fa-3x fa-fw"></i><span class="sr-only"></span><p><span style="color:#4a4a4a" style="text-align:center" class="loading-text"></span> ',
            },
            drawCallback: function () {
                $("#DataTable tbody td").addClass("blurry");
                setTimeout(function () {
                    $("#DataTable tbody td").removeClass("blurry");
                });
                $('[data-toggle="tooltip"]').tooltip();
            },
            "buttons": [
                //     {
                //     text: `<i class="fas fa-plus fs-3"></i>`,
                //     className: "bg-primary",
                //     action: function (e, dt, node, config) {
                //         window.location.href = $('meta[name="base_url"]').attr('content') + "Backend/Blog/index"
                //     }
                // }, {
                //     text: `<i class="fas fa-edit fs-3"></i>`,
                //     className: "btn btn-warning",
                //     action: function (e, dt, node, config) {
                //         var RowData = dt.rows({
                //             selected: true
                //         }).data();
                //         if (RowData.length == 0) {
                //             Swal.fire({
                //                 icon: 'warning',
                //                 title: 'Ooppss...',
                //                 text: 'Please select data to be update !',
                //                 footer: '<a href="javascript:void(0)" class="text-danger">Notifikasi System</a>'
                //             });
                //         } else {
                //             Init_Append_Modal_Update(RowData[0].SysId)
                //         }
                //     }
                // }, {
                //     text: `<i class="fas fa-trash"></i>`,
                //     className: "btn disabled text-dark bg-white",
                //     action: function (e, dt, node, config) {
                //         var RowData = dt.rows({
                //             selected: true
                //         }).data();
                // if (RowData.length == 0) {
                //     Swal.fire({
                //         icon: 'warning',
                //         title: 'Ooppss...',
                //         text: 'Please select data to be delete !',
                //         footer: '<a href="javascript:void(0)" class="text-danger">Notifikasi System</a>'
                //     });
                // } else {
                //     Fn_Delete_RowData(RowData[0].SysId)
                // }
                // }
                // },
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
                }],
        }).buttons().container().appendTo('#TableData_wrapper .col-md-6:eq(0)');
    }
    InitDataTable($('#var').val(), $('#param').val());

})