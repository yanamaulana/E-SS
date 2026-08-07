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
    var lastClickedBox = null;

    var TableData = $("#TableData").DataTable({
        destroy: true,
        processing: true,
        serverSide: true,
        paging: true,
        dom: 'lBfrtip',
        orderCellsTop: true,
        select: false,
        "lengthMenu": [
            [1000, 15, 30, 100, 10000],
            [1000, 15, 30, 100, 10000]
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
        { data: "CBReq_No", name: "CBReq_No" },
        { data: "Termin_Ke", name: "Termin_Ke" },
        { data: "Type", name: "Type", visible: false },
        { data: "Amount_Type", name: "Amount_Type" },
        { data: "Document_Date", name: "Document_Date", render: function (data) { return data.substring(0, data.indexOf(' ')); } },
        { data: "Termin_Payment_Plan_Date", name: "Termin_Payment_Plan_Date", render: function (data) { return data ? data.substring(0, data.indexOf(' ')) : ''; } },
        {
            data: "Payment_Plan_Date",
            name: "Payment_Plan_Date",
            // render: function (data) { return data ? data.substring(0, data.indexOf(' ')) : ''; }
        },
        { data: "Currency_Id", name: "Currency_Id" },
        { data: "Amount", name: "Amount", render: function (data) { return parseFloat(data).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); } },
        { data: "Document_Number", name: "Document_Number" },
        { data: "Descript", name: "Descript" },
        { data: "baseamount", name: "baseamount", visible: false },
        { data: "curr_rate", name: "curr_rate", visible: false },
        { data: "Approval_Status", name: "Approval_Status", visible: false },
        {
            data: "Status_AppvPresidentDirector", name: "Status_AppvPresidentDirector", visible: false
            // render: function (data) {
            //     if (data == 0) return `<a href="javascript:void(0)" class="text-dark badge badge-warning btn-icon" title="Waiting">Waiting</a>`;
            //     if (data == 1) return `<a href="javascript:void(0)" class="badge badge-success btn-icon" title="Approved">Approved</a>`;
            //     if (data == 2) return `<a href="javascript:void(0)" class="badge badge-danger btn-icon" title="Rejected">Rejected</a>`;
            // }
        },
        {
            data: "Payment_Status", // Mengambil dari TA.Payment_Status
            name: "Payment_Status",
            render: function (data) {
                if (data == 0) return `<span class="text-dark badge badge-warning">Not Paid</span>`;
                if (data == 3) return `<span class="text-white badge badge-info" style="background-color: #17a2b8;">Partially Paid</span>`;
                if (data == 1) return `<span class="text-white badge badge-success">Fully Paid</span>`;
                if (data == 2) return `<span class="text-white badge badge-danger">Payment Rejected</span>`;
                return `<span class="text-dark badge badge-light">Unknown</span>`;
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
            // center all columns except Amount (9) and Descript (11)
            targets: [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23],
        }, {
            className: "details-control pr-4 dt-nowrap",
            targets: [1]
        }, {
            className: "dt-nowrap text-center",
            targets: [5]
        }, {
            className: "text-start",
            // Amount and Description should be left aligned
            targets: [9, 11]
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
            lastClickedBox = null;
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
            renderSummaryHTML();
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

    // 2.a Clear selection ketika filter/search berubah,
    // agar checkbox tersembunyi dari hasil pencarian sebelumnya tidak ikut ter-approve.
    TableData.on('search.dt', function () {
        selected_cbr = [];
        selected_details = {};
        $('#CheckAll').prop('checked', false);
        renderSummaryHTML();
    });

    // 3. Listener Checkbox Individu (Support SHIFT + CLICK)
    $('#TableData tbody').on('click', 'input[name="CBReq_No[]"]', function (e) {
        var $chkboxes = $('input[name="CBReq_No[]"]'); // Ambil semua checkbox di halaman aktif
        var isChecked = $(this).is(':checked');

        // JIKA USER MENEKAN TOMBOL SHIFT + KLIK (Dan sebelumnya sudah ada yg di-klik)
        if (e.shiftKey && lastClickedBox) {
            var start = $chkboxes.index(this);
            var end = $chkboxes.index(lastClickedBox);

            // Tentukan titik potong baris awal dan baris akhir
            var groupSubset = $chkboxes.slice(Math.min(start, end), Math.max(start, end) + 1);

            groupSubset.each(function () {
                var $item = $(this);
                var id = $item.val();
                var curr = $item.data('curr');
                var amount = parseFloat($item.data('amount'));

                // 1. Ubah visual centangnya mengikuti target
                $item.prop('checked', isChecked);

                // 2. Masukkan/Keluarkan dari Array sistem
                if (isChecked) {
                    if (!selected_cbr.includes(id)) {
                        selected_cbr.push(id);
                        selected_details[id] = { curr: curr, amount: amount };
                    }
                } else {
                    selected_cbr = selected_cbr.filter(val => val !== id);
                    delete selected_details[id];
                }
            });
        } else {
            // NORMAL SINGLE CLICK (Tanpa menekan Shift)
            var id = $(this).val();
            var curr = $(this).data('curr');
            var amount = parseFloat($(this).data('amount'));

            if (isChecked) {
                if (!selected_cbr.includes(id)) {
                    selected_cbr.push(id);
                    selected_details[id] = { curr: curr, amount: amount };
                }
            } else {
                selected_cbr = selected_cbr.filter(val => val !== id);
                delete selected_details[id];
            }
        }

        // Simpan elemen yang baru saja di-klik sebagai "titik pijak" untuk Shift-Click berikutnya
        lastClickedBox = this;

        updateCheckAllStatus();
        renderSummaryHTML();
    });

    // 4. Listener Tombol "Check All" di Header (Pastikan ID checkbox header Anda adalah #CheckAll)
    $('#CheckAll').on('click', function () {
        var isChecked = $(this).is(':checked');
        if (isChecked) {
            // Reset selection sebelum memilih semua baris yang sedang tampil.
            selected_cbr = [];
            selected_details = {};
        }
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



    // function renderSummaryHTML() {
    //     if (selected_cbr.length === 0) {
    //         $('#summary-container').addClass('d-none');
    //         $('#summary-text').html('');
    //         return;
    //     }

    //     // Kalkulasi Total per Currency
    //     var sums = {};
    //     for (var key in selected_details) {
    //         var item = selected_details[key];
    //         var curr = item.curr;
    //         var amount = item.amount;

    //         if (!sums[curr]) sums[curr] = 0;
    //         sums[curr] += amount;
    //     }

    //     // Generate HTML Output
    //     var htmlParts = [];
    //     for (var curr in sums) {
    //         // Format angka (ribuan separator)
    //         var formattedAmount = sums[curr].toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    //         htmlParts.push(`<span class="badge badge-light-primary fs-6 me-2 mb-1 border border-primary text-primary">${curr} : ${formattedAmount}</span>`);
    //     }

    //     $('#summary-text').html(htmlParts.join(' '));
    //     $('#summary-container').removeClass('d-none');
    // }

    function renderSummaryHTML() {
        // --- 1. Hitung Total ALL (Semua baris yang tampil di tabel saat ini) ---
        var sumsAll = {};
        // Kita ambil semua data dari instance DataTable yang sedang tampil
        var allData = $("#TableData").DataTable().rows().data();

        allData.each(function (row) {
            var curr = row.Currency_Id;
            var amount = parseFloat(row.Amount) || 0;

            if (!sumsAll[curr]) sumsAll[curr] = 0;
            sumsAll[curr] += amount;
        });

        // --- 2. Hitung Total SELECTED (Dari array selected_details) ---
        var sumsSelected = {};
        for (var key in selected_details) {
            var item = selected_details[key];
            if (!sumsSelected[item.curr]) sumsSelected[item.curr] = 0;
            sumsSelected[item.curr] += item.amount;
        }

        // --- 3. Generate Tampilan Perbandingan ---
        var htmlParts = [];

        // Kita looping berdasarkan Currency yang ditemukan di tabel
        Object.keys(sumsAll).forEach(function (curr) {
            var totalAll = sumsAll[curr];
            var totalSelected = sumsSelected[curr] || 0;

            var fmtAll = totalAll.toLocaleString('en-US', { minimumFractionDigits: 2 });
            var fmtSelected = totalSelected.toLocaleString('en-US', { minimumFractionDigits: 2 });

            // Tampilan Card Kecil
            htmlParts.push(`
            <div class="badge badge-light border border-secondary me-2 mb-2 p-3 text-start shadow-sm">
                <div class="fw-bolder text-dark fs-6 border-bottom mb-1">${curr}</div>
                <div class="text-primary">
                    <i class="fas fa-check-square me-1"></i> Selected: <b>${fmtSelected}</b>
                </div>
                <div class="text-dark fs-8 mt-3">
                    <i class="fas fa-list me-1"></i> Outstanding Balance: ${fmtAll}
                </div>
            </div>
        `);
        });

        if (htmlParts.length > 0) {
            $('#summary-text').html(htmlParts.join(''));
            $('#summary-container').removeClass('d-none');
        } else {
            $('#summary-container').addClass('d-none');
        }
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