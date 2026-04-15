$(document).ready(function () {
    const site_url = $('meta[name="base_url"]').attr('content');
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

    // Trigger saat Currency di Header berubah
    $('#selCurrency').on('change', function () {
        var selectedCurr = $(this).val(); // Ambil USD, IDR, dll
        $('.curr-label').text(selectedCurr);
        getCurrencyRate(selectedCurr);
        // lpage(); // sudah di panggil di dalam getCurrencyRate setelah rate berhasil diambil
    });

    getCurrencyRate($('#selCurrency').val()); // Panggil saat load untuk inisialisasi (jika sudah ada value)

    // Inisialisasi label saat halaman pertama kali load (setelah reload submit)
    var currentType = $('input[name="rdoAllocate"]:checked').val();
    updateAllocateLabel(currentType);

    // Event Listener untuk Radio Button
    $('input[name="rdoAllocate"]').on('change', function () {
        var selectedVal = $(this).val();

        // Jalankan logika ganti label
        updateAllocateLabel(selectedVal);

        // Update global variable (sesuai fungsi asli: curAllocateTo)
        window.curAllocateTo = parseInt(selectedVal);

        // Eksekusi Submit Form sesuai logic asli Anda
        $('#frmNew').attr('action', '').submit();
    });

    // Fungsi pembantu untuk update label (menggantikan innerHTML)
    function updateAllocateLabel(val) {
        if (val == "1") {
            $('#allocateTo').text("Cost Center");
        } else {
            // Fallback ke Project jika value "" atau "0" sesuai logic asli
            $('#allocateTo').text("Project Component");
        }
    }
    // --------------------------------------------------------

    // 1. Fungsi untuk memproses string rate dari server
    function createElementCurrency(valCurr) {
        const baseCurrency = 'IDR';
        const objTblCurr = document.getElementById('tblCurrConverter');
        const objTblTax = document.getElementById('tblTaxConverter');

        if (objTblCurr) objTblCurr.innerHTML = "";
        if (objTblTax) objTblTax.innerHTML = "";

        if (!valCurr) return;
        //Amount|USD|16922.00000000;Tax|USD|16922.00000000
        // ubah jadi IDR|1;USD|16922 untuk di masukan ke value input hidden #CurrencyRateList

        const bagi = valCurr.split(";");
        let CurrencyRateList = 'IDR|1';
        for (let i = 0; i < bagi.length; i++) {
            let awal = bagi[i];
            if (!awal) continue;

            let detail = awal.split("|");
            let type = detail[0];
            let curr = detail[1];
            window.currConverter = detail[2];
            window.currID = curr;
            if (i == 0 && curr != 'IDR') {
                CurrencyRateList = `DR|1;${curr}|${parseFloat(window.currConverter)}`;
            }
            if (i == 0) {
                $('#CurrencyRateList').val(CurrencyRateList);
            }

            // Hapus pengecekan != baseCurrency agar IDR tetap muncul
            if (type == "Amount") {
                addRowCurrency('tblCurrConverter', type, curr);
            } else if (type == "Tax") {
                addRowCurrency('tblTaxConverter', type, curr);
            }
        }
    }

    // 2. Fungsi untuk membuat baris input (sm style)
    function addRowCurrency(table, typeofTransation, currency) {
        let objTbl = document.getElementById(table);
        let newTR = objTbl.insertRow(objTbl.rows.length);
        let inputName = (typeofTransation == "Amount") ? "txtCurr_" + currency : "txtTax_" + currency;
        let baseCurrency = 'IDR';

        // Gunakan class sm agar input terlihat ringkas
        newTR.innerHTML = `
        <td class="py-1">
            <div class="input-group input-group-sm">
                <div class="input-group-prepend">
                    <span class="input-group-text border-0 bg-transparent">1 ${currency} =</span>
                </div>
                <input name="${inputName}" type="text" value="${parseFloat(window.currConverter)}"
                    class="form-control form-control-sm text-right" 
                    onBlur="recalcTotal();" 
                    onKeyPress="return isIntOnlyNew(event);" 
                    onFocus="this.select()" 
                    onKeyUp="decimalinForMoney(this);">
                <div class="input-group-append">
                    <span class="input-group-text border-0 bg-transparent">${baseCurrency}</span>
                </div>
            </div>
        </td>`;
    }

    // Di dalam add.js
    function getCurrencyRate(val) {
        if (!val || val == '') return;

        // Gunakan site_url yang di-define di view
        fetch($('meta[name="base_url"]').attr('content') + 'SalesOrder/get_currency_rate?curr=' + val + '&sodate=' + $('#txtSODate').val())
            .then(response => response.text())
            .then(data => {
                if (data != "") {
                    createElementCurrency(data);

                    // Pastikan fungsi hitung ulang dipanggil agar total SO update
                    if (typeof recalcTotal === "function") {
                        recalcTotal();
                    }
                } else {
                    // Jika rate tidak ditemukan, bersihkan tabel converter
                    document.getElementById('tblCurrConverter').innerHTML = "";
                    document.getElementById('tblTaxConverter').innerHTML = "";
                }
            })
            .catch(err => console.error("Gagal ambil rate:", err));
    }

    // Global array untuk menampung window popup (agar bisa ditutup masal jika perlu)
    window.arrNewPop = window.arrNewPop || [];

    window.pickItem = function (ctype, quo) {
        // Ambil nilai-nilai dari form menggunakan jQuery
        const selCurrency = $('#selCurrency').val() || '';
        const txtSODate = $('#txtSODate').val() || '';
        const txtCPCode = $('#txtCPCode').val() || '';
        const txtCustCode = $('#txtCustCode').val() || '';


        // Susun URL sesuai route CI3 Anda
        // Saya asumsikan routenya: /purchase/po/forms/pickitem
        let strURL = site_url + 'SalesOrder/pickitem';
        strURL += '?selCatType=FG';
        strURL += '&menu=sales';
        strURL += '&source=SO';
        strURL += '&selRFQ=' + quo;
        strURL += '&sumber=sales';
        strURL += '&selCurrency=' + selCurrency;
        strURL += '&date=' + txtSODate;
        strURL += '&cboCP=' + txtCPCode;
        strURL += '&cboCustomer=' + txtCustCode;

        // selCatType=FG&menu=sales&source=SO&selRFQ=&sumber=sales&selCurrency=IDR&date=03/29/2026&cboCP=&cboCustomer=

        // Pengaturan Ukuran Window (Sesuai aslinya 500x500)
        const w = 720;
        const h = 720;
        const left = (screen.width / 2) - (w / 2);
        const top = (screen.height / 2) - (h / 2);

        // Buka Popup
        const itemwindow = window.open(strURL, 'Preview',
            'width=' + w + ',height=' + h + ',top=' + top + ',left=' + left + ',scrollbars=yes,status=yes,resizable=yes');

        // Simpan ke array popup (sesuai logic asli Anda)
        arrNewPop.push(itemwindow);

        if (window.focus) {
            itemwindow.focus();
        }
    };

    // Event Listener untuk tombol [+ Multiple Item]
    $('#btnPickItem').on('click', function () {
        const selCatType = $('#selCatType').val() || '';
        const selQuotation = $('#selQuotation').val() || '';

        // Panggil fungsi di atas
        pickItem(selCatType, selQuotation);
    });

    // Listener Tombol Remove
    $('#btnRemoveItem').on('click', function () {
        delRow('tbl_ID');
    });

    // $(document).on('keyup change', '#idDiscall, #txt_cd_amount', function () {
    //     lpage();
    // });

    // Fitur Select All (Cek ID chkAll)
    $(document).on('change', '#chkAll', function () {
        let isChecked = $(this).is(':checked');
        $('#tbl_ID tbody input[name="chk_item[]"]').prop('checked', isChecked);

        // Tambahan: beri warna highlight pada row jika di-check (opsional)
        if (isChecked) {
            $('#tbl_ID tbody tr').addClass('bg-light-danger');
        } else {
            $('#tbl_ID tbody tr').removeClass('bg-light-danger');
        }
    });

    // Listener otomatis uncheck 'Select All' jika salah satu baris di-uncheck manual
    $(document).on('change', 'input[name="chk_item[]"]', function () {
        let total = $('#tbl_ID tbody input[name="chk_item[]"]').length;
        let checked = $('#tbl_ID tbody input[name="chk_item[]"]:checked').length;
        $('#chkAll').prop('checked', (total === checked && total > 0));
    });

    // Fungsi buildList (Versi Modern tanpa eval)
    window.buildList = function () {
        var items = [];
        var rowCount = parseInt($('#rowCount').val()) || 0;

        for (var i = 1; i <= rowCount; i++) {
            // Cek apakah baris tersebut ada (menggunakan selector attribute)
            var objPart = $('input[name="txtPartNo_' + i + '"]');
            if (objPart.length > 0) {
                var detailID = $('input[name="hdnSCDetailID_' + i + '"]').val();
                if (detailID) items.push(detailID);
            }
        }

        $('#hdnLstItemID').val(items.join(','));
        $('#frmNew').submit();
    };

    // Trigger lpage saat kurs diubah
    $(document).on('keyup change', 'input[name="txtCurr_USD"], input[name="txtTax_USD"]', function () {
        lpage();
    });

    // Alias untuk mencocokkan fungsi onblur="recalcTotal()" di HTML Mas Yana
    function recalcTotal() {
        lpage();
    }


    // Trigger saat input diubah
    $(document).on('keyup change', '.qty-trigger, .price-trigger, .disc-trigger, .disc-pct-trigger, .tax-trigger, #idDiscall, #txt_cd_amount, input[name="txtCurr_USD"], input[name="txtTax_USD"]', function () {
        // Qty 2 mengikuti Qty 1
        if ($(this).hasClass('qty-trigger')) {
            $(this).closest('tr').find('input[name="qty2[]"]').val($(this).val());
        }
        // Ini sudah mencakup semua trigger, termasuk diskon global & claim
        lpage();
    });


    // Trigger Modal
    $('#btnUploadItem').on('click', function () {
        if (!$('#txtCustCode').val()) {
            alert("Silakan pilih customer terlebih dahulu!");
            return;
        }

        $('#modalUploadExcel').modal('show');
    });

    // 1. Tombol Trigger Upload di Modal
    $('#btnExecuteUpload').on('click', function () {
        let file_data = $('#excel_file').prop('files')[0];

        if (!file_data) {
            alert("Silakan pilih file Excel terlebih dahulu!");
            return;
        }

        let formData = new FormData();
        formData.append('file_excel', file_data);

        $.ajax({
            url: site_url + 'SalesOrder/process_excel_import',
            type: 'POST',
            data: formData,
            cache: false,
            contentType: false,
            processData: false,
            dataType: 'JSON',
            beforeSend: function () {
                $('#btnExecuteUpload').prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Processing...');
            },
            success: function (response) {
                // 1. Cek jika server kirim error status
                if (response.status === "error") {
                    alert("Waduh: " + response.msg);
                    return;
                }

                if (Array.isArray(response) && response.length > 0) {

                    // --- KUNCI UTAMA: KOSONGKAN TABEL ---
                    // Menghapus semua baris <tr> yang ada di dalam tbody sebelum diisi data Excel
                    $('#tbl_ID tbody').empty();

                    response.forEach(function (item) {
                        let rowHtml = buildRowDetail(item);
                        let $row = $(rowHtml);

                        // 2. Tempel row baru ke tabel yang sudah kosong
                        $('#tbl_ID tbody').append($row);

                        // 3. Handle Select Biasa (Tax 1 & Tax 2)
                        $row.find('select[name="tax1[]"], select[name="tax2[]"]').each(function () {
                            let valExcel = $(this).attr('data-selected');
                            if (valExcel !== undefined && valExcel !== "") {
                                $(this).val(valExcel);
                            }
                        });

                        // 4. Handle Select2 untuk CC (Cost Center)
                        let $ccSelect = $row.find('.select2-item-new');
                        let ccVal = $ccSelect.attr('data-selected');

                        $ccSelect.select2({
                            theme: 'bootstrap5',
                            width: '100%'
                        });

                        if (ccVal !== undefined && ccVal !== "") {
                            $ccSelect.val(ccVal).trigger('change');
                        }

                        $ccSelect.removeClass('select2-item-new').addClass('select2-item');
                    });

                    // 5. Jalankan Flatpickr untuk baris baru
                    $(".date-picker").flatpickr({ dateFormat: "Y-m-d" });

                    // 6. Trigger hitung ulang semua total (Qty/Price change)
                    $('.qty-trigger').trigger('change');

                    // Tutup modal setelah berhasil
                    $('#modalUploadExcel').modal('hide');
                    alert("Data Excel berhasil di-import!");

                } else {
                    alert("Data Excel kosong atau Item Code tidak ditemukan!");
                }

                // tutup modal setelah berhasil
                $('#modalUploadExcel').modal('hide');
                // clear form input file 
                $('#excel_file').val('');
            },
            error: function (xhr) {
                alert("Terjadi kesalahan sistem saat memproses Excel.");
            },
            error: function (xhr) {
                alert("Terjadi kesalahan sistem: " + xhr.statusText);
            },
            complete: function () {
                $('#btnExecuteUpload').prop('disabled', false).html('<i class="fas fa-upload"></i> Proses Detail');
            }
        });
    });

    function buildRowDetail(data) {
        const totalAmount = data.total_amount || "0.00";
        const notes = data.notes || "";
        // Jika tanggal di excel kosong, pakai hari ini
        const estDate = data.est_date || new Date().toISOString().split('T')[0];

        return `
        <tr class="text-nowrap">
            <td><input type="checkbox" name="chk_item[]"></td>
            <td>
                ${data.item_code} 
                <input type="hidden" name="item_code[]" value="${data.item_code}">
                <input type="hidden" name="unit_id[]" value="${data.unit_id}"> 
                <input type="hidden" name="unit_id2[]" value="${data.unit_id}">
                <input type="hidden" name="dim_id[]" value="${data.dim_id}">
            </td>
            <td>
                ${data.item_name} 
                <input type="hidden" name="item_name[]" value="${data.item_name}">
                <input type="hidden" name="gen_flag[]" value="0">
                <input type="hidden" name="parent_item[]" value="0">
                <input type="hidden" name="parent_path[]" value="0">
            </td>
            <td style="min-width: 120px;"><input type="text" name="notes[]" class="form-control form-control-sm" value="${notes}"></td>
            <td style="display:none">${data.size}</td>
            <td>${data.color}</td>
            <td>${data.brand}</td>
            <td>${data.type}</td>
            
            <td style="min-width: 85px;">
                <input type="number" name="qty[]" class="form-control form-control-sm text-right qty-trigger" value="${data.qty}">
            </td>
            <td class="fw-bold text-muted">${data.unit_name}</td> 
            <td style="min-width: 85px;">
                <input type="number" name="qty2[]" class="form-control form-control-sm text-right bg-light" readonly value="0">
            </td>
            <td class="fw-bold text-muted">${data.unit_name}</td> 
            
            <td style="display:none">
                <input type="hidden" name="cs_number[]" value="">
                <input type="hidden" name="extra_price[]" value="0">
                <input type="hidden" name="others[]" value="">
            </td>
            
            <td style="min-width: 85px;"><input type="text" name="price[]" class="form-control form-control-sm text-right price-trigger" value="${data.price}"></td>
            <td style="min-width: 85px;"><input type="text" name="disc_val[]" class="form-control form-control-sm text-right disc-trigger" value="0"></td>
            <td style="min-width: 85px;"><input type="text" name="disc_pct[]" class="form-control form-control-sm text-right disc-pct-trigger" value="${data.disc_pct}"></td>
            <td class="text-right fw-bold total-amount">${totalAmount}</td>
            
            <td style="min-width: 110px;">
                <select name="tax1[]" class="form-control form-control-sm tax-trigger" data-selected="${data.tax1}">
                    ${taxOptionsHtml}
                </select>
            </td>
            <td style="min-width: 110px;">
                <select name="tax2[]" class="form-control form-control-sm tax-trigger" data-selected="${data.tax2}">
                    ${taxOptionsHtml}
                </select>
            </td>

            <td colspan="2" style="min-width: 110px;">
                <input type="text" name="est_date[]" class="form-control form-control-sm date-picker" value="${estDate}">
            </td>

            <td style="min-width: 110px;">
                <select name="cc[]" class="form-control form-control-sm select2-item-new" data-selected="${data.cc}">
                    ${CcOptionsHtml}
                </select>
            </td>
        </tr>`;
    }

    // 3. Fungsi Inisialisasi Ulang Plugin UI
    function initNewRowPlugins() {
        // Inisialisasi Flatpickr
        if ($(".date-picker").length > 0) {
            $(".date-picker").flatpickr({
                dateFormat: "Y-m-d",
                allowInput: true
            });
        }

        // Inisialisasi Select2 (khusus yang baru ditambah)
        $('.select2-item-new').select2({
            theme: 'bootstrap5',
            width: '100%'
        }).removeClass('select2-item-new').addClass('select2-item');
    }

});

