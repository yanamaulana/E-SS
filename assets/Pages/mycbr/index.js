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

    var TableData = $("#TableData").DataTable({
        destroy: true,
        processing: true,
        serverSide: true,
        paging: true,
        dom: 'lBfrtip',
        orderCellsTop: true,
        select: false,
        fixedHeader: {
            header: true,
            headerOffset: 65
        },
        "lengthMenu": [
            [15, 30, 90, 100],
            [15, 30, 90, 100]
        ],
        ajax: {
            url: $('meta[name="base_url"]').attr('content') + "MyCbr/DT_List_To_Approve",
            dataType: "json",
            type: "POST",
        },
        columns: [{
            data: 'CBReq_No',
            name: "CheckBox",
            orderable: false,
            render: function (data, type, row, meta) {
                return `<div class="form-check">
                    <input class="form-check-input" type="checkbox" value="${row.CBReq_No}" id="${row.CBReq_No}" name="CBReq_No[]">
                  </div>`
            }
        },
        {
            data: "CBReq_No",
            name: "CBReq_No",
        },
        {
            data: "Type",
            name: "Type",
            visible: false
        },
        {
            data: "Document_Date",
            name: "Document_Date",
            render: function (data) {
                return '<pre>' + data.substring(0, data.indexOf(' ')) + '</pre>';
            }
        },
        {
            data: "Currency_Id",
            name: "Currency_Id",
        },
        {
            data: "Amount",
            name: "Amount",
            render: function (data) {
                return parseFloat(data).toLocaleString('en-US', {
                    minimumFractionDigits: 4,
                    maximumFractionDigits: 4
                });
            }
        },
        {
            data: "Document_Number",
            name: "Document_Number",
        },
        {
            data: "Descript",
            name: "Descript",
        },
        {
            data: "baseamount",
            name: "baseamount",
            visible: false
        },
        {
            data: "curr_rate",
            name: "curr_rate",
            visible: false
        },
        {
            data: "Approval_Status",
            name: "Approval_Status",
            visible: false
        },
        {
            data: "CBReq_Status",
            name: "CBReq_Status",
            render: function (data) {
                if (data == 3) {
                    return `<a hreff="javascript:void(0)" data-bs-toggle="tooltip" data-bs-placement="left" data-bs-custom-class="tooltip-dark" title="Close" class="badge badge-success btn-icon"><i class="text-white fas fa-file-archive"></i></a>`
                } else if (data == 2) {
                    return `<a hreff="javascript:void(0)" data-bs-toggle="tooltip" data-bs-placement="left" data-bs-custom-class="tooltip-dark" title="Open" class="badge badge-info btn-icon"><i class="text-white fas fa-folder-open"></i></a></button>`
                } else {
                    return `<a hreff="javascript:void(0)" data-bs-toggle="tooltip" data-bs-placement="left" data-bs-custom-class="tooltip-dark" title="New" class="badge badge-warning btn-icon"><i class="text-white fas fa-file"></i></a></button>`
                }
            }
        },
        {
            data: "Paid_Status",
            name: "Paid_Status",
            render: function (data) {
                if (data == 'NP') {
                    return `<span class="text-dark badge badge-warning">Not Paid</span>`
                } else {
                    return `<span class="text-dark badge badge-success">Full Paid</span>`
                }
            }
        },
        {
            data: "Creation_DateTime",
            name: "Creation_DateTime",
            visible: false
        },
        {
            data: "Created_By",
            name: "Created_By",
            visible: false
        },
        {
            data: "First_Name",
            name: "First_Name",
        },
        {
            data: "Last_Update",
            name: "Last_Update",
            visible: false
        },
        {
            data: "Acc_ID",
            name: "Acc_ID",
            visible: false
        },
        {
            data: "Approve_Date",
            name: "Approve_Date",
            visible: false
        }
        ],
        order: [
            [3, "DESC"]
        ],
        columnDefs: [{
            className: "text-center",
            targets: [0, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13],
        }, {
            className: "details-control pr-4 dt-nowrap",
            targets: [1]
        }, {
            className: "dt-nowrap",
            targets: [6]
        }],
        autoWidth: false,
        responsive: false,
        "rowCallback": function (row, data) {
            // if (data.is_active == "0") {
            // 	$('td', row).css('background-color', 'pink');
            // }
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
        "buttons": [{
            text: `<i class="fas fa-external-link-alt"></i> Send Submission`,
            className: "btn btn-success",
            action: function (e, dt, node, config) {
                Swal.fire({
                    title: 'System Message !',
                    text: `Are you sure to approve all checked submission ?`,
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Yes'
                }).then((result) => {
                    if (result.isConfirmed) {
                        Fn_Approve_Submission();
                    }
                })
            }
        },
        {
            text: `-`,
            className: "btn btn-default btn-icon disabled",
            action: function (e, dt, node, config) {
                // var RowData = dt.rows({
                // 	selected: true
                // }).data();
                // if (RowData.length == 0) {
                // 	Swal.fire({
                // 		icon: 'warning',
                // 		title: 'Ooppss...',
                // 		text: 'Please select data to be update !',
                // 		footer: '<a href="javascript:void(0)" class="text-danger">Notifikasi System</a>'
                // 	});
                // } else {
                // 	Init_Append_Modal_Update(RowData[0].SysId)
                // }
            }
        },
        {
            text: `<i class="fas fa-times fs-3"></i> Reject (Not Send)`,
            className: "btn btn-danger",
            action: function (e, dt, node, config) {
                Swal.fire({
                    title: 'System Message !',
                    text: `Are you sure to reject all checked submission ?`,
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Yes'
                }).then((result) => {
                    if (result.isConfirmed) {
                        Fn_Reject_Submission();
                    }
                })
            }
        },
            // {
            // 	text: `Export to :`,
            // 	className: "btn disabled text-dark bg-white",
            // }, {
            // 	text: `<i class="far fa-copy fs-2"></i>`,
            // 	extend: 'copy',
            // 	className: "btn btn-light-warning",
            // }, {
            // 	text: `<i class="far fa-file-excel fs-2"></i>`,
            // 	extend: 'excelHtml5',
            // 	title: $('#table-title').text() + '~' + moment().format("YYYY-MM-DD"),
            // 	className: "btn btn-light-success",
            // }, {
            // 	text: `<i class="far fa-file-pdf fs-2"></i>`,
            // 	extend: 'pdfHtml5',
            // 	title: $('#table-title').text() + '~' + moment().format("YYYY-MM-DD"),
            // 	className: "btn btn-light-danger",
            // 	orientation: "landscape"
            // }, {
            // 	text: `<i class="fas fa-print fs-2"></i>`,
            // 	extend: 'print',
            // 	className: "btn btn-light-dark",
            // }
        ],
    }).buttons().container().appendTo('#TableData_wrapper .col-md-6:eq(0)');

    $('#TableData tbody').on('click', 'td.details-control', function () {
        var tr = $(this).parents('tr');
        var row = $("#TableData").DataTable().row(tr);

        if (row.child.isShown()) {
            // This row is already open - close it
            row.child.hide();
            tr.removeClass('shown');
        } else {
            // Open this row (the format() function would return the data to be shown)
            row.child(format(row.data())).show();
            tr.addClass('shown');
            getInsDetail(row.data().CBReq_No, row.data().Document_Number);
        }
    });

    function format(d) {
        return `<div class="row py-3" style="background-color: #CFE2FF;">
                    <div class="container-fluid">
                        <div class="card shadow-sm">
                            <div class="card-body">
                                <div class="table-responsive overflow-auto">
                                    <table class="table-sm table-striped overflow-auto table-bordered display compact" style="width: 100%;">
                                        <thead>
                                            <tr>
                                                <th class="text-dark" colspan="3">Cash Book Requisition Number : ${d.CBReq_No}</th>
                                            </tr>
                                            <tr class="bg-dark">
                                                <th class="text-center">#</th>
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
                    </div >
                    <div class="container-fluid mt-5">
                        <div class="card shadow-sm">
                            <div class="card-body">
                                <div class="table-responsive overflow-auto">
                                    <table class="table-sm table-striped overflow-auto table-bordered display compact" style="width: 100%;">
                                        <thead>
                                            <tr>
                                                <th class="text-dark" colspan="11">Purchase Invoice  : ${d.Document_Number}</th>
                                            </tr>
                                            <tr class="bg-dark">
                                                <th class="text-center">#</th>
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
                    </div >
                </div >`
    }

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
                            <td class="text-center">${item.iteration}</td>
                            <td>${item.Account_Name}</td>
                            <td>${item.Description}</td>
                            <td>${item.Amount_Detail}</td>
                            </tr>`);
                    });
                } else {
                    tr.append(`<tr><td colspan="3">Detail Cash Book Requisition Not found !</td></tr>`);
                }

                var tr = $("#tbody_vin_" + Req_No);
                if (response.code_vin == 200) {
                    $.each(response.dataVins, function (index, item) {
                        console.log(item.Account_Name);
                        tr.append(
                            `<tr>
                                <td class="text-center">${item.iteration}</td>
                                <td>${item.Invoice_Number}</td>
                                <td>${item.VenInvoice_Number}</td>
                                <td>${item.Invoice_Date}</td>
                                <td>${item.Due_Date}</td>
                                <td>${item.PO_NUMBER}</td>
                                <td>${item.Account_Name}</td>
                                <td>${item.Invoice_Status}</td>
                                <td>${item.isVoid}</td>
                                <td>${item.is_document_received}</td>
                                <td>${item.document_received_date}</td>
                            </tr>`);
                    });
                } else {
                    tr.append(`<tr><td colspan="13">This Cash Book Requisition doesnt have a Purchase Invoice !</td></tr>`);
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


    function Fn_Approve_Submission() {
        if ($('input[name="SysId[]"]:checked').length == 0) {
            return Swal.fire({
                icon: 'error',
                title: 'Oops...',
                text: 'You need check the submission first !',
                footer: '<a href="javascript:void(0)">Notifikasi System</a>'
            });
        }

        $.ajax({
            dataType: "json",
            type: "POST",
            url: $('meta[name="base_url"]').attr('content') + "ApprovalAttendance/Approve_Submission",
            data: $('#form-submission').serialize(),
            beforeSend: function () {
                Swal.fire({
                    title: 'Loading....',
                    html: '<div class="spinner-border text-primary"></div>',
                    showConfirmButton: false,
                    allowOutsideClick: false,
                    allowEscapeKey: false
                })
            },
            success: function (response) {
                Swal.close()
                if (response.code == 200) {
                    Toast.fire({
                        icon: 'success',
                        title: response.msg
                    });
                    $("#TableData").DataTable().ajax.reload(null, false);
                    $("#TableDataHistory").DataTable().ajax.reload(null, false);
                } else {
                    Toast.fire({
                        icon: 'error',
                        title: response.msg
                    });
                }
            },
            error: function (xhr, status, error) {
                var statusCode = xhr.status;
                var errorMessage = xhr.responseJSON && xhr.responseJSON.message ? xhr.responseJSON.message : xhr.responseText ? xhr.responseText : "Terjadi kesalahan: " + error;
                Swal.fire({
                    icon: "error",
                    title: "Error!",
                    html: `Kode HTTP: ${statusCode}<br\>Pesan: ${errorMessage}`,
                });
            }
        });
    }

    function Fn_Reject_Submission() {
        if ($('input[name="SysId[]"]:checked').length == 0) {
            return Swal.fire({
                icon: 'error',
                title: 'Oops...',
                text: 'You need check the submission first !',
                footer: '<a href="javascript:void(0)">Notifikasi System</a>'
            });
        }

        $.ajax({
            dataType: "json",
            type: "POST",
            url: $('meta[name="base_url"]').attr('content') + "ApprovalAttendance/Reject_Submission",
            data: $('#form-submission').serialize(),
            beforeSend: function () {
                Swal.fire({
                    title: 'Loading....',
                    html: '<div class="spinner-border text-primary"></div>',
                    showConfirmButton: false,
                    allowOutsideClick: false,
                    allowEscapeKey: false
                })
            },
            success: function (response) {
                Swal.close()
                if (response.code == 200) {
                    Toast.fire({
                        icon: 'success',
                        title: response.msg
                    });
                    $("#TableData").DataTable().ajax.reload(null, false);
                    $("#TableDataHistory").DataTable().ajax.reload(null, false);
                } else {
                    Toast.fire({
                        icon: 'error',
                        title: response.msg
                    });
                }
            },
            error: function (xhr, status, error) {
                var statusCode = xhr.status;
                var errorMessage = xhr.responseJSON && xhr.responseJSON.message ? xhr.responseJSON.message : xhr.responseText ? xhr.responseText : "Terjadi kesalahan: " + error;
                Swal.fire({
                    icon: "error",
                    title: "Error!",
                    html: `Kode HTTP: ${statusCode}<br\>Pesan: ${errorMessage}`,
                });
            }
        });
    }

    // var TableDataHistory = $("#TableDataHistory").DataTable({
    //     destroy: true,
    //     processing: true,
    //     serverSide: true,
    //     paging: true,
    //     dom: 'lBfrtip',
    //     orderCellsTop: true,
    //     select: true,
    //     fixedHeader: {
    //         header: true,
    //         headerOffset: 48
    //     },
    //     "lengthMenu": [
    //         [15, 30, 90, 1000],
    //         [15, 30, 90, 1000]
    //     ],
    //     ajax: {
    //         url: $('meta[name="base_url"]').attr('content') + "ApprovalAttendance/DT_List_History_Submission",
    //         dataType: "json",
    //         type: "POST",
    //     },
    //     columns: [{
    //         data: "SysId",
    //         name: "SysId",
    //         render: function (data, type, row, meta) {
    //             return meta.row + meta.settings._iDisplayStart + 1;
    //         }
    //     },
    //     {
    //         data: "Name",
    //         name: "Name",
    //     },
    //     {
    //         data: "Access_ID",
    //         name: "Access_ID",
    //     },
    //     {
    //         data: "Card",
    //         name: "Card",
    //     },
    //     {
    //         data: "Date_Att",
    //         name: "Date_Att",
    //     },
    //     {
    //         data: "Time_Att",
    //         name: "Time_Att",
    //     },
    //     {
    //         data: "Schedule_Number",
    //         name: "Schedule_Number",
    //     },
    //     {
    //         data: "Day",
    //         name: "Day",
    //     },
    //     {
    //         data: "Kelas",
    //         name: "Kelas",
    //     },
    //     {
    //         data: "Mata_Pelajaran",
    //         name: "Mata_Pelajaran",
    //     },
    //     {
    //         data: "Time_Start",
    //         name: "Time_Start",
    //     },
    //     {
    //         data: "Time_Over",
    //         name: "Time_Over",
    //     },
    //     {
    //         data: "Stand_Hour",
    //         name: "Stand_Hour",
    //     },
    //     {
    //         data: "Status",
    //         name: "Status",
    //         render: function (data, type, row, meta) {
    //             if (data == '1') {
    //                 return `<button type="button" class="btn btn-sm btn-primary" title="Approved" data-toggle="tooltip"><i class="fas fa-check fs-3"></i> Approved</button>`
    //             } else {
    //                 return `<button type="button" class="btn btn-sm btn-danger" title="Reject" data-toggle="tooltip"><i class="fas fa-times fs-3"></i> Rejected</button>`
    //             }
    //         }
    //     },
    //     ],
    //     order: [
    //         [2, "ASC"]
    //     ],
    //     columnDefs: [{
    //         className: "align-middle text-center",
    //         targets: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
    //     }],
    //     autoWidth: false,
    //     responsive: true,
    //     "rowCallback": function (row, data) {
    //         // if (data.is_active == "0") {
    //         // 	$('td', row).css('background-color', 'pink');
    //         // }
    //     },
    //     preDrawCallback: function () {
    //         $("TableDataHistory tbody td").addClass("blurry");
    //     },
    //     language: {
    //         processing: '<i style="color:#4a4a4a" class="fa fa-spinner fa-spin fa-3x fa-fw"></i><span class="sr-only"></span><p><span style="color:#4a4a4a" style="text-align:center" class="loading-text"></span> ',
    //         searchPlaceholder: "Search..."
    //     },
    //     drawCallback: function () {
    //         $("TableDataHistory tbody td").addClass("blurry");
    //         setTimeout(function () {
    //             $("TableDataHistory tbody td").removeClass("blurry");
    //         });
    //         $('[data-bs-toggle="tooltip"]').tooltip();
    //     },
    //     "buttons": [{
    //         text: `Export to :`,
    //         className: "btn disabled text-dark bg-white",
    //     }, {
    //         text: `<i class="far fa-copy fs-2"></i>`,
    //         extend: 'copy',
    //         className: "btn btn-light-warning",
    //     }, {
    //         text: `<i class="far fa-file-excel fs-2"></i>`,
    //         extend: 'excelHtml5',
    //         title: $('#table-title-history').text() + '~' + moment().format("YYYY-MM-DD"),
    //         className: "btn btn-light-success",
    //     }, {
    //         text: `<i class="far fa-file-pdf fs-2"></i>`,
    //         extend: 'pdfHtml5',
    //         title: $('#table-title-history').text() + '~' + moment().format("YYYY-MM-DD"),
    //         className: "btn btn-light-danger",
    //         orientation: "landscape"
    //     }, {
    //         text: `<i class="fas fa-print fs-2"></i>`,
    //         extend: 'print',
    //         className: "btn btn-light-dark",
    //     }],
    // }).buttons().container().appendTo('TableDataHistory_wrapper .col-md-6:eq(0)');
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
