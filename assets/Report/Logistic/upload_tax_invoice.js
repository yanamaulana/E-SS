$(document).ready(function () {
    const site_url = $('meta[name="base_url"]').attr('content');

    $('#btnProcessUpload').on('click', function () {
        let fileInput = $('#fileExcel')[0];
        if (fileInput.files.length === 0) {
            Swal.fire({
                icon: 'warning',
                title: 'Oops...',
                text: 'Silakan pilih file Excel terlebih dahulu!',
            });
            return;
        }

        let formData = new FormData($('#formUploadFaktur')[0]);

        $.ajax({
            url: site_url + 'Report/Logistic/process_upload_tax_invoice', // Target controller untuk proses data
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            dataType: 'json',
            beforeSend: function () {
                $('#btnProcessUpload').prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Processing...');
            },
            success: function (response) {
                if (response.status === 'success') {
                    Swal.fire({
                        icon: 'success',
                        title: 'Berhasil!',
                        text: response.message,
                    }).then(() => {
                        // (Opsional) Reload halaman atau bersihkan form
                        location.reload();
                    });
                } else {
                    let errorHtml = response.message;

                    // Cek apakah response.details ada dan tidak kosong
                    if (response.details) {
                        errorHtml += '<br><br><ul style="text-align: left; font-size: 14px; margin-bottom: 0;">';

                        // Jika details berupa Array
                        if (Array.isArray(response.details)) {
                            response.details.forEach(function (err) {
                                errorHtml += '<li>' + err + '</li>';
                            });
                        }
                        // Jika details berupa Object (key-value)
                        else {
                            for (const key in response.details) {
                                if (response.details.hasOwnProperty(key)) {
                                    errorHtml += '<li>' + response.details[key] + '</li>';
                                }
                            }
                        }

                        errorHtml += '</ul>';
                    }

                    // Tampilkan di SweetAlert
                    Swal.fire({
                        icon: 'error',
                        title: 'Gagal!',
                        html: errorHtml,
                    });;
                }
            },
            error: function (xhr, status, error) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error Sistem',
                    text: 'Terjadi kesalahan saat menghubungi server: ' + error,
                });
            },
            complete: function () {
                $('#btnProcessUpload').prop('disabled', false).html('<i class="fas fa-cogs"></i> Proses & Simpan');
            }
        });
    });
});