<!DOCTYPE html>
<html lang="en">
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="shortcut icon" href="<?= base_url() ?>assets/E-SBA_assets/web-logo/favicon.ico" />
<style>
    @page {
        size: A4 landscape;
        margin: 20px 20px 20px 20px;
        font-size: 10pt !important;
        font-family: sans-serif;
    }

    @media print {
        @page {
            size: A4 landscape;
            margin: 20px 20px 20px 20px;
            font-size: 10pt !important;
            font-family: sans-serif;
        }
    }

    html,
    body {
        /* height: 200mm; */
        width: 297mm;
        background: #FFF;
        overflow: visible;
    }

    .table-ttd {
        border-collapse: collapse;
        width: 295mm;
        margin-left: 1mm;
        font-size: 10pt !important;
        font-family: sans-serif;
    }

    h3 {
        font-family: sans-serif;
    }

    .table-ttd tr,
    .table-ttd tr td {
        border: 0.5px solid black;
        padding: 4px;
        padding: 4px;
        font-size: 10pt !important;
        font-family: sans-serif;
    }

    input,
    textarea,
    select {
        font-family: inherit;
    }

    .table-ttd tr,
    .table-ttd tr td {
        border: 1px solid black;
        padding: 3px;
        padding: 3px;
        font-size: 10pt !important;
    }

    /* tr {
        page-break-before: always;
        page-break-inside: avoid;
        font-size: 10pt !important;
    } */

    .tablee td,
    .tablee th {
        border-collapse: collapse;
        /* border: 0.5px solid black; */
        padding: 2.5px;
        font-size: 10pt !important;
        font-size: 10pt !important;
        font-family: sans-serif;
    }


    /* ul,
    li {
        list-style-type: none;
        font-size: 10pt !important;
    } */

    .table-ttd thead tr td,
    #tr-footer {
        font-weight: bold;
        font-family: sans-serif;
    }

    .container {
        display: flex;
        justify-content: space-between;
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

    .tablee {
        border-collapse: collapse;
        border-spacing: 0;
        width: 148mm;
        /* border: 1px solid #ddd; */
    }

    .tablee th,
    .tablee td {
        padding: 2.5px;
    }

    .table-loop tr,
    .table-loop tr td {
        padding: 7px !important;
    }
</style>

<head>
    <title>Report Cbr - <?= $CbrHeader->CBReq_No ?></title>
</head>
<?php
$i = 1;
function format_rupiah($angka)
{
    $rupiah = number_format($angka, 2, ',', '.');
    return $rupiah;
}
?>

<body>
    <div class="row">
        <table class="table-ttd" style="width: 100%;">
            <tr>
                <td>SLIP DATE</td>
                <td><?= substr($CbrHeader->Document_Date, 0, 10) ?></td>
                <td rowspan="3" class="text-center"><b style="font-size: 16pt; width: 40%;">PAYMENT RESOLUTION</b></td>
                <td>INPUT DEPT</td>
                <td><?= $CbrHeader->Input_Dept ?></td>
            </tr>
            <tr>
                <td>SLIP NO</td>
                <td><?= $CbrHeader->CBReq_No ?></td>
                <td>INPUT NAME</td>
                <td><?= $CbrHeader->Input_Name ?></td>
            </tr>
            <tr>
                <td>PAGE</td>
                <td><?= "1 - 1" ?></td>
                <td>OUTPUT NAME</td>
                <td><?= $CbrHeader->Output_Name ?></td>
            </tr>
        </table>

        <table class="table-ttd table-loop" style="width: 100%;">
            <tr>
                <td class="text-center">NO</td>
                <td class="text-center">DESCRIPTION</td>
                <td class="text-center">ACCOUNT</td>
                <td class="text-center" style="border-right: solid black 8px;">AMOUNT</td>
                <td class="text-center"></td>
                <td class="text-center"></td>
            </tr>
            <?php
            $Must = 9;
            $There =  $CbrDetail->num_rows();
            $RestLine = $Must - $There;
            ?>
            <?php foreach ($CbrDetail->result() as $li) : ?>
                <tr>
                    <td style="width: 3%;"><?= $i ?></td>
                    <td><?= $li->Description ?></td>
                    <td><?= '[' . $li->Acc_ID . ']' . ' ' . $li->Account_Name ?></td>
                    <td style="border-right: solid black 8px; width: 15%;">
                        <div class="container">
                            <div style="text-align: left;"><?= $li->currency_id ?></div>
                            <div style="text-align: right;"><?= format_rupiah($li->Amount_Detail) ?></div>
                        </div>
                    </td>
                    <td style="border-right: none;">
                        <?php
                        if ($i == 1) {
                            echo 'Date Line';
                        } else if ($i == 2) {
                            echo 'Amount of Payment';
                        } else if ($i == 3) {
                            echo '1st Payment';
                        } else if ($i == 4) {
                            echo '2nd Payment';
                        } else if ($i == 5) {
                            echo 'Discount';
                        } else if ($i == 6) {
                            echo 'Amount of Deduction';
                        } else if ($i == 7) {
                            echo 'Sum of Payment';
                        } else {
                            echo '';
                        }
                        ?>
                    </td>
                    <td style="border-left: none;"><b>:</b>
                        <?php
                        if ($i == 1) {
                            echo substr($CbrHeader->duedate, 0, 10);
                        } else {
                            echo ' ';
                        }
                        ?>
                    </td>
                    <?php $i++; ?>
                </tr>
            <?php endforeach; ?>
            <?php for ($loop = 1; $loop <= $RestLine; $loop++) : ?>
                <tr>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td style="border-right: solid black 8px;">&nbsp;</td>
                    <td style="border-right: none;">
                        <?php
                        if ($i == 1) {
                            echo 'Date Line';
                        } else if ($i == 2) {
                            echo 'Amount of Payment';
                        } else if ($i == 3) {
                            echo '1st Payment';
                        } else if ($i == 4) {
                            echo '2nd Payment';
                        } else if ($i == 5) {
                            echo 'Discount';
                        } else if ($i == 6) {
                            echo 'Amount of Deduction';
                        } else if ($i == 7) {
                            echo 'Sum of Payment';
                        } else {
                            echo '';
                        }
                        ?>
                    </td>
                    <td style="border-left: none;"><b>:</b>
                        <?php
                        if ($i == 1) {
                            echo substr($CbrHeader->duedate, 0, 10);
                        } else {
                            echo ' ';
                        }
                        ?>
                    </td>
                    <?php $i++; ?>
                </tr>
            <?php endfor; ?>
            <tr>
                <td colspan="2">TOTAL AMOUNT</td>
                <td>TOTAL ==> <?= $CbrHeader->Currency_ID ?></td>
                <td style="border-right: solid black 8px;">
                    <?php if ($CbrHeader->Currency_ID == 'IDR') : ?>
                        <div class="container">
                            <div style="text-align: left;"><?= $CbrHeader->Currency_ID ?></div>
                            <div style="text-align: right;"><?= format_rupiah($CbrHeader->Amount) ?></div>
                        </div>
                    <?php else : ?>
                        <div class="container">
                            <div style="text-align: left;"><?= $CbrHeader->Currency_ID ?></div>
                            <div style="text-align: right;"><?= format_rupiah($CbrHeader->Amount) ?></div>
                        </div>
                        <div class="container">
                            <div style="text-align: left;"><?= 'IDR' ?></div>
                            <div style="text-align: right;"><?= format_rupiah($CbrHeader->BaseAmount) ?></div>
                        </div>
                    <?php endif; ?>
                </td>
                <td colspan="2">
                    <?php if ($CbrHeader->Currency_ID == 'IDR') : ?>
                        <div class="container">
                            <div style="text-align: left;"><?= $CbrHeader->Currency_ID ?></div>
                            <div style="text-align: right;"><?= format_rupiah($CbrHeader->Amount) ?></div>
                        </div>
                    <?php else : ?>
                        <div class="container">
                            <div style="text-align: left;"><?= $CbrHeader->Currency_ID ?></div>
                            <div style="text-align: right;"><?= format_rupiah($CbrHeader->Amount) ?></div>
                        </div>
                        <div class="container">
                            <div style="text-align: left;"><?= 'IDR' ?></div>
                            <div style="text-align: right;"><?= format_rupiah($CbrHeader->BaseAmount) ?></div>
                        </div>
                    <?php endif; ?>
                </td>

            </tr>
        </table>
    </div>
</body>

</html>