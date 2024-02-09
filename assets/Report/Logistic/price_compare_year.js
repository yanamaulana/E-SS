$(document).ready(function () {
    $('.date-picker').daterangepicker({
        singleDatePicker: true,
        showDropdowns: true,
        locale: {
            format: "YYYY-MM"
        }
    }).on('hide.daterangepicker', function (ev, picker) {
        $('.table-condensed tbody tr:nth-child(2) td').click();
    });

    $('#Generate').click(function () {
        window.open($('meta[name="base_url"]').attr('content') + "Report/Logistic/rpt_comparison_price_last_year?" +
            "&year=" + $('[name="year"]').val() +
            "&month=" + $('[name="month"]').val(), 'WindowReportPdf', 'width=800,height=600');
    })
});
