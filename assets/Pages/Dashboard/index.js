$(document).ready(function () {

    var site_url = $('meta[name="base_url"]').attr('content');
    $('#btn_search_history').on('click', function () {
        var $btn = $(this);

        // 1. Mekanisme Disable & Animasi Loading (15 Detik)
        $btn.prop('disabled', true);
        var originalText = $btn.html(); // Simpan teks tombol asli

        // Ganti teks/isi tombol dengan indikator loading (Bootstrap / Metronic style)
        $btn.html('<span class="spinner-border spinner-border-sm align-middle me-2"></span>Loading...');

        setTimeout(function () {
            $btn.prop('disabled', false);
            $btn.html(originalText); // Kembalikan teks asli tombol
        }, 5000); // 15000 milidetik = 15 detik

        // Ambil nilai tahun dan bulan dari dropdown
        var selectedYear = $('#year_hist').val();
        var selectedMonth = $('#month_hist').val();

        $.ajax({
            url: $('meta[name="base_url"]').attr('content') + 'Dashboard/get_history_data',
            type: 'POST',
            data: {
                year: selectedYear,
                month: selectedMonth
            },
            dataType: 'json',
            success: function (response) {
                // Kosongkan komponen tabel lama sebelum render baru
                $('#history_head').empty();
                $('#history_body').empty();

                var currencies = response.currencies; // Array: ['IDR', 'USD', ...]
                var divisions = response.divisions;   // Object/Associative Array

                // Cek apakah data objek divisions kosong atau tidak
                if (Object.keys(divisions).length > 0) {

                    // ==========================================
                    // A. MEMBUAT HEADER TABEL Secara Dinamis
                    // ==========================================
                    var headRow = '<tr class="fw-bolder text-muted">';
                    headRow += '<th class="w-25px">';
                    headRow += '    <div class="form-check form-check-sm form-check-custom form-check-solid">';
                    headRow += '        <input class="form-check-input" type="checkbox" disabled value="1" data-kt-check="true" data-kt-check-target=".widget-9-check">';
                    headRow += '    </div>';
                    headRow += '</th>';
                    headRow += '<th>Division</th>';
                    headRow += '<th>Total CBRs</th>';

                    // Tambah kolom Header untuk tiap mata uang yang ditemukan
                    $.each(currencies, function (index, curr) {
                        headRow += '<th>Amount ' + curr + '</th>';
                    });

                    headRow += '</tr>';
                    $('#history_head').append(headRow);


                    // ++ TAMBAHAN UNTUK TOTAL: Siapkan variabel penampung ++
                    var grandTotalCBRs = 0;
                    var grandTotalAmounts = {};
                    $.each(currencies, function (index, curr) {
                        grandTotalAmounts[curr] = 0; // Setel nilai awal tiap mata uang jadi 0
                    });
                    // ++ AKHIR TAMBAHAN ++


                    // ==========================================
                    // B. MEMBUAT BODY TABEL Secara Dinamis
                    // ==========================================
                    $('#history_body').html('<tr id="loader_body"><td colspan="5" class="text-center"><span class="spinner-border spinner-border-sm align-middle me-2"></span>Loading data...</td></tr>');
                    $.each(divisions, function (divName, divData) {
                        var image_name = divName.replace(/ /g, "_");

                        // ++ TAMBAHAN UNTUK TOTAL: Jumlahkan Total CBRs ++
                        grandTotalCBRs += parseInt(divData.Total_CBRs) || 0;
                        // ++ AKHIR TAMBAHAN ++

                        var bodyRow = '<tr>';
                        bodyRow += '<td><span class="bullet bullet-vertical h-40px bg-success"></span></td>';
                        bodyRow += `<td>
                                        <div class="d-flex align-items-center">
                                            <div class="symbol symbol-45px me-5">
                                                <img src="${site_url}assets/media/Department/${image_name}.png" alt="${divName}">
                                            </div>
                                            <div class="d-flex justify-content-start flex-column">
                                                <span href="#" class="text-dark fw-bolder text-hover-primary fs-6">${divName}</span>
                                                <span class="text-muted fw-bold text-muted d-block fs-7">Department</span>
                                            </div>
                                        </div>
                                    </td>`;
                        bodyRow += `<td>
                                        <span href="#" class="text-dark fw-bolder text-hover-primary d-block fs-6">${divData.Total_CBRs}</span>
                                        <span class="text-muted fw-bold text-muted d-block fs-7">Total Cbr Submitted</span>
                                    </td>`;

                        // Looping berdasarkan master daftar mata uang agar kolomnya konsisten menyamping
                        $.each(currencies, function (index, curr) {
                            var amount = 0;
                            // Cek apakah divisi ini memiliki nominal untuk mata uang terkait
                            if (divData.Amounts && divData.Amounts[curr] !== undefined) {
                                amount = parseFloat(divData.Amounts[curr]) || 0;
                            }

                            // ++ TAMBAHAN UNTUK TOTAL: Tambahkan ke total mata uang terkait ++
                            grandTotalAmounts[curr] += amount;
                            // ++ AKHIR TAMBAHAN ++

                            // Format angka desimal sesuai mata uang (IDR/JPY tanpa desimal, selain itu 2 desimal)
                            var formattedAmount = "";
                            if (curr === 'IDR' || curr === 'JPY') {
                                formattedAmount = Number(amount).toLocaleString('id-ID', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
                            } else {
                                formattedAmount = Number(amount).toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                            }

                            bodyRow += '<td>' + formattedAmount + '</td>';
                        });

                        bodyRow += '</tr>';
                        // tampilkan juga loader di tbl_history_body untuk indikasi sedang memuat data
                        setTimeout(function () {
                            $('#history_body').append(bodyRow);
                        }, 3500);

                    });


                    // ==========================================
                    // C. MEMBUAT BARIS TOTAL DI BAWAH (FOOTER)
                    // ==========================================
                    // ++ TAMBAHAN UNTUK TOTAL: Render baris Total ++
                    var totalRow = '<tr class="bg-light fw-bolder text-dark">'; // Background agak abu agar beda
                    totalRow += '<td></td>'; // Kolom 1 (Checkbox/Bullet) kosong
                    totalRow += '<td class="text-end pe-5 fs-5">GRAND TOTAL :</td>'; // Label
                    totalRow += '<td class="fs-5">' + grandTotalCBRs + '</td>'; // Print Grand Total CBRs

                    // Looping format untuk Grand Total per Currency
                    $.each(currencies, function (index, curr) {
                        var totalAmt = grandTotalAmounts[curr];
                        var formattedTotalAmt = "";

                        if (curr === 'IDR' || curr === 'JPY') {
                            formattedTotalAmt = Number(totalAmt).toLocaleString('id-ID', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
                        } else {
                            formattedTotalAmt = Number(totalAmt).toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                        }

                        totalRow += '<td class="fs-5">' + formattedTotalAmt + '</td>';
                    });

                    totalRow += '</tr>';
                    setTimeout(function () {
                        $('#history_body').append(totalRow);
                        $('#loader_body').hide(); // Hapus row loader setelah data dan total tampil
                    }, 4000);
                    // ++ AKHIR TAMBAHAN ++

                } else {
                    // Jika data kosong
                    var totalCols = 3 + currencies.length;
                    var noDataRow = '<tr><td colspan="' + totalCols + '" class="text-center">No data found for the selected month and year.</td></tr>';
                    $('#history_body').append(noDataRow);
                }
            },
            error: function (xhr, status, error) {
                console.error('Error fetching history data:', error);
                // Hitung estimasi colspan jika response gagal agar tidak merusak layout tabel
                var noDataRow = '<tr><td colspan="5" class="text-center text-danger">An error occurred while fetching data. Please try again.</td></tr>';
                $('#history_body').append(noDataRow);
            }
        });
    });

    // Trigger klik pertama kali untuk memuat data default saat halaman dibuka
    $('#btn_search_history').trigger('click');
});