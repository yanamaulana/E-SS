$(document).ready(function () {
    // Membuat objek Date untuk mendapatkan tanggal hari ini
    var today = new Date();

    // Mendapatkan tahun, bulan, dan tanggal dari objek Date
    var year = today.getFullYear();
    var month = ('0' + (today.getMonth() + 1)).slice(-2); // Ditambah 1 karena bulan dimulai dari 0
    var day = ('0' + today.getDate()).slice(-2);

    // Menggabungkan tahun, bulan, dan tanggal dengan format YYYY-MM-DD
    var formattedDate = year + '-' + month + '-' + day;

    $('.date-picker').flatpickr({
        minDate: formattedDate,
        maxDate: formattedDate
    });


    $('#Generate').on('click', function () {
        let SelLocation = $('#SelLocation').val();
        let DatePeriod = $('#DatePeriod').val();
        let selCatType = $('#selCatType').val();
        let item_code = $('#item_code').val();
        let Category = $('#Category').val();
        let Gudang = $('#Gudang').val();

        if (!SelLocation || SelLocation.trim() === '') {

        }


        window.location.href = $('meta[name="base_url"]').attr('content') + `Opname/Generate?SelLocation=${SelLocation}&DatePeriod=${DatePeriod}&selCatType=${selCatType}&item_code=${item_code}&Category=${Category}&Gudang=${Gudang}`;
    })

})

function Initialize_select2_category(el_selCatType) {
    $('#Category').val('ALL').trigger('change');

    $('#Category').select2({
        minimumInputLength: 0,
        allowClear: true,
        cache: true,
        ajax: {
            dataType: 'json',
            url: $('meta[name="base_url"]').attr('content') + `Opname/select2_category?selCatType=${el_selCatType}`,
            delay: 800,
            data: function (params) {
                return {
                    search: params.term
                }
            },
            processResults: function (data, page) {
                return {
                    results: $.map(data, function (obj) {
                        return {
                            id: obj.id,
                            text: obj.text
                        };
                    })
                };
            },
        }
    })
}

function Initialize_select2_bin(el_location) {
    if (el_location != 1) {
        $('#Gudang').val(null).trigger('change');
    } else {
        $('#Gudang').val(1).trigger('change');
    }

    $('#Gudang').select2({
        minimumInputLength: 0,
        allowClear: true,
        cache: true,
        ajax: {
            dataType: 'json',
            url: $('meta[name="base_url"]').attr('content') + `Opname/select2_bin?location=${el_location}`,
            delay: 800,
            data: function (params) {
                return {
                    search: params.term
                }
            },
            processResults: function (data, page) {
                return {
                    results: $.map(data, function (obj) {
                        return {
                            id: obj.id,
                            text: obj.text
                        };
                    })
                };
            },
        }
    })
}

Initialize_select2_category('SP')
Initialize_select2_bin(1)
