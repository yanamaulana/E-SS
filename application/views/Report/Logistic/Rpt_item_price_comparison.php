<!DOCTYPE html>
<html lang="en">

<head>
    <title><?= $this->config->item('init_app_name') ?> | Report Item Price Comparison <?= $Year ?> Vs Under <?= $Year ?></title>
    <script type="text/javascript" src="https://unpkg.com/xlsx@0.15.1/dist/xlsx.full.min.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="shortcut icon" href="<?= base_url() ?>assets/E-SBA_assets/web-logo/favicon.ico" />
</head>
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

function format_rpt_date($dateString)
{
    $dateTime = new DateTime($dateString);
    $formattedDate = $dateTime->format('d F Y');

    return $formattedDate;
}

function parseCurrencyRates($str)
{
    $pairs = explode(';', $str);
    $rates = [];
    foreach ($pairs as $pair) {
        list($key, $value) = explode('|', $pair);
        $rates[$key] = $value;
    }
    return $rates;
}

function getCurrencyRate($rates, $currency)
{
    if (array_key_exists($currency, $rates)) {
        return floatval($rates[$currency]);
    }
    return null;
}
?>
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
        width: 98%;
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
        /* white-space: nowrap; */
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
                    <th colspan="14">RR 2024</th>
                    <th colspan="3">RR DIBAWAH <?= $Year ?></th>
                    <th colspan="5">KESIMPULAN</th>
                </tr>
                <tr>
                    <th>RR NUMBER</th>
                    <th>RR DATE</th>
                    <th>ITEM CODE</th>
                    <th>ITEM NAME</th>
                    <th>BIN</th>
                    <th>ITEM TYPE</th>
                    <th>ITEM SIZE (LxWxH)</th>
                    <th>UOM</th>
                    <th>UNIT PRICE</th>
                    <th>CURR</th>
                    <th>RATE TO IDR</th>
                    <th>QTY RR</th>
                    <th>TOTAL PRICE ORIGINAL CURRENCY</th>
                    <th>TOTAL PRICE IDR</th>

                    <!-- ============================= Delimiter ======================== -->

                    <th>RR DATE - UNDER 2024</th>
                    <th>UNIT PRICE - UNDER 2024</th>
                    <th>CURRENCY</th>

                    <!-- ============================= Delimiter ======================== -->

                    <td>KONKLUSI HARGA</td>
                    <td>KESAMAAN CURRENCY</td>
                    <td>GAP HARGA</td>
                    <td>CURR</td>
                    <td>QTY RR x GAP HARGA</td>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($DataSql as $li) : ?>
                    <?php
                    // $Rate = 1;
                    // if ($li->Currency_ID != 'IDR') {
                    //     $currencyRates = $li->CurrencyRateList;
                    //     $rates         = parseCurrencyRates($currencyRates);
                    //     $curr          = $li->Currency_ID;
                    //     $Rate          = getCurrencyRate($rates, $curr);
                    // }
                    // 
                    ?>
                    <tr>
                        <td><?= $li->RR_Number ?></td>
                        <td><?= $li->RR_Date ?></td>
                        <td><?= $li->Item_Code ?></td>
                        <td><?= $li->Item_Name ?></td>
                        <td><?= $li->Bin_Name ?></td>
                        <td><?= $li->Item_Type ?></td>
                        <td><?= floatval($li->Item_Length) ?> x <?= floatval($li->Item_Width) ?> x <?= floatval($li->Item_Height) ?></td>
                        <td><?= $li->Unit_Name ?></td>
                        <td><?= $li->UnitPrice ?></td>
                        <td><?= $li->Currency_ID ?></td>
                        <td><?php
                            $Rate = 1;
                            if ($li->Currency_ID != 'IDR') {
                                $TAccJournal = $this->db->query("SELECT TOP 1 curr_rate from TAccJournalDetail where JournalH_Code = '$li->RR_Number' and JournalD_Kredit > 0")->row();
                                $Rate = floatval($TAccJournal->curr_rate);
                            }
                            echo $Rate;
                            ?></td>
                        <td><?= $li->Qty ?></td>
                        <td><?= $li->total_price ?></td>
                        <td><?= $li->total_price * $Rate ?></td>
                        <!-- Delimiter -->
                        <?php
                        $Sql_Compare = $this->db->query("SELECT 
                        TOP 1 
                        TAccRR_Header.RR_Date, 
                        TAccRR_Header.RR_Number, 
                        -- TAccPO_Header.CurrencyRateList, 
                        TAccPO_Detail.Qty, 
                        TAccPO_Header.Currency_ID,
                        -- TAccPO_Detail.UnitPrice,
                        TAccPO_Detail.Disc_percentage,
                        -- Menghitung harga setelah diskon
                        (TAccPO_Detail.UnitPrice * (1 - (TAccPO_Detail.Disc_percentage / 100.0))) AS UnitPrice
                    FROM TAccRR_Item
                    JOIN TAccRR_Header ON TAccRR_Item.RR_Number = TAccRR_Header.RR_Number
                    LEFT JOIN TAccPO_Header ON TAccRR_Header.Ref_Number = TAccPO_Header.PO_Number
                    LEFT JOIN TAccPO_Detail ON TAccPO_Header.PO_Number = TAccPO_Detail.PO_Number AND TAccRR_Item.Item_Code = TAccPO_Detail.Item_Code
                    WHERE TAccRR_Item.Item_Code = '$li->Item_Code'
                        AND TAccRR_Header.isVoid = 0 
                        AND TAccRR_Header.Approval_Status = 3 
                        AND TAccRR_Header.RR_Status = 3
                        AND TAccPO_Header.Approval_Status = 3
                        AND TAccPO_Header.PO_Status = 3
                        AND YEAR(TAccRR_Header.RR_Date) = '$Year_Minus'
                    ORDER BY TAccRR_Header.RR_Date DESC;")->row();
                        ?>
                        <td><?= empty($Sql_Compare->RR_Date) ? '-' : (new DateTime($Sql_Compare->RR_Date))->format('Y-m-d') ?></td>
                        <!-- <php
                        $ValueIDR2 = empty($Sql_Compare->UnitPrice) ? 0 : $Sql_Compare->UnitPrice;
                        $Currency_ID = empty($Sql_Compare->Currency_ID) ? NULL : $Sql_Compare->Currency_ID;
                        if ($Currency_ID != 'IDR') {
                            if (!empty($Currency_ID)) {
                                $currencyRates = $Sql_Compare->CurrencyRateList;
                                $rates      = parseCurrencyRates($currencyRates);
                                $curr       = $Sql_Compare->Currency_ID;
                                $Rate       = getCurrencyRate($rates, $curr);
                            }
                        }
                        ?> -->
                        <td><?= empty($Sql_Compare->UnitPrice) ? 0 : floatval($Sql_Compare->UnitPrice) ?></td>
                        <td><?= empty($Sql_Compare->Currency_ID) ? $li->Currency_ID : $Sql_Compare->Currency_ID ?></td>
                        <!-- ============================= Delimiter ======================== -->

                        <td><?php
                            $_UnitPrice = empty($Sql_Compare->UnitPrice) ? 0 : floatval($Sql_Compare->UnitPrice);
                            $_Currency_ID = empty($Sql_Compare->Currency_ID) ? 0 : $Sql_Compare->Currency_ID;
                            if ($li->Currency_ID == $_Currency_ID) {
                                $G5 = $li->UnitPrice;
                                $L5 = empty($_UnitPrice) ? 0 : floatval($_UnitPrice);
                            } else if ($li->Currency_ID == 'IDR' && $_Currency_ID != 'IDR') {
                                $G5 = $li->UnitPrice;
                                $L5 = ($_UnitPrice * $Rate);
                            } else if ($li->Currency_ID != 'IDR' && $_Currency_ID != 'IDR') {
                                $G5 = $li->UnitPrice;
                                $L5 = ($_UnitPrice / $Rate);
                            } else {
                                $G5 = $li->UnitPrice;
                                $L5 = empty($_UnitPrice) ? 0 : floatval($_UnitPrice);
                            }

                            if ($L5 == 0) {
                                $result = "New Item";
                            } elseif ($G5 > $L5) {
                                $result = "increases";
                            } elseif ($G5 == $L5) {
                                $result = "Equal";
                            } else {
                                $result = "Reduction";
                            }

                            echo $result; ?>
                        </td>
                        <td><?= ($li->Currency_ID == $_Currency_ID) ? 'SAMA' : 'BEDA'; ?></td>
                        <td>
                            <?php
                            if ($li->Currency_ID == $_Currency_ID) {
                                $Gap = floatval($li->UnitPrice) - $_UnitPrice;
                            } else if ($li->Currency_ID == 'IDR' && $_Currency_ID != 'IDR') {
                                $Gap = floatval($li->UnitPrice) - ($_UnitPrice * $Rate);
                            } else if ($li->Currency_ID != 'IDR' && $_Currency_ID != 'IDR') {
                                $Gap = floatval($li->UnitPrice) - ($_UnitPrice / $Rate);
                            } else {
                                $Gap = floatval($li->UnitPrice) - $_UnitPrice;
                            }
                            echo $Gap;
                            ?>
                        </td>
                        <td><?= $li->Currency_ID ?></td>
                        <td><?= $li->Qty * $Gap ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>

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
            XLSX.writeFile(wb, fn || ('Report Item Price Comparison <?= $Year ?> Vs Under <?= $Year ?>.' + (type || 'xlsx')));
    }
</script>

</html>