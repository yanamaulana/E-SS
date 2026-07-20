$(document).ready(function () {
    // mengambil menu yang di buka, untuk menentukan hasil populasi data yang akan di tampilkan pada halaman
    // yang akan di kiprim ke controller nanti controller yang akan memproses keputusan data tersebut.
    const SegmentMenu = window.location.pathname.split('/').pop();

    function Fn_Initialized_DataTable() {
        $("#TableDataTermin").DataTable({
            destroy: true,
            processing: true,
            serverSide: true,
            paging: true,
            dom: '<"row mb-3"<"col-sm-12"B>><"row"<"col-sm-11"f><"col-sm-1"l>>rtip',
            select: true,
            "lengthMenu": [
                [10, 100, 1000, 4999],
                [10, 100, 1000, 4999]
            ],
            ajax: {
                url: $('meta[name="base_url"]').attr('content') + "MonitoringTermin/DT_List_Hst_Submission_Termin",
                dataType: "json",
                type: "POST",
                data: {
                    from: $('#from_termin').val(),
                    until: $('#until_termin').val(),
                    column_range: $('#column_range_termin').val(),
                    SegmentMenu: SegmentMenu,
                }
            },
            columns: [
                {
                    data: "CBReq_No", name: "CBReq_No", orderable: false, render: function (data, type, row, meta) {
                        return meta.row + meta.settings._iDisplayStart + 1;
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
                    data: "IsAppvManager", name: "IsAppvManager", orderable: false, visible: true, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvManager) + ' <br/> ' + row.AppvManager_At;
                    }
                },
                {
                    data: "IsAppvSeniorManager", name: "IsAppvSeniorManager", orderable: false, visible: true, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvSeniorManager) + ' <br/> ' + row.AppvSeniorManager_At;
                    }
                },
                {
                    data: "IsAppvGeneralManager", name: "IsAppvGeneralManager", orderable: false, visible: true, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvGeneralManager) + ' <br/> ' + row.AppvGeneralManager_At;
                    }
                },
                {
                    data: "IsAppvAdditional", name: "IsAppvAdditional", orderable: false, visible: true, render: function (data, type, row, meta) {
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
                        return renderApprovalStatus(1, row.Status_AppvPresidentDirector) + ' <br/> ' + row.AppvPresidentDirector_At;
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
                $("TableDataTermin tbody td").addClass("blurry");
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
                $("TableDataTermin tbody td").addClass("blurry");
                setTimeout(function () {
                    $("TableDataTermin tbody td").removeClass("blurry");
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
            }
            ],
        }).buttons().container().appendTo('TableDataTermin_wrapper .col-md-6:eq(0)');
    }

    document.querySelectorAll('a[data-bs-toggle="tab"]').forEach((el) => {
        el.addEventListener('shown.bs.tab', () => {
            DataTable.tables({ visible: true, api: true }).columns.adjust();
        });
    });

    $('#do--filter_termin').on('click', function () {
        $("#TableDataTermin").DataTable().clear().destroy(), Fn_Initialized_DataTable(), DataTable.tables({ visible: true, api: true }).columns.adjust();
    })

    Fn_Initialized_DataTable()
})