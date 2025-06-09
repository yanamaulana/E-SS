<!DOCTYPE html>
<html>

<head>
    <title>Customer Transaction Report</title>
</head>

<body>
    <!-- Add your HTML content here -->
    <?php
    header("Content-Type: application/vnd.ms-excel");
    header("Content-Disposition: attachment; filename=Customer_Report_" . date("Y-m-d") . ".xls");
    header("Pragma: no-cache");
    header("Expires: 0");
    $startdate = '2025-01-01';
    $enddate = '2025-04-30';
    // Base URL
    // $base_url = $Application['stApp']['Web_Path'][$VST_IDX] . '/' . $Application['stApp']['Home_URL'][$VST_IDX];

    // Security Access
    // $varSecAccess = REQUEST['SFSecAccess']['SecAccessFile']([
    //     'FILEACCESSCODE' => 'ERSTD0846902',
    //     'BACKURL' => $base_url . '/index.php?selLisTITEM=1&menu=0'
    // ]);

    // Language List
    $languageList = [
        "SalesReport",
        "Print",
        "Close",
        "CustomerTransactionReport",
        "PrintedOn",
        "SONumber",
        "TotalAmount",
        "TotalDiscount",
        "TotalInvoiced",
        "SalesOrder",
        "CustomerRFQ",
        "RFQCode",
        "RFQDate",
        "NoTransactionAvailable",
        "ItemCode",
        "ItemName",
        "Qty",
        "Qty2",
        "NoRecordFound",
        "SODate",
        "QtyDelivered",
        "UnitPrice",
        "Amount",
        "Discount",
        "Tax",
        "CustomerName",
        "CustomerAddress",
        "Quotation",
        "SNDate",
        "IncludedPPN",
        "ProformaInvoice",
        "PINumber",
        "PIDate",
        "QuotationNumber",
        "QuotationDate",
        "SalesInvoice",
        "SINumber",
        "SIDate",
        "SalesReturn",
        "SRNumber",
        "SRDate",
        "ShipmentNote",
        "SNNumber",
        "UnitType",
        "UnitType2",
        "mthJanuary",
        "mthFebruary",
        "mthMarch",
        "mthApril",
        "mthMay",
        "mthJune",
        "mthJuly",
        "mthAugust",
        "mthSeptember",
        "mthOctober",
        "mthNovember",
        "mthDecember",
        "TotalAmount",
        "AdditionalDisc",
        "SalesContract",
        "SalesContractNumber",
        "SalesContractDate",
        "QuotationNumber",
        "QuotationDueDate",
        "SalesContractStartDate",
        "SalesContractEndDate",
        "DiscountValue",
        "category",
        "Dimension",
        "AccountName",
        "AccountCode",
        "Notes",
        "Debit",
        "Credit",
        "currency",
        "DirectSalesInvoice",
        "DocumentReference",
        "Type",
        "Color",
        "Brand",
        "InvoicePrintNo",
        "grandtotal",
        "ShippingInstructionNumber",
        "claimdeduction",
        "TotAmount1"
    ];

    // Include external files
    // include $Application['stApp']['CFWeb_Path'][1] . $Application['stApp']['SPT'][$VST_IDX] . 'include' .
    //     $Application['stApp']['SPT'][$VST_IDX] . 'calendar' . $Application['stApp']['SPT'][$VST_IDX] . 'sunfish_calendar.php';

    // Include JavaScript
    // echo '<script src="' . $Application['stApp']['Web_Path'][$vst_idx] . '/include/js/allscripts.js"></script>';

    // Border style
    $borderStyle = "border-right: 1px solid #CCCCCC; border-top: 1px solid #CCCCCC; border-bottom: 1px solid #CCCCCC; border-left: 1px solid #CCCCCC;";

    // Query for currency
    // $qcurrency = $this->db->query("SELECT * FROM tcurrency");

    // Query for accounts
    $qGetAccount = $this->db->query("SELECT	DISTINCT
			Account_ID,
			Account_Name,
			Account_Address1,
			AccountTitle_Code
	FROM	TACCOUNT
	WHERE (Cust_FG = 1)
	AND		Category_ID IN (SELECT DISTINCT CATEGORY_ID FROM TDATAGROUPACCOUNT WHERE DATAGROUP_ID IN (20,86))
	AND Account_ID in ('12694','366')
	AND 	Company_ID = 2
	AND 	TACCOUNT.Flag <> 1
	ORDER BY Account_Name")->result_array();

    // Define grand total variables
    $customerrfq_gtqty = 0;
    $quotation_gtamt = 0;
    $proformainvoice_gtamt = 0;
    $salescontract_gtamt = 0;
    $salesorder_gtqty_1 = 0;
    $salesorder_gtqty_2 = 0;
    $salesorder_gtamt = 0;
    $shipmentnote_gtqty_1 = 0;
    $shipmentnote_gtqty_2 = 0;
    $salesreturn_gtqty = 0;

    $totqty = 0;
    $totAmtIDR = 0;
    $totAmtEUR = 0;
    $totAmtUSD = 0;
    $totAmtDIDR = 0;
    $totAmtDEUR = 0;
    $totAmtDUSD = 0;
    ?>
    <?php
    foreach ($qGetAccount as $curr_row => $account) {
        $NoTransactionAvailable = 1;

        // Query untuk transaksi Sales Invoice

        $query = "SELECT taccsi_header.invoice_number,
							taccsi_header.invoiceprintnumber,
							taccsi_header.invoice_date,
							taccsi_header.currency_id,
							taccsi_header.invoice_id,
							taccso_header.PO_NumCustomer,
							taccsi_detail.item_code,
							isnull(taccsi_detail.qty,0) as qty,
							isnull(taccsi_detail.unitprice,0) as unitprice,
							isnull(taccsi_detail.disc_percentage,0) as disc_percentage ,
							isnull(taccsi_detail.disc_value,0) as disc_value,
							taccsi_detail.tax_code1,
							taccsi_detail.tax_code2,
							titem.item_name,
							dimension_name,
							isnull(taccsi_header.transactiondiscountrate,0) as transactiondiscountrate, 
							titem.customfield1 as item_type, 
							titem.item_size as brand, 
							tgscolor.color_name,
							taccsi_header.so_number,
							'claimdeduction' = case TAccSI_Header.Ori_Invoice_Amount
								when 0 then 0	
								else (
									dbo.fnc_calcsalesreport(TAccSI_Detail.qty, TAccSI_Detail.unitprice, TAccSI_Header.Ori_Invoice_Amount, TAccSI_Header.claimdeduction, 1.000000000)
								)
								end,
							'base_claimdeduction' = case TAccSI_Header.Ori_Base_Invoice_Amount
								when 0 then 0	
								else (
									   dbo.fnc_calcsalesreport(TAccSI_Detail.qty, TAccSI_Detail.unitprice, TAccSI_Header.Ori_Invoice_Amount, TAccSI_Header.claimdeduction, TAccSI_Header.base_invoice_amount/TAccSI_Header.invoice_amount)
								) end,
							isnull(BOMDetail.BOM_TYPE,0) bom_type,
							isnull(prod_cost_percentage,0) prod_cost_percentage,
							isnull(loss_percentage,0) loss_percentage,
							isnull(total_cost,0) total_cost,
							isnull(loss_cost,0) loss_cost,
							isnull(salary2,0) salary2,
							isnull(prod_cost,0) prod_cost,
							isnull(TScale.scale,1) scale,
							isnull(BOMDetail.TotalCOGS * TScale.scale,0) as TotalCOGS,
							isnull(TBOM_Guitar.total_cost_rm , 0) as total_cost_rm,
							isnull(TBOM_Guitar_2.total_cost_rm2 , 0) as total_cost_rm2,
							isnull(TBOM_Guitar_3.total_cost_rm_3 , 0) as total_cost_rm_3
					from taccsi_header
						inner join taccsi_detail WITH (NOLOCK) on taccsi_header.invoice_number = taccsi_detail.invoice_number
						inner join titem WITH (NOLOCK) on taccsi_detail.item_code = titem.item_code
						inner join titemdimension WITH (NOLOCK) on titemdimension.dimension_id = taccsi_detail.dimension_id
						left  join taccso_header WITH (NOLOCK) on taccso_header.so_number = taccsi_detail.so_number
						left join tgscolor WITH (NOLOCK) on tgscolor.color_code = titem.item_color
						Left join (
							Select 
								bom_type,
								item_code,  		 
								umr_salary, 
								currency_id,
								loss_percentage, 
								salary, 
								prod_cost_percentage, 
								sum(total_cost) TotalCost,
								sum(total_cost) total_cost,(((sum(total_cost)) * (loss_percentage)) / 100) loss_cost, salary salary2 ,((((sum(total_cost)) + (umr_salary)) * prod_cost_percentage) / 100) prod_cost,
								(sum(total_cost) + (((sum(total_cost)) * (loss_percentage)) / 100) + (salary) + ((((sum(total_cost)) + (umr_salary)) * prod_cost_percentage) / 100)) TotalCOGS
							from (
									select	bom_type,
											bom_code, 
											item_code,  
											item_type, 
											brand, 
											umr_salary, 
											currency_id,
											loss_percentage, 
											salary, 
											prod_cost_percentage,   
											sum(total_cost_converted) as total_cost 
									from (
										select	
												bom_type,
												bom_code, 
												item_code,  
												item_type, 
												brand, 
												umr_salary,  
												header_curr as currency_id,
												global_loss as loss_percentage, 
												salary, 
												prod_cost_percentage, 
												cast((total_cost / isnull(scale, 1)) as money) as total_cost_converted	 
										from (
											select	distinct  
													tppicitembom.bom_type,
													tppicitembom.bom_code, 
													tppicitembom.item_code,  
													titem.customfield1 as item_type, 
													titem.item_size as brand, 
													tppicitembom.umr_salary, 
													isnull(tppicitembom.currency_id, 'idr') as header_curr,
													isnull(tppicitembom.loss_percentage, 0) as global_loss, 
													isnull(tppicitembom.salary, 0) as salary, 
													isnull(tppicitembom.prod_cost_percentage, 0) as prod_cost_percentage, 
								 
													tppicitembom_detail.rm_code, 
													tppicitembom_detail.rm_qty, 
													isnull(tppicitembom_detail.currency_id, 'idr') as details_curr, 
													isnull(tppicitembom_detail.is_accessories, 0) as is_accessories, 
													( 
														((tppicitembom_detail.cost * tppicitembom_detail.item_convertion) * tppicitembom_detail.rm_qty) +
														(
															(
																(
																	(tppicitembom_detail.cost * tppicitembom_detail.item_convertion) * tppicitembom_detail.rm_qty
																) * tppicitembom_detail.comp_loss_percentage
															) / 100
														)
													) as total_cost, 
													( 
														select top 1 scale from tcurrencyconverter 
														where	currency_id_1 = isnull(tppicitembom.currency_id, 'idr')
															and	currency_id_2 = isnull(tppicitembom_detail.currency_id, 'idr')
															and	tcurrencyconverter.status = 1
														order by last_update desc
													) as scale, 
													( 
														case 
															when tppicitembom_detail.is_expensive_parts = 1 
															then  
																tppicitembom_detail.loss_percentage
															else 
																100
														end
													) as detail_loss_percent
								
											from tppicitembom_detail
												inner join tppicitembom on tppicitembom.bom_code = tppicitembom_detail.bom_code
												inner join  (
														select 
														item_code,MAX(LAST_UPDATE) LAST_UPDATE
														from TPPICITEMBOM 
														GROUP BY item_code) last_TPPICITEMBOM ON   
														(TPPICITEMBOM.item_code=last_TPPICITEMBOM.item_code) 
														AND (TPPICITEMBOM.LAST_UPDATE=last_TPPICITEMBOM.LAST_UPDATE)
												inner join titem on titem.item_code = tppicitembom.item_code 
							 
											where	  1=1
										) first_layer
										where	isnull(first_layer.total_cost, 0) <> 0 and first_layer.total_cost <> 0
								) second_layer
								group by	bom_type,bom_code, item_code,  item_type, brand,  umr_salary, 
											currency_id, loss_percentage, salary, prod_cost_percentage, 
											total_cost_converted 
							) T										  
							  Group by bom_type,bom_code, 
								item_code,  
								item_type, 
								brand, 
								umr_salary, 
								currency_id,
								loss_percentage, 
								salary,
								prod_cost_percentage
						) BOMDetail on (taccsi_detail.item_code=BOMDetail.item_code)
						Left Join vw_TBOM_Guitar AS TBOM_Guitar WITH (NOLOCK)  ON (taccsi_detail.item_code=TBOM_Guitar.item_code)
						Left Join vw_TBOM_Guitar_2 AS TBOM_Guitar_2 WITH (NOLOCK) ON (taccsi_detail.item_code=TBOM_Guitar_2.item_code)
						Left join vw_TBOM_Guitar_3 AS TBOM_Guitar_3 WITH (NOLOCK) ON (taccsi_detail.item_code=TBOM_Guitar_3.item_code)
						Left Join (
							select	distinct x.currency_id_1 as curr_to, x.currency_id_2 as curr_from, 
									(
										select top 1 scale 
											from TCurrencyConverter 
										where currency_id_1 = x.currency_id_1 
											and currency_id_2 = x.currency_id_2 
										order by last_update desc
									) as scale 
							
							from (
								select	distinct tcurrencyconverter.currency_id_1, currency_id_2
								from tcurrency 
								inner join tcurrencyconverter
									on tcurrency.currency_id = tcurrencyconverter.currency_id_1
								where tcurrency.status = 1
							) x	
						) TScale on (TScale.curr_from=BOMDetail.currency_id) and (TScale.curr_to=taccsi_header.currency_ID) 
					where taccsi_header.account_id = '" . $account['Account_ID'] . "'
						and taccsi_header.invoice_date >= {d '$startdate'}
						and taccsi_header.invoice_date <= {d '$enddate'}
						and isnull(taccsi_header.isvoid,0) = 0
					order by taccsi_header.invoice_number
                ";



        $sql = "SELECT  taccsi_header.invoice_number,
						taccsi_header.invoiceprintnumber,
						taccsi_header.so_number,
						taccsi_header.invoice_date,
						taccsi_header.directtype,
						taccsi_header.currency_id ,
						taccchartaccount.account_number,
						taccchartaccount.account_nameen as acc_name,
						taccjournaldetail.notes,
						journald_debet, 
						journald_kredit,
						taccsi_header.so_number,
						0 as claimdeduction,
						0 as base_claimdeduction
				from	taccsi_header
					inner join taccjournaldetail on taccjournaldetail.journalh_code = taccsi_header.invoice_number
					inner join taccchartaccount on	taccjournaldetail.acc_id = taccchartaccount.acc_id 
				where   taccjournaldetail.isextra = 1
					and taccsi_header.isdirect = 1
					and taccsi_header.account_id = '" . $account['Account_ID'] . "'
					and	taccsi_header.invoice_date >= {d '$startdate'}
					and	taccsi_header.invoice_date <= {d '$enddate'}
					and isnull(taccsi_header.isvoid,0) = 0
				order by taccsi_header.invoice_number";

        $qSelectTransactionSalesInvoiceDirect = $this->db->query($sql)->result_array();


        if (isset($qSelectTransactionSalesInvoiceDirect) && count($qSelectTransactionSalesInvoiceDirect) > 0) {
            $NoTransactionAvailable = 0;
        } else {
            $NoTransactionAvailable = 1;
        }

        $qSelectTransactionSalesInvoice = $this->db->query($query)->result_array();

        if (count($qSelectTransactionSalesInvoice) > 0) {
            $NoTransactionAvailable = 0;
        }

        if ($NoTransactionAvailable !== 1) {
            if ($curr_row > 1) {
                echo '<br><hr style="border-top:1px solid #CCCCCC;border-left:none;border-right:none;border-bottom:none"><br>';
            }
        }

        // Transaction Sales Invoice

        if (empty($selDocument) || $selDocument === 'SalesInvoice') {
            if (count($qSelectTransactionSalesInvoice) > 0) {
                echo '<br>';
                echo '<table border="0" cellpadding="3" cellspacing="1" width="100%">';
                echo '<tr class="formtextreport" style="border-left: 1px solid #000000; border-right: 1px solid #000000; border-top: 1px solid #000000; border-bottom: 1px solid #000000;">';
                echo '<td bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;" colspan="28" align="center"><b>Sales Invoice</b></td>';
                echo '</tr>';
                echo '<tr class="formtextreport" style="border-left: 1px solid #000000; border-right: 1px solid #000000; border-top: 1px solid #000000; border-bottom: 1px solid #000000;">';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">No.</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Customer Name</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Sales Invoice Number</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Invoice Print Number</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Customer PO Number</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Shipping Instruction Number</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">SI Date</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Item Code</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Item Name</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Category</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Type</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Color</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Brand</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Qty</td>';
                echo '<td bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;" colspan="2">Unit Price</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Discount Value</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Discount</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Additional Discount</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Amount</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Tax 1</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Tax 2</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Claim Deduction</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Total Amount</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Material</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Payroll</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Manufacture</td>';
                echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">Cost Of Goods</td>';
                echo '</tr>';

                // Initialize variables
                $Nomor = 1;
                $amt = 0;
                $cd = 0;
                $amtd = 0;

                $subAmtIDR = 0;
                $subAmtEUR = 0;
                $subAmtUSD = 0;
                $subAmtDIDR = 0;
                $subAmtDEUR = 0;
                $subAmtDUSD = 0;
            }
        }

        $Subqty = 0;
        foreach ($qSelectTransactionSalesInvoice as $index => $row) {
            echo '<tr class="formtextreport" valign="top" style="' . $borderStyle . '">';

            // Nomor kolom
            if ($index === 0 || $row['invoice_number'] !== $qSelectTransactionSalesInvoice[$index - 1]['invoice_number']) {
                echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . $Nomor . '.</td>';
                $Nomor++;
            } else {
                echo '<td style="' . $borderStyle . '" class="formtextreport">&nbsp;</td>';
            }

            // Kolom data
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($account['Account_Name']) ? htmlspecialchars($account['Account_Name']) : '&nbsp;') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['invoice_number']) ? htmlspecialchars($row['invoice_number']) : '&nbsp;') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['invoiceprintnumber']) ? htmlspecialchars($row['invoiceprintnumber']) : '&nbsp;') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['PO_NumCustomer']) ? htmlspecialchars($row['PO_NumCustomer']) : '&nbsp;') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['so_number']) ? htmlspecialchars($row['so_number']) : '&nbsp;') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . (!empty($row['invoice_date']) ? date('d M Y', strtotime($row['invoice_date'])) : '&nbsp;') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['item_code']) ? htmlspecialchars($row['item_code']) : '&nbsp;') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['item_name']) ? htmlspecialchars($row['item_name']) : '&nbsp;') . '</td>';

            // Query kategori item
            $qSalesInvoicecategoryitem = $this->db->query("SELECT itemcategory_name 
            FROM titemcategory
            INNER JOIN titemcompany ON titemcompany.itemcategory_id = titemcategory.itemcategory_id
            WHERE item_code = '" . $row['item_code'] . "'");

            $categoryItem = $qSalesInvoicecategoryitem->row_array();

            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($categoryItem['itemcategory_name']) ? htmlspecialchars($categoryItem['itemcategory_name']) : '&nbsp;') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['item_type']) ? htmlspecialchars($row['item_type']) : '&nbsp;') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['color_name']) ? htmlspecialchars($row['color_name']) : '&nbsp;') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['brand']) ? htmlspecialchars($row['brand']) : '&nbsp;') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . (is_numeric($row['qty']) ? number_format($row['qty'], 2) : '0.00') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['Currency_ID']) ? htmlspecialchars($row['Currency_ID']) : '&nbsp;') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . (is_numeric($row['unitprice']) ? number_format($row['unitprice'], 2) : '0.00') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . (is_numeric($row['disc_value']) ? number_format($row['disc_value'], 2) : '0.00') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . (is_numeric($row['disc_percentage']) ? number_format($row['disc_percentage'], 2) . '%' : '0.00') . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . (is_numeric($row['transactiondiscountrate']) ? number_format($row['transactiondiscountrate'], 2) . '%' : '0.00') . '</td>';

            // Perhitungan
            $amt = $row['qty'] * ($row['unitprice'] - $row['disc_value']) * (1 - ($row['disc_percentage'] / 100));
            $amt -= $amt * ($row['transactiondiscountrate'] / 100);
            $cd = $row['claimdeduction'];
            $amtd = $amt - $cd;

            $Subqty += $row['qty'];
            ${"subAmt" . $row['currency_id']} += $amt;
            ${"subAmtD" . $row['currency_id']} += $amtd;

            $totqty += $row['qty'];
            ${"totAmt" . $row['currency_id']} += $amt;
            ${"totAmtD" . $row['currency_id']} += $amtd;

            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . number_format($amt, 2) . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . ($row['tax_code1'] === '0' ? '-' : htmlspecialchars($row['tax_code1'])) . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . ($row['tax_code2'] === '0' ? '-' : htmlspecialchars($row['tax_code2'])) . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . number_format($cd, 2) . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . number_format($amtd, 2) . '</td>';



            if ($row['bom_type'] > 3 || $row['bom_type'] == 0) {
                $total_COGS = floatval($row['total_cost']);
                $total_lossCOGS = ($total_COGS * floatval($row['loss_percentage'])) / 100;
                $total_prod_costCOGS = ($total_COGS * floatval($row['prod_cost_percentage'])) / 100;
                $grandtotal = round($total_COGS, 2) + round($total_lossCOGS, 2) + round($row['salary2'], 2) + round($total_prod_costCOGS, 2);

                echo "<td class='formtextreport' align='right'>" .
                    number_format((round($total_COGS, 2) + round($total_lossCOGS, 2)) / $row['scale'], 2, '.', ',') .
                    "</td>";

                echo "<td class='formtextreport' align='right'>" .
                    number_format(round($row['salary2'], 2) / $row['scale'], 2, '.', ',') .
                    "</td>";

                echo "<td class='formtextreport' align='right'>";
                if (is_numeric($total_prod_costCOGS)) {
                    echo number_format($total_prod_costCOGS / $row['scale'], 2, '.', ',');
                } else {
                    echo "0.00";
                }
                echo "</td>";

                echo "<td class='formtextreport' align='right'>";
                if (is_numeric($grandtotal)) {
                    echo number_format($grandtotal / $row['scale'], 2, '.', ',');
                } else {
                    echo "0.00";
                }
                echo "</td>";
            } else {
                $total_acc = 0;
                $total_costR = 0;
                $total_idr = $row['total_cost_rm2'];
                $total_costR += $total_idr;
                $total_loss_amountR = 0;

                $tcostidr = $row['total_cost_rm_3'];
                $losspersen = 1 - ($row['loss_percentage'] / 100);
                $lossamount = $tcostidr * $losspersen;
                $total_loss_amountR += $lossamount;

                $cost_idr = $row['total_cost_rm'];
                $total_acc += $cost_idr;

                $rm_1_cost = $total_costR - $total_acc;
                $rm_2_cost = $rm_1_cost - $total_loss_amountR;

                $total_loss_amount = $rm_2_cost * ($row['loss_percentage'] / 100);
                $total_prod_cost = ($total_loss_amount + $rm_2_cost) * ($row['prod_cost_percentage'] / 100);
                $total_cog = $total_prod_cost + $total_loss_amount + $row['salary2'] + $total_costR;

                echo "<td class='formtextreport' align='right'>" .
                    number_format(
                        ($total_cog / $row['scale']) -
                            ($total_prod_cost / $row['scale']) -
                            (round($row['salary2'], 2) / $row['scale']),
                        2,
                        '.',
                        ','
                    ) .
                    "</td>";

                echo "<td class='formtextreport' align='right'>" .
                    number_format(round($row['salary2'], 2) / $row['scale'], 2, '.', ',') .
                    "</td>";

                echo "<td class='formtextreport' align='right'>";
                if (is_numeric($total_prod_cost)) {
                    echo number_format($total_prod_cost / $row['scale'], 2, '.', ',');
                } else {
                    echo "0.00";
                }
                echo "</td>";

                echo "<td class='formtextreport' align='right'>";
                if (is_numeric($total_cog)) {
                    echo number_format($total_cog / $row['scale'], 2, '.', ',');
                } else {
                    echo "0.00";
                }
                echo "</td>";
            }
            echo '</tr>';
        }

        $lstCurr = ["EUR", "IDR", "USD"];
        $cnt = 0;

        foreach ($lstCurr as $curr) {
            echo '<tr>';
            echo '<td colspan="12">&nbsp;</td>';
            $cnt++;

            if ($cnt === 1) {
                echo '<td nowrap style="' . $borderStyle . '" class="formtext" align="right">SUB</td>';
            } else {
                echo '<td nowrap style="' . $borderStyle . '" class="formtext" align="right">&nbsp;</td>';
            }

            if ($cnt === 1) {
                echo '<td nowrap style="' . $borderStyle . '" class="formtext" align="right"><b>';
                echo is_numeric($Subqty) ? number_format($Subqty, 2, '.', ',') : '0.00';
                echo '</b></td>';
            } else {
                echo '<td>&nbsp;</td>';
            }

            echo '<td colspan="4">&nbsp;</td>';
            echo '<td>' . htmlspecialchars($curr) . '</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtext" align="right">';
            echo isset(${"subAmt" . $curr}) ? number_format(${"subAmt" . $curr}, 4, '.', ',') : '0.0000';
            echo '</td>';
            echo '<td colspan="3">&nbsp;</td>';
            echo '<td nowrap style="' . $borderStyle . '" class="formtext" align="right">';
            echo isset(${"subAmtD" . $curr}) ? number_format(${"subAmtD" . $curr}, 4, '.', ',') : '0.0000';
            echo '</td>';
            echo '</tr>';
        }

        echo '</table>';


        $Nomor = 1;

        if (count($qSelectTransactionSalesInvoiceDirect) > 0) {
            echo '<br>';
            echo '<table border="0" cellpadding="3" cellspacing="1" width="100%">';
            echo '<tr class="formtextreport" style="border-left: 1px solid #000000; border-right: 1px solid #000000; border-top: 1px solid #000000; border-bottom: 1px solid #000000;">';
            echo '<td bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;" colspan="11" align="center"><b>' . htmlspecialchars($DO_VAR['DirectSalesInvoice']) . '</b></td>';
            echo '</tr>';
            echo '<tr class="formtextreport" style="border-left: 1px solid #000000; border-right: 1px solid #000000; border-top: 1px solid #000000; border-bottom: 1px solid #000000;">';
            echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">No.</td>';
            echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">' . htmlspecialchars($DO_VAR['customername']) . '</td>';
            echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">' . htmlspecialchars($DO_VAR['SINumber']) . '</td>';
            echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">' . htmlspecialchars($DO_VAR['InvoicePrintNo']) . '</td>';
            echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">' . htmlspecialchars($DO_VAR['SIDate']) . '</td>';
            echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">' . htmlspecialchars($DO_VAR['DocumentReference']) . '</td>';
            echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">' . htmlspecialchars($DO_VAR['AccountCode']) . '</td>';
            echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">' . htmlspecialchars($DO_VAR['AccountName']) . '</td>';
            echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">' . htmlspecialchars($DO_VAR['Notes']) . '</td>';
            echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">' . htmlspecialchars($DO_VAR['currency']) . '</td>';
            echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">' . htmlspecialchars($DO_VAR['Debit']) . '</td>';
            echo '<td nowrap bgcolor="EFEFEF" style="' . $borderStyle . '; border-top: 1px solid #CCCCCC;">' . htmlspecialchars($DO_VAR['Credit']) . '</td>';
            echo '</tr>';

            foreach ($qSelectTransactionSalesInvoiceDirect as $index => $row) {
                echo '<tr class="formtextreport" valign="top" style="' . $borderStyle . '">';

                // Nomor kolom
                if ($index === 0 || $row['invoice_number'] !== $qSelectTransactionSalesInvoiceDirect[$index - 1]['invoice_number']) {
                    echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . $Nomor . '.</td>';
                    $Nomor++;
                } else {
                    echo '<td style="' . $borderStyle . '" class="formtextreport">&nbsp;</td>';
                }

                // Kolom data
                echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($account['Account_Name']) ? htmlspecialchars($account['Account_Name']) : '&nbsp;') . '</td>';
                echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['invoice_number']) ? htmlspecialchars($row['invoice_number']) : '&nbsp;') . '</td>';
                echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['invoiceprintnumber']) ? htmlspecialchars($row['invoiceprintnumber']) : '&nbsp;') . '</td>';
                echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . (!empty($row['Invoice_Date']) ? date('d M Y', strtotime($row['Invoice_Date'])) : '&nbsp;') . '</td>';
                echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="center">' . (!empty($row['SO_Number']) ? htmlspecialchars($row['SO_Number']) : '-') . '</td>';
                echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['account_number']) ? htmlspecialchars($row['account_number']) : '&nbsp;') . '</td>';
                echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['acc_name']) ? htmlspecialchars($row['acc_name']) : '&nbsp;') . '</td>';
                echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['notes']) ? htmlspecialchars($row['notes']) : '&nbsp;') . '</td>';
                echo '<td nowrap style="' . $borderStyle . '" class="formtextreport">' . (!empty($row['currency_ID']) ? htmlspecialchars($row['currency_ID']) : '&nbsp;') . '</td>';
                echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . (is_numeric($row['JournalD_Debet']) ? number_format($row['JournalD_Debet'], 2, '.', ',') : '0.00') . '</td>';
                echo '<td nowrap style="' . $borderStyle . '" class="formtextreport" align="right">' . (is_numeric($row['JournalD_Kredit']) ? number_format($row['JournalD_Kredit'], 2, '.', ',') : '0.00') . '</td>';
                echo '</tr>';
            }

            echo '</table>';
        }
    }
    ?>
    <br>
    <!-- <php
    if (isset($seldocument)) {
        echo '<table width="100%" border="1">';
        echo '<tr>';

        // Sales Invoice Grand Total
        if ($seldocument === 'salesinvoice') {
            $lstCurr = ["EUR", "IDR", "USD"];
            $cnt = 0;

            foreach ($lstCurr as $curr) {
                echo '<tr>';
                echo '<td colspan="11">&nbsp;</td>';
                $cnt++;

                if ($cnt === 1) {
                    echo '<td nowrap style="' . $borderStyle . '" class="formtext" align="right">TOTAL</td>';
                } else {
                    echo '<td nowrap style="' . $borderStyle . '" class="formtext" align="right">&nbsp;</td>';
                }

                if ($cnt === 1) {
                    echo '<td nowrap style="' . $borderStyle . '" class="formtext" align="right"><b>';
                    echo is_numeric($totqty) ? number_format($totqty, 2, '.', ',') : '0.00';
                    echo '</b></td>';
                } else {
                    echo '<td>&nbsp;</td>';
                }

                echo '<td colspan="4">&nbsp;</td>';
                echo '<td>' . htmlspecialchars($curr) . '</td>';
                echo '<td nowrap style="' . $borderStyle . '" class="formtext" align="right">';
                echo isset(${"totAmt" . $curr}) ? number_format(${"totAmt" . $curr}, 4, '.', ',') : '0.0000';
                echo '</td>';
                echo '<td colspan="3">&nbsp;</td>';
                echo '<td nowrap style="' . $borderStyle . '" class="formtext" align="right">';
                echo isset(${"totAmtD" . $curr}) ? number_format(${"totAmtD" . $curr}, 4, '.', ',') : '0.0000';
                echo '</td>';
                echo '</tr>';
            }
        }

        echo '</tr>';
        echo '</table>';
    }
    ?> -->

</body>

</html>