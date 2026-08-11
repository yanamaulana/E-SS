$(document).ready(function () {
    // mengambil menu yang di buka, untuk menentukan hasil populasi data yang akan di tampilkan pada halaman
    // yang akan di kiprim ke controller nanti controller yang akan memproses keputusan data tersebut.
    const SegmentMenu = window.location.pathname.split('/').pop();

    // Fungsi untuk validasi format H.Payment_Plan_Date
    function validatePaymentPlanDateFormat() {
        if ($('#column_range_termin').val() === 'H.Payment_Plan_Date') {
            const paramPlanDateValue = $('#param_plan_date').val();

            // Validasi gagal jika string kosong ATAU jumlah strip kurang dari 2
            if (!paramPlanDateValue || (paramPlanDateValue.match(/-/g) || []).length < 2) {
                Swal.fire({
                    icon: 'error',
                    title: 'Format Salah',
                    text: 'Saat memfilter "Sign Plan Date", harus dalam format "[DIVISI]_YYYY-MM-DD", contoh: logistic_2026-08-11',
                });
                return false; // Validasi gagal
            }
        }
        return true; // Validasi berhasil atau tidak relevan
    }



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
                    param_plan_date: $('#param_plan_date').val(),
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
                { data: "Amount_Type", name: "Amount_Type" },
                {
                    data: "Document_Date", name: "Document_Date", render: function (data) {
                        return data ? data.substring(0, data.indexOf(' ')) : '-';
                    }
                },
                {
                    data: "Termin_Payment_Plan_Date", name: "Termin_Payment_Plan_Date", render: function (data) {
                        return data ? data.substring(0, data.indexOf(' ')) : '-';
                    }
                },
                {
                    data: "Header_Payment_Plan_Date",
                    name: "Header_Payment_Plan_Date",
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
                        return renderApprovalStatus(data, row.Status_AppvPresidentDirector) + ' <br/> ' + row.AppvPresidentDirector_At;
                    }
                },
                { data: "Payment_Status_Time_Change", name: "Payment_Status_Time_Change" }
            ],
            // 1. Order: Berdasarkan Document_Date sekarang berada di kolom indeks 4
            order: [
                [4, "DESC"]
            ],

            // 2. Gabungan ColumnDefs yang rapi
            columnDefs: [
                {
                    // Pengaturan lebar khusus untuk kolom Description (sekarang di indeks 9)
                    width: "220px",
                    targets: [9]
                },
                {
                    // Alignment center untuk kolom yang sifatnya status/ID/tanggal
                    className: "text-center dt-nowrap",
                    targets: [0, 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
                },
                {
                    // Ikon detail
                    className: "details-control pr-4 dt-nowrap",
                    targets: [1]
                },
                {
                    // Alignment kanan untuk angka (Amount di indeks 8)
                    className: "dt-nowrap text-end",
                    targets: [8]
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
                text: `<i class="far fa-file-excel fs-2"></i> Export`,
                className: "btn btn-light-success",
                action: function (e, dt, node, config) {
                    if (!validatePaymentPlanDateFormat()) {
                        return; // Hentikan eksekusi jika validasi gagal
                    }

                    // Ambil semua parameter filter yang sama dengan yang dikirim oleh DataTable
                    let from = $('#from_termin').val();
                    let until = $('#until_termin').val();
                    let column_range = $('#column_range_termin').val();
                    let param_plan_date = $('#param_plan_date').val();

                    // Bangun URL dengan parameter
                    let url = new URL($('meta[name="base_url"]').attr('content') + 'MonitoringTermin/exportExcelTerminMonitoring');
                    url.searchParams.append('from', from);
                    url.searchParams.append('until', until);
                    url.searchParams.append('column_range', column_range);
                    url.searchParams.append('param_plan_date', param_plan_date);
                    url.searchParams.append('SegmentMenu', SegmentMenu);

                    // Buka URL di tab baru
                    window.open(url, '_blank');
                }
            }
            ],
        }).buttons().container().appendTo('TableDataTermin_wrapper .col-md-6:eq(0)');
    }

    document.querySelectorAll('a[data-bs-toggle="tab"]').forEach((el) => {
        el.addEventListener('shown.bs.tab', () => {
            DataTable.tables({ visible: true, api: true }).columns.adjust();
        });
    });

    Fn_Initialized_DataTable()

    // Function to toggle visibility of date inputs
    function toggleDateInputs() {
        if ($('#column_range_termin').val() === 'H.Payment_Plan_Date') {
            $('#param_plan_date').show();
            $('#from_termin').hide();
            $('#dash').hide();
            $('#until_termin').hide();
        } else {
            $('#param_plan_date').hide();
            $('#from_termin').show();
            $('#dash').show();
            $('#until_termin').show();
        }
    }

    // Add the change event listener
    $('#column_range_termin').on('change', function () {
        toggleDateInputs();
    });

    // Trigger the function on page load to set the initial state
    toggleDateInputs();

    $('#do--filter_termin').on('click', function () {
        // Panggil fungsi validasi yang sudah dibuat
        if (!validatePaymentPlanDateFormat()) {
            return; // Hentikan eksekusi jika validasi gagal
        }
        $("#TableDataTermin").DataTable().clear().destroy(), Fn_Initialized_DataTable(), DataTable.tables({ visible: true, api: true }).columns.adjust();
    })

})