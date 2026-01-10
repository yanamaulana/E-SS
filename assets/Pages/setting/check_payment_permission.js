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

    // $('[data-bs-toggle="tooltip"]').tooltip();

    // Atau jika Anda menggunakan Bootstrap 4:
    $('[data-bs-toggle="tooltip"]').tooltip({ html: true });


    function Fn_Initialized_DataTable() {
        $("#TableData").DataTable({
            destroy: true,
            processing: true,
            serverSide: true,
            paging: true,
            dom: '<"row"<"col-md-12"B><"col-md-11"f><"col-md-1"l>>rtip',
            orderCellsTop: true,
            select: true,
            "lengthMenu": [
                [15, 30, 90, 100],
                [15, 30, 90, 100]
            ],
            ajax: {
                url: $('meta[name="base_url"]').attr('content') + "CheckPayment/DT_list_user_permissions",
                dataType: "json",
                type: "POST",
            },
            columns: [
                {
                    data: "SysId",
                    name: "SysId",
                    title: "#",
                    orderable: false, // Biasanya nomor urut tidak perlu diurutkan
                    render: function (data, type, row, meta) {
                        // Kolom Nomor Urut (Nomor Baris)
                        return meta.row + meta.settings._iDisplayStart + 1;
                    }
                },
                {
                    data: "UserName",
                    name: "UserName",
                    title: "User Name"
                },
                {
                    data: "First_Name",
                    name: "First_Name",
                    title: "Name"
                },
                {
                    data: "inserted_at",
                    name: "inserted_at",
                    title: "Granted at"
                },
                {
                    data: "inserted_by",
                    name: "inserted_by",
                    title: "Granted By"
                },

            ],
            order: [
                [1, "ASC"]
            ],
            columnDefs: [{
                className: "text-center",
                targets: "_all"
            }, {
                className: "details-control pr-4 dt-nowrap",
                targets: [1]
            }, {
                className: "dt-nowrap",
                targets: []
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
                text: `<i class="fas fa-plus"></i> Add Permission`,
                className: "btn btn-info",
                action: function (e, dt, node, config) {
                    $('#modal-add-permission').modal('show');
                }
            },
            {
                text: `<i class="fas fa-trash"></i> Delete Permission`,
                className: "btn btn-danger",
                action: function (e, dt, node, config) {
                    var RowData = dt.rows({
                        selected: true
                    }).data();
                    if (RowData.length == 0 || RowData[0].isCancel == 1) {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Ooppss...',
                            text: 'Please select a user to delete permission !',
                            footer: '<a href="javascript:void(0)" class="text-danger">Notifikasi System</a>'
                        });
                    } else {
                        Fn_Init_Delete(RowData[0].SysId)
                    }
                }
            },
            {
                text: `Export to :`,
                className: "btn btn-default disabled",
            },
            {
                text: `<i class="far fa-file-excel fs-2"></i>`,
                extend: 'excelHtml5',
                title: $('.card-title').text() + '_' + moment().format("YYYY-MM-DD"),
                className: "btn btn-light-success",
            }],
        }).buttons().container().appendTo('#TableData_wrapper .col-md-6:eq(0)');
    }

    Fn_Initialized_DataTable();

    // --------------------------- form validation section

    const main_form = $('#main-form')
    main_form.validate({
        errorElement: 'span',
        errorPlacement: function (error, element) {
            error.addClass('invalid-feedback');
            element.closest('.fv-row, .input-group').append(error);
        },
        highlight: function (element, errorClass, validClass) {
            $(element).addClass('is-invalid');
        },
        unhighlight: function (element, errorClass, validClass) {
            $(element).removeClass('is-invalid');
        }
    });
    $.validator.setDefaults({
        debug: true,
        success: 'valid'
    });

    $('#submit-main-data').click(function (e) {
        e.preventDefault();
        if (main_form.valid()) {
            Swal.fire({
                title: 'System Message !',
                text: `Are you sure to save this record ?`,
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes'
            }).then((result) => {
                if (result.isConfirmed) {
                    Init_Submit_Form(main_form)
                }
            })
        } else {
            $('html, body').animate({
                scrollTop: ($('.error:visible').offset().top - 200)
            }, 400);
        }
    });

    function Init_Submit_Form(DataForm) {
        let BtnAction = $('#submit-main-data');
        $.ajax({
            dataType: "json",
            type: "POST",
            url: $('meta[name="base_url"]').attr('content') + "CheckPayment/store",
            data: DataForm.serialize(),
            beforeSend: function () {
                BtnAction.prop("disabled", true);
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
                    $("#TableData").DataTable().ajax.reload(null, false);
                    Swal.fire({
                        icon: 'success',
                        title: response.msg,
                        showConfirmButton: true
                    }).then(() => {
                        $('#modal-add-permission').modal('hide');
                        $('#main-form').trigger("reset");
                    });
                } else {
                    Swal.fire({
                        icon: "error",
                        title: "Warning !",
                        html: response.msg
                    });
                }
                BtnAction.prop("disabled", false);
            },
            error: function (xhr, status, error) {
                Swal.close()
                BtnAction.prop("disabled", false);
                var statusCode = xhr.status;
                var errorMessage = xhr.responseJSON && xhr.responseJSON.message ? xhr.responseJSON.message : xhr.responseText ? xhr.responseText : "there is an error : " + error;
                Swal.fire({
                    icon: "error",
                    title: "Error!",
                    html: `Kode HTTP: ${statusCode}<br\>Pesan: ${errorMessage}`,
                });
            }
        });
    }

    function Fn_Init_Delete(SysId) {
        Swal.fire({
            title: 'System Message !',
            text: `Are you sure to delete permission for this user ?`,
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes'
        }).then((result) => {
            if (result.isConfirmed) {
                $.ajax({
                    dataType: "json",
                    type: "POST",
                    url: $('meta[name="base_url"]').attr('content') + "CheckPayment/destroy",
                    data: { SysId: SysId },
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
                            Swal.fire({
                                icon: 'success',
                                title: response.msg,
                                showConfirmButton: true
                            }).then(() => {
                                $("#TableData").DataTable().ajax.reload(null, false);
                            });
                        } else {
                            Swal.fire({
                                icon: "error",
                                title: "Warning !",
                                html: response.msg
                            });
                        }
                    },
                    error: function (xhr, status, error) {
                        Swal.close()
                        var statusCode = xhr.status;
                        var errorMessage = xhr.responseJSON && xhr.responseJSON.message ? xhr.responseJSON.message : xhr.responseText ? xhr.responseText : "there is an error : " + error;
                        Swal.fire({
                            icon: "error",
                            title: "Error!",
                            html: `Kode HTTP: ${statusCode}<br\>Pesan: ${errorMessage}`,
                        });
                    }
                });
            }
        })
    }
});