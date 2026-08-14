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

    var selected_termin = [];
    var lastClickedBox = null;

    function Fn_Initialized_DataTable() {
        $("#TableDataHistory").DataTable({
            destroy: true,
            processing: true,
            serverSide: true,
            paging: true,
            dom: '<"row mb-3"<"col-sm-12"B>><"row"<"col-sm-11"f><"col-sm-1"l>>rtip',
            lengthMenu: [
                [10, 30, 90, 99999],
                [10, 30, 90, 99999]
            ],
            ajax: {
                url: $('meta[name="base_url"]').attr('content') + "CbrPaymentStatus/DT_List_History_Approval",
                dataType: "json",
                type: "POST",
                data: function (d) {
                    // Disarankan menggunakan parameter 'd' untuk mengirim extra data di serverSide
                    d.from = $('#from').val();
                    d.until = $('#until').val();
                    d.column_range = $('#column_range').val();
                }
            },
            columns: [
                {
                    data: "SysID_Termin",
                    name: "CheckBox",
                    orderable: false,
                    render: function (data, type, row, meta) {
                        var isChecked = selected_termin.includes(row.SysID_Termin) ? 'checked' : '';
                        return `
                        <div class="form-check">
                            <input class="form-check-input row-checkbox" type="checkbox" 
                                value="${row.SysID_Termin}" 
                                id="termin_${row.SysID_Termin}" 
                                name="TerminIdx[]" 
                                ${isChecked}>
                        </div>`;
                    }
                },
                { data: "CBReq_No", name: "CBReq_No" },
                {
                    data: "Termin_Ke",
                    name: "Termin_Ke",
                    render: function (data) {
                        return `<span class="badge badge-light-primary text-dark border">Termin ${data}</span>`;
                    }
                },
                {
                    data: "Document_Date",
                    name: "Document_Date",
                    render: function (data) {
                        return data ? data.substring(0, data.indexOf(' ')) : '-';
                    }
                },
                { data: "Currency_Id", name: "Currency_Id" },
                {
                    data: "Amount",
                    name: "Amount",
                    render: function (data) {
                        return parseFloat(data).toLocaleString('en-US', { minimumFractionDigits: 4, maximumFractionDigits: 4 });
                    }
                },
                { data: "Document_Number", name: "Document_Number" },
                { data: "Descript", name: "Descript" },
                { data: "baseamount", name: "baseamount", visible: false },
                { data: "Approval_Status", name: "Approval_Status", visible: false },
                { data: "CBReq_Status", name: "CBReq_Status", visible: false },
                {
                    data: "Status_AppvPresidentDirector",
                    name: "Status_AppvPresidentDirector",
                    visible: true,
                    render: function (data) {
                        // Penulisan 'href' diperbaiki di sini
                        if (data == 0) {
                            return `<a href="javascript:void(0)" data-bs-toggle="tooltip" data-bs-placement="left" data-bs-custom-class="tooltip-dark" title="Waiting Approval" class="text-dark badge badge-warning btn-icon">Waiting</a>`;
                        } else if (data == 1) {
                            return `<a href="javascript:void(0)" data-bs-toggle="tooltip" data-bs-placement="left" data-bs-custom-class="tooltip-dark" title="Open" class="badge badge-success btn-icon">Approved</a>`;
                        } else if (data == 2) {
                            return `<a href="javascript:void(0)" data-bs-toggle="tooltip" data-bs-placement="left" data-bs-custom-class="tooltip-dark" title="New" class="badge badge-danger btn-icon"> Rejected</a>`;
                        }
                        return '-';
                    }
                },
                { data: "Paid_Status", name: "Paid_Status", visible: false },
                {
                    data: "Payment_Status",
                    name: "Payment_Status",
                    render: function (data, type, row) {
                        let badge = '';
                        if (data == 1) {
                            badge = `<span class="badge badge-success">Paid</span>`;
                        } else if (data == 2) {
                            badge = `<span class="badge badge-danger">Rejected</span>`;
                        } else {
                            badge = `<span class="badge badge-warning">Pending</span>`;
                        }
                        return `${badge}<br><small class="text-muted">${row.Payment_Status_Time_Change || ''}</small>`;
                    }
                },
                { data: "Payment_Status_Change_By", name: "Payment_Status_Change_By" },
                {
                    data: "Payment_Status",
                    name: "Payment_Status",
                    visible: false,
                    render: function (data) {
                        if (data == 0 || data == null || data == '') {
                            return `<span class="text-dark badge badge-warning">Not Paid</span>`;
                        } else if (data == 3) {
                            return `<span class="text-white badge badge-info" style="background-color: #17a2b8;">Partially Paid</span>`;
                        } else if (data == 1) {
                            return `<span class="text-white badge badge-success">Fully Paid</span>`;
                        } else if (data == 2) {
                            return `<span class="text-white badge badge-danger">Payment Rejected</span>`;
                        } else {
                            return `<span class="text-dark badge badge-light">-</span>`;
                        }
                    }
                },
                { data: "Creation_DateTime", name: "Creation_DateTime", visible: false },
                { data: "Created_By", name: "Created_By", visible: false },
                { data: "UserDivision", name: "UserDivision", orderable: true },
                { data: "First_Name", name: "First_Name", orderable: false },
                { data: "Last_Update", name: "Last_Update", visible: false },
                { data: "Approve_Date", name: "Approve_Date", visible: false },
                { data: "IsAppvStaff", name: "IsAppvStaff", visible: false },
                { data: "IsAppvChief", name: "IsAppvChief", visible: false },
                { data: "IsAppvAsstManager", name: "IsAppvAsstManager", visible: false },
                {
                    data: "IsAppvManager", name: "IsAppvManager", orderable: false, visible: false,
                    render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvManager);
                    }
                },
                {
                    data: "IsAppvSeniorManager", name: "IsAppvSeniorManager", orderable: false, visible: false,
                    render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvSeniorManager);
                    }
                },
                {
                    data: "IsAppvGeneralManager", name: "IsAppvGeneralManager", orderable: false, visible: false,
                    render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvGeneralManager);
                    }
                },
                {
                    data: "IsAppvAdditional", name: "IsAppvAdditional", orderable: false, visible: false,
                    render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvAdditional);
                    }
                },
                {
                    data: "IsAppvFinancePerson", name: "IsAppvFinancePerson", orderable: false, visible: true,
                    render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvFinancePerson);
                    }
                },
                {
                    data: "IsAppvDirector", name: "IsAppvDirector", orderable: false,
                    render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvDirector);
                    }
                },
                {
                    data: "IsAppvFinanceDirector", name: "IsAppvFinanceDirector", orderable: false,
                    render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvFinanceDirector);
                    }
                },
                {
                    data: "IsAppvPresidentDirector", name: "IsAppvPresidentDirector", orderable: false,
                    render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvPresidentDirector);
                    }
                }
            ],
            order: [[3, "DESC"]],
            columnDefs: [
                { width: 220, targets: 7 },
                {
                    className: "text-center dt-nowrap",
                    targets: [0, 2, 3, 4, 5, 6, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]
                },
                { className: "details-control pr-4 dt-nowrap", targets: [1] }
            ],
            scrollCollapse: true,
            scrollX: true,
            responsive: false,
            rowCallback: function (row, data) {
                if (data.Status_AppvManager == '2' ||
                    data.Status_AppvSeniorManager == '2' ||
                    data.Status_AppvGeneralManager == '2' ||
                    data.Status_AppvAdditional == '2' ||
                    data.Status_AppvFinancePerson == '2' ||
                    data.Status_AppvDirector == '2' ||
                    data.Status_AppvPresidentDirector == '2' ||
                    data.Status_AppvFinanceDirector == '2') {
                    $('td', row).css('background-color', '#F8D7DA');
                }
            },
            preDrawCallback: function () {
                // Tanda pagar (#) ditambahkan
                $("#TableDataHistory tbody td").addClass("blurry");
            },
            language: {
                processing: '<i style="color:#4a4a4a" class="fa fa-spinner fa-spin fa-3x fa-fw"></i><span class="sr-only"></span><p><span style="color:#4a4a4a" style="text-align:center" class="loading-text"></span> ',
                searchPlaceholder: "Search..."
            },
            drawCallback: function () {
                // Tanda pagar (#) ditambahkan
                $("#TableDataHistory tbody td").addClass("blurry");
                setTimeout(function () {
                    $("#TableDataHistory tbody td").removeClass("blurry");
                });
                $('[data-bs-toggle="tooltip"]').tooltip();
                DataTable.tables({ visible: true, api: true }).columns.adjust();
            },
            buttons: [
                {
                    text: `Export to :`,
                    className: "btn disabled text-dark bg-white",
                },
                {
                    text: `<i class="far fa-copy fs-2"></i>`,
                    extend: 'copy',
                    className: "btn btn-light-warning",
                },
                {
                    text: `<i class="far fa-file-excel fs-2"></i>`,
                    extend: 'excelHtml5',
                    title: $('#table-title-history').text() + '~' + moment().format("YYYY-MM-DD"),
                    className: "btn btn-light-success",
                },
                {
                    text: `-`,
                    className: "btn btn-default btn-icon disabled",
                },
                {
                    text: `<i class="fas fa-undo text-white fs-3"></i> Revoke Payment`,
                    className: "btn btn-danger",
                    action: function (e, dt, node, config) {
                        // Pastikan variabel 'selected_termin' dan fungsi 'Fn_Revoke_Approval()' sudah dideklarasikan secara global di file JS Anda
                        if (typeof selected_termin === 'undefined' || selected_termin.length === 0) {
                            return Swal.fire('Error', 'Please select at least one item to revoke!', 'error');
                        }

                        Swal.fire({
                            title: 'System Message',
                            text: `Are you sure to revoke the payment status for ${selected_termin.length} selected item(s)?`,
                            icon: 'question',
                            showCancelButton: true,
                            confirmButtonColor: '#d33',
                            cancelButtonColor: '#3085d6',
                            confirmButtonText: 'Yes, Revoke!',
                            cancelButtonText: 'Cancel'
                        }).then((result) => {
                            if (result.isConfirmed) {
                                Fn_Revoke_Approval();
                            }
                        });
                    }
                }
            ]
        }).buttons().container().appendTo('#TableDataHistory_wrapper .col-md-6:eq(0)'); // ID ditambahkan pagar
    }

    $('#CheckAll_hst').on('click', function () {
        var isChecked = $(this).is(':checked');
        check_uncheck_checkbox_hst(isChecked);
    });

    $('#TableDataHistory tbody').on('click', 'input[name="TerminIdx[]"]', function (e) {
        var $chkboxes = $('input[name="TerminIdx[]"]');
        var isChecked = $(this).is(':checked');
        var id = $(this).val();

        if (e.shiftKey && lastClickedBox) {
            var start = $chkboxes.index(this);
            var end = $chkboxes.index(lastClickedBox);
            var groupSubset = $chkboxes.slice(Math.min(start, end), Math.max(start, end) + 1);

            groupSubset.each(function () {
                var currentId = $(this).val();
                $(this).prop('checked', isChecked);
                if (isChecked) {
                    if (!selected_termin.includes(currentId)) {
                        selected_termin.push(currentId);
                    }
                } else {
                    selected_termin = selected_termin.filter(val => val !== currentId);
                }
            });
        } else {
            if (isChecked) {
                if (!selected_termin.includes(id)) {
                    selected_termin.push(id);
                }
            } else {
                selected_termin = selected_termin.filter(val => val !== id);
            }
        }

        lastClickedBox = this;
        updateCheckAllStatus();
    });

    function check_uncheck_checkbox_hst(isChecked) {
        $('input[name="TerminIdx[]"]').each(function () {
            var id = $(this).val();
            $(this).prop('checked', isChecked);
            if (isChecked) {
                if (!selected_termin.includes(id)) {
                    selected_termin.push(id);
                }
            } else {
                selected_termin = selected_termin.filter(item => item !== id);
            }
        });
    }

    function updateCheckAllStatus() {
        var allCheckedInPage = true;
        var checkboxes = $('input[name="TerminIdx[]"]');
        if (checkboxes.length === 0) {
            allCheckedInPage = false;
        } else {
            checkboxes.each(function () {
                if (!$(this).prop('checked')) { allCheckedInPage = false; }
            });
        }
        $('#CheckAll_hst').prop('checked', allCheckedInPage);
    }

    document.querySelectorAll('a[data-bs-toggle="tab"]').forEach((el) => {
        el.addEventListener('shown.bs.tab', () => {
            DataTable.tables({ visible: true, api: true }).columns.adjust();
        });
    });

    $('#do--filter').on('click', function () {
        $("#TableDataHistory").DataTable().clear().destroy(), Fn_Initialized_DataTable(), DataTable.tables({ visible: true, api: true }).columns.adjust();
    })

    $(document).on('click', 'td.details-control', function () {
        var tr = $(this).closest('tr'); // Menggunakan closest() untuk mendapatkan elemen tr terdekat
        var row = tr.closest('table').DataTable().row(tr); // Mendapatkan instance DataTable dari tabel terdekat

        if (row.child.isShown()) {
            // This row is already open - close it
            row.child.hide();
            tr.removeClass('shown');
        } else {
            // Open this row (the format() function would return the data to be shown)
            row.child(format(row.data())).show();
            tr.addClass('shown');
            // select element tr next var tr
            tr.next().addClass('bg-primary')
            getInsDetail(row.data().CBReq_No, row.data().Document_Number);
        }
    });

    function Fn_Revoke_Approval() {
        if (selected_termin.length === 0) {
            return Swal.fire({
                icon: 'error',
                title: 'Oops...',
                text: 'You need to check the submission first!'
            });
        }

        $.ajax({
            dataType: "json",
            type: "POST",
            url: $('meta[name="base_url"]').attr('content') + "CbrPaymentStatus/revoke_approval",
            data: { "TerminIdx": selected_termin },
            beforeSend: function () {
                Swal.fire({
                    title: 'Loading....',
                    html: '<div class="spinner-border text-primary"></div>',
                    showConfirmButton: false,
                    allowOutsideClick: false,
                    allowEscapeKey: false
                });
            },
            success: function (response) {
                Swal.close();
                if (response.code == 200) {
                    Toast.fire({ icon: 'success', title: response.msg });
                    selected_termin = [];
                    $('#CheckAll_hst').prop('checked', false);
                    $('#TableData').DataTable().ajax.reload(null, false);
                    $("#TableDataHistory").DataTable().ajax.reload(null, false);
                } else {
                    let errorHtml = response.details ? '<ul>' + response.details.map(d => `<li>${d}</li>`).join('') + '</ul>' : response.msg;
                    Swal.fire({
                        icon: "error",
                        title: response.msg || "Revoke Failed!",
                        html: errorHtml
                    });
                }
            },
            error: function (xhr, status, error) {
                var statusCode = xhr.status;
                var errorMessage = xhr.responseJSON && xhr.responseJSON.message ? xhr.responseJSON.message : xhr.responseText ? xhr.responseText : "An error occurred: " + error;
                Swal.fire({
                    icon: "error",
                    title: "Error!",
                    html: `HTTP Code: ${statusCode}<br/>Message: ${errorMessage}`,
                });
            }
        });
    }

    function format(d) {
        let container = `
        <div class="row bg-primary">
            <div class="col-md-6">
                <div class="card my-3 px-1 py-1">
                    <div class="table-responsive overflow-auto">
                        <table class="table-sm overflow-auto table-bordered rounded-sm" style="width:100%;">
                            <thead>
                                <tr>
                                    <th class="text-dark" colspan="4">
                                        <button type="button" value="${d.CBReq_No}" class="btn btn-sm btn-light-info btn-cbr">
                                            🖨️ Cash Book Requisition Number : ${d.CBReq_No}
                                        </button>
                                    </th>
                                </tr>
                                <tr class="bg-dark">
                                    <th class="text-center">Account</th>
                                    <th class="text-center">Description</th>
                                    <th class="text-center">Amount</th>
                                </tr>
                            </thead>
                            <tbody id="tbody_${d.CBReq_No}"></tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card my-3 px-1 py-1">
                    <div class="table-responsive overflow-auto">
                        <table class="table-sm overflow-auto table-bordered rounded-sm" style="width:100%;">
                            <thead>
                                <tr>
                                    <th class="text-center" colspan="4">
                                        <button type="button" class="btn btn-sm btn-bg-light btn-color-dark">
                                            List Attachment : ${d.CBReq_No}
                                        </button>
                                    </th>
                                </tr>
                                <tr class="bg-dark">
                                    <th class="text-center">#</th>
                                    <th class="text-center">File Name</th>
                                    <th class="text-center">Doc Type</th>
                                    <th class="text-center">Note</th>
                                </tr>
                            </thead>
                            <tbody id="tbody_attachment_${d.CBReq_No}"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <div class="row bg-primary">
            <div class="col-md-6">
    `;

        // Detail Ref CBR : Ref Container
        if (d.Document_Number == null || d.Document_Number == '') {
            container += `
                <div class="card my-3 px-2 py-2">
                    <div class="table-responsive overflow-auto">
                        <table class="table-sm overflow-auto table-bordered rounded-sm" style="width:100%;">
                            <thead>
                                <tr>
                                    <th class="text-dark" colspan="11">Purchase Invoice : -N/A-</th>
                                </tr>
                                <tr class="bg-dark">
                                    <th class="text-center">Invoice No</th>
                                    <th class="text-center">Vendor Invoice Number</th>
                                    <th class="text-center">Invoice Date</th>
                                    <th class="text-center">Due Date</th>
                                    <th class="text-center">Purchase Order Number</th>
                                    <th class="text-center">Vendor Name</th>
                                    <th class="text-center">Payment Status</th>
                                    <th class="text-center">Is Void</th>
                                    <th class="text-center">Document Status</th>
                                    <th class="text-center">Receipt Date</th>
                                </tr>
                            </thead>
                            <tbody id="tbody_vin_${d.CBReq_No}"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
        } else if (d.Document_Number.startsWith('PWU')) {
            container += `
                <div class="card my-3 px-2 py-2">
                    <div class="table-responsive overflow-auto">
                        <table class="table-sm overflow-auto table-bordered rounded-sm" style="width:100%;">
                            <thead>
                                <tr>
                                    <th class="text-dark" colspan="11">Purchase Order : ${d.Document_Number}</th>
                                </tr>
                                <tr class="bg-dark">
                                    <th class="text-center">PO Number</th>
                                    <th class="text-center">Vendor</th>
                                    <th class="text-center">PO Date</th>
                                    <th class="text-center">Pick Up Date</th>
                                    <th class="text-center">Vendor SO Number</th>
                                    <th class="text-center">Document Status</th>
                                    <th class="text-center">PO Status</th>
                                    <th class="text-center">Approval</th>
                                    <th class="text-center">Invoiced</th>
                                    <th class="text-center">Active</th>
                                </tr>
                            </thead>
                            <tbody id="tbody_vin_${d.CBReq_No}"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
        } else {
            container += `
                <div class="card my-3 px-2 py-2">
                    <div class="table-responsive overflow-auto">
                        <table class="table-sm table-bordered rounded-sm" style="width:100%;">
                            <thead>
                                <tr>
                                    <th class="text-dark" colspan="7">
                                        Purchase Invoice : ${d.Document_Number}
                                    </th>
                                    <th style="text-align: center;" colspan="3">
                                        <button type="button" value="${d.Document_Number}" class="btn btn-sm btn-light-danger rpt-vin">🔍 Purchase Invoice</button>
                                    </th>
                                </tr>
                                <tr class="bg-dark">
                                    <th class="text-center">Invoice No</th>
                                    <th class="text-center">Vendor Invoice Number</th>
                                    <th class="text-center">Invoice Date</th>
                                    <th class="text-center">Due Date</th>
                                    <th class="text-center" style="white-space: pre-line; max-width: 200px;">Purchase Order Number</th>
                                    <th class="text-center">Vendor Name</th>
                                    <th class="text-center">Payment Status</th>
                                    <th class="text-center">Is Void</th>
                                    <th class="text-center">Document Status</th>
                                    <th class="text-center">Receipt Date</th>
                                </tr>
                            </thead>
                            <tbody id="tbody_vin_${d.CBReq_No}"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
        }
        // Bagian BDJ (Kolom Kanan pada Row Kedua)
        container += `
                    </div>
                        <div class="row bg-primary">
                            <div class="col-md-6">
                                <div class="card my-3 px-2 py-2">
                                    <div class="table-responsive overflow-auto">
                                        <table class="table-sm table-bordered rounded-sm" style="width:100%;">
                                            <thead>
                                                <tr>
                                                    <th colspan="6">
                                                        <button type="button" value="${d.CBReq_No}" class="btn btn-sm btn-warning">LIst BDJ - Cashbook</button>
                                                    </th>
                                                </tr>
                                                <tr class="bg-dark">
                                                    <th class="text-center">Doc Numb</th>
                                                    <th class="text-center">Payee</th>
                                                    <th class="text-center">Date</th>
                                                    <th class="text-center">Account</th>
                                                    <th class="text-center">Bank Payment</th>
                                                    <th class="text-center">Memo</th>
                                                </tr>
                                            </thead>
                                            <tbody id="tbody_bdj_${d.CBReq_No}"></tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>`;

        return container;
    }

    $(document).on('click', '.rpt-vin', function () {
        let vin = $(this).val();

        window.open($('meta[name="base_url"]').attr('content') + `MyCbr/get_detail_purchase_invoice/${vin}`, `RptVin-${vin}`, 'width=800,height=600');
    })

    $(document).on('click', '.rpt-bdj', function () {
        let bdj = $(this).data('bdj');

        window.open($('meta[name="base_url"]').attr('content') + `MyCbr/get_detail_bdj/${bdj}`, `RptBdj-${bdj}`, 'width=800,height=600');
    })

    function getInsDetail(Req_No, Ref_no) {
        $.ajax({
            dataType: "json",
            type: "POST",
            url: $('meta[name="base_url"]').attr('content') + "MyCbr/get_detail_cbr",
            data: {
                Req_No: Req_No,
                Ref_no: Ref_no
            }, success: function (response) {
                var lastitem = '0';
                var i;
                var tr = $("#tbody_" + Req_No);
                tr.empty();
                if (response.code == 200) {
                    $.each(response.data, function (index, item) {
                        console.log(item.Account_Name);
                        tr.append(
                            `<tr>
                            <td class="text-center">${item.Account_Name}</td>
                            <td class="text-center">${item.Description}</td>
                            <td>${item.Amount_Detail}</td>
                            </tr>`);
                    });
                } else {
                    tr.append(`<tr><td colspan="3">Detail Cash Book Requisition Not found !</td></tr>`);
                }

                var tr = $("#tbody_vin_" + Req_No);
                if (Ref_no == null || Ref_no == '') {
                    tr.append(`<tr><td colspan="11">This Cash Book Requisition doesnt have a Purchase Invoice !</td></tr>`);
                }
                else if (Ref_no.startsWith('PWU')) {
                    if (response.code_vin == 200) {
                        $.each(response.dataVins, function (index, item) {
                            tr.append(
                                `<tr>
                                <td style="white-space: pre-line; max-width: 200px;">${item.PO_Number}</td>
                                <td class="text-center">${item.Account_Name}</td>
                                <td class="text-center">${item.PO_Date}</td>
                                <td class="text-center">${item.ETD}</td>
                                <td class="text-center">${item.SO_NumCustomer}</td>
                                <td class="text-center">${item.Doc_Status}</td>
                                <td class="text-center">${item.PO_Status}</td>
                                <td class="text-center">${item.Approval_Status}</td>
                                <td class="text-center">${item.Invoice_Status}</td>
                                <td class="text-center">${item.isNotActive}</td>
                            </tr>`);
                        });
                    } else {
                        tr.append(`<tr><td colspan="11">This Cash Book Requisition doesnt have a Purchase Order !</td></tr>`);
                    }
                } else {
                    if (response.code_vin == 200) {
                        $.each(response.dataVins, function (index, item) {
                            tr.append(
                                `<tr>
                                <td>${item.Invoice_Number}</td>
                                <td>${item.VenInvoice_Number}</td>
                                <td class="text-center">${item.Invoice_Date}</td>
                                <td class="text-center">${item.Due_Date}</td>
                                <td style="white-space: pre-line; max-width: 200px;">${item.PO_NUMBER}</td>
                                <td class="text-center">${item.Account_Name}</td>
                                <td class="text-center">${item.Invoice_Status}</td>
                                <td class="text-center">${item.isVoid}</td>
                                <td class="text-center">${item.is_document_received}</td>
                                <td class="text-center">${item.document_received_date}</td>
                            </tr>`);
                        });
                    } else {
                        tr.append(`<tr><td colspan="11">This Cash Book Requisition doesnt have a Purchase Invoice !</td></tr>`);
                    }
                }

                var tbody_attachment = $("#tbody_attachment_" + Req_No);
                if (response.data_Attachments.length > 0) {
                    $.each(response.data_Attachments, function (index, att) {
                        tbody_attachment.append(
                            `<tr>
                                <td class="text-center">${att.iteration}</td>
                                <td>${att.attachment}</td>
                                <td class="text-center">${att.AttachmentType}</td>
                                <td>${att.Note}</td>
                            </tr>`);
                    });
                } else {
                    tbody_attachment.append(`<tr><td colspan="4">This Cash Book Requisition doesnt have attachment file !</td></tr>`);
                }

                var tbody_bdj = $("#tbody_bdj_" + Req_No);
                if (response.code_bdj == 200) {
                    $.each(response.dataBdjs, function (index, bdj) {
                        tbody_bdj.append(
                            `<tr>
                                <td><a href="#" class="rpt-bdj" class="btn rpt-bdj" data-bdj="${bdj.JournalH_Code}">🖨️ ${bdj.JournalH_Code}</a></td>
                                <td>${bdj.Payor_Payee}</td>
                                <td>${bdj.CashBookDate}</td>
                                <td>${bdj.Account_Name}</td>
                                <td>${bdj.Currency_ID} ${bdj.Total_Amount}</td>
                                <td>${bdj.Memo}</td>
                            </tr>`);
                    });
                } else {
                    tbody_bdj.append(`<tr><td colspan="6">This Cash Book Requisition doesnt have BDJ !</td></tr>`);
                }



            }, error: function (xhr, status, error) {
                var statusCode = xhr.status;
                var errorMessage = xhr.responseJSON && xhr.responseJSON.message ? xhr.responseJSON.message : xhr.responseText ? xhr.responseText : "Terjadi kesalahan: " + error;
                Swal.fire({
                    icon: "error",
                    title: "Error!",
                    html: `Kode HTTP: ${statusCode}<br\>message: ${errorMessage}`,
                });
            }
        });
    }

    $(document).on('click', '.btn-attachment', function () {
        $('#txt-cbr').text($(this).val());
        $.ajax({
            // dataType: "json",
            type: "GET",
            url: $('meta[name="base_url"]').attr('content') + "MyCbr/m_list_cbr_attachment",
            data: {
                CbrNo: $(this).val(),
            }, beforeSend: function () {
                Swal.fire({
                    title: 'Loading....',
                    html: '<div class="spinner-border text-primary"></div>',
                    showConfirmButton: false,
                    allowOutsideClick: false,
                    allowEscapeKey: false
                })
            },
            success: function (ajaxData) {
                Swal.close()
                $("#location").html(ajaxData);
                $("#ModalAttachment").modal('show');
            }, error: function (xhr, status, error) {
                var statusCode = xhr.status;
                var errorMessage = xhr.responseJSON && xhr.responseJSON.message ? xhr.responseJSON.message : xhr.responseText ? xhr.responseText : "Terjadi kesalahan: " + error;
                Swal.fire({
                    icon: "error",
                    title: "Error!",
                    html: `Kode HTTP: ${statusCode}<br\>message: ${errorMessage}`,
                });
            }
        });
    })


    $(document).on('click', '.btn-cbr', function () {
        let Cbr_no = $(this).val();

        window.open($('meta[name="base_url"]').attr('content') + `MyCbr/get_rpt_cbr/${Cbr_no}`, `RptCbr-${Cbr_no}`, 'width=854,height=480');
    })

    Fn_Initialized_DataTable()

})

function check_uncheck_checkbox(isChecked) {
    if (isChecked) {
        $('input[name="CBReq_No[]"]').each(function () {
            this.checked = true;
        });
    } else {
        $('input[name="CBReq_No[]"]').each(function () {
            this.checked = false;
        });
    }
}