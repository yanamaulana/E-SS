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

    $('#Pdf').on('click', function () {
        window.open($('meta[name="base_url"]').attr('content') +
            "Report/Sales/Rpt_ostpo_rawmaterial?" +
            "customer=" + $('[name="customer"]').val() +
            "&sales_type=" + $('[name="sales_type"]').val() +
            "&from=" + $('[name="from"]').val() +
            "&until=" + $('[name="until"]').val() +
            "&report_type=" + $(this).val(), 'WindowReportPdf', 'width=800,height=600');
    });
})