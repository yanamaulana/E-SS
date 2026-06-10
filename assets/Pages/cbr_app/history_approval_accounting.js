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


    $(document).on('input', '.inp-amount-termin', function () {
        // 1. Ganti semua karakter yang BUKAN angka atau titik dengan string kosong
        let val = $(this).val().replace(/[^0-9.]/g, '');

        // 2. Mencegah user mengetik titik lebih dari satu kali (misal: 50.00.00)
        let parts = val.split('.');
        if (parts.length > 2) {
            val = parts[0] + '.' + parts.slice(1).join('');
        }

        // Set kembali nilai yang sudah bersih ke dalam input
        $(this).val(val);
    });

    function Fn_Initialized_DataTable() {
        $("#TableDataHistory").DataTable({
            destroy: true,
            processing: true,
            serverSide: true,
            paging: true,
            dom: '<"row mb-3"<"col-sm-12"B>><"row"<"col-sm-11"f><"col-sm-1"l>>rtip',
            select: true,
            "lengthMenu": [
                [10, 30, 90, 1000],
                [10, 30, 90, 1000]
            ],
            ajax: {
                url: $('meta[name="base_url"]').attr('content') + "HistoryApproval_Accounting/DT_List_History_Approval",
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
                        // Cek status: Jika sudah Close ATAU Void, maka tombol tidak perlu ditampilkan
                        // (Asumsi isClose == 1 adalah closed, isVoid == 1 adalah void)
                        if (row.isClose == 1 || row.isVoid == 1) {
                            return '<span class="badge badge-light-secondary fs-8">Closed/Void</span>';
                        }

                        // Jika data aktif, tampilkan tombolnya
                        return `<div class="btn-group btn-group-sm" role="group" aria-label="Basic example">
                    <button type="button" class="btn btn-sm btn-primary btn-list-attachment" data-bs-toggle="tooltip" title="Upload Attachment">
                        <i class="fas fa-paperclip"></i>
                    </button>
                    <button type="button" class="btn btn-sm btn-info btn-set-termin" 
                            data-bs-toggle="tooltip" 
                            title="Set Partial Payment" 
                            data-cbreq-no="${data}" 
                            data-amount="${row.Amount}" 
                            data-currency="${row.Currency_ID}">
                        <i class="fas fa-comments-dollar"></i>
                    </button>
                </div>`;
                    }
                },
                { data: "CBReq_No", name: "CBReq_No", },
                { data: "Type", name: "Type", visible: false },
                {
                    data: "Document_Date", name: "Document_Date", render: function (data) {
                        return data ? data.substring(0, data.indexOf(' ')) : '-'; // Tambah cek NULL
                    }
                },
                { data: "Currency_Id", name: "Currency_Id" },
                {
                    data: "Amount", name: "Amount", render: function (data) {
                        return parseFloat(data).toLocaleString('en-US', { minimumFractionDigits: 4, maximumFractionDigits: 4 });
                    }
                },
                { data: "Document_Number", name: "Document_Number" },
                { data: "Descript", name: "Descript" },
                { data: "baseamount", name: "baseamount", visible: false },
                { data: "curr_rate", name: "curr_rate", visible: false },
                { data: "Approval_Status", name: "Approval_Status", visible: false },
                {
                    data: "isClose", name: "isClose",
                    render: function (data) {
                        if (data == 0 || data == '' || data == null) {
                            return `<span class="text-dark badge badge-success">Open</span>`;
                        } else {
                            return `<span class="text-dark badge badge-danger">VOID</span>`;
                        }
                    }
                },
                {
                    data: "Paid_Status", name: "Paid_Status",
                    render: function (data) {
                        if (data == 'NP') {
                            return `<span class="text-dark badge badge-danger">Not Paid</span>`
                        } else if (data == 'HP') {
                            return `<span class="text-dark badge badge-warning">Half Paid</span>`
                        } else if (data == 'FP') {
                            return `<span class="text-dark badge badge-success">Full Paid</span>`
                        } else {
                            return ''
                        }
                    }
                },
                { data: "Creation_DateTime", name: "Creation_DateTime", visible: false },
                { data: "Created_By", name: "Created_By", visible: false },
                { data: "UserDivision", name: "UserDivision", orderable: true },
                { data: "First_Name", name: "First_Name", orderable: false },
                { data: "Last_Update", name: "Last_Update", visible: false },
                { data: "Acc_ID", name: "Acc_ID", visible: false },
                { data: "Approve_Date", name: "Approve_Date", visible: false },
                { data: "IsAppvStaff", name: "IsAppvStaff", visible: false },
                { data: "IsAppvChief", name: "IsAppvChief", visible: false },
                {
                    data: "IsAppvAsstManager", name: "IsAppvAsstManager", orderable: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvAsstManager) + ' <br/> ' + row.AppvAsstManager_Name;
                    },
                },
                {
                    data: "IsAppvManager", name: "IsAppvManager", orderable: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvManager) + ' <br/> ' + row.AppvManager_Name;
                    }
                },
                {
                    data: "IsAppvSeniorManager", name: "IsAppvSeniorManager", orderable: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvSeniorManager) + ' <br/> ' + row.AppvSeniorManager_Name;
                    }
                },
                {
                    data: "IsAppvGeneralManager", name: "IsAppvGeneralManager", orderable: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvGeneralManager) + ' <br/> ' + row.AppvGeneralManager_Name;
                    }
                },
                {
                    data: "IsAppvAdditional", name: "IsAppvAdditional", orderable: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvAdditional) + ' <br/> ' + row.AppvAdditional_Name;
                    }
                },
                {
                    data: "IsAppvFinancePerson", name: "IsAppvFinancePerson", orderable: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvFinancePerson) + ' <br/> ' + row.AppvFinancePerson_Name;
                    }
                },
                {
                    data: "IsAppvDirector", name: "IsAppvDirector", orderable: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvDirector) + ' <br/> ' + row.AppvDirector_Name;
                    }
                },
                {
                    data: "IsAppvFinanceDirector", name: "IsAppvFinanceDirector", orderable: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvFinanceDirector) + ' <br/> ' + row.AppvFinanceDirector_Name;
                    }
                },
                {
                    data: "IsAppvPresidentDirector", name: "IsAppvPresidentDirector", orderable: false, render: function (data, type, row, meta) {
                        return renderApprovalStatus(data, row.Status_AppvPresidentDirector) + ' <br/> ' + row.AppvPresidentDirector_Name;
                    }
                }

            ],
            order: [
                [3, "DESC"]
            ],
            columnDefs: [{
                width: 220,
                targets: 7
            }, {
                className: "text-center dt-nowrap",
                targets: [0, 3, 4, 5, 6, 11, 12, 15, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29],
            }, {
                className: "details-control pr-4 dt-nowrap",
                targets: [1]
            }],
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

                    if (data.Legitimate == '1') {
                        $('td', row).css('background-color', '#D4EDDA');
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
            drawCallback: function () {
                $("TableDataHistory tbody td").addClass("blurry");
                setTimeout(function () {
                    $("TableDataHistory tbody td").removeClass("blurry");
                });
                $('[data-bs-toggle="tooltip"]').tooltip();
                DataTable.tables({ visible: true, api: true }).columns.adjust();
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


    $(document).on('click', '.btn-list-attachment', function () {
        $('#txt-cbr').text($(this).val());
        $.ajax({
            // dataType: "json",
            type: "GET",
            url: $('meta[name="base_url"]').attr('content') + "MyCbr/m_list_cbr_attachment",
            data: {
                CbrNo: $(this).val(),
                auth_upload: 1,
                note: 'Accounting'
            }, beforeSend: function () {
                Swal.fire({
                    title: 'Loading....',
                    html: '<div class="spinner-border text-primary"></div>',
                    showConfirmButton: false,
                    allowOutsideClick: false,
                    allowEscapeKey: false
                })
            }, success: function (ajaxData) {
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


    let totalCbrAmount = 0;
    let cbrCurrency = 'IDR';

    $(document).on('click', '.btn-set-termin', function () {
        const cbreqNo = $(this).data('cbreq-no');
        totalCbrAmount = parseFloat($(this).data('amount')) || 0;
        cbrCurrency = $(this).data('currency') || 'IDR';

        $('#txt_modal_cbr_no').text(cbreqNo);
        $('#inp_modal_cbreq_no').val(cbreqNo);
        $('#txt_modal_total_amount').text(cbrCurrency + ' ' + formatRupiah(totalCbrAmount));
        $('#inp_modal_total_amount_raw').val(totalCbrAmount);

        $.ajax({
            url: $('meta[name="base_url"]').attr('content') + "CbrAppAccounting/get_termin_data/" + encodeURIComponent(cbreqNo),
            type: "GET",
            dataType: "JSON",
            success: function (response) {
                $('#termin_table_body').empty();

                let totalApproved = 0;
                let hasActiveAwaiting = false;

                if (response && response.length > 0) {
                    response.forEach(function (item, index) {
                        let planDate = item.Payment_Plan_Date ? item.Payment_Plan_Date.split(' ')[0] : '';

                        addTerminRow(item.Amount_Termin, planDate, item.Status_AppvPresdir, cbrCurrency);

                        // Akumulasi hanya yang sudah APPROVED (Status 1)
                        if (item.Status_AppvPresdir == 1) {
                            totalApproved += parseFloat(item.Amount_Termin);
                        }

                        if (item.Status_AppvPresdir == 0) {
                            hasActiveAwaiting = true;
                        }
                    });

                    // LOGIKA: Jika nominal Approved sudah sama dengan Total CBR
                    // Kita gunakan Math.abs agar toleransi desimal aman
                    if (Math.abs(totalApproved - totalCbrAmount) < 0.01) {
                        $('#msg_termin_complete').removeClass('d-none'); // Tampilkan pesan
                        $('#table_termin_wrapper').addClass('d-none');   // Sembunyikan tabel
                        $('#btn_save_termin').hide();                    // Sembunyikan tombol simpan
                    } else {
                        $('#msg_termin_complete').addClass('d-none');
                        $('#table_termin_wrapper').removeClass('d-none');

                        // Jika tidak ada yang awaiting, baru buatkan baris draft sisa
                        let outstanding = totalCbrAmount - totalApproved; // Outstanding dari yang sudah approved
                        if (!hasActiveAwaiting && outstanding > 0.01) {
                            addTerminRow(outstanding, '', 'draft', cbrCurrency);
                        }
                    }

                } else {
                    // Jika data benar-benar kosong
                    $('#msg_termin_complete').addClass('d-none');
                    $('#table_termin_wrapper').removeClass('d-none');
                    addTerminRow(totalCbrAmount, '', 'draft', cbrCurrency);
                }

                calculateRemaining();
                $('#modal_set_termin').modal('show');
            }
        });
    });

    function addTerminRow(amount = 0, date = '', status = 0, cbrCurrency) {
        const rowCount = $('.termin-row').length + 1;

        // Input terkunci HANYA jika status dari DB adalah 1 (Approved) atau 2 (Rejected)
        // Jika statusnya 0 (Awaiting) atau 'draft', input tetap TERBUKA agar bisa di-split/diubah
        const isDisabled = (status == 1 || status == 2) ? 'disabled' : '';
        const isDeleteHidden = (status == 1 || status == 2) ? 'd-none' : '';

        // Pemetaan Badge Status berdasarkan standarisasi angka Anda + kondisi 'draft'
        let badgeStatus = '';
        if (status == 1) {
            badgeStatus = '<span class="badge badge-sm badge-light-success fw-bold">Approved</span>';
        } else if (status == 2) {
            badgeStatus = '<span class="badge badge-sm badge-light-danger fw-bold">Rejected</span>';
        } else if (status === 'draft') {
            // Tampilan khusus untuk baris otomatis yang belum masuk DB
            badgeStatus = '<span class="badge badge-sm badge-light-primary fw-bold">Draft</span>';
        } else {
            // Status 0 dari DB
            badgeStatus = '<span class="badge badge-sm badge-light-warning fw-bold">Awaiting</span>';
        }

        const html = `<tr class="termin-row fs-7" data-status="${status}">
                    <td class="text-center fw-bold row-number ps-2">${rowCount}</td>
                    <td class="text-center">${badgeStatus}</td>
                    <td>
                        <div class="input-group input-group-sm input-group-solid">
                            <span class="input-group-text fw-bold fs-7 py-1 px-2">${cbrCurrency}</span>
                            <input type="text" name="amount_termin[]" class="form-control form-control-sm form-control-solid inp-amount-termin fs-7 py-1" value="${amount}" required ${isDisabled}>
                            ${(status == 1 || status == 2) ? `<input type="hidden" name="amount_termin[]" value="${amount}">` : ''}
                        </div>
                    </td>
                    <td>
                        <input type="text" name="payment_plan_date[]" class="form-control form-control-sm form-control-solid date-picker fs-7 py-1" value="${date}" required ${isDisabled}>
                        ${(status == 1 || status == 2) ? `<input type="hidden" name="payment_plan_date[]" value="${date}">` : ''}
                    </td>
                   <!-- <td class="text-center pe-2">
                        <button type="button" class="btn btn-icon btn-light-danger btn-sm w-25px h-25px btn-delete-row ${isDeleteHidden}" title="Hapus">
                            <i class="fas fa-trash fs-8"></i>
                        </button> --!> 
                    </td>
                </tr>`;

        $('#termin_table_body').append(html);
        calculateRemaining();
        $('.date-picker').flatpickr({
            dateFormat: "Y-m-d"
        });
    }

    // Handler tombol "Hapus" baris termin
    $(document).on('click', '.btn-delete-row', function () {
        if ($('.termin-row').length > 1) {
            $(this).closest('.termin-row').remove();
            // Susun ulang nomor urut termin (1, 2, 3...)
            $('.termin-row').each(function (index) {
                $(this).find('.row-number').text(index + 1);
            });
            calculateRemaining();
        } else {
            alert('Minimal harus ada 1 termin pembayaran!');
        }
    });

    // Handler hitung ulang tiap kali akuntan mengubah angka input secara manual
    $(document).on('input', '.inp-amount-termin', function () {
        calculateRemaining();
    });

    function calculateRemaining() {
        let totalInputed = 0;
        let totalApprovedOnly = 0;

        $('.termin-row').each(function () {
            const status = parseInt($(this).data('status'));
            const val = parseFloat($(this).find('.inp-amount-termin').val()) || 0;

            totalInputed += val;

            if (status === 1) {
                totalApprovedOnly += val;
            }
        });

        let remaining = totalCbrAmount - totalInputed;
        $('#txt_modal_remaining_amount').text(formatRupiah(remaining)).data('val', remaining);

        // Jika total yang disetujui (Approved) sudah sama dengan total anggaran CBR
        let approvedRemaining = totalCbrAmount - totalApprovedOnly;
        if (Math.abs(approvedRemaining) < 0.01) {
            $('#txt_modal_remaining_amount').text(formatRupiah(0)).removeClass('text-danger').addClass('text-success');
            $('#btn_save_termin').hide();
            return;
        }

        // Tampilkan tombol jika masih dalam proses termin berjalan
        $('#btn_save_termin').show();

        // Tombol aktif jika sisa input pas (0) atau bernilai positif (parsial termin diizinkan)
        if (remaining >= 0) {
            $('#txt_modal_remaining_amount').removeClass('text-danger').addClass('text-success');
            $('#btn_save_termin').prop('disabled', false);
        } else {
            $('#txt_modal_remaining_amount').removeClass('text-success').addClass('text-danger');
            $('#btn_save_termin').prop('disabled', true); // Kunci jika melampaui total dana CBR
        }
    }

    // Fungsi bantu format angka nominal agar rapi dibaca di modal
    function formatRupiah(angka) {
        return parseFloat(angka).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
    }

    $('#form_termin').on('submit', function (e) {
        e.preventDefault(); // Tahan form agar tidak reload dulu

        const form = $(this);
        const btnSave = $('#btn_save_termin');

        let isValid = true;
        let errorMsg = "";
        let totalInputed = 0;

        // LOOPING UNTUK VALIDASI PER BARIS TABEL
        $('.termin-row').each(function (index) {
            const rowNum = index + 1;
            const amountVal = parseFloat($(this).find('.inp-amount-termin').val()) || 0;
            const dateVal = $(this).find('.date-picker').val();

            totalInputed += amountVal;

            // 1. Validasi Required & Tidak Boleh 0
            if (!amountVal || amountVal <= 0) {
                isValid = false;
                errorMsg = `Nominal Pembayaran pada baris ke-${rowNum} tidak boleh kosong atau 0!`;
                return false; // Break loop jQuery
            }

            // 2. Validasi Plan Date Required
            if (!dateVal || dateVal.trim() === "") {
                isValid = false;
                errorMsg = `Rencana Tanggal Bayar pada baris ke-${rowNum} wajib diisi!`;
                return false; // Break loop jQuery
            }
        });

        if (!isValid) {
            Swal.fire({ text: errorMsg, icon: "warning", buttonsStyling: false, confirmButtonText: "Ok, Perbaiki", customClass: { confirmButton: "btn btn-sm btn-warning" } });
            return false;
        }

        // 3. Validasi Keseluruhan Termin Tidak Boleh Lebih Besar dari Nilai Amount CBR
        // Menggunakan selisih toleransi desimal 0.01 untuk menghindari bug tipe data float
        if ((totalInputed - totalCbrAmount) > 0.01) {
            Swal.fire({
                text: `Total akumulasi termin (${formatRupiah(totalInputed)}) melebihi nilai total nominal CBR (${formatRupiah(totalCbrAmount)})!`,
                icon: "error",
                buttonsStyling: false,
                confirmButtonText: "Sesuaikan Angka",
                customClass: { confirmButton: "btn btn-sm btn-danger" }
            });
            return false;
        }

        // --- JIKA LOLOS SEMUA VALIDASI, JALANKAN AJAX SIMPAN ---
        btnSave.attr('data-kt-indicator', 'on').prop('disabled', true);

        $.ajax({
            url: form.attr('action'),
            type: "POST",
            data: form.serialize(),
            dataType: "JSON",
            success: function (response) {
                btnSave.removeAttr('data-kt-indicator').prop('disabled', false);

                if (response.code === 200) {
                    Swal.fire({ text: response.msg, icon: "success", buttonsStyling: false, confirmButtonText: "Selesai", customClass: { confirmButton: "btn btn-sm btn-primary" } }).then(function () {
                        $('#modal_set_termin').modal('hide');
                        if ($.fn.DataTable.isDataTable('#TableDataHistory')) {
                            $('#TableDataHistory').DataTable().ajax.reload(null, false);
                        }
                    });
                } else {
                    Swal.fire({ text: response.msg, icon: "error", buttonsStyling: false, confirmButtonText: "Coba Lagi", customClass: { confirmButton: "btn btn-sm btn-danger" } });
                }
            },
            error: function () {
                btnSave.removeAttr('data-kt-indicator').prop('disabled', false);
                Swal.fire({ text: "Terjadi kesalahan sistem server.", icon: "error", buttonsStyling: false, confirmButtonText: "Tutup", customClass: { confirmButton: "btn btn-sm btn-light" } });
            }
        });
    });


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
