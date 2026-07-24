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

    var selected_cbr = [];
    var selected_details = {};
    var lastClickedBox = null;

    // 3. Listener Checkbox Individu (Support SHIFT + CLICK)
    $('#TableDataHistory tbody').on('click', 'input[name="CBReq_No_hst[]"]', function (e) {
        var $chkboxes = $('input[name="CBReq_No_hst[]"]');
        var isChecked = $(this).is(':checked');

        // JIKA USER MENEKAN TOMBOL SHIFT + KLIK (Dan sebelumnya sudah ada yg di-klik)
        if (e.shiftKey && lastClickedBox) {
            var start = $chkboxes.index(this);
            var end = $chkboxes.index(lastClickedBox);

            // Tentukan titik potong baris awal dan baris akhir
            var groupSubset = $chkboxes.slice(Math.min(start, end), Math.max(start, end) + 1);

            groupSubset.each(function () {
                var $item = $(this);
                var id = $item.val();
                var curr = $item.data('curr');
                var amount = parseFloat($item.data('amount'));

                // 1. Ubah visual centangnya mengikuti target
                $item.prop('checked', isChecked);

                // 2. Masukkan/Keluarkan dari Array sistem
                if (isChecked) {
                    if (!selected_cbr.includes(id)) {
                        selected_cbr.push(id);
                        selected_details[id] = { curr: curr, amount: amount };
                    }
                } else {
                    selected_cbr = selected_cbr.filter(val => val !== id);
                    delete selected_details[id];
                }
            });
        } else {
            // NORMAL SINGLE CLICK (Tanpa menekan Shift)
            var id = $(this).val();
            var curr = $(this).data('curr');
            var amount = parseFloat($(this).data('amount'));

            if (isChecked) {
                if (!selected_cbr.includes(id)) {
                    selected_cbr.push(id);
                    selected_details[id] = { curr: curr, amount: amount };
                }
            } else {
                selected_cbr = selected_cbr.filter(val => val !== id);
                delete selected_details[id];
            }
        }

        // Simpan elemen yang baru saja di-klik sebagai "titik pijak" untuk Shift-Click berikutnya
        lastClickedBox = this;

        updateCheckAllStatus_hst();
    });

    $('#CheckAll_hst').on('click', function () {
        var isChecked = $(this).is(':checked');
        check_uncheck_checkbox_hst(isChecked);
    });

    function updateCheckAllStatus_hst() {
        var allCheckedInPage = true;
        var checkboxes = $('input[name="CBReq_No_hst[]"]');

        if (checkboxes.length === 0) {
            allCheckedInPage = false;
        } else {
            checkboxes.each(function () {
                if (!$(this).prop('checked')) {
                    allCheckedInPage = false;
                }
            });
        }
        $('#CheckAll').prop('checked', allCheckedInPage);
    }

    function check_uncheck_checkbox_hst(isChecked) {
        $('input[name="CBReq_No_hst[]"]').each(function () {
            var id = $(this).val();

            // 🔥 AMBIL DATA DARI ATRIBUT LANGSUNG
            var curr = $(this).data('curr');
            var amount = parseFloat($(this).data('amount'));

            // Update visual
            $(this).prop('checked', isChecked);

            // Update Logic Array
            if (isChecked) {
                if (!selected_cbr.includes(id)) {
                    selected_cbr.push(id);
                    selected_details[id] = {
                        curr: curr,
                        amount: amount
                    };
                }
            } else {
                selected_cbr = selected_cbr.filter(item => item !== id);
                delete selected_details[id];
            }
        });
        // renderSummaryHTML();
    }

    function Fn_Initialized_DataTable() {
        $("#TableDataHistory").DataTable({
            destroy: true,
            processing: true,
            serverSide: true,
            paging: true,
            dom: '<"row mb-3"<"col-sm-12"B>><"row"<"col-sm-11"f><"col-sm-1"l>>rtip',
            // select: true,
            "lengthMenu": [
                [15, 100, 1000, 4999],
                [15, 100, 1000, 4999]
            ],
            ajax: {
                url: $('meta[name="base_url"]').attr('content') + "CbrAppPresidentDirector/DT_List_History_Approval",
                dataType: "json",
                type: "POST",
                data: {
                    from: $('#from').val(),
                    until: $('#until').val(),
                    column_range: $('#column_range').val(),
                }
            },
            columns: [
                {
                    data: "CBReq_No", name: "CBReq_No", orderable: false, render: function (data, type, row, meta) {
                        var isChecked = selected_cbr.includes(row.CBReq_No) ? 'checked' : '';
                        return `<div class="form-check">
                            <input class="form-check-input row-checkbox" type="checkbox" 
                                value="${row.SysID_Termin}" 
                                id="${row.CBReq_No}" 
                                name="CBReq_No_hst[]" 
                                ${isChecked}
                                data-curr="${row.Currency_Id}"
                                data-amount="${row.Amount}">
                        </div>`
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
                    data: "Document_Date", name: "Document_Date", render: function (data) {
                        return data ? data.substring(0, data.indexOf(' ')) : '-';
                    }
                },
                { data: "Currency_Id", name: "Currency_Id" },
                {
                    data: "Amount", name: "Amount", render: function (data) {
                        return parseFloat(data).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                    }
                },
                { data: "Descript", name: "Descript" },
                {
                    data: "isClose", name: "isClose",
                    render: function (data) {
                        return (data == 0 || data == '' || data == null) ?
                            `<span class="text-dark badge badge-success">Open</span>` :
                            `<span class="text-dark badge badge-danger">VOID</span>`;
                    }
                },
                {
                    data: "Status_AppvPresidentDirector",
                    name: "Status_AppvPresidentDirector",
                    render: function (data, type, row, meta) {
                        if (data == 0) return `<span class="text-dark badge badge-warning">Waiting</span>`;
                        if (data == 1) return `<span class="badge badge-success">Approved</span><br>${row.AppvPresidentDirector_At}`;
                        if (data == 2) return `<span class="badge badge-danger">Rejected</span><br>${row.AppvPresidentDirector_At}`;
                    }
                },
                {
                    data: "Payment_Status",
                    name: "Payment_Status",
                    render: function (data) {
                        if (data == 0) return `<span class="text-dark badge badge-warning">Pending</span>`;
                        if (data == 1) return `<span class="text-white badge badge-success">Paid</span>`;
                        if (data == 2) return `<span class="text-white badge badge-danger">Rejected</span>`;
                    }
                },
                { data: "UserDivision", name: "UserDivision" },
                { data: "First_Name", name: "First_Name" },
                {
                    data: "IsAppvAsstManager", name: "IsAppvAsstManager", orderable: false, visible: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvAsstManager) + ' <br/> ' + row.AppvAsstManager_At;
                    }
                },
                {
                    data: "IsAppvManager", name: "IsAppvManager", orderable: false, visible: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvManager) + ' <br/> ' + row.AppvManager_At;
                    }
                },
                {
                    data: "IsAppvSeniorManager", name: "IsAppvSeniorManager", orderable: false, visible: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvSeniorManager) + ' <br/> ' + row.AppvSeniorManager_At;
                    }
                },
                {
                    data: "IsAppvGeneralManager", name: "IsAppvGeneralManager", orderable: false, visible: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvGeneralManager) + ' <br/> ' + row.AppvGeneralManager_At;
                    }
                },
                {
                    data: "IsAppvAdditional", name: "IsAppvAdditional", orderable: false, visible: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvAdditional) + ' <br/> ' + row.AppvAdditional_At;
                    }
                },
                {
                    data: "IsAppvFinancePerson", name: "IsAppvFinancePerson", orderable: false, visible: true, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvFinancePerson) + ' <br/> ' + row.AppvFinancePerson_At;
                    }
                },
                {
                    data: "IsAppvDirector", name: "IsAppvDirector", orderable: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvDirector) + ' <br/> ' + row.AppvDirector_At;
                    }
                },
                {
                    data: "IsAppvFinanceDirector", name: "IsAppvFinanceDirector", orderable: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvFinanceDirector) + ' <br/> ' + row.AppvFinanceDirector_At;
                    }
                },
                {
                    data: "IsAppvPresidentDirector", name: "IsAppvPresidentDirector", orderable: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvPresidentDirector) + ' <br/> ' + row.AppvPresidentDirector_At;
                    }
                },
                { data: "Payment_Status_Time_Change", name: "Payment_Status_Time_Change" }
            ],
            // 1. Order: Berdasarkan Document_Date sekarang berada di kolom indeks 3 (karena ada kolom Termin di indeks 2)
            order: [
                [3, "DESC"]
            ],

            // 2. Gabungan ColumnDefs yang rapi
            columnDefs: [
                {
                    // Pengaturan lebar khusus untuk kolom Description (sekarang di indeks 6)
                    width: "220px",
                    targets: [6]
                },
                {
                    // Alignment center untuk kolom yang sifatnya status/ID/tanggal
                    className: "text-center dt-nowrap",
                    targets: [0, 2, 3, 4, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
                },
                {
                    // Ikon detail
                    className: "details-control pr-4 dt-nowrap",
                    targets: [1]
                },
                {
                    // Alignment kanan untuk angka (Amount di indeks 4)
                    className: "dt-nowrap text-end",
                    targets: [4]
                }
            ],
            // orderCellsTop: true,
            // fixedColumns: true,
            scrollCollapse: true,
            scrollX: true,
            // scrollY: 410,
            // autoWidth: true,
            responsive: false,
            "rowCallback": function (row, data) {
                if (data.isClose == '1') {
                    $('td', row).css('background-color', '#e97781');
                } else {
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
                }
            },
            preDrawCallback: function () {
                $("TableDataHistory tbody td").addClass("blurry");
            },
            language: {
                processing: '<i style="color:#4a4a4a" class="fa fa-spinner fa-spin fa-3x fa-fw"></i><span class="sr-only"></span><p><span style="color:#4a4a4a" style="text-align:center" class="loading-text"></span> ',
                searchPlaceholder: "Search..."
            },
            drawCallback: function (settings) {
                var api = this.api();
                var json = api.ajax.json(); // Ambil response JSON dari server

                if (json && json.summary) {
                    var s = json.summary;
                    var html = `<div class="row g-2">
                                    <div class="col-md-4">
                                        <div class="card bg-white border border-gray-300 p-2 shadow-sm">
                                            <span class="fs-8 fw-bold text-gray-700">ROW STATUS</span>
                                            <div class="d-flex justify-content-between fs-9">
                                                <span>Total: <b>${s.total_rows}</b></span>
                                                <span class="text-success">Appv: <b>${s.approved}</b></span>
                                            </div>
                                            <div class="d-flex justify-content-between fs-9 mt-1">
                                                <span class="text-primary">Paid: <b>${s.paid}</b></span>
                                                <span class="text-warning">Pending: <b>${s.pending}</b></span>
                                            </div>
                                            <div class="d-flex justify-content-between fs-9 mt-1">
                                                <span class="text-danger">&nbsp;</span>
                                                <span class="text-danger">Reject: <b>${s.rejected}</b></span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-8">
                                        <div class="card bg-white border border-gray-300 p-2 shadow-sm">
                                            <span class="fs-8 fw-bold text-gray-700 mb-1">MONETARY SUMMARY (SUM)</span>
                                            <div class="table-responsive">
                                                <table class="table table-borderless table-sm p-0 m-0" style="font-size: 9px;">
                                                    <thead>
                                                        <tr class="border-bottom">
                                                            <th>Status</th>
                                                            ${Object.keys({ ...s.sum_pending_approved, ...s.sum_paid_approved, ...s.sum_rejected }).map(c => `<th>${c}</th>`).join('')}
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <tr>
                                                            <td class="text-warning py-0">Appv Pending</td>
                                                            ${Object.keys({ ...s.sum_pending_approved, ...s.sum_paid_approved, ...s.sum_rejected }).map(c => `<td class="fw-bold py-0">${(s.sum_pending_approved[c] || 0).toLocaleString()}</td>`).join('')}
                                                        </tr>
                                                        <tr>
                                                            <td class="text-success py-0">Appv Paid</td>
                                                            ${Object.keys({ ...s.sum_pending_approved, ...s.sum_paid_approved, ...s.sum_rejected }).map(c => `<td class="fw-bold py-0">${(s.sum_paid_approved[c] || 0).toLocaleString()}</td>`).join('')}
                                                        </tr>
                                                        <tr>
                                                            <td class="text-danger py-0">Rejected</td>
                                                            ${Object.keys({ ...s.sum_pending_approved, ...s.sum_paid_approved, ...s.sum_rejected }).map(c => `<td class="fw-bold py-0">${(s.sum_rejected[c] || 0).toLocaleString()}</td>`).join('')}
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>`;

                    $('#data-summary-container').html(html);
                }

                // Effect Blurry & Tooltip
                $("TableDataHistory tbody td").addClass("blurry");
                setTimeout(function () {
                    $("TableDataHistory tbody td").removeClass("blurry");
                });
                $('[data-bs-toggle="tooltip"]').tooltip();
            },
            "buttons": [{
                text: `Export to :`,
                className: "btn disabled text-dark bg-white",
            }, {
                text: `<i class="far fa-copy fs-2"></i>`,
                extend: 'copy',
                className: "btn btn-light-warning",
            }, {
                text: `<i class="far fa-file-excel fs-2"></i>`,
                extend: 'excelHtml5',
                title: $('#table-title-history').text() + '~' + moment().format("YYYY-MM-DD"),
                className: "btn btn-light-success",
            }, {
                text: `-`,
                className: "btn btn-default btn-icon disabled",
            },
            {
                text: `<i class="fas fa-undo text-white fs-3"></i> Revoke Approval`,
                className: "btn btn-danger",
                action: function (e, dt, node, config) {
                    if (selected_cbr.length === 0) {
                        return Swal.fire('Error', 'Please select at least one item!', 'error');
                    }

                    Swal.fire({
                        title: 'System Message !',
                        text: `Are you sure to Revoke Approval ${selected_cbr.length} selected CBR(s)?`,
                        icon: 'question',
                        showCancelButton: true,
                        confirmButtonColor: '#3085d6',
                        cancelButtonColor: '#d33',
                        confirmButtonText: 'Yes'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            Fn_Revoke_Approval();
                        }
                    })
                }
            }
            ],
        }).buttons().container().appendTo('TableDataHistory_wrapper .col-md-6:eq(0)');
    }

    document.querySelectorAll('a[data-bs-toggle="tab"]').forEach((el) => {
        el.addEventListener('shown.bs.tab', () => {
            DataTable.tables({ visible: true, api: true }).columns.adjust();
        });
    });

    $('#do--filter').on('click', function () {
        $("#TableDataHistory").DataTable().clear().destroy(), Fn_Initialized_DataTable(), DataTable.tables({ visible: true, api: true }).columns.adjust();
    })

    Fn_Initialized_DataTable()


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

    function format(d) {
        let container = `<div class="row bg-primary">
                            <div class="col-md-6">
                                <div class="card my-3 px-1 py-1">
                                    <div class="table-responsive overflow-auto">
                                        <table class="table-sm overflow-auto table-bordered rounded-sm" style="width:100%;">
                                            <thead>
                                                <tr>
                                                    <th class="text-dark" colspan="4"><button type="button" value="${d.CBReq_No}" class="btn btn-sm btn-light-info btn-cbr">🖨️ Cash Book Requisition Number : ${d.CBReq_No}</button></th>
                                                </tr>
                                                <tr class="bg-dark">
                                                    <th class="text-center">Account</th>
                                                    <th class="text-center">Description</th>
                                                    <th class="text-center">Amount</th>
                                                </tr>
                                            </thead>
                                            <tbody id="tbody_${d.CBReq_No}">
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card my-3 px-1 py-1">
                                    <div class="table-responsive overflow-auto">
                                        <table class="table-sm overflow-auto table-bordered rounded-sm" style="width:100%;" >
                                            <thead>
                                                <tr>
                                                    <th class="text-center" colspan="4">
                                                        <button type="button" class="btn btn-sm btn-bg-light btn-color-dark">List Attachment : ${d.CBReq_No}</button>
                                                    </th>
                                                </tr>
                                                <tr class="bg-dark">
                                                    <th class="text-center">#</th>
                                                    <th class="text-center">File Name</th>
                                                    <th class="text-center">Doc Type</th>
                                                    <th class="text-center">Note</th>
                                                </tr>
                                            </thead>
                                            <tbody id="tbody_attachment_${d.CBReq_No}">
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row bg-primary">
                            <div class="col-md-12">
                        `;
        // detail ref cbr : ref_container
        if (d.Document_Number == null || d.Document_Number == '') {
            container = container + `<div class="card my-3 px-2 py-2">
                                        <div class="table-responsive overflow-auto">
                                            <table class="table-sm overflow-auto table-bordered rounded-sm" style="width:100%;">
                                                <thead>
                                                    <tr>
                                                        <th class="text-dark" colspan="11">Purchase Invoice  : -N/A-</th>
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
                                                <tbody id="tbody_vin_${d.CBReq_No}">
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>`;
        } else if (d.Document_Number.startsWith('PWU')) {
            container = container + `<div class="card my-3 px-2 py-2">
                                                <div class="table-responsive overflow-auto">
                                                    <table class="table-sm overflow-auto table-bordered rounded-sm" style="width:100%;">
                                                        <thead>
                                                            <tr>
                                                                <th class="text-dark" colspan="11">Purchase Order  : ${d.Document_Number}</th>
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
                                                        <tbody id="tbody_vin_${d.CBReq_No}">
                                                        </tbody>
                                                    </table>
                                        </div>
                                    </div>
                                </div>
                            </div>`;
        } else {
            container = container + `<div class="card my-3 px-2 py-2">
                                                <table class="table-sm table-bordered rounded-sm" style="width:100%;">
                                                    <thead>
                                                        <tr>
                                                            <th class="text-dark" colspan="7">
                                                                Purchase Invoice  : ${d.Document_Number}
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
                                                    <tbody id="tbody_vin_${d.CBReq_No}">
                                                    </tbody>
                                                </table>
                                        </div>
                                </div>
                            </div>`;
        }

        return container;

    }
    $(document).on('click', '.rpt-vin', function () {
        let vin = $(this).val();

        window.open($('meta[name="base_url"]').attr('content') + `MyCbr/get_detail_purchase_invoice/${vin}`, `RptVin-${vin}`, 'width=800,height=600');
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


    function Fn_Revoke_Approval() {
        // Validasi menggunakan length array, bukan DOM element
        if (selected_cbr.length == 0) {
            return Swal.fire({
                icon: 'error',
                title: 'Oops...',
                text: 'You need check the submission first !'
            });
        }

        console.log("Selected CBRs for Revoke Approval:", selected_cbr);
        $.ajax({
            dataType: "json",
            type: "POST",
            url: $('meta[name="base_url"]').attr('content') + "CbrAppPresidentDirector/revoke_approval",
            data: { "TerminIdx": selected_cbr }, // Kirim array ID
            beforeSend: function () {
                Swal.fire({
                    title: 'Loading....',
                    html: '<div class="spinner-border text-primary"></div>',
                    showConfirmButton: false,
                    allowOutsideClick: false
                })
            },
            success: function (response) {
                Swal.close()
                if (response.code == 200) {
                    Toast.fire({ icon: 'success', title: response.msg });
                    selected_cbr = [];
                    selected_details = {}; // RESET DETAIL JUGA
                    // renderSummaryHTML();   /
                    $('#CheckAll_hst').prop('checked', false);
                    $('#TableData').DataTable().ajax.reload(null, false);
                    $("#TableDataHistory").DataTable().ajax.reload(null, false);
                } else {
                    let errorHtml = '';
                    if (response.details && Array.isArray(response.details)) {
                        errorHtml = '<ul>';
                        response.details.forEach(detail => {
                            errorHtml += `<li>${detail}</li>`;
                        });
                        errorHtml += '</ul>';
                    } else {
                        errorHtml = response.msg;
                    }
                    Swal.fire({
                        icon: "error",
                        title: "Peringatan!",
                        html: errorHtml
                    });
                }
            },
            error: function (xhr, status, error) {
                Swal.fire({
                    icon: "error",
                    title: "Error!",
                    text: "Terjadi kesalahan server."
                });
            }
        });
    }


})