const site_url = $('meta[name="base_url"]').attr('content');

function lpage() {
    // 1. Helper function untuk ambil angka aman
    const getNum = (selector, defaultVal = 0) => {
        let element = $(selector);
        if (element.length === 0) return defaultVal;
        let val = element.val() || "";
        return parseFloat(val.toString().replace(/,/g, '')) || defaultVal;
    };

    // 2. Ambil Parameter Global
    let kursCurr = getNum('input[name="txtCurr_USD"]', 1);
    let kursTax = getNum('input[name="txtTax_USD"]', 1);
    let globalDiscPct = getNum('#idDiscall', 0);
    let claimIDR = getNum('#txt_cd_amount', 0);

    let grandTotQty = 0;
    let totalNetAmountSO = 0;
    let totalTaxIDRPlus = 0;
    let totalTaxIDRMinus = 0;

    // 3. LOOP 1: Hitung Net Amount per baris (SO Currency)
    $('#tbl_ID tbody tr').each(function () {
        let row = $(this);
        let qty = parseFloat(row.find('.qty-trigger').val()) || 0;
        let price = parseFloat(row.find('.price-trigger').val().replace(/,/g, '')) || 0;
        let dVal = parseFloat(row.find('.disc-trigger').val().replace(/,/g, '')) || 0;
        let dPct = parseFloat(row.find('.disc-pct-trigger').val()) || 0;

        let baseAmount = qty * (price - dVal);
        let rowNetAmountSO = baseAmount - (baseAmount * (dPct / 100));

        row.find('.total-amount').text(rowNetAmountSO.toLocaleString('en-US', { minimumFractionDigits: 2 }));

        grandTotQty += qty;
        totalNetAmountSO += rowNetAmountSO;
    });

    // 4. LOOP 2: Hitung Pajak (IDR) dari DPP setelah Diskon Global
    $('#tbl_ID tbody tr').each(function () {
        let row = $(this);
        let rowAmountSO = parseFloat(row.find('.total-amount').text().replace(/,/g, '')) || 0;
        let dppRowSO = rowAmountSO * (1 - (globalDiscPct / 100));

        function getTaxIDR(selectName) {
            let opt = row.find(`select[name="${selectName}"] option:selected`);
            let rate = parseFloat(opt.data('rate')) || 0;
            let op = opt.data('op') || '+';
            return { val: (dppRowSO * (rate / 100)) * kursTax, op: op };
        }

        let t1 = getTaxIDR('tax1[]');
        let t2 = getTaxIDR('tax2[]');

        if (t1.op === '+') totalTaxIDRPlus += t1.val; else totalTaxIDRMinus += t1.val;
        if (t2.op === '+') totalTaxIDRPlus += t2.val; else totalTaxIDRMinus += t2.val;
    });

    // 5. UPDATE SUMMARY (SO Currency)
    let globalDiscValSO = totalNetAmountSO * (globalDiscPct / 100);

    $('#txtTotAmount').val(totalNetAmountSO.toLocaleString('en-US', { minimumFractionDigits: 4 }));
    $('#idTotalDiscall').val(globalDiscValSO.toLocaleString('en-US', { minimumFractionDigits: 4 }));

    // 6. UPDATE TAX (IDR)
    $('#txtTotTaxConv').val(totalTaxIDRPlus.toLocaleString('en-US', { minimumFractionDigits: 4 }));
    $('#txtTotDeductConv').val(totalTaxIDRMinus.toLocaleString('en-US', { minimumFractionDigits: 4 }));

    // 7. HITUNG GRAND TOTAL (SO Currency)
    let adjSO = (totalTaxIDRPlus - totalTaxIDRMinus - claimIDR) / kursCurr;
    let finalGrandTotalSO = (totalNetAmountSO - globalDiscValSO) + adjSO;

    $('#txtGrandTotal').val(finalGrandTotalSO.toLocaleString('en-US', { minimumFractionDigits: 4 }));
    $('#txtTotQty').val(grandTotQty.toFixed(4));

    // 8. UPDATE PAYMENT DETAIL (Hanya bisa dihitung SETELAH finalGrandTotalSO ketemu)
    let percentage1 = parseFloat($('#hidPercentage1').val()) || 100;
    let paymentAmount1 = finalGrandTotalSO * (percentage1 / 100);
    $('#txtAmount1').val(paymentAmount1.toLocaleString('en-US', { minimumFractionDigits: 4 }));

    // 9. UI Toggle
    finalGrandTotalSO > 0 ? $('#idTaxHide2').show() : $('#idTaxHide2').hide();
}

