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

    const main_form = $('#main-form')
    main_form.validate({
        errorElement: 'span',
        errorPlacement: function (error, element) {
            error.addClass('invalid-feedback');
            element.closest('.fv-row').append(error);
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
            url: $('meta[name="base_url"]').attr('content') + "Set_StepApprovalCbr/store",
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
                    Toast.fire({
                        icon: 'success',
                        title: response.msg
                    });
                } else {
                    Toast.fire({
                        icon: 'error',
                        title: response.msg
                    });
                }
                BtnAction.prop("disabled", false);
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
})