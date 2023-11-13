<!DOCTYPE html>
<html lang="en">
<title><?= $this->config->item('init_app_name') ?></title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="shortcut icon" href="<?= base_url() ?>assets/E-SBA_assets/web-logo/favicon.ico" />
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

<head>
    <title><?= $vin ?></title>
</head>
<?php $i = 1; ?>

<body>
    <div class="row">
        <table class="tablee">
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
        <table class="table-ttd">
            <thead>
            </thead>
            <tbody>
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
?>

</html>