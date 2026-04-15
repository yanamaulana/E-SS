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
                url: $('meta[name="base_url"]').attr('content') + "SalesOrder/DT_list_sales_order",
                dataType: "json",
                type: "POST",
                data: {
                    from: $('#from').val(),
                    until: $('#until').val(),
                }
            },
            columns: [{
                data: 'SO_Number',
                name: "CheckBox",
                orderable: false,
                visible: false,
                render: function (data, type, row, meta) {
                    return `<div class="form-check">
                    <input class="form-check-input" type="checkbox" value="${row.SO_Number}" id="${row.SO_Number}" name="SO_Number[]">
                  </div>`
                }
            },
            {
                data: "SO_Number",
                name: "SO_Number",
                render: function (data) {
                    return `<a href="${$('meta[name="base_url"]').attr('content')}SalesOrder/add/edit/${data}">${data}</a>`
                }
            },
            {
                data: "Account_Name",
                name: "Account_Name",
            },
            {
                data: "PO_NumCustomer",
                name: "PO_NumCustomer",
            },
            {
                data: "SO_Date",
                name: "SO_Date",
                render: function (data) {
                    return data.substring(0, data.indexOf(' '));
                }
            },
            {
                data: "Doc_Status",
                name: "Doc_Status",
                // Tambahkan parameter 'row' untuk mengakses data di kolom lain pada baris yang sama
                render: function (data, type, row) {
                    if (data == 1) {
                        return '<span class="badge badge-info"><i class="fas fa-folder-open mr-1"></i> Open</span>';
                    } else if (data == 2) {
                        return '<span class="badge badge-success"><i class="fas fa-check mr-1"></i> Confirm</span>';
                    } else if (data == 3) {
                        // Pengecekan khusus untuk SN_Status
                        if (row.SN_Status === 'ND') {
                            return '<span class="badge badge-success"><i class="fas fa-check mr-1"></i> Confirm</span>';
                        } else {
                            return '<span class="badge badge-primary"><i class="fas fa-truck mr-1"></i> Delivered</span>';
                        }
                    } else if (data == 4) {
                        return '<span class="badge badge-warning text-dark"><i class="fas fa-file-invoice-dollar mr-1"></i> Invoiced</span>';
                    } else {
                        return '<span class="badge badge-secondary"><i class="fas fa-archive mr-1"></i> Closed</span>';
                    }
                }
            },
            {
                data: "SO_Status",
                name: "SO_Status",
                render: function (data, type, row) {
                    if (data == 1) {
                        return '<span class="badge badge-primary"><i class="fas fa-star mr-1"></i> New</span>';
                    } else if (data == 2) {
                        return '<span class="badge badge-warning text-dark"><i class="fas fa-folder-open mr-1"></i> Open</span>';
                    } else if (data == 3) {
                        return '<span class="badge badge-secondary"><i class="fas fa-archive mr-1"></i> Closed</span>';
                    } else {
                        return '<span class="badge badge-light">-</span>';
                    }
                }
            },
            {
                data: "Approval_Status",
                name: "Approval_Status",
                render: function (data, type, row) {
                    let badge = '';

                    // 1. Tentukan jenis Badge
                    if (data == 0) {
                        badge = '<span class="badge badge-info" title="New"><i class="fas fa-file-alt mr-1"></i> New</span>';
                    } else if (data == 2) {
                        badge = '<span class="badge badge-warning text-dark" title="Awaiting"><i class="fas fa-hourglass-half mr-1"></i> Awaiting</span>';
                    } else if (data == 3) {
                        badge = '<span class="badge badge-success" title="Approved"><i class="fas fa-check-double mr-1"></i> Approved</span>';
                    } else if (data == 4) {
                        badge = '<span class="badge badge-danger" title="Rejected"><i class="fas fa-times-circle mr-1"></i> Rejected</span>';
                    } else if (data == 5) {
                        badge = '<span class="badge badge-primary" title="Revising"><i class="fas fa-pencil-alt mr-1"></i> Revising</span>';
                    } else {
                        badge = '<span class="badge badge-secondary">-</span>';
                    }

                    // 2. Buat Link Popup
                    let baseUrl = $('meta[name="base_url"]').attr('content');
                    // Pastikan row.SO_Number terbawa di query database DataTable Anda
                    let popupUrl = baseUrl + "SalesOrder/approval_detail?SONum=" + encodeURIComponent(row.SO_Number) + "&task=Edit";

                    let html = `<a href="javascript:void(0);" onclick="window.open('${popupUrl}', 'Detail', 'width=600,height=600,scrollbars=yes,resizable=yes');" class="text-decoration-none">${badge}</a>`;

                    // 3. Tambahkan teks Revise Counter jika dokumen pernah direvisi
                    let reviseCounter = parseInt(row.ReviseCounter) || 0;
                    if (reviseCounter > 0) {
                        html += `<br><small class="text-muted">- Revise [${reviseCounter}]</small>`;
                    }

                    // Bungkus dengan div center agar rapi di dalam cell tabel
                    return `<div class="text-center">${html}</div>`;
                }
            },
            {
                data: "Invoice_Status",
                name: "Invoice_Status",
                render: function (data) {
                    if (data == 'FI') {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Is_Active/yes.gif" alt="Full Invoiced" title="Full Invoiced" class="img-fluid" width="20" height="20">`;
                    } else if (data == 'NI') {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Is_Active/No.gif" alt="Open" title="Not Invoiced" class="img-fluid" width="20" height="20">`;
                    }
                }
            },
            {
                data: "isNotActive",
                name: "isNotActive",
                render: function (data) {
                    if (data == 0) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Is_Active/yes.gif" alt="Active" title="Active" class="img-fluid" width="20" height="20">`;
                    } else if (data == 1) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Is_Active/No.gif" alt="Not Active" title="Not Active" class="img-fluid" width="20" height="20">`;
                    }
                }
            }
            ],
            order: [
                [0, "DESC"]
            ],
            columnDefs: [{
                className: "text-center", // Use "dt-center" if NOT using Bootstrap
                targets: [0, 1, 4, 5, 6, 7, 8, 9]
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
            },
            "buttons": [
                {
                    text: `<i class="fas fa-plus fs-2"></i> New SO`,
                    className: "btn btn-success",
                    action: function (e, dt, node, config) {
                        return window.location.href = $('meta[name="base_url"]').attr('content') + `SalesOrder/add/new`;

                    }
                },
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

    Initialize_DataTable();

    $('#do--filter').on('click', function () {
        $("#TableData").DataTable().clear().destroy(), Initialize_DataTable();
    })

});