<!DOCTYPE html>
<html lang="en">

<head>
    <title><?= $this->config->item('init_app_name') ?> | Report Po item, ETA date <?= $from ?> sd <?= $until ?></title>
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
                    <th>PO NUMBER</th>
                    <th>EstimateDate</th>
                    <th>Vendor</th>
                    <th>ITEM CODE</th>
                    <th style="width: 20%;">ITEM NAME</th>
                    <th>SIZE</th>
                    <!-- <th>TYPE</th> -->
                    <th>QTY</th>
                    <th>UOM</th>
                    <th>RR QTY</th>
                    <th>OST QTY</th>
                    <th>Curr</th>
                    <th>UNIT PRICE</th>
                    <th>AMOUNT</th>
                </tr>
            </thead>
            <tbody>
                <?php if ($query->num_rows() > 0) : ?>
                    <?php foreach ($query->result() as $li) : ?>
                        <!-- SELECT TAccPO_Detail.PODetail_ID, TAccPO_Detail.Po_number, TAccPO_header.PO_Date, TAccPO_Header.Currency_ID,TAccPO_header.EstTimeArrival, TAccPO_Detail.Item_Code, TAccPO_Detail.Qty, TAccPO_Detail.Qty_RR, TAccPO_Detail.UnitPrice, TAccPO_Detail.Base_UnitPrice, TAccPO_Detail.Disc_percentage, TAccPO_Detail.Tax_Code1, TAccPO_Detail.Tax_Percentage1, TAccPO_Detail.Tax_Operator1, isnull(TAccPO_Detail.Tax_Amount1, 0) as Tax_Amount1, TAccPO_Detail.Tax_Code2, TAccPO_Detail.Tax_Percentage2, TAccPO_Detail.Tax_Operator2, isnull(TAccPO_Detail.Tax_Amount2, 0) as Tax_Amount2, TAccPO_Detail.TotalPrice, TAccPO_Detail.Base_TotalPrice, TAccPO_Detail.Others, TAccPO_Detail.Include_RR, TAccPO_Detail.EstimateDate, TAccPO_Detail.Comp_ID, TAccPO_Detail.Parent_Item, TAccPO_Detail.Parent_Path, TAccPO_Detail.Generate_Flag, TAccPO_Detail.config_level, TAccPO_Detail.config_ratio, TAccPO_Detail.config_order, TAccPO_Detail.preq_id, TAccPO_Detail.Dimension_ID, TAccPO_Header.POType,  Titem.Item_name, tgscolor.color_name, titem.customfield1 AS item_type,  titem.item_size AS brand,  titem.item_length, titem.item_width, titem.item_height, TAccPO_Header.Account_ID, TAccount.Account_Address1,  Titem.PriceType,  TAccPO_Header.Tax_Code AS VAT_Tax_Code, TItemDimension.Dimension_Name,  ISNULL(MOQ, 0) MOQ -->
                        <tr>
                            <td><?= $li->Po_number; ?></td>
                            <td><?= format_rpt_date($li->EstimateDate); ?></td>
                            <td><?= $li->Account_Name ?></td>
                            <td><?= $li->Item_Code; ?></td>
                            <td><?= $li->Item_name; ?></td>
                            <td><?= $li->item_length; ?> x <?= $li->item_width; ?> x <?= $li->item_height; ?> mm</td>
                            <!-- <td><= $li->item_type; ?></td> -->
                            <td><?= floatval($li->Qty); ?></td>
                            <?php $SqlUom = $this->db->query("SELECT TITEM.Unit_Type_ID, TACCUNITTYPE.Unit_Name 
                            FROM TITEM INNER JOIN TACCUNITTYPE ON TACCUNITTYPE.Unit_Type_ID = TITEM.Unit_Type_ID 
                            WHERE TITEM.Item_Code = 'SU016824'"); ?>
                            <?php if ($SqlUom->num_rows() > 0) : ?>
                                <?php $RowUom = $SqlUom->row(); ?>
                                <td><?= $RowUom->Unit_Name; ?></td>
                            <?php else : ?>
                                <td>-</td>
                            <?php endif; ?>
                            <?php
                            $QrrQty = $this->db->query("SELECT TACCRR_ITEM.ITEM_CODE,SUM(TACCRR_ITEM.QTY) AS RR_QTY from TAccRR_Item
								INNER JOIN TACCRR_HEADER ON TACCRR_HEADER.RR_NUMBER=TACCRR_ITEM.RR_NUMBER
								WHERE TACCRR_HEADER.REF_NUMBER='PWU2012312-0003957'
								AND TACCRR_ITEM.ITEM_CODE='$li->Item_Code'
								AND TACCRR_ITEM.DIMENSION_ID='$li->Dimension_ID'
								AND ISNULL(TACCRR_HEADER.ISVOID,0)=0
								AND TACCRR_HEADER.APPROVAL_STATUS <> 4
								GROUP BY TACCRR_ITEM.ITEM_CODE");
                            ?>
                            <?php if ($QrrQty->num_rows() > 0) : ?>
                                <?php $RowRRqty = $QrrQty->row();
                                $RRQTY = floatval($RowRRqty->RR_QTY); ?>
                                <td><?= floatval($RowRRqty->RR_QTY) ?></td>
                            <?php else : ?>
                                <?php $RRQTY = 0; ?>
                                <td>0</td>
                            <?php endif; ?>
                            <td><?= floatval($li->Qty) - $RRQTY ?></td>
                            <td><?= $li->Currency_ID ?></td>
                            <td><?= formatNumber($li->UnitPrice); ?></td>
                            <td><?= formatNumber($li->TotalPrice); ?></td>
                        </tr>
                    <?php endforeach; ?>
                <?php else : ?>
                    <tr>
                        <th colspan="10" class="text-center">--- Data Not Found ---</th>
                    </tr>
                <?php endif; ?>
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
            XLSX.writeFile(wb, fn || ('Report Po item, ETA date <?= $from ?> sd <?= $until ?>.' + (type || 'xlsx')));
    }
</script>

</html>