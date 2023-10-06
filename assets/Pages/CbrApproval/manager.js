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
            headerOffset: 48
        },
        "lengthMenu": [
            [1000],
            [1000]
        ],
        ajax: {
            url: $('meta[name="base_url"]').attr('content') + "CbrApp_Manager/DT_List_To_Approve",
            dataType: "json",
            type: "POST",
        },
        columns: [{
            data: "SysId",
            name: "SysId",
            orderable: false,
            render: function (data, type, row, meta) {
                return `<div class="form-check">
                    <input class="form-check-input" type="checkbox" value="${row.SysId}" id="${row.SysId}" name="SysId[]">
                  </div>`
            }
        },
        {
            data: "Name",
            name: "Name",
        },
        {
            data: "Access_ID",
            name: "Access_ID",
        },
        {
            data: "Card",
            name: "Card",
        },
        {
            data: "Date_Att",
            name: "Date_Att",
        },
        {
            data: "Time_Att",
            name: "Time_Att",
        },
        {
            data: "Schedule_Number",
            name: "Schedule_Number",
        },
        {
            data: "Day",
            name: "Day",
        },
        {
            data: "Kelas",
            name: "Kelas",
        },
        {
            data: "Mata_Pelajaran",
            name: "Mata_Pelajaran",
        },
        {
            data: "Time_Start",
            name: "Time_Start",
        },
        {
            data: "Time_Over",
            name: "Time_Over",
        },
        {
            data: "Stand_Hour",
            name: "Stand_Hour",
        },
        {
            data: "Status",
            name: "Status",
            render: function (data, type, row, meta) {
                return `<button type="button" class="btn btn-warning btn-icon" data-pk="${row.SysId}" data-toggle="tooltip"><i class="fas fa-question"></i></button>`

            }
        },
        ],
        order: [
            [2, "ASC"]
        ],
        columnDefs: [{
            className: "align-middle text-center",
            targets: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
        }],
        autoWidth: false,
        responsive: true,
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
            $('[data-toggle="tooltip"]').tooltip();
        },
        "buttons": [{
            text: `<i class="fas fa-check"></i> Approve`,
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
        }, {
            text: `-`,
            className: "btn btn-default btn-icon disabled",
            action: function (e, dt, node, config) {
                // 	var RowData = dt.rows({
                // 		selected: true
                // 	}).data();
                // 	if (RowData.length == 0) {
                // 		Swal.fire({
                // 			icon: 'warning',
                // 			title: 'Ooppss...',
                // 			text: 'Please select data to be update !',
                // 			footer: '<a href="javascript:void(0)" class="text-danger">Notifikasi System</a>'
                // 		});
                // 	} else {
                // 		Init_Append_Modal_Update(RowData[0].SysId)
                // 	}
            }
        }, {
            text: `<i class="fas fa-times fs-3"></i> Reject`,
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

    function check_uncheck_checkbox(isChecked) {
        if (isChecked) {
            $('input[name="SysId[]"]').each(function () {
                this.checked = true;
            });
        } else {
            $('input[name="SysId[]"]').each(function () {
                this.checked = false;
            });
        }
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
    //         $('[data-toggle="tooltip"]').tooltip();
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
