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
        const w = 500;
        const h = 500;
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

});

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


    // 2. PROSES ITEM DETAIL (Tetap sama seperti sebelumnya)
    var popupWindow = window.pickItemWindow;
    if (!popupWindow) return;

    $(popupWindow.document).find('input[name="chkItem"]:checked').each(function () {
        var itemCode = $(this).val();
        var row = $(this).closest('tr');

        var itemName = row.find('td:eq(3)').text().trim();
        var color = row.find('td:eq(4)').text().trim();
        var brand = row.find('td:eq(5)').text().trim();
        var size = row.find('td:eq(6)').text().trim();
        var type = row.find('td:eq(7)').text().trim();

        var isExist = false;
        $('#tbl_ID tbody tr').each(function () {
            if ($(this).find('td:eq(1)').text().trim() == itemCode) {
                isExist = true;
            }
        });

        if (!isExist) {
            var newRow = `
                <tr class="text-nowrap">
                    <td><input type="checkbox" name="chk_item[]"></td>
                    <td>${itemCode}</td>
                    <td>${itemName}</td>
                    <td><input type="text" name="notes[]" class="form-control form-control-sm"></td>
                    <td style="display:none">${size}</td>
                    <td>${color}</td>
                    <td>${brand}</td>
                    <td>${type}</td>
                    <td><input type="number" name="qty[]" class="form-control form-control-sm text-right" value="1"></td>
                    <td>PCS</td>
                    <td><input type="number" name="qty2[]" class="form-control form-control-sm text-right" value="0"></td>
                    <td>PCS</td>
                    <td style="display:none">0</td>
                    <td style="display:none">PCS</td>
                    <td><input type="text" name="price[]" class="form-control form-control-sm text-right" value="0"></td>
                    <td><input type="text" name="disc_val[]" class="form-control form-control-sm text-right" value="0"></td>
                    <td><input type="text" name="disc_pct[]" class="form-control form-control-sm text-right" value="0"></td>
                    <td class="text-right">0</td>
                    <td><input type="text" name="tax1[]" class="form-control form-control-sm" value=""></td>
                    <td><input type="text" name="tax2[]" class="form-control form-control-sm" value=""></td>
                    <td colspan="2"><input type="date" name="est_date[]" class="form-control form-control-sm" value="<?= date('Y-m-d') ?>"></td>
                    <td><input type="text" name="cc[]" class="form-control form-control-sm"></td>
                </tr>
            `;
            $('#tbl_ID tbody').append(newRow);
        }
    });

    if (typeof lpage === "function") {
        lpage();
    }
}

// Tambahkan ini di tag <script> Main Page Mas Yana
function lpage() {
    console.log("Kalkulasi lpage dijalankan...");
    // Di sini nantinya Mas Yana isi logic untuk hitung Total, Grand Total, atau Pajak
    // Untuk sementara kita biarkan kosong agar tidak error
}

// Tambahan: Fungsi saat Mas buka popup
var pickItemWindow; // Variabel global untuk menampung window popup
function openPickItem() {
    pickItemWindow = window.open('<?=base_url("SalesOrder/pickitem")?>', 'pickItem', 'width=900,height=600');
}