var taxOptionsHtml = '<option value="0" data-rate="0" data-op="+" selected>-- No Tax --</option>';
function loadTaxOptions() {
    $.ajax({
        url: $('meta[name="base_url"]').attr('content') + 'SalesOrder/get_tax_list',
        type: "GET",
        dataType: "json",
        success: function (data) {
            $.each(data, function (key, val) {
                // Pastikan variabel tidak null agar tidak error trim
                var tName = (val.Tax_Name || '').trim();
                var tCode = (val.Tax_Code || '').trim();
                var tRate = val.Tax_Rate || 0;
                var tOp = (val.Tax_operator || '').trim();

                // Gunakan penggabungan string manual (+) agar lebih aman dari karakter spesial
                taxOptionsHtml += '<option value="' + val.Tax_Code + '" ' +
                    'data-rate="' + tRate + '" ' +
                    'data-op="' + tOp + '">' +
                    tName +
                    '</option>';
            });
            // console.log("Tax list loaded successfully.");
        }
    });
}
loadTaxOptions()

var CcOptionsHtml = '<option value="0">..::[NONE]::..</option>';
function loadCostCenterOptions() {
    $.ajax({
        url: $('meta[name="base_url"]').attr('content') + 'SalesOrder/get_cc_list',
        type: "GET",
        dataType: "json",
        success: function (data) {
            CcOptionsHtml = '<option value="0">..::[NONE]::..</option>'; // Reset
            $.each(data, function (key, val) {
                var ccName = (val.Comp_Name || '').trim();
                // Simpan ID sebagai value
                CcOptionsHtml += '<option value="' + val.Comp_ID + '">' + ccName + '</option>';
            });
            console.log("Cost Center list loaded.");
        }
    });
}
loadCostCenterOptions();

function getItem(meth, custData) {
    // 1. UPDATE HEADER SO & ACCOUNT GROUPS
    if (custData) {
        // Header Customer (Seperti sebelumnya)
        $('#txtCustName').val(custData.Account_Name);
        $('#txtCustCode').val(custData.Account_ID);
        $('#txtCustAddress').val(custData.Addr);
        $('input[name="txtSPName"]').val(custData.salesname);
        $('#selCurrency').val(custData.Account_CurrencyID).trigger('change');
        $('#chkKawasan').prop('checked', custData.kawasanberikat == 1);

        var accountText = custData.Account_Name;
        var singleOption = `<option value="${custData.Account_ID}" selected>${accountText}</option>`;

        // Langsung masukkan ke dropdown SN dan SI
        $('select[name="selSNGroup"]').html(singleOption);
        $('select[name="selSIGroup"]').html(singleOption);

        // ISI DATA CONTACT PERSON
        if ($('#txtCPName').length) {
            $('#txtCPName').val(custData.cpName);
        }
        if ($('#txtCPCode').length) {
            $('#txtCPCode').val(custData.cpCode);
        }
        if ($('input[name="txtCPAddress"]').length) {
            $('input[name="txtCPAddress"]').val(custData.cpAddr);
        }

        // Mapping NPWP (NPWP yang tadi)
        if ($('#txtnpwp').length) $('#txtnpwp').val(custData.taxNumber);
        if ($('#CPTaxFileNumber').length) $('#CPTaxFileNumber').text(custData.taxNumber || '-');
    }


    var popupWindow = window.pickItemWindow;
    if (!popupWindow) return;

    var today = new Date().toISOString().split('T')[0];

    // Fungsi ini biasanya dipanggil di dalam getItem(meth, custData)
    $(popupWindow.document).find('input[name="chkItem"]:checked').each(function () {
        var $chk = $(this); // Checkbox yang sedang di-loop
        var itemCode = $chk.val();

        // Ambil data dari atribut data-* yang kita buat di pickitem_view
        var itemName = $chk.data('name');
        var color = $chk.data('color');
        var brand = $chk.data('brand');
        var size = $chk.data('size');
        var type = $chk.data('type');
        var unitId = $chk.data('unitid');
        var unitName = $chk.data('unitname');
        var unitId2 = $chk.data('unitid2');
        var unitName2 = $chk.data('unitname2');
        var dimensionId = $chk.data('dimid');

        // Cek Duplikat
        var isExist = false;
        $('#tbl_ID tbody tr').each(function () {
            if ($(this).find('input[name="item_code[]"]').val() == itemCode) {
                isExist = true;
            }
        });

        if (!isExist) {
            // Render Row (Gunakan variabel yang sudah ditangkap di atas)
            var newRow = `
            <tr class="text-nowrap">
                <td><input type="checkbox" name="chk_item[]"></td>
                <td>
                    ${itemCode} 
                    <input type="hidden" name="item_code[]" value="${itemCode}">
                    <input type="hidden" name="unit_id[]" value="${unitId}"> 
                    <input type="hidden" name="unit_id2[]" value="${unitId2}">
                    <input type="hidden" name="dim_id[]" value="${dimensionId || 3}">
                </td>
                <td>
                    ${itemName} 
                    <input type="hidden" name="item_name[]" value="${itemName}">
                    <input type="hidden" name="gen_flag[]" value="0">
                    <input type="hidden" name="parent_item[]" value="0">
                    <input type="hidden" name="parent_path[]" value="0">
                </td>
                <td style="min-width: 120px;"><input type="text" name="notes[]" class="form-control form-control-sm"></td>
                <td style="display:none">${size}</td>
                <td>${color}</td>
                <td>${brand}</td>
                <td>${type}</td>
                
                <td style="min-width: 85px;">
                    <input type="number" name="qty[]" class="form-control form-control-sm text-right qty-trigger" value="0">
                </td>
                <td class="fw-bold text-muted">${unitName}</td> 
                <td style="min-width: 85px;">
                    <input type="number" name="qty2[]" class="form-control form-control-sm text-right bg-light" readonly value="0">
                </td>
                <td class="fw-bold text-muted">${unitName2}</td> 
                
                <td style="display:none">
                    <input type="hidden" name="cs_number[]" value="">
                    <input type="hidden" name="extra_price[]" value="0">
                    <input type="hidden" name="others[]" value="">
                </td>
                
                <td style="min-width: 85px;"><input type="text" name="price[]" class="form-control form-control-sm text-right price-trigger" value="0"></td>
                <td style="min-width: 85px;"><input type="text" name="disc_val[]" class="form-control form-control-sm text-right disc-trigger" value="0"></td>
                <td style="min-width: 85px;"><input type="text" name="disc_pct[]" class="form-control form-control-sm text-right disc-pct-trigger" value="0"></td>
                <td class="text-right fw-bold total-amount">0.00</td>
                
                <td style="min-width: 110px;">
                    <select name="tax1[]" class="form-control form-control-sm tax-trigger">
                        ${taxOptionsHtml}
                    </select>
                </td>
                <td style="min-width: 110px;">
                    <select name="tax2[]" class="form-control form-control-sm tax-trigger">
                        ${taxOptionsHtml}
                    </select>
                </td>

                <td colspan="2" style="min-width: 110px;">
                    <input type="text" name="est_date[]" class="form-control form-control-sm date-picker" value="${typeof today !== 'undefined' ? today : ''}">
                </td>

                <td style="min-width: 110px;">
                    <select name="cc[]" class="form-control form-control-sm select2-item">
                        ${CcOptionsHtml}
                    </select>
                </td>
            </tr>
        `;

            var $row = $(newRow);
            $('#tbl_ID tbody').append($row);

            // Re-inisialisasi Plugin
            $row.find('.date-picker').flatpickr();
            $row.find('.select2-item').select2({
                width: '100%',
                dropdownParent: $('#tbl_ID').parent()
            });
        }
    });

    if (typeof lpage === "function") {
        lpage();
    }
}

// Tambahan: Fungsi saat Mas buka popup
var pickItemWindow; // Variabel global untuk menampung window popup
function openPickItem() {
    pickItemWindow = window.open('<?=base_url("SalesOrder/pickitem")?>', 'pickItem', 'width=900,height=1280,scrollbars=yes,resizable=yes');
}

function delRow(tableId) {
    // 1. Ambil semua checkbox yang dicek
    let checkedItems = $(`#${tableId} tbody input[name="chk_item[]"]:checked`);

    if (checkedItems.length === 0) {
        alert("Pilih item yang ingin dihapus !");
        return;
    }

    if (confirm("Yakin ingin menghapus " + checkedItems.length + " item terpilih?")) {

        // 2. Hapus baris (TR)
        checkedItems.each(function () {
            $(this).closest('tr').remove();
        });

        // 3. Reset Checkbox 'Select All' di header
        $('#chkAll').prop('checked', false);

        // 4. CEK APAKAH TABEL KOSONG
        if ($(`#${tableId} tbody tr`).length === 0) {
            // Jika kosong, paksa nol-kan semua field summary secara manual
            $('#txtTotQty, #txtTotAmount, #idTotalDiscall, #txtTotTaxConv, #txtTotDeductConv, #txtGrandTotal, #txtAmount1').val('0.0000');
            $('#idTaxHide2').hide();
            console.log("Table is now empty. Summary reset.");
        } else {
            // 5. JIKA MASIH ADA BARIS, PANGGIL lpage()
            // Ini yang bikin summary Mas langsung update otomatis!
            lpage();
            console.log("Item removed. lpage() triggered.");
        }
    }

    $('#btnRevise').on('click', function (e) {
        e.preventDefault(); // Mencegah form langsung submit

        // Ambil value dari input alasan revisi dan hilangkan spasi kosong di awal/akhir
        var revisionReason = $.trim($('#txtRevisionReason').val());

        // Validasi: Cek apakah kosong
        if (revisionReason.length === 0) {
            alert('Alasan revisi wajib diisi!');
            $('#txtRevisionReason').focus(); // Arahkan kursor ke input tersebut
            return false;
        } else {
            // Lolos validasi, jalankan fungsi save/passing data
            passingVars();
            // Catatan: Jika saat revisi Mas butuh melempar parameter khusus ke passingVars 
            // (misal: passingVars('REVISE')), silakan sesuaikan di sini.
        }
    });
}

function passingVars(IsConfirm) {
    // 1. Inisialisasi Data Form
    let form = $('#frmNew');
    let rowCount = parseInt($('#rowCount').val());

    // 2. Validasi Credit Limit (CF Logic konversi ke JS)
    let remainingCredit = parseFloat($('#txtRemainingCredit').val()) || 0;
    if (remainingCredit < 0) {
        alert("Insufficient Credit!");
        // Jika setting rule ketat (eq 1), hentikan proses
        // return false; 
    }

    // 3. Validasi Header (Customer, Sales Person, Date)
    if ($.trim($('#txtCustName').val()) == "") {
        alert('Customer is required!');
        return false;
    }
    if ($('#txtSPCode').val() == "" || $('#txtSPCode').val() == "0") {
        alert('Please Select Sales Person');
        return false;
    }

    // validasi harus ada tr di dalam #tbl_ID tbody
    if ($('#tbl_ID tbody tr').length < 1) {
        alert('Please add at least one item!');
        return false;
    }

    // Validasi Tanggal (SODate vs DueDate)
    let soDate = new Date($('#txtSODate').val());
    let dueDate = new Date($('#txtInvDueDate').val());
    if (dueDate < soDate) {
        alert("Due Date must be greater than Sales Order Date");
        return false;
    }

    // 4. Validasi Detail Item (Looping Row)
    if (rowCount < 1) {
        alert('Please Select Item!');
        return false;
    }

    for (let r = 1; r <= rowCount; r++) {
        let rowElement = $('#tr' + r);
        if (rowElement.length) {
            let qty = parseFloat($('#txtQty_' + r).val()) || 0;
            let partNo = $('#txtPartNo_' + r).val();

            // Validasi Qty minimal 1
            if (qty < 1) {
                alert("Qty for " + partNo + " must be greater than zero!");
                $('#txtQty_' + r).focus();
                return false;
            }

            // Validasi SO Revision (Jika qty baru < qty lama/SN)
            let snQty = parseFloat($('#txtSNQty_' + r).val()) || 0;
            if (qty < snQty) {
                alert(partNo + " is lower than reserved Qty!");
                return false;
            }
        }
    }

    // 5. Validasi Payment Term
    let numRowsTerm = $('#tblPayment tr').length - 1;
    if (numRowsTerm < 1) {
        alert('Add Payment Term!');
        return false;
    }

    // Prod Month/Year required jika isinya '' maka false
    if ($('#txtProdMonth').length && $('#txtProdYear').length) {
        if ($.trim($('#txtProdMonth').val()) === '' || $.trim($('#txtProdYear').val()) === '') {
            alert('Production Month and Year are required!');
            return false;
        }
    }

    //txtPiNumber required jika string txtPONum
    if ($('#txtPiNumber').length && $.trim($('#txtPiNumber').val()) === '') {
        alert('PI Number is required!');
        return false;
    }
    if ($('#txtPONum').length && $.trim($('#txtPONum').val()) === '') {
        alert('PO Number Customer is required!');
        return false;
    }

    // 6. Jika semua validasi lolos, siapkan kirim via AJAX
    // Matikan tombol agar tidak double klik
    $('#btnSubmit, #btnConfirm').prop('disabled', true);

    // Kumpulkan data untuk dikirim ke Controller CI3
    let formData = $('#frmNew').serializeArray();
    formData.push({ name: 'txtconfirm', value: IsConfirm });

    $.ajax({
        url: site_url + '/SalesOrder/store',
        method: "POST",
        data: formData,
        dataType: "JSON",
        success: function (response) {
            if (response.code == 200) {
                alert(response.msg);
            } else {
                alert("Error: " + response.msg);
                $('#btnSubmit, #btnConfirm').prop('disabled', false);
            }
        },
        error: function () {
            alert("Terjadi kesalahan pada server.");
            $('#btnSubmit, #btnConfirm').prop('disabled', false);
        }
    });
}