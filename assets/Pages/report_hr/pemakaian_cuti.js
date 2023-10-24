$(document).ready(function () {
    $("#TableDataHistory").DataTable({
        destroy: true,
        dom: 'lBfrtip',
        orderCellsTop: true,
        fixedHeader: {
            header: true,
            headerOffset: 48
        },
        order: [
            [3, "ASC"]
        ],
        columnDefs: [{
            className: "align-middle text-center",
            targets: [0, 1, 2, 3, 5, 6],
        }],
        autoWidth: false,
        responsive: true,
        "rowCallback": function (row, data) {
            // if (data.Approve == "0") {
            // $('td', row).css('background-color', 'pink');
            // }
        },
        preDrawCallback: function () {
            $("#TableDataHistory tbody td").addClass("blurry");
        },
        language: {
            processing: '<i style="color:#4a4a4a" class="fa fa-spinner fa-spin fa-3x fa-fw"></i><span class="sr-only"></span><p><span style="color:#4a4a4a" style="text-align:center" class="loading-text"></span> ',
            searchPlaceholder: "Search..."
        },
        drawCallback: function () {
            $("#TableDataHistory tbody td").addClass("blurry");
            $('[data-toggle="tooltip"]').tooltip();
        },
        "buttons": [{
            text: `<i class="fas fa-plus fs-3"></i>`,
            className: "btn btn-info",
            action: function (e, dt, node, config) {
                $('#Modal-Add').modal('show');
            }
        }, {
            text: `Export to :`,
            className: "btn disabled text-dark bg-white",
        }, {
            text: `<i class="far fa-copy fs-2"></i>`,
            extend: 'copy',
            className: "btn btn-light-warning",
        }, {
            text: `<i class="far fa-file-excel fs-2"></i>`,
            extend: 'excelHtml5',
            footer: true,
            title: $('#table-title-detail').text() + '~' + moment().format("YYYY-MM-DD"),
            className: "btn btn-light-success",
        }, {
            text: `<i class="far fa-file-pdf fs-2"></i>`,
            extend: 'pdfHtml5',
            title: $('#table-title-detail').text() + '~' + moment().format("YYYY-MM-DD"),
            className: "btn btn-light-danger",
            footer: true,
            orientation: "landscape"
        }, {
            text: `<i class="fas fa-print fs-2"></i>`,
            extend: 'print',
            footer: true,
            className: "btn btn-light-dark",
        }],
    }).buttons().container().appendTo('#TableDataHistory_wrapper .col-md-6:eq(0)');
})