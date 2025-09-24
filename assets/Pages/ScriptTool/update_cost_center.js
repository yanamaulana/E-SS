$(document).ready(function () {

    var main_form = $('#main-form');
    main_form.validate({
        errorElement: 'span',
        errorPlacement: function (error, element) {
            error.addClass('invalid-feedback');
            element.closest('.el-validation').append(error);
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

    $('#submit-main-form').click(function (e) {
        e.preventDefault();
        if (main_form.valid()) {
            Swal.fire({
                title: 'Loading....',
                html: '<div class="spinner-border text-primary"></div>',
                showConfirmButton: false,
                allowOutsideClick: false,
                allowEscapeKey: false
            });
            let formData = new FormData(main_form[0]);
            Fn_Submit_Main_Form(formData)
        } else {
            $('html, body').animate({
                scrollTop: ($('.error:visible').offset().top - 200)
            }, 400);
        }
    });

    function Fn_Submit_Main_Form(DataForm) {
        $.ajax({
            dataType: "json",
            type: "POST",
            url: $('meta[name="base_url"]').attr('content') + "ScriptTool/store_update_costcenter",
            processData: false,
            contentType: false,
            data: DataForm,
            success: function (response) {
                Swal.close()
                if (response.code == 200) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: response.msg,
                        didClose: () => {
                            Fn_reset_form();
                        }
                    })
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Oops...',
                        text: response.msg,
                        footer: '<a href="javascript:void(0)">Notifikasi System</a>'
                    });
                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                Swal.close();
                let errorMessage = 'Terjadi kesalahan teknis. Harap lapor admin!';
                if (jqXHR.responseJSON && jqXHR.responseJSON.msg) {
                    errorMessage = jqXHR.responseJSON.msg;
                } else if (errorThrown) {
                    errorMessage = errorThrown;
                } else if (textStatus) {
                    errorMessage = textStatus;
                }

                Swal.fire({
                    icon: 'error',
                    title: 'Oops...',
                    text: errorMessage,
                    footer: '<a href="javascript:void(0)">Notifikasi System</a>'
                });
            }
        });
    }

    function Fn_reset_form() {
        main_form[0].reset();
        $('#CostCenter').val(null).trigger('change');
    }

})