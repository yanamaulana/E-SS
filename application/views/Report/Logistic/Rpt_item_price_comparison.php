<!DOCTYPE html>
<html lang="en">

<head>
    <title><?= $this->config->item('init_app_name') ?> | Report Item Price Comparison <?= $Year . '-' . $Month ?> Vs Last <?= $Year_Minus ?></title>
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
                    <th colspan="10">Year :<?= $Year ?>, Month : <?= $Month ?></th>
                    <th colspan="4">Last Purchase on <?= $Year_Minus ?></th>
                </tr>
                <tr>
                    <th>ITEM CODE</th>
                    <th>ITEM Name</th>
                    <th>BIN</th>
                    <th>ITEM Type</th>
                    <th>ITEM Size (LxWxH)</th>
                    <th>Uom</th>
                    <th>Curr</th>
                    <th>Qty</th>
                    <th>Unit Price</th>
                    <th>Total Price</th>
                    <!-- Delimiter -->
                    <th>Last Purchase Price</th>
                    <th>Last Purchase Curr</th>
                    <th>Total Last Purchase Price</th>
                    <th>Last Purchase Qty</th>
                    <th>Total Purchase <?= $Year_Minus ?></th>
                </tr>
            </thead>
            <!-- Select , , ItemCategory_Name, , Item_Color, Color_Name, Item_Size,
            , , , , , , ,
            (SUM(Qty) * UnitPrice) as  , WhBin,  -->
            <tbody>
                <?php foreach ($DataSql as $li) : ?>
                    <tr>
                        <td><?= $li->Item_Code ?></td>
                        <td><?= $li->Item_Name ?></td>
                        <td><?= $li->Bin_Name ?></td>
                        <td><?= $li->Item_Type ?></td>
                        <td><?= floatval($li->Item_Length) ?> x <?= floatval($li->Item_Width) ?> x <?= floatval($li->Item_Height) ?></td>
                        <td><?= $li->Unit_Name ?></td>
                        <td><?= $li->Currency_ID ?></td>
                        <td><?= floatval($li->UnitPrice)  ?></td>
                        <td><?= floatval($li->Sum_Qty_RR) ?></td>
                        <td><?= floatval($li->total_price); ?></td>
                        <!-- Delimiter -->
                        <?php
                        $Sql_Compare = $this->db->query("SELECT TOP 1 RR_Date, TAccPO_Detail.Qty, TAccPO_Header.Currency_ID, TAccPO_Detail.UnitPrice, (TAccPO_Detail.Qty * TAccPO_Detail.UnitPrice) as Total_Price
                                                    from TAccRR_Item
                                                    join TAccRR_Header on TAccRR_Item.RR_Number = TAccRR_Header.RR_Number
                                                    join TAccPO_Header on TAccRR_Header.Ref_Number = TAccPO_Header.PO_Number
                                                    join TAccPO_Detail on TAccPO_Header.PO_Number = TAccPO_Detail.PO_Number
                                                    and TAccRR_Item.Item_Code = '$li->Item_Code' 
                                                    and TAccRR_Header.isVoid = 0 
                                                    and TAccRR_Header.Approval_Status not in (4)
                                                    and TAccPO_Header.isNotActive = 0
                                                    and TAccPO_header.Approval_Status not in (4)
                                                    and YEAR(TAccPO_Header.PO_Date) = '$Year_Minus'
                                                    order by TAccRR_Header.RR_Date desc")->row();
                        ?>
                        <td><?= empty($Sql_Compare->UnitPrice) ? 'No Data' : floatval($Sql_Compare->UnitPrice) ?></td>
                        <td><?= empty($Sql_Compare->Currency_ID) ? 'No Data' : $Sql_Compare->Currency_ID ?></td>
                        <td><?= empty($Sql_Compare->Qty) ? 'No Data' : floatval($Sql_Compare->Qty) ?></td>
                        <td><?= empty($Sql_Compare->Total_Price) ? 'No Data' : floatval($Sql_Compare->Total_Price) ?></td>
                        <?php $SqlCompareSumQty = $this->db->query("SELECT Item_Code, ISNULL(SUM(Qty),0) as Total_Qty_purchase
                            from TAccPO_Detail
                            join TAccPO_Header on TAccPO_Detail.PO_Number = TAccPO_Header.PO_Number
                            where Item_Code = '$li->Item_Code' 
                            and TAccPO_Header.isNotActive = 0
                            and TAccPO_header.Approval_Status not in (4)
                            and TAccPO_Header.isNotActive = 0
                            and year(PO_Date) = '$Year_Minus'
                            group by Item_Code")->row()  ?>
                        <td><?= empty($SqlCompareSumQty->Total_Qty_purchase) ? 'No Data' : floatval($SqlCompareSumQty->Total_Qty_purchase) ?></td>
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
            XLSX.writeFile(wb, fn || ('Report Item Price Comparison <?= $Year . '-' . $Month ?> Vs Last <?= $Year_Minus ?>.' + (type || 'xlsx')));
    }
</script>

</html>