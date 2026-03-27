$(document).ready(function () {
    const Toast = Swal.mixin({
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        didOpen: (toast) => {
            toast.addEventListener('mouseenter', Swal.stopTimer)
            toast.addEventListener('mouseleave', Swal.resumeTimer)
        }
    })

    $('.date-picker').flatpickr();

    function Initialize_DataTable() {
        var TableData = $("#TableData").DataTable({
            destroy: true,
            processing: true,
            serverSide: true,
            paging: true,
            dom: '<"row mb-3"<"col-sm-12"B>><"row"<"col-sm-11"f><"col-sm-1"l>>rtip',
            orderCellsTop: true,
            select: false,
            "lengthMenu": [
                [15, 30, 90, 99999],
                [15, 30, 90, 99999]
            ],
            ajax: {
                url: $('meta[name="base_url"]').attr('content') + "Dashboard/DT_list_Access_Log",
                dataType: "json",
                type: "POST",
                data: {
                    from: $('#from').val(),
                    until: $('#until').val(),
                }
            },
            columns: [{
                data: "UserLog_ID",
                name: "UserLog_ID",
                title: "#",
                orderable: false, // Biasanya nomor urut tidak perlu diurutkan
                render: function (data, type, row, meta) {
                    // Kolom Nomor Urut (Nomor Baris)
                    return meta.row + meta.settings._iDisplayStart + 1;
                }
            },
            {
                data: "User_Name",
                name: "User_Name",
            },
            {
                data: "First_Name",
                name: "First_Name",
            },
            {
                data: "Remote_IP",
                name: "Remote_IP",
            },
            {
                data: "Log_Date",
                name: "Log_Date",
            },
            {
                data: "Log_Action",
                name: "Log_Action",
            },
            ],
            order: [
                [0, "DESC"]
            ],
            columnDefs: [{
                className: "text-center", // Use "dt-center" if NOT using Bootstrap
                targets: [0, 1, 2, 3, 4, 5]
            }, {
                className: "dt-nowrap",
                targets: []
            }],
            autoWidth: false,
            responsive: false,
            "rowCallback": function (row, data) {

            },
            preDrawCallback: function () {
                $("#TableData tbody td").addClass("blurry");
            },
            language: {
                processing: '<i style="color:#4a4a4a" class="fa fa-spinner fa-spin fa-3x fa-fw"></i><span class="sr-only"></span><p><span style="color:#4a4a4a" style="text-align:center" class="loading-text"></span> ',
                searchPlaceholder: "Search..."
            },
            drawCallback: function () {
                $("#TableData tbody td").addClass("blurry");
                setTimeout(function () {
                    $("#TableData tbody td").removeClass("blurry");
                });
                $('[data-bs-toggle="tooltip"]').tooltip();
            }, "buttons": [
                {
                    text: `Export To :`,
                    className: "btn btn-default disabled",
                }, {
                    text: `<i class="far fa-file-excel fs-2"></i>`,
                    extend: 'excelHtml5',
                    title: $('#table-title-main').text() + '~' + moment().format("YYYY-MM-DD"),
                    className: "btn btn-light-success",
                }
            ],
        }).buttons().container().appendTo('#TableData_wrapper .col-md-12:eq(0)');
    }

    Initialize_DataTable()

    $('#do--filter').on('click', function () {
        $("#TableData").DataTable().clear().destroy(), Initialize_DataTable();
    })
});