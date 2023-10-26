<div class="modal fade" id="ModalAttachment" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="ModalAttachmentLabel" aria-hidden="true">
    <div class="modal-dialog">
        <!-- modal-lg -->
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="ModalAttachmentLabel">Upload Attachment : <?= $CbrNo; ?></h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="form-attachment" enctype="multipart/form-data" method="post">
                    <input type="hidden" name="CbrNo" id="CbrNo" value="<?= $CbrNo; ?>">
                    <div class="mt-1 fv-row">
                        <label for="attachment" class="form-label font-weight-bold"><b>Choose Attachment :</b></label>
                        <input type="file" accept="image/jpeg,image/png,application/pdf" required class="form-control form-control-sm" name="attachment" id="attachment" placeholder="Choose file attachment....">
                    </div>
                    <div class="mt-5 fv-row">
                        <label for="attachment" class="form-label font-weight-bold"><b>Note Attachment :</b></label>
                        <textarea rows="2" required class="form-control form-control-sm" name="note" id="note" placeholder="Note attachment...."></textarea>
                    </div>
                    <?php if ($Attachments->num_rows() > 0) : ?>
                        <hr />
                        <div class="mt-3 table-responsive">
                            <table class="table-sm table-striped table-hover table-bordered w-100">
                                <thead>
                                    <tr style="background-color: #CFE2FF;">
                                        <th class="text-center">#</th>
                                        <th class="text-center">File Name</th>
                                        <th class="text-center">Description</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php $i = 1; ?>
                                    <?php foreach ($Attachments->result() as $li) : ?>
                                        <tr>
                                            <td class="text-center"><?= $i; ?></td>
                                            <td class=""><?= $li->Attachment_FileName; ?></td>
                                            <td class=""><?= $li->Note; ?></td>
                                        </tr>
                                        <?php $i++; ?>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    <?php endif; ?>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-danger" data-bs-dismiss="modal"><i class="fas fa-times"></i> Close</button>
                <button type="button" id="submit--data" class="btn btn-sm btn-primary float-end"><i class="fas fa-folder"></i> Submit</button>
            </div>
        </div>
    </div>
</div>
<script>
    $(document).ready(function() {
        const Toast = Swal.mixin({
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 4000,
            timerProgressBar: true,
            didOpen: (toast) => {
                toast.addEventListener('mouseenter', Swal.stopTimer)
                toast.addEventListener('mouseleave', Swal.resumeTimer)
            }
        })

        const main_form = $('#form-attachment')
        main_form.validate({
            errorElement: 'span',
            errorPlacement: function(error, element) {
                error.addClass('invalid-feedback');
                element.closest('.fv-row').append(error);
            },
            highlight: function(element, errorClass, validClass) {
                $(element).addClass('is-invalid');
            },
            unhighlight: function(element, errorClass, validClass) {
                $(element).removeClass('is-invalid');
            }
        });
        $.validator.setDefaults({
            debug: true,
            success: 'valid'
        });

        $('#submit--data').click(function(e) {
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
                    if (result.isConfirmed == true) {
                        Init_Submit_Form(main_form)
                    }
                })
            } else {
                $('html, body').animate({
                    scrollTop: ($('.error:visible').offset().top - 200)
                }, 400);
            }
        });

        function Init_Submit_Form(main_form) {
            let BtnAction = $('#submit--data');
            $.ajax({
                dataType: "json",
                type: "POST",
                url: $('meta[name="base_url"]').attr('content') + "MyCbr/store_attachment",
                data: new FormData(main_form[0]),
                processData: false,
                contentType: false,
                beforeSend: function() {
                    BtnAction.prop("disabled", true);
                    Swal.fire({
                        title: 'Loading....',
                        html: '<div class="spinner-border text-primary"></div>',
                        showConfirmButton: false,
                        allowOutsideClick: false,
                        allowEscapeKey: false
                    })
                },
                success: function(response) {
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
                error: function(xhr, status, error) {
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
    });
</script>