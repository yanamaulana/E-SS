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

    $('.date-picker').flatpickr();

    $('#selCurrency').on('change', function () {
        document.location.href = $('meta[name="base_url"]').attr('content') + "Report/Sales/OstSO_v_Bom_v_StokMtrl?SelCurr=" + $(this).val()
    })

    $('#Pdf').on('click', function () {
        window.open($('meta[name="base_url"]').attr('content') +
            "Report/Sales/Rpt_OstSO_v_Bom_v_StokMtrl?" +
            "customer=" + $('[name="customer"]').val() +
            "&sales_type=" + $('[name="sales_type"]').val() +
            "&from=" + $('[name="from"]').val() +
            "&until=" + $('[name="until"]').val() +
            "&rdocurrency=" + $('[name="rdocurrency"]').val() +
            "&selCurrency=" + $('[name="selCurrency"]').val() +
            "&TxtUSD=" + $('[name="TxtUSD"]').val() +
            "&TxtEUR=" + $('[name="TxtEUR"]').val() +
            "&TxtAUD=" + $('[name="TxtAUD"]').val() +
            "&TxtSGD=" + $('[name="TxtSGD"]').val() +
            "&TxtKRW=" + $('[name="TxtKRW"]').val() +
            "&TxtJPY=" + $('[name="TxtJPY"]').val() +
            "&TxtGBP=" + $('[name="TxtGBP"]').val() +
            "&report_type=" + $(this).val(), 'WindowReportPdf', 'width=800,height=600');
    });
    $('#Excel').on('click', function () {
        window.open($('meta[name="base_url"]').attr('content') +
            "Report/Sales/Rpt_OstSO_v_Bom_v_StokMtrl?" +
            "customer=" + $('[name="customer"]').val() +
            "&sales_type=" + $('[name="sales_type"]').val() +
            "&from=" + $('[name="from"]').val() +
            "&until=" + $('[name="until"]').val() +
            "&rdocurrency=" + $('[name="rdocurrency"]').val() +
            "&selCurrency=" + $('[name="selCurrency"]').val() +
            "&TxtUSD=" + $('[name="TxtUSD"]').val() +
            "&TxtEUR=" + $('[name="TxtEUR"]').val() +
            "&TxtAUD=" + $('[name="TxtAUD"]').val() +
            "&TxtSGD=" + $('[name="TxtSGD"]').val() +
            "&TxtKRW=" + $('[name="TxtKRW"]').val() +
            "&TxtJPY=" + $('[name="TxtJPY"]').val() +
            "&TxtGBP=" + $('[name="TxtGBP"]').val() +
            "&report_type=" + $(this).val(), 'WindowReportExcel', 'width=800,height=600');
    });
})