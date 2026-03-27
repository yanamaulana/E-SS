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
                render: function (data) {
                    if (data == 1) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Doc_Status/58.gif" alt="Open" title="Open" class="img-fluid" width="20" height="20">`;
                    } else if (data == 2) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Doc_Status/list.png" alt="Confirmed" title="Confirmed" class="img-fluid" width="20" height="20">`;
                    } else if (data == 3) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Doc_Status/icon_truck_big.png" alt="Delivered" title="Delivered" class="img-fluid" width="20" height="20">`;
                    } else if (data == 4) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Doc_Status/money.gif" alt="Invoiced" title="Invoiced" class="img-fluid" width="20" height="20">`;
                    } else {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Doc_Status/boxin.gif" alt="Closed" title="Closed" class="img-fluid" width="20" height="20">`;
                    }

                }
            },
            {
                data: "SO_Status",
                name: "SO_Status",
                render: function (data) {
                    if (data == 1) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/SO_Status/25.gif" alt="New" title="New" class="img-fluid" width="20" height="20">`;
                    } else if (data == 2) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/SO_Status/26.gif" alt="Open" title="Open" class="img-fluid" width="20" height="20">`;
                    } else if (data == 3) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/SO_Status/27.gif" alt="Closed" title="Closed" class="img-fluid" width="20" height="20">`;
                    }
                }
            },
            {
                data: "Approval_Status",
                name: "Approval_Status",
                render: function (data) {
                    if (data == 0) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Approval_Status/28.gif" alt="New" title="New" class="img-fluid" width="20" height="20">`;
                    } else if (data == 2) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Approval_Status/29.gif" alt="Awaiting" title="Awaiting" class="img-fluid" width="20" height="20">`;
                    } else if (data == 3) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Approval_Status/30.gif" alt="Approved" title="Approved" class="img-fluid" width="20" height="20">`;
                    } else if (data == 4) {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Approval_Status/31.gif" alt="Rejected" title="Rejected" class="img-fluid" width="20" height="20">`;
                    } else {
                        return `<img src="${$('meta[name="base_url"]').attr('content')}assets/media/Approval_Status/32.gif" alt="Revising" title="Revising" class="img-fluid" width="20" height="20">`;
                    }
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
                        return window.location.href = $('meta[name="base_url"]').attr('content') + `SalesOrder/add`;

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