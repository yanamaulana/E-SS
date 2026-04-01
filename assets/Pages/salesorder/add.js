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
        lpage(); // Hitung ulang jika perlu
    });

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

    $('#selCurrency').on('change', function () {
        var val = $(this).val();
        getCurrencyRate(val); // Ini akan jalan meskipun function di dalam ready()
    });
    // --------------------------------------------------------

    // 1. Fungsi untuk memproses string rate dari server
    function createElementCurrency(valCurr) {
        const baseCurrency = 'IDR';
        const objTblCurr = document.getElementById('tblCurrConverter');
        const objTblTax = document.getElementById('tblTaxConverter');

        // Reset tabel agar tidak double saat ganti currency
        if (objTblCurr) objTblCurr.innerHTML = "";
        if (objTblTax) objTblTax.innerHTML = "";

        if (!valCurr) return;

        const bagi = valCurr.split(";");
        for (let i = 0; i < bagi.length; i++) {
            let awal = bagi[i];
            if (!awal) continue;

            let detail = awal.split("|");
            let type = detail[0]; // Amount atau Tax
            let curr = detail[1]; // USD, EUR, dll
            window.currConverter = detail[2]; // Simpan ke global agar terbaca addRowCurrency
            window.currID = curr;

            if (type == "Amount" && curr != baseCurrency) {
                addRowCurrency('tblCurrConverter', type, curr);
            } else if (type == "Tax" && curr != baseCurrency) {
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
        fetch($('meta[name="base_url"]').attr('content') + 'SalesOrder/get_currency_rate?curr=' + val)
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



    // 2. Klik Tombol Remove Item
    $('#btnRemoveItem').on('click', function () {
        // Panggil fungsi delRow (pastikan fungsi ini sudah Anda miliki)
        if (typeof window.delRow === "function") {
            window.delRow('tbl_ID', 1);
        }
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
        lpage();
    });

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

});

var taxOptionsHtml = '<option value="0" selected>-- No Tax --</option>';
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
                taxOptionsHtml += '<option value="' + val.Tax_ID + '" ' +
                    'data-rate="' + tRate + '" ' +
                    'data-op="' + tOp + '">' +
                    tName + ' (' + tCode + ')' +
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
            CcOptionsHtml = '<option value="">-- No CC --</option>'; // Reset
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

    $(popupWindow.document).find('input[name="chkItem"]:checked').each(function () {
        var itemCode = $(this).val();
        var row = $(this).closest('tr');

        var itemName = row.find('td:eq(3)').text().trim();
        var color = row.find('td:eq(4)').text().trim();
        var brand = row.find('td:eq(5)').text().trim();
        var size = row.find('td:eq(6)').text().trim();
        var type = row.find('td:eq(7)').text().trim();

        // Cek Duplikat
        var isExist = false;
        $('#tbl_ID tbody tr').each(function () {
            if ($(this).find('td:eq(1)').text().trim() == itemCode) {
                isExist = true;
            }
        });

        if (!isExist) {
            var newRow = `
                <tr>
                    <td><input type="checkbox" name="chk_item[]"></td>
                    <td>${itemCode}</td>
                    <td>${itemName}</td>
                    <td><input type="text" name="notes[]" class="form-control form-control-sm"></td>
                    <td style="display:none">${size}</td>
                    <td>${color}</td>
                    <td>${brand}</td>
                    <td>${type}</td>
                    <td><input type="number" name="qty[]" class="form-control form-control-sm text-right qty-trigger" value="0"></td>
                    <td>PCS</td>
                    <td><input type="number" name="qty2[]" class="form-control form-control-sm text-right" readonly value="0"></td>
                    <td>PCS</td>
                    <td style="display:none">0</td>
                    <td style="display:none">PCS</td>
                    <td><input type="text" name="price[]" class="form-control form-control-sm text-right price-trigger" value="0"></td>
                    <td><input type="text" name="disc_val[]" class="form-control form-control-sm text-right disc-trigger" value="0"></td>
                    <td><input type="text" name="disc_pct[]" class="form-control form-control-sm text-right disc-pct-trigger" value="0"></td>
                    <td class="text-right total-amount">0</td>
                    
                    <td>
                        <select name="tax1[]" class="form-control form-control-sm tax-trigger" style="min-width:100px">
                            ${taxOptionsHtml}
                        </select>
                    </td>
                    <td>
                        <select name="tax2[]" class="form-control form-control-sm tax-trigger" style="min-width:100px">
                            ${taxOptionsHtml}
                        </select>
                    </td>

                    <td colspan="2"><input type="text" name="est_date[]" class="form-control form-control-sm date-picker" value="${today}"></td>

                    <td>
                        <select name="cc[]" class="form-control form-control-sm select2-item" style="min-width:150px">
                            ${CcOptionsHtml}
                        </select>
                    </td>
                </tr>
            `;
            var $row = $(newRow);
            $('#tbl_ID tbody').append($row);
            $row.find('.date-picker').flatpickr();
            $row.find('.select2-item').select2({
                // allowClear: true,
                width: '100%',
                // placeholder: '-- Select --',
                // PENTING: dropdownParent supaya dropdown-nya gak "ngumpet" atau terpotong
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
