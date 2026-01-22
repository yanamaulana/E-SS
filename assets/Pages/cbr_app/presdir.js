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

    // 1. Variabel Global Penampung ID
    var selected_cbr = [];
    var selected_details = {};

    var TableData = $("#TableData").DataTable({
        destroy: true,
        processing: true,
        serverSide: true,
        paging: true,
        dom: 'lBfrtip',
        orderCellsTop: true,
        select: false,
        "lengthMenu": [
            [15, 30, 90, 100],
            [15, 30, 90, 100]
        ],
        ajax: {
            url: $('meta[name="base_url"]').attr('content') + "CbrAppPresidentDirector/DT_List_To_Approve",
            dataType: "json",
            type: "POST",
        },
        columns: [{
            data: 'CBReq_No',
            name: "CheckBox",
            orderable: false,
            render: function (data, type, row, meta) {
                var isChecked = selected_cbr.includes(row.CBReq_No) ? 'checked' : '';
                // 🔥 TAMBAHKAN data-curr dan data-amount DI SINI
                return `<div class="form-check">
            <input class="form-check-input row-checkbox" type="checkbox" 
                value="${row.CBReq_No}" 
                id="${row.CBReq_No}" 
                name="CBReq_No[]" 
                ${isChecked}
                data-curr="${row.Currency_Id}" 
                data-amount="${row.Amount}">
          </div>`
            }
        },
        // ... (Kolom-kolom lain tetap sama, saya persingkat agar fokus ke logika) ...
        { data: "CBReq_No", name: "CBReq_No" },
        { data: "Type", name: "Type", visible: false },
        { data: "Document_Date", name: "Document_Date", render: function (data) { return data.substring(0, data.indexOf(' ')); } },
        { data: "Currency_Id", name: "Currency_Id" },
        { data: "Amount", name: "Amount", render: function (data) { return parseFloat(data).toLocaleString('en-US', { minimumFractionDigits: 4, maximumFractionDigits: 4 }); } },
        { data: "Document_Number", name: "Document_Number" },
        { data: "Descript", name: "Descript" },
        { data: "baseamount", name: "baseamount", visible: false },
        { data: "curr_rate", name: "curr_rate", visible: false },
        { data: "Approval_Status", name: "Approval_Status", visible: false },
        {
            data: "Status_AppvPresidentDirector", name: "Status_AppvPresidentDirector", render: function (data) {
                if (data == 0) return `<a href="javascript:void(0)" class="text-dark badge badge-warning btn-icon" title="Waiting">Waiting</a>`;
                if (data == 1) return `<a href="javascript:void(0)" class="badge badge-success btn-icon" title="Approved">Approved</a>`;
                if (data == 2) return `<a href="javascript:void(0)" class="badge badge-danger btn-icon" title="Rejected">Rejected</a>`;
            }
        },
        {
            data: "Payment_Status", name: "Payment_Status", render: function (data) {
                if (data == 0) return `<span class="text-dark badge badge-warning">Pending Payment</span>`;
                if (data == 1) return `<span class="text-white badge badge-success">Paid</span>`;
                return `<span class="text-white badge badge-danger">Payment Rejected</span>`;
            }
        },
        { data: "Creation_DateTime", name: "Creation_DateTime", visible: false },
        { data: "Created_By", name: "Created_By", visible: false },
        { data: "UserDivision", name: "UserDivision" },
        { data: "First_Name", name: "First_Name" },
        { data: "Last_Update", name: "Last_Update", visible: false },
        { data: "Acc_ID", name: "Acc_ID", visible: false },
        { data: "Approve_Date", name: "Approve_Date", visible: false }
        ],
        order: [
            [3, "DESC"]
        ],
        columnDefs: [{
            className: "text-center",
            targets: [0, 2, 3, 4, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
        }, {
            className: "details-control pr-4 dt-nowrap",
            targets: [1]
        }, {
            className: "dt-nowrap",
            targets: [6]
        }],
        autoWidth: false,
        responsive: false,
        preDrawCallback: function () {
            $("#TableData tbody td").addClass("blurry");
        },
        language: {
            processing: '<i style="color:#4a4a4a" class="fa fa-spinner fa-spin fa-3x fa-fw"></i><span class="sr-only"></span><p><span style="color:#4a4a4a" style="text-align:center" class="loading-text"></span> ',
            searchPlaceholder: "Search..."
        },
        // 2. Draw Callback: Menjaga konsistensi visual saat pindah page
        drawCallback: function () {
            $("#TableData tbody td").addClass("blurry");
            setTimeout(function () {
                $("#TableData tbody td").removeClass("blurry");
            });
            $('[data-bs-toggle="tooltip"]').tooltip();

            // Loop semua checkbox di halaman aktif, sinkronkan dengan array selected_cbr
            $('input[name="CBReq_No[]"]').each(function () {
                var id = $(this).val();
                if (selected_cbr.includes(id)) {
                    $(this).prop('checked', true);
                } else {
                    $(this).prop('checked', false);
                }
            });

            // Update status tombol "Check All" di header
            updateCheckAllStatus();
        },
        "buttons": [{
            text: `<i class="fas fa-check"></i> Approve`,
            className: "btn btn-success",
            action: function (e, dt, node, config) {
                // Panggil fungsi dengan array selected_cbr
                if (selected_cbr.length === 0) {
                    return Swal.fire('Error', 'Please select at least one item!', 'error');
                }

                Swal.fire({
                    title: 'System Message !',
                    text: `Are you sure to approve ${selected_cbr.length} selected submission(s)?`,
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Yes'
                }).then((result) => {
                    if (result.isConfirmed) {
                        Fn_Approve_Submission();
                    }
                })
            }
        },
        {
            text: `-`,
            className: "btn btn-default btn-icon disabled",
        },
        {
            text: `<i class="fas fa-times text-white fs-3"></i> Reject`,
            className: "btn btn-danger",
            action: function (e, dt, node, config) {
                if (selected_cbr.length === 0) {
                    return Swal.fire('Error', 'Please select at least one item!', 'error');
                }

                Swal.fire({
                    title: 'System Message',
                    text: `Please provide reason for rejecting ${selected_cbr.length} submission(s):`,
                    input: 'textarea',
                    inputLabel: 'Rejection Reason (Required)',
                    inputPlaceholder: 'Enter your justification here...',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#d33',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: 'Yes, Reject',
                    inputValidator: (value) => {
                        if (!value || value.trim() === '') {
                            return 'You must enter a reason for rejection!';
                        }
                    }
                }).then((result) => {
                    if (result.isConfirmed) {
                        Fn_Reject_Submission(result.value);
                    }
                });
            }
        }],
    }).buttons().container().appendTo('#TableData_wrapper .col-md-6:eq(0)');

    // 3. Listener Checkbox Individu
    $('#TableData tbody').on('click', 'input[name="CBReq_No[]"]', function () {
        var id = $(this).val();
        var isChecked = $(this).is(':checked');

        // 🔥 AMBIL DATA DARI ATRIBUT LANGSUNG (Lebih Stabil)
        var curr = $(this).data('curr');
        var amount = parseFloat($(this).data('amount'));

        if (isChecked) {
            if (!selected_cbr.includes(id)) {
                selected_cbr.push(id);
                // Simpan detail
                selected_details[id] = {
                    curr: curr,
                    amount: amount
                };
            }
        } else {
            selected_cbr = selected_cbr.filter(item => item !== id);
            // Hapus detail
            delete selected_details[id];
        }

        updateCheckAllStatus();
        renderSummaryHTML(); // Hitung ulang total
    });

    // 4. Listener Tombol "Check All" di Header (Pastikan ID checkbox header Anda adalah #CheckAll)
    $('#CheckAll').on('click', function () {
        var isChecked = $(this).is(':checked');
        check_uncheck_checkbox(isChecked);
    });

    function check_uncheck_checkbox(isChecked) {
        $('input[name="CBReq_No[]"]').each(function () {
            var id = $(this).val();

            // 🔥 AMBIL DATA DARI ATRIBUT LANGSUNG
            var curr = $(this).data('curr');
            var amount = parseFloat($(this).data('amount'));

            // Update visual
            $(this).prop('checked', isChecked);

            // Update Logic Array
            if (isChecked) {
                if (!selected_cbr.includes(id)) {
                    selected_cbr.push(id);
                    selected_details[id] = {
                        curr: curr,
                        amount: amount
                    };
                }
            } else {
                selected_cbr = selected_cbr.filter(item => item !== id);
                delete selected_details[id];
            }
        });
        renderSummaryHTML();
    }

    function renderSummaryHTML() {
        if (selected_cbr.length === 0) {
            $('#summary-container').addClass('d-none');
            $('#summary-text').html('');
            return;
        }

        // Kalkulasi Total per Currency
        var sums = {};
        for (var key in selected_details) {
            var item = selected_details[key];
            var curr = item.curr;
            var amount = item.amount;

            if (!sums[curr]) sums[curr] = 0;
            sums[curr] += amount;
        }

        // Generate HTML Output
        var htmlParts = [];
        for (var curr in sums) {
            // Format angka (ribuan separator)
            var formattedAmount = sums[curr].toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            htmlParts.push(`<span class="badge badge-light-primary fs-6 me-2 mb-1 border border-primary text-primary">${curr} : ${formattedAmount}</span>`);
        }

        $('#summary-text').html(htmlParts.join(' '));
        $('#summary-container').removeClass('d-none');
    }

    function updateCheckAllStatus() {
        var allCheckedInPage = true;
        var checkboxes = $('input[name="CBReq_No[]"]');

        if (checkboxes.length === 0) {
            allCheckedInPage = false;
        } else {
            checkboxes.each(function () {
                if (!$(this).prop('checked')) {
                    allCheckedInPage = false;
                }
            });
        }
        $('#CheckAll').prop('checked', allCheckedInPage);
    }

    function Fn_Approve_Submission() {
        // Validasi menggunakan length array, bukan DOM element
        if (selected_cbr.length == 0) {
            return Swal.fire({ icon: 'error', title: 'Oops...', text: 'You need check the submission first !' });
        }

        $.ajax({
            dataType: "json",
            type: "POST",
            url: $('meta[name="base_url"]').attr('content') + "CbrAppPresidentDirector/approve_submission",
            data: { "CBReq_No": selected_cbr }, // Kirim array ID
            beforeSend: function () {
                Swal.fire({ title: 'Loading....', html: '<div class="spinner-border text-primary"></div>', showConfirmButton: false, allowOutsideClick: false })
            },
            success: function (response) {
                Swal.close()
                if (response.code == 200) {
                    Toast.fire({ icon: 'success', title: response.msg });
                    selected_cbr = [];
                    selected_details = {}; // RESET DETAIL JUGA
                    renderSummaryHTML();   // HILANGKAN SUMMARY
                    $('#CheckAll').prop('checked', false);
                    $('#TableData').DataTable().ajax.reload(null, false);
                    $("#TableDataHistory").DataTable().ajax.reload(null, false);
                } else {
                    Toast.fire({ icon: 'error', title: response.msg });
                }
            },
            error: function (xhr, status, error) {
                Swal.fire({ icon: "error", title: "Error!", text: "Terjadi kesalahan server." });
            }
        });
    }

    function Fn_Reject_Submission(rejectionReason) {
        if (selected_cbr.length == 0) {
            return Swal.fire({ icon: 'error', title: 'Oops...', text: 'You need check the submission first !' });
        }

        $.ajax({
            dataType: "json",
            type: "POST",
            url: $('meta[name="base_url"]').attr('content') + "CbrAppPresidentDirector/reject_submission",
            data: {
                "CBReq_No": selected_cbr,
                "rejection_reason": rejectionReason
            },
            beforeSend: function () {
                Swal.fire({ title: 'Loading....', html: '<div class="spinner-border text-primary"></div>', showConfirmButton: false, allowOutsideClick: false })
            },
            success: function (response) {
                Swal.close()
                if (response.code == 200) {
                    Toast.fire({ icon: 'success', title: response.msg });
                    selected_cbr = [];
                    selected_details = {}; // RESET DETAIL JUGA
                    renderSummaryHTML();   // HILANGKAN SUMMARY
                    $('#CheckAll').prop('checked', false);
                    $('#TableData').DataTable().ajax.reload(null, false);
                    $("#TableDataHistory").DataTable().ajax.reload(null, false);
                } else {
                    Toast.fire({ icon: 'error', title: response.msg });
                }
            },
            error: function (xhr, status, error) {
                Swal.fire({ icon: "error", title: "Error!", text: "Terjadi kesalahan server." });
            }
        });
    }
});