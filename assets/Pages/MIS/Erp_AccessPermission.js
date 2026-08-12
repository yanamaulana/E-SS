$(document).ready(function () {
    const site_url = $('meta[name="base_url"]').attr('content');

    // Inisialisasi Select2 pada dropdown filter
    $('.select2-filter').select2({
        theme: 'bootstrap5',
        width: '100%'
    });

    // --- 1. INISIALISASI DATATABLE ---
    var table = $('#table_erp_access').DataTable({
        processing: true,
        serverSide: true,
        pageLength: 30,
        lengthMenu: [
            [30, 10, 25, 100, -1],
            ['30 Baris', '10', '25', '100', 'Semua']
        ],
        dom: '<"row mb-3"<"col-sm-12">><"row"<"col-sm-11"f><"col-sm-1"l>>rtip',
        ajax: {
            url: site_url + "Report/MIS/DT_ERP_AccessPermission",
            type: "POST",
            data: function (d) {
                d.usergroup_id = $('#filter_usergroup').val();
                d.function_id = $('#filter_function').val();
            }
        },
        columns: [
            {
                data: 'UserGroupFuncL_ID',
                name: 'UserGroupFuncL_ID',
                visible: false
            },
            {
                data: 'UserGroup_Name',
                name: 'UserGroup_Name'
            },
            {
                data: 'SF_UFUNC_NAME_EN',
                name: 'SF_UFUNC_NAME_EN'
            },
            {
                data: 'sf_ufunc_access',
                name: 'sf_ufunc_access',
                searchable: false,
                className: 'text-center',
                render: function (data, type, row) {
                    let checked = (data && data.toLowerCase() === 'delete') ? 'checked' : '';
                    return `<div class="form-check form-switch d-flex justify-content-center">
                                <input class="form-check-input access-switch" type="checkbox" data-id="${row.UserGroupFuncL_ID}" ${checked}>
                            </div>`;
                }
            },
            {
                data: 'isLog',
                name: 'isLog',
                className: 'text-center',
                render: function (data, type, row) {
                    return (data == 1) ? '<span class="badge badge-light-success">Ya</span>' : '<span class="badge badge-light-danger">Tidak</span>';
                }
            }
        ],
        order: [[1, 'asc'], [2, 'asc']]
    });

    $('#btn_filter').on('click', function () {
        table.ajax.reload(); // Muat ulang data tabel dengan filter baru
    });

    // --- 3. EVENT SAAT SWITCH AKSES DIUBAH ---
    $('#table_erp_access tbody').on('change', '.access-switch', function () {
        let id = $(this).data('id');
        let hasAccess = $(this).is(':checked');

        $.ajax({
            url: site_url + 'Report/MIS/update_access_permission',
            type: 'POST',
            dataType: 'json',
            data: {
                id: id,
                access: hasAccess
            },
            success: function (response) {
                if (response.status === 'success') {
                    Swal.fire({
                        toast: true,
                        position: 'top-end',
                        icon: 'success',
                        title: response.message,
                        showConfirmButton: false,
                        timer: 1500
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Update Gagal',
                        text: response.message
                    });
                    // Kembalikan posisi switch jika update gagal
                    $(this).prop('checked', !hasAccess);
                }
            },
            error: function () {
                Swal.fire({
                    icon: 'error',
                    title: 'Oops...',
                    text: 'Terjadi kesalahan saat mengirim permintaan!'
                });
                // Kembalikan posisi switch jika error
                $(this).prop('checked', !hasAccess);
            }
        });
    });

});