<!DOCTYPE html>
<html lang="en">
<?php
function terbilang($n, $c)
{
    $n = (float) $n;
    $units = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    $tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    $levels = ['', 'Thousand', 'Million', 'Billion', 'Trillion'];

    if ($n == 0) return 'Zero';

    $n = number_format($n, 2, '.', ',');
    $parts = explode('.', $n);
    $intPart = str_replace(',', '', $parts[0]);
    $intPart = (int) $intPart;

    $res = '';
    $level = 0;

    while ($intPart > 0) {
        $num = $intPart % 1000;
        if ($num > 0) {
            $chunk = '';
            if ($num >= 100) {
                $chunk .= $units[(int)($num / 100)] . ' Hundred ';
                $num %= 100;
            }
            if ($num >= 20) {
                $chunk .= $tens[(int)($num / 10)];
                if ($num % 10 > 0) $chunk .= '-' . $units[$num % 10];
                $chunk .= ' ';
            } else if ($num > 0) {
                $chunk .= $units[$num] . ' ';
            }
            $res = $chunk . $levels[$level] . ' ' . $res;
        }
        $intPart = (int)($intPart / 1000);
        $level++;
    }

    return trim($res) . " $c";
}
?>

<head>
    <meta charset="UTF-8">
    <title>Bank Disbursement - <?= $header->JournalH_Code ?></title>
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
    </style>
</head>

<body>
    <table width="100%" border="0">
        <tr>
            <td width="50%"><strong><?= $company->company_name ?></strong></td>
            <td width="50%" class="text-right">
                NO. : <?= $header->JournalH_Code ?><br>
                Date : <?= date('d/m/Y', strtotime($header->CashBookDate)) ?>
            </td>
        </tr>
    </table>

    <h3 class="text-center">Bank Disbursement</h3>

    <table width="100%" style="font-size: 10pt; margin-bottom: 10px;">
        <tr>
            <td width="12%">Paid to</td>
            <td width="2%">:</td>
            <td><?= $header_k->Payor_Payee ?></td>
            <td width="15%">Bank</td>
            <td width="2%">:</td>
            <td><?= $header_k->Account_NameEn ?></td>
        </tr>
        <tr>
            <td>Memo</td>
            <td>:</td>
            <td><?= $header_k->Memo ?></td>
            <td>Account Number</td>
            <td>:</td>
            <td><?= $header_k->Account_Number ?></td>
        </tr>
    </table>

    <table class="table-ttd">
        <thead>
            <tr id="tr-footer">
                <td class="text-center" width="5%">No.</td>
                <td class="text-center" width="35%">Description</td>
                <td class="text-center" width="25%">Account</td>
                <td class="text-center" width="17%">Debit</td>
                <td class="text-center" width="17%">Credit</td>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class="text-center">1</td>
                <td><?= $header_k->Account_NameEn ?></td>
                <td><?= $header_k->Account_Number ?> - <?= $header_k->Account_Name ?></td>
                <td class="text-right"><?= $header_k->Currency_ID  ?> 0</td>
                <td class="text-right"><?= $header_k->Currency_ID  ?> ( <?= number_format($header_k->Total_Amount, 2) ?> )</td>
            </tr>
            <?php
            $no = 2;
            $tD = 0;
            $tC = 0;
            foreach ($details as $row):
                // Logika memisahkan Debet/Kredit berdasarkan kolom DebCred
                $debit = ($row->DebCred == 'D') ? $row->Amount : 0;
                $kredit = ($row->DebCred == 'K') ? $row->Amount : 0;

                $tD += $debit;
                $tC += $kredit;
            ?>
                <tr>
                    <td class="text-center"><?= $no++ ?></td>
                    <td><?= $row->Description ?><?= !empty($row->Invoice_No) ? '<br><br>[' . $row->Invoice_No . ']' : '' ?></td>
                    <td><?= $row->Account_Number ?> - <?= $row->Account_Name ?></td>
                    <td class="text-right"><?= $header_k->Currency_ID  ?> <?= number_format($debit, 2) ?></td>
                    <td class="text-right"><?= $header_k->Currency_ID  ?> ( <?= number_format($kredit, 2) ?> )</td>
                </tr>
            <?php endforeach; ?>
        </tbody>
        <tfoot>
            <tr id="tr-footer">
                <td colspan="3" class="text-right">Total</td>
                <td class="text-right"><?= $header_k->Currency_ID ?> <?= number_format($tD, 4) ?></td>
                <td class="text-right"><?= $header_k->Currency_ID ?> <?= number_format($header_k->Total_Amount, 4) ?></td>
            </tr>
        </tfoot>
    </table>

    <p style="font-style: italic;"><strong>Stated : </strong> <?= terbilang($header_k->Total_Amount, $header_k->words_en) ?></p>

    <script>
        // window.print();
    </script>
</body>

</html>

</html>