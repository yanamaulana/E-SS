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
    <?php
    // Mengambil data Currency_ID dari TCurrency
    $qGetCurrency = $this->db->query("SELECT Currency_ID FROM TCurrency WHERE Status = 1");
    $results = $qGetCurrency->result_array();

    // Inisialisasi variabel intGrandTotal
    foreach ($results as $currency) {
        ${"intGrandTotal" . $currency['Currency_ID']} = 0;
    }
    ?>

    <div class="row">
        <table class="table-ttd">
            <thead>
                <tr>
                    <th rowspan="2">No</th>
                    <th colspan="3">Sales Order</th>
                    <th rowspan="2">Customer Name</th>
                    <th colspan="2">Item</th>
                    <th rowspan="2">Unit Name</th>
                    <th rowspan="2">Color</th>
                    <th rowspan="2">Brand</th>
                    <th rowspan="2">Type</th>
                    <th rowspan="2">Qty</th>
                    <th rowspan="2">Currency</th>
                    <th rowspan="2">Price</th>
                    <th rowspan="2">Disc Value</th>
                    <th rowspan="2">Discount</th>
                    <th rowspan="2">Tax 1</th>
                    <th rowspan="2">Tax 2</th>
                    <th rowspan="2">Total Amount</th>
                    <th colspan="4">Shipment Note</th>
                    <th rowspan="2">Remaining Qty</th>
                    <th colspan="2">Invoice</th>
                </tr>
                <tr>
                    <th>Sales Order Number</th>
                    <th>SO Date</th>
                    <th>Create Date</th>
                    <th>Item Code</th>
                    <th>Item Description</th>
                    <th>Shipment Note Number</th>
                    <th>SN Date</th>
                    <th>Create Date</th>
                    <th>Qty Delivered</th>
                    <th>Invoice No</th>
                    <th>Invoice Date</th>
                </tr>
            </thead>
            <?php
            $sql = "SELECT TAccSO_Header.SO_Number as DocNumber,
            TAccSO_Header.Approval_Status,
            TAccSO_Header.SO_Date as DocDate,
            TAccSO_Header.SO_Notes,
            TAccSO_Header.Creation_DateTime as CreateDate, ";
            if ($rdocurrency == "Doc") {
                $sql .= "TAccSO_Header.currency_id, ";
            } elseif ($rdocurrency == "Base") {
                $sql .= "'IDR' as currency_id, ";
            } else {
                $sql .= "TAccSO_Header.currency_id, ";
            }
            $sql .= "TAccSO_Header.Account_ID,
            TAccSO_Header.SN_Status, 
            TAccSO_Header.isTaxAble,
            TAccSO_Detail.tax_code1 as tax_code1,
            TAccSO_Detail.tax_percentage1,
            TAccSO_Detail.tax_amount1,
            TAccSO_Detail.tax_operator1,
            TAccSO_Detail.tax_code2 as tax_code2,
            TAccSO_Detail.tax_percentage2,
            TAccSO_Detail.tax_amount2,
            TAccSO_Detail.tax_operator2,
            TAccSO_Detail.Item_code,
            TAccSO_Detail.qty as qty,
            TAccSO_Detail.extraprice,
            0 AS AdditionalCost,";
            if ($rdocurrency == "Doc") {
                $sql .= "TAccSO_Detail.Unitprice as unitprice, ";
            } elseif ($rdocurrency == "Base") {
                $sql .= "TAccSO_Detail.Base_unitprice as unitprice, ";
            } else {
                $sql .= "TAccSO_Detail.Unitprice as unitprice, ";
            }
            $sql .= "TAccSO_Detail.Disc_percentage as Disc_percentage,
            TAccSO_Detail.Disc_Value as Disc_Value,
            TaccSO_Detail.dimension_id,
            Dimension_Name,
            TAccount.Cust_FG,
            TAccount.Cust_Ast,
            TAccount.Cust_RM,
            TAccount.Cust_SP,
            TAccount.AccountTitle_Code,
            TAccount.Account_Name,
            Titem.Item_name,
            titem.customfield1 as item_type, 
            titem.item_size as brand, 
            tgscolor.color_name,
            titem.item_length,
            titem.item_width,
            titem.item_height,
            (SELECT Unit_Name FROM TaccUnitType WHERE Unit_Type_ID=TItem.Unit_Type_ID) AS Unit_Name,
            ISNULL((SELECT SUM(taccSN_Item.Qty) FROM taccSN_Header INNER JOIN taccSN_Item ON taccSN_Item.SN_number = taccSN_Header.SN_number
            WHERE	TAccSN_Item.SO_number = TaccSO_Header.SO_Number
            AND isNull(TAccSN_Header.isVoid,0) = 0 AND taccSN_Item.Item_code = TaccSO_Detail.item_code 
            AND taccSN_Item.dimension_id = TaccSO_Detail.dimension_id
            AND taccSN_Header.Approval_Status = 3),0) AS qtyDeliver,
            ISNULL((SELECT SUM(Invoice_Amount) FROM TAccSI_Header WHERE TaccSI_Header.SO_Number = TaccSO_Header.SO_Number AND isNull(TAccSI_Header.isVoid,0) = 0),0) AS Invoice_Amount,
            IsNull(TAccSO_Header.TransactionDiscountRate,0) AS TransDiscRate,
            TAccSO_Header.SOType AS TaxType,
            TAccSO_Header.Tax_Code
            FROM TAccSO_Header INNER JOIN TAccSO_Detail ON TAccSO_Detail.SO_Number = TAccSO_Header.SO_Number
            INNER JOIN Titem ON TAccSO_Detail.Item_Code = Titem.Item_Code 
            INNER JOIN TITEMCOMPANY ON TITEMCOMPANY.ITEM_CODE = TAccSO_Detail.ITEM_CODE AND TAccSO_Detail.Dimension_ID = TITEMCOMPANY.Dimension_ID AND TITEMCOMPANY.COMPANY_ID = TAccSO_Header.COMPANY_ID
            INNER JOIN TItemCategory ON TItemCategory.ItemCategory_ID = TITEMCOMPANY.ItemCategory_ID
            INNER JOIN TAccount ON TAccount.Account_ID = TAccSO_Header.Account_ID 
            INNER JOIN TItemDimension ON TItemDimension.Dimension_ID = TAccSO_Detail.Dimension_ID
            LEFT JOIN tgscolor ON tgscolor.color_code = titem.item_color
            WHERE	TAccSO_Header.SO_Date >= {d '$from'}
            AND 	TAccSO_Header.SO_Date <{d '$until'} 

            -- AND		TAccSO_Header.ItemCategoryType = 'FG'
            AND		TAccSO_Header.Company_ID = 2

            -- AND		TAccSO_Header.WH_ID = 9 
            AND (TAccSO_Header.IsNotActive is NULL or TAccSO_Header.IsNotActive <> 1)
            AND (((TAccount.Cust_FG = 1) AND TItemcategory.ItemCategoryType = 'FG') OR
            	((TAccount.Cust_RM = 1) AND TItemcategory.ItemCategoryType = 'RM') OR
            	((TAccount.Cust_SP = 1) AND TItemcategory.ItemCategoryType = 'SP') OR
				((TAccount.Cust_SF = 1) AND TItemcategory.ItemCategoryType = 'SF') OR
            	((TAccount.Cust_WIP = 1) AND TItemcategory.ItemCategoryType = 'WIP'))
            AND	TAccount.Category_ID IN (SELECT DISTINCT CATEGORY_ID FROM TDATAGROUPACCOUNT WHERE DATAGROUP_ID IN (20,86)) ";
            if ($customer != 'ALL') {
                $sql .= "AND TAccount.account_id IN ($customer) ";
            }
            if ($sales_type != 'ALL') {
                $sql .= "AND TAccSO_Header.isExport = $sales_type ";
            }
            $sql .= " ORDER BY (CAST(DATEPART(yyyy,TAccSO_Header.SO_Date) AS VARCHAR(5)) + '-' + RIGHT('00' + CAST(DATEPART(mm,TAccSO_Header.SO_Date) AS VARCHAR(5)),2) + '-' + RIGHT('00' + CAST(DATEPART(dd,TAccSO_Header.SO_Date) AS VARCHAR(5)),2)), RIGHT(TAccSO_Header.SO_Number,5) ASC";

            $data = $this->db->query($sql);
            $RecordCount = $data->num_rows();
            $qVendor = $data->result();

            $grandtotal = 0;
            $isSameNum = "";
            $TotPerSO = 0;
            $TotInvoice = 0;
            $TotDisc = 0;
            $TotQTY = 0;
            $TotPrice = 0;
            $TotQTYD = 0;
            $rowspan = 0;
            $rowInvoiceAmount = 0;
            $intLoop = 0;
            $i = 1;

            ?>
            <tbody>
                <?php foreach ($qVendor as $li) : ?>
                    <tr>
                        <?php if ($isSameNum != $li->DocNumber) : ?>
                            <?php $intLoop = $intLoop + 1; ?>
                            <td align="right"><?= $intLoop ?></td>
                        <?php else : ?>
                            <td align="right">&nbsp;</td>
                        <?php endif; ?>
                        <td><?= $li->DocNumber ?></td>
                        <td><?= date("d-m-Y", strtotime($li->DocDate)) ?></td>
                        <td><?= date("d-m-Y", strtotime($li->CreateDate)); ?></td>
                        <td>
                            <?php if (strlen(trim($li->AccountTitle_Code)) != 0) : ?>
                                <?php echo $li->AccountTitle_Code; ?>
                            <?php endif; ?>
                            <?php echo $li->Account_Name; ?>&nbsp;
                        </td>
                        <?php
                        $isSameNum = $li->DocNumber;
                        $totTaxPlus = 0;
                        $totTaxMinus = 0;
                        ?>
                        <td><?= $li->Item_code ?></td>
                        <td><?= $li->Item_name ?></td>
                        <td><?= $li->Unit_Name ?></td>
                        <td><?= $li->color_name ?></td>
                        <td><?= $li->brand ?></td>
                        <td><?= $li->item_type ?></td>
                        <td><?= number_format($li->qty, 2, '.', ',') ?></td>
                        <td><?= $li->currency_id ?></td>
                        <td><?= number_format($li->unitprice, 2, '.', ',') ?></td>
                        <td><?= number_format($li->Disc_Value, 2, '.', ',') ?></td>
                        <td><?= number_format($li->Disc_percentage, 2, '.', ',') ?></td>

                        <td>
                            <?php if ($li->TaxType == 0 && ($li->Tax_Code != 0 && strlen(trim($li->Tax_Code)) != 0)) : ?>
                                <?php echo $DO_VAR['IncludedPPN']; ?>
                            <?php else : ?>
                                <?php if ($li->tax_code1 != 0 && strlen(trim($li->tax_code1)) != 0) : ?>
                                    <?php echo $li->tax_code1; ?>
                                <?php else : ?>
                                    <i>N/A</i>
                                <?php endif; ?>
                            <?php endif; ?>
                        </td>
                        <td>
                            <?php if ($li->tax_code2 != 0 && strlen(trim($li->tax_code2)) != 0) : ?>
                                <?php echo $li->tax_code2; ?>
                            <?php else : ?>
                                <i>N/A</i>
                            <?php endif; ?>
                        </td>

                        <?php
                        $totTaxPlus = 0;
                        if ($rdocurrency == "Rate") {
                            if ($li->currency_id == $selCurrency) {
                                $Unitpricex = floatval($li->unitprice) * 1;
                            } else {
                                foreach ($qGetCurrency->result_array() as $currency) {
                                    if ($li->currency_id == $li->currency_id) {
                                        $Unitpricex = floatval($li->unitprice) * floatval(str_replace(",", "", ${"TXT" . $li->currency_id}));
                                        break;
                                    }
                                }
                            }
                            $currency_idx = $selCurrency;
                        } else {
                            $Unitpricex = $li->unitprice;
                            $currency_idx = $li->currency_id;
                        }

                        if (!empty($li->disc_value)) {
                            $discvalue = floatval($li->disc_value);
                        } else {
                            $discvalue = 0;
                        }


                        $totalPrice = ($li->qty * ($Unitpricex - $discvalue) * (100 - floatval($li->Disc_percentage)) / 100) + floatval($li->extraprice);
                        $newtotalPriceafter = 0;

                        if ($li->TransDiscRate > 0) {
                            $newtotalPrice = $totalPrice * (100 - $li->TransDiscRate) / 100;
                        } else {
                            $newtotalPrice = $totalPrice;
                        }


                        if ($li->TaxType == 0 && ($li->Tax_Code != 0 && strlen(trim($li->Tax_Code)) != 0)) {
                            $IsExclude = false;


                            // Eksekusi query untuk mendapatkan nilai Tax_Rate dari TAccTax
                            $taxCode = $li->Tax_Code;
                            $qRateInc = $this->db->query("SELECT Tax_Rate FROM TAccTax WHERE Tax_Code = '$taxCode'")->row_array();

                            $rateIncluded = $row['Tax_Rate'];

                            // Hitung pajak yang sudah termasuk dalam harga
                            $taxIncluded = floatval($newtotalPrice) * floatval($rateIncluded) / (100 + floatval($rateIncluded));

                            // Hitung total harga setelah dikurangi pajak
                            $newtotalPriceafter = floatval($newtotalPrice) - floatval($taxIncluded);

                            // Tambahkan pajak yang sudah termasuk dalam total pajak
                            $totTaxPlus += floatval($taxIncluded);
                        } else {
                            $IsExclude = true;

                            // TAX1
                            if (
                                $li->tax_code1 != 0 &&
                                strlen(trim($li->tax_code1)) != 0 &&
                                $li->tax_percentage1 > 0 &&
                                $li->tax_percentage1 != 0 &&
                                strlen(trim($li->tax_percentage1)) != 0
                            ) {
                                if ($li->Tax_Operator1 == "+") {
                                    $totTaxPlus += (floatval($newtotalPrice) * floatval($li->tax_percentage1) / 100);
                                } elseif ($li->Tax_Operator1 == "-") {
                                    $totTaxMinus += (floatval($newtotalPrice) * floatval($li->tax_percentage1) / 100);
                                }
                                $newtotalPriceafter = $newtotalPrice;
                            }

                            // TAX2
                            if (
                                $li->tax_code2 != 0 &&
                                strlen(trim($li->tax_code2)) != 0 &&
                                $li->tax_percentage2 > 0 &&
                                $li->tax_percentage2 != 0 &&
                                strlen(trim($li->tax_percentage2)) != 0
                            ) {
                                if ($li->Tax_Operator2 == "+") {
                                    $totTaxPlus += (floatval($newtotalPrice) * floatval($li->tax_percentage2) / 100);
                                } elseif ($li->Tax_Operator2 == "-") {
                                    $totTaxMinus += (floatval($newtotalPrice) * floatval($li->tax_percentage2) / 100);
                                }
                                $newtotalPriceafter = $newtotalPrice;
                            }
                        }
                        ?>
                        <td>
                            <?php echo  number_format($totalPrice, 2, '.', ','); ?>
                            <?php
                            $TotPerSO += floatval($totalPrice);

                            if ($i <= $RecordCount) {
                                if (!empty($qVendor[$i]->DocNumber)) {
                                    $qVendorDocNumber = $qVendor[$i]->DocNumber;
                                } else {
                                    $qVendorDocNumber = "";
                                }

                                if ($qVendorDocNumber != $li->DocNumber) {
                                    if ($li->TransDiscRate > 0) {
                                        echo '<br>';
                                        $totDiscAmount = floatval($TotPerSO) * floatval($li->TransDiscRate) / 100;
                                        $TotPerSO = floatval($TotPerSO) * (100 - floatval($li->TransDiscRate)) / 100;
                                        echo 'Discount ' . floatval($li->TransDiscRate) . '% ' . str_repeat("&nbsp;", 4) . number_format($totDiscAmount, 2, '.', ',');
                                    }

                                    if ($totTaxPlus > 0 && $IsExclude) {
                                        echo '<br>';
                                        $TotPerSO += floatval($totTaxPlus);
                                        echo 'Total Tax ' . str_repeat("&nbsp;", 6) . number_format($totTaxPlus, 2, '.', ',');
                                    }

                                    if ($totTaxMinus > 0) {
                                        echo '<br>';
                                        $TotPerSO -= floatval($totTaxMinus);
                                        echo 'Total Deduction' . str_repeat("&nbsp;", 6) . number_format($totTaxMinus, 2, '.', ',');
                                    }

                                    if ($li->AdditionalCost > 0) {
                                        echo '<br>';
                                        $totAddCost = floatval($li->AdditionalCost);
                                        $TotPerSO += floatval($li->AdditionalCost);
                                        echo 'Additional Cost ' . str_repeat("&nbsp;", 6) . number_format($li->AdditionalCost, 2, '.', ',');
                                    }

                                    echo '<div style="height:8px; border-bottom:solid 2px black"></div>';
                                    echo $currency_idx . ' ' . number_format($TotPerSO, 2, '.', ',');
                                    echo '<div style="height:1px; border-top:solid 2px black"></div>';

                                    $strCurrencyID = $li->currency_id;
                                    foreach ($qGetCurrency->result_array() as $currency) {
                                        if ($currency['Currency_ID'] == $strCurrencyID) {
                                            ${"intGrandTotal" . $currency['Currency_ID']} += floatval($TotPerSO);
                                            break;
                                        }
                                    }

                                    $TotPerSO = 0;
                                }
                            }
                            ?>
                        </td>
                        <?php
                        $qSN = $this->db->query("SELECT TAccSN_Header.SN_Number, CONVERT(VARCHAR(50),TAccSN_Header.SN_Date,106) AS SN_Date,
                                CONVERT(VARCHAR(50),TAccSN_Header.Creation_DateTime,106) AS CreateDate 
                                FROM TaccSN_Header
                                INNER JOIN TAccSN_Item ON TAccSN_Item.SN_Number = TaccSN_Header.SN_Number
                                WHERE TAccSN_Item.Qty > 0
                                AND TAccSN_Item.SO_Number = '$li->DocNumber'
                                AND TAccSN_Item.Item_Code = '$li->Item_code'
                                AND isNull(TAccSN_Header.isVoid,0) = 0
                                AND TAccSN_Header.Approval_Status in (0,1,2,3)");
                        ?>
                        <td align="center">
                            <?php if ($qSN->num_rows() > 0) : ?>
                                <?php foreach ($qSN->result_array() as $Qsn) : ?>
                                    <?= $Qsn['SN_Number'] ?>
                                <?php endforeach; ?>
                            <?php else : ?>
                                &nbsp;
                            <?php endif; ?>
                        </td>
                        <?php
                        $lstSNDate = implode(",", array_column($qSN->result_array(), 'SN_Date'));
                        ?>

                        <td align="center">
                            <?php
                            if ($qSN->num_rows() > 0) {
                                $dates = explode(",", $lstSNDate);
                                foreach ($dates as $i) {
                                    echo date("d-m-y", strtotime($i)) . "<br>";
                                }
                            } else {
                                echo "&nbsp;";
                            }
                            ?>
                        </td>

                        <?php
                        $lstSNCreateDate = implode(",", array_column($qSN->result_array(), 'CreateDate'));
                        ?>

                        <td align="center">
                            <?php
                            if ($qSN->num_rows() > 0) {
                                $dates = explode(",", $lstSNCreateDate);
                                foreach ($dates as $i) {
                                    echo date("d-m-y", strtotime($i)) . "<br>";
                                }
                            } else {
                                echo "&nbsp;";
                            }
                            ?>
                        </td>
                        <td><?= number_format($li->qtyDeliver, 2, '.', ',') ?></td>
                        <td><?= number_format(floatval($li->qty) - floatval($li->qtyDeliver), 2, '.', ',') ?></td>
                        <?php
                        // Eksekusi query
                        $query = "SELECT DISTINCT TAccSI_Header.Invoice_Number, CONVERT(VARCHAR(50), TAccSI_Header.Invoice_Date, 106) AS Invoice_Date 
                                    FROM TaccSI_Header
                                    INNER JOIN TAccSN_Header ON TAccSN_Header.Ref_Number = TAccSI_Header.SO_Number
                                    INNER JOIN TAccSN_Item ON TAccSN_Item.SN_Number = TAccSN_Header.SN_Number
                                    WHERE TAccSN_Item.SO_Number = '$li->DocNumber'
                                    AND TaccSN_Item.Item_Code = '$li->Item_code'
                                    AND ISNULL(TAccSI_Header.isVoid, 0) = 0";

                        $result = $this->db->query($query)->result();

                        echo '<td align="center">';
                        if (!empty($result)) {
                            foreach ($result as $row) {
                                echo $row->Invoice_Number . '<br>';
                            }
                        } else {
                            echo '&nbsp;';
                        }
                        echo '</td>';

                        $lstSIDate = implode(",", array_column($result, 'Invoice_Date'));

                        echo '<td align="center">';
                        if (!empty($result)) {
                            $dates = explode(",", $lstSIDate);
                            foreach ($dates as $i) {
                                echo date("d-m-y", strtotime($i)) . '<br>';
                            }
                        } else {
                            echo '&nbsp;';
                        }
                        echo '</td>';
                        ?>



                    </tr>
                    <?php $i++; ?>
                <?php endforeach; ?>
                <?php $tmpColspan = 18; ?>
                <?php if ($rdocurrency == 'rate') : ?>
                    <?php $totalAll = 0; ?>
                    <?php foreach ($qGetCurrency->result_array() as $row) {
                        $totalAll += intval(${'intGrandTotal' . $row['Currency_ID']});
                    } ?>
                    <tr>
                        <td colspan="<?php echo $tmpColspan; ?>" align="right">
                            <strong><?php echo 'Grand Total' ?></strong>
                        </td>
                        <td class="formtextreport" align="right">
                            <div style="height:5px; border-bottom:solid 2px black;white-space:nowrap"></div>
                            <font size="2"><?php echo $selCurrency . ' ' . number_format($totalAll, 2, '.', ','); ?></font>
                            <div style="height:1px; border-top:solid 2px black"></div>
                        </td>
                        <td colspan="7" class="formtextreport">&nbsp;</td>
                    </tr>
                <?php else : ?>
                    <?php
                    foreach ($qGetCurrency->result_array() as $row) {
                        $currencyID = $row['Currency_ID'];
                        $grandTotal = ${'intGrandTotal' . $currencyID};
                        if ($grandTotal > 0) {
                            echo '<tr>';
                            echo '<td colspan="' . $tmpColspan . '" align="right" class="formtextreport">';
                            echo '<strong>' . 'Grand Total' . '</strong>';
                            echo '</td>';
                            echo '<td class="formtextreport" align="right" nowrap>';
                            echo '<div style="height:5px; border-bottom:solid 2px black"></div>';
                            echo '<font size="2">' . $currencyID . ' ' . number_format($grandTotal, 2, '.', ',') . '</font>';
                            echo '<div style="height:1px; border-top:solid 2px black"></div>';
                            echo '</td>';
                            echo '<td colspan="7" class="formtextreport">&nbsp;</td>';
                            echo '</tr>';
                        }
                    }
                    ?>

                <?php endif; ?>
            </tbody>
        </table>
    </div>
</body>

<?php
function penyebut($nilai)
{
    $nilai = abs($nilai);
    $huruf = array("", "satu", "dua", "tiga", "empat", "lima", "enam", "tujuh", "delapan", "sembilan", "sepuluh", "sebelas");
    $temp = "";
    if ($nilai < 12) {
        $temp = " " . $huruf[$nilai];
    } else if ($nilai < 20) {
        $temp = penyebut($nilai - 10) . " belas";
    } else if ($nilai < 100) {
        $temp = penyebut($nilai / 10) . " puluh" . penyebut($nilai % 10);
    } else if ($nilai < 200) {
        $temp = " seratus" . penyebut($nilai - 100);
    } else if ($nilai < 1000) {
        $temp = penyebut($nilai / 100) . " ratus" . penyebut($nilai % 100);
    } else if ($nilai < 2000) {
        $temp = " seribu" . penyebut($nilai - 1000);
    } else if ($nilai < 1000000) {
        $temp = penyebut($nilai / 1000) . " ribu" . penyebut($nilai % 1000);
    } else if ($nilai < 1000000000) {
        $temp = penyebut($nilai / 1000000) . " juta" . penyebut($nilai % 1000000);
    } else if ($nilai < 1000000000000) {
        $temp = penyebut($nilai / 1000000000) . " milyar" . penyebut(fmod($nilai, 1000000000));
    } else if ($nilai < 1000000000000000) {
        $temp = penyebut($nilai / 1000000000000) . " trilyun" . penyebut(fmod($nilai, 1000000000000));
    }
    return $temp;
}
?>

</html>