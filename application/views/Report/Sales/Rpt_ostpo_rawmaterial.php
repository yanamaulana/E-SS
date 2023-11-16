<!DOCTYPE html>
<html lang="en">

<head>
    <title><?= $this->config->item('init_app_name') ?> | Report Bom Vs Oustanding SO</title>
    <script type="text/javascript" src="https://unpkg.com/xlsx@0.15.1/dist/xlsx.full.min.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="shortcut icon" href="<?= base_url() ?>assets/E-SBA_assets/web-logo/favicon.ico" />
    <script type="text/javascript" src="https://unpkg.com/xlsx@0.15.1/dist/xlsx.full.min.js"></script>
</head>
<style>
    @page {
        size: A4 landscape;
        margin: 20px 20px 20px 20px;
        font-size: 9pt !important;
        font-family: sans-serif;
    }

    @media print {
        @page {
            size: A4 landscape;
            margin: 20px 20px 20px 20px;
            font-size: 9pt !important;
            font-family: sans-serif;
        }

        #btnExport {
            display: none;
        }
    }

    html,
    body {
        height: 100%;
        width: 100%;
        background: #FFF;
        overflow: visible;
    }

    .table-ttd {
        border-collapse: collapse;
        width: 100%;
        margin-left: 1mm;
        font-size: 9pt !important;
        font-family: sans-serif;
    }

    h3 {
        font-family: sans-serif;
    }

    .table-ttd tr,
    .table-ttd tr td,
    .table-ttd tr th {
        border: 0.5px solid black;
        padding: 3px;
        white-space: nowrap;
        font-size: 9pt !important;
        font-family: sans-serif;
    }

    .table-ttd tr th {
        font-weight: bold;
    }

    input,
    textarea,
    select {
        font-family: inherit;
    }

    /* tr {
        page-break-before: always;
        page-break-inside: avoid;
        font-size: 9pt !important;
    } */

    .tablee td,
    .tablee th {
        border-collapse: collapse;
        font-size: 9pt !important;
        font-family: sans-serif;
    }

    .table-ttd tbody tr td {
        vertical-align: top;
    }

    /* ul,
    li {
        list-style-type: none;
        font-size: 9pt !important;
    } */

    .table-ttd thead tr td,
    .table-ttd thead tr th,
    #tr-footer {
        font-weight: bold;
        font-family: sans-serif;
    }

    .text-center {
        text-align: center;
        vertical-align: middle;
    }

    .text-left {
        text-align: left;
        vertical-align: top;
    }

    .text-right {
        text-align: right;
        vertical-align: middle;
    }

    .font-weight-bold {
        font-weight: bold;
    }

    .rotate {
        /* FF3.5+ */
        -moz-transform: rotate(-90.0deg);
        /* Opera 10.5 */
        -o-transform: rotate(-90.0deg);
        /* Saf3.1+, Chrome */
        -webkit-transform: rotate(-90.0deg);
        /* IE6,IE7 */
        filter: progid: DXImageTransform.Microsoft.BasicImage(rotation=0.083);
        /* IE8 */
        -ms-filter: "progid:DXImageTransform.Microsoft.BasicImage(rotation=0.083)";
        /* Standard */
        transform: rotate(-90.0deg);
    }

    * {
        box-sizing: border-box;
    }

    .row {
        margin-left: -5px;
        margin-right: -5px;
    }

    .column {
        float: left;
        width: 50%;
        padding: 5px;
    }

    /* Clearfix (clear floats) */
    /* .row::after {
        content: "";
        clear: both;
        display: table;
    } */
</style>
<?php $i = 1; ?>

<body>
    <button id="btnExport" onclick="ExportToExcel('xlsx')">Export to excel</button>
    <br>
    <div class="row">
        <table class="tablee" id="Header">
            <tbody>
                <tr>
                    <td rowspan="7"><img src="<?= base_url() ?>assets/media/Samick/samick4.bmp" alt=""></td>
                </tr>
                <tr>
                    <td class="font-weight-bold">PT. Samick Indonesia</td>
                </tr>
                <tr>
                    <td>Jl. Perkebunan, Kp.Cibeureum, Ds.Cileungsi Kidul, </td>
                </tr>
                <tr>
                    <td>RT/RW:004/05, Cileungsi, Bogor </td>
                </tr>
                <tr>
                    <td>, Indonesia</td>
                </tr>
                <tr>
                    <td>Phone 021-8230538</td>
                </tr>
                <tr>
                    <td>Fax 021-8230162</td>
                </tr>
            </tbody>
        </table>
    </div>

    <div class="row">
        <table class="table-ttd" id="tbl_exporttable_to_xls">
            <thead>
                <tr>
                    <th>PRODUCT/ITEM CODE</th>
                    <th>TOTAL QTY PO PER ITEM</th>
                    <th>TOTAL QTY DELIVER</th>
                    <th>OUTSTANDING QTY PO</th>
                    <th>BOM CODE</th>
                    <th>order</th>
                    <th>BOM RAW MATERIAL CODE</th>
                    <th>RAW MATERIAL NAME</th>
                    <th>RAW MATERIAL SIZE</th>
                    <th>RAW MATERIAL TYPE</th>
                    <th>RAW MATERIAL BRAND</th>
                    <th>RAW MATERIAL COLOR</th>
                    <th>RAW MATERIAL DIMENSION</th>
                    <th>RAW MATERIAL UOM</th>
                    <th>CURRENCY</th>
                    <th>BOM RAW MATERIAL QTY</th>
                    <th>BOM RAW MATERIAL COST</th>
                    <th>OUTSTANDING QTY PO x BOM RAW MATERIAL QTY</th>
                    <th>COST OUTSTANDING QTY PO x BOM RAW MATERIAL</th>
                </tr>
            </thead>
            <?php
            $product_code = '';
            $qty_po = '';
            $qty_deliver = '';
            $qty_outstanding = '';
            $bom_code = '';
            ?>
            <tbody>
                <?php $rowColor = true; ?>
                <?php foreach ($SqlBomPerOstPO->result() as $li) : ?>
                    <?php if ($product_code = $li->ITEM_CODE && $qty_po = $li->QTY_PO_PERITEM && $qty_deliver != $li->qtyDeliver && $qty_outstanding != $li->RemainingQty && $bom_code != $li->bom_code) : ?>
                        <?php $bgColor = $rowColor ? '#b1d7fc' : '#ffffff'; ?>
                        <?php $i = 1; ?>
                        <tr <?= "style='background-color: $bgColor;'"; ?>>
                            <td class="font-weight-bold" style="font-size: 12pt !important;"><?= $li->ITEM_CODE; ?></td>
                            <td class="font-weight-bold" style="font-size: 12pt !important;"><?= formatNumber($li->QTY_PO_PERITEM); ?></td>
                            <td class="font-weight-bold" style="font-size: 12pt !important;"><?= formatNumber($li->qtyDeliver); ?></td>
                            <td class="font-weight-bold" style="font-size: 12pt !important;"><?= formatNumber($li->RemainingQty); ?></td>
                            <td class="font-weight-bold" style="font-size: 12pt !important;"><?= $li->bom_code; ?></td>
                            <td><?= $i; ?></td>
                            <td><?= $li->rm_code; ?></td>
                            <td><?= $li->item_name; ?></td>
                            <td><?= $li->item_size; ?></td>
                            <td><?= $li->type; ?></td>
                            <td><?= $li->brand; ?></td>
                            <td><?= $li->color_name; ?></td>
                            <td><?= $li->dimension_name; ?></td>
                            <td><?= $li->unit_name; ?></td>
                            <td><?= $li->currency_id; ?></td>
                            <td><?= formatNumber($li->rm_qty); ?></td>
                            <td><?= formatNumber($li->cost); ?></td>
                            <td><?= formatNumber($li->Qty_Needed_ForSO); ?></td>
                            <td><?= formatNumber(floatval($li->cost) * floatval($li->Qty_Needed_ForSO)) ?></td>
                        </tr>
                        <?php $rowColor = !$rowColor; ?>
                    <?php else : ?>
                        <?php $i++; ?>
                        <tr <?= "style='background-color: $bgColor; border: none;'"; ?>>
                            <td class="font-weight-bold" style="border:none">&nbsp;</td>
                            <td class="font-weight-bold" style="border:none">&nbsp;</td>
                            <td class="font-weight-bold" style="border:none">&nbsp;</td>
                            <td class="font-weight-bold" style="border:none">&nbsp;</td>
                            <td class="font-weight-bold" style="border:none">&nbsp;</td>
                            <td><?= $i; ?></td>
                            <td><?= $li->rm_code; ?></td>
                            <td><?= $li->item_name; ?></td>
                            <td><?= $li->item_size; ?></td>
                            <td><?= $li->type; ?></td>
                            <td><?= $li->brand; ?></td>
                            <td><?= $li->color_name; ?></td>
                            <td><?= $li->dimension_name; ?></td>
                            <td><?= $li->unit_name; ?></td>
                            <td><?= $li->currency_id; ?></td>
                            <td><?= formatNumber($li->rm_qty); ?></td>
                            <td><?= formatNumber($li->cost); ?></td>
                            <td><?= formatNumber($li->Qty_Needed_ForSO); ?></td>
                            <td><?= formatNumber(floatval($li->cost) * floatval($li->Qty_Needed_ForSO)) ?></td>
                        </tr>
                    <?php endif; ?>
                    <?php
                    $product_code = $li->ITEM_CODE;
                    $qty_po = $li->QTY_PO_PERITEM;
                    $qty_deliver = $li->qtyDeliver;
                    $qty_outstanding = $li->RemainingQty;
                    $bom_code = $li->bom_code;
                    ?>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>

<?php
function penyebut($nilai)
{
    $nilai = abs($nilai);
    $huruf = array("", "Satu", "Dua", "Tiga", "Empat", "Lima", "Enam", "Tujuh", "Delapan", "Sembilan", "Sepuluh", "Sebelas");
    $temp = "";
    if ($nilai < 12) {
        $temp = " " . $huruf[$nilai];
    } else if ($nilai < 20) {
        $temp = penyebut($nilai - 10) . " Belas";
    } else if ($nilai < 100) {
        $temp = penyebut($nilai / 10) . " Puluh" . penyebut($nilai % 10);
    } else if ($nilai < 200) {
        $temp = " seratus" . penyebut($nilai - 100);
    } else if ($nilai < 1000) {
        $temp = penyebut($nilai / 100) . " Ratus" . penyebut($nilai % 100);
    } else if ($nilai < 2000) {
        $temp = " seribu" . penyebut($nilai - 1000);
    } else if ($nilai < 1000000) {
        $temp = penyebut($nilai / 1000) . " Ribu" . penyebut($nilai % 1000);
    } else if ($nilai < 1000000000) {
        $temp = penyebut($nilai / 1000000) . " Juta" . penyebut($nilai % 1000000);
    } else if ($nilai < 1000000000000) {
        $temp = penyebut($nilai / 1000000000) . " Milyar" . penyebut(fmod($nilai, 1000000000));
    } else if ($nilai < 1000000000000000) {
        $temp = penyebut($nilai / 1000000000000) . " Trilyun" . penyebut(fmod($nilai, 1000000000000));
    }
    return $temp;
}

function formatNumber($number)
{
    // Menggunakan number_format untuk menambahkan pemisah ribuan dan dua desimal
    $formattedNumber = number_format($number, 2, '.', ',');

    return $formattedNumber;
}
?>

<script>
    function ExportToExcel(type, fn, dl) {
        var elt = document.getElementById('tbl_exporttable_to_xls');
        var wb = XLSX.utils.table_to_book(elt, {
            sheet: "sheet1"
        });
        return dl ?
            XLSX.write(wb, {
                bookType: type,
                bookSST: true,
                type: 'base64'
            }) :
            XLSX.writeFile(wb, fn || ('OST PO vs MATERIAL BOM , PO DATE <?= $from ?> sd <?= $until ?>.' + (type || 'xlsx')));
    }
</script>

</html>