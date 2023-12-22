$(document).ready(function () {
    $('.date-picker').flatpickr();

    $('#Generate').on('click', function () {
        window.open($('meta[name="base_url"]').attr('content') + "Report/Logistic/Rpt_eta_purchase_order?" +
            // "SelLocation=" + $('[name="SelLocation"]').val() +
            // "&selCatType=" + $('[name="selCatType"]').val() +
            "&from=" + $('[name="from"]').val() +
            "&until=" + $('[name="until"]').val(), 'WindowReportPdf', 'width=800,height=600');
    });
})