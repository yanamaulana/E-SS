<div class="row">
    <!-- kiri -->
    <div class="col-md-6">
        <div class="row">
            <div class="col-md-12">
                <label for="SO_NUMBER">SO Number : </label>
                <input type="text" id="SO_NUMBER" name="SO_NUMBER">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtSOtype">SO Tax Type :</label>
                <input type="Radio" name="txtSOtype" id="txtSOtype" value="1" checked=""> Normal &nbsp;
                <input type="Radio" name="txtSOtype" id="txtSOtype" value="0"> VAT Include
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="selProject">Project Name :</label>
                <input type="text" id="selProject" name="selProject">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="rdoAllocate">Allocate To :</label>
                <input type="radio" name="rdoAllocate" value="0">Project Component
                <input type="radio" name="rdoAllocate" value="1" checked="">Cost Center
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="rbTypedoc">Document Source :</label>
                <input type="Radio" name="rbTypedoc" value="0" checked=""> Quotation
                <input type="Radio" name="rbTypedoc" value="2"> Proforma Invoice
                <input type="Radio" name="rbTypedoc" value="3"> Sales Contract
                <br>
                <br>
                <div id="DivQuotation" style="display: ;">
                    <input name="selQuotation" id="selQuotation" type="text" onkeyup="switched('Quo',this)" size="25" maxlength="25" onclick="switched('Quo',this)" onkeypress="return onEnter(event);" value="">
                    <a style="cursor:pointer" onclick="setObjField('selQuotation','divAjaxLookupQuo'); onEvent();" title="GO">
                        <img src="/samickerp/erp/images/quicksearch.jpg" alt="Search" border="0" width="18" height="18">
                    </a>
                    <br>
                    <div id="divAjaxLookupQuo" style="width:500px;height:200px;position:absolute;display:none;border:2px solid black;background-color:white;z-index:1000;overflow:auto">
                    </div>
                </div>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtCustName">Customer * : </label>
                <input type="text" name="txtCustName" id="txtCustName" value="">
                <!-- HIDDEN VALUE -->
                <input type="hidden" name="txtCustCode" id="txtCustCode" value="">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtCustAddress">Address : </label>
                <textarea name="txtCustAddress" id="txtCustAddress" cols="30" rows="5">1510 ELM HILL PIKE SUITE 212NASHVILLE, TENNESSEE 37210</textarea>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtCPName">Contact Person : </label>
                <input type="hidden" name="txtCPCode" id="txtCPCode" value="8220">
                <input type="text" name="txtCPName" id="txtCPName" value="Dennis Zager">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtCPAddress">Contact Address : </label>
                <input type="text" name="txtCPAddress" value="">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtSPName">Sales Person * : </label>
                <input type="Text" name="txtSPName" size="40" maxlength="100" value="" readonly="" class="inplabel">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtMemo">Remarks : </label>
                <textarea name="txtMemo" cols="50" rows="7"></textarea>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="chkKawasan">Bonded Area : </label>
                <input type="checkbox" name="chkKawasan" value="1"> Yes
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="selSNGroup">SN Account : </label>
                <select name="selSNGroup">
                    <option value="214">GIBSON GUITAR CORPORATION</option>
                </select>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="selSIGroup">SI Account : </label>
                <select name="selSIGroup">
                    <option value="214">GIBSON GUITAR CORPORATION</option>
                </select>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtRevisionReason">Revision Reason : </label>
                <textarea name="txtRevisionReason" cols="50" rows="7"></textarea>
            </div>
        </div>
    </div>
    <!-- end kiri -->
    <!-- kanan -->
    <div class="col-md-6">
        <div class="row">
            <div class="col-md-12">
                <label for="txtSODate">SO Date : </label>
                <input type="text" id="txtSODate" name="txtSODate">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtInvDueDate">SO Tax Type :</label>
                <input type="text" id="txtInvDueDate" name="txtInvDueDate">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtPONum">Customer PO Number :</label>
                <input type="text" id="txtPONum" name="txtPONum">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtPODate">Customer PO Date :</label>
                <input type="text" id="txtPODate" name="txtPODate">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtProMonth">Production Month & Year :</label>
                <select name="txtProMonth" id="txtProMonth">
                    <option value="" selected=""> --select month--</option>
                    <option value="1"> January</option>
                    <option value="2"> February</option>
                    <option value="3"> March</option>
                    <option value="4"> April</option>
                    <option value="5"> May</option>
                    <option value="6"> June</option>
                    <option value="7"> July</option>
                    <option value="8"> August</option>
                    <option value="9"> September</option>
                    <option value="10"> October</option>
                    <option value="11"> November</option>
                    <option value="12"> December</option>
                </select>
                <select name="txtProYear" id="txtProYear">
                    <option value="" selected=""> --select year--</option>
                    <option value="2024"> 2024</option>
                    <option value="2025"> 2025</option>
                    <option value="2026"> 2026</option>
                    <option value="2027"> 2027</option>
                    <option value="2028"> 2028</option>
                    <option value="2029"> 2029</option>
                    <option value="2030"> 2030</option>
                </select>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="selCurrency">SO Currency :</label>
                <select name="selCurrency" id="selCurrency">
                    <option value="AUD">AUD</option>
                    <option value="EUR">EUR</option>
                    <option value="GBP">GBP</option>
                    <option value="IDR" selected>IDR</option>
                    <option value="JPY">JPY</option>
                    <option value="KRW">KRW</option>
                    <option value="SGD">SGD</option>
                    <option value="USD">USD</option>
                </select>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="selTaxCurrency">Tax Currency :</label>
                <select name="selTaxCurrency" id="selTaxCurrency">
                    <option value="IDR" selected="">IDR</option>
                    <option value="USD">USD</option>
                </select>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="BaseCurr">Base Currency :</label>
                <select name="BaseCurr" id="BaseCurr">
                    <option value="IDR" selected="">IDR</option>
                </select>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="cboTerms">Payment Schedule :</label>
                <input type="Hidden" name="txtTerms" value="0">
                <select name="cboTerms" id="cboTerms" onchange="lpage();">
                    <option value="NONE" selected="">NONE - 1 monthly (cash)</option>
                </select>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="cboTermsNew">Payment Terms :</label>
                <input type="Hidden" name="txtTermsNew">
                <select name="cboTermsNew" id="cboTermsNew" onchange="lpage();">
                    <option value="" selected="">None - 1 month (default)</option>
                    <option value="Term001">Pembayaran dengan uang cash - 30 days</option>
                </select>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtDeliveryTerms">Delivery Terms :</label>
                <textarea name="txtDeliveryTerms" cols="40" rows="3"></textarea>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="Info">Credit Info :</label>
                <td colspan="2">&nbsp;
                    <input type="Hidden" name="txtcreditlimit" value="0">
                    <input type="Hidden" name="baseCreditLimit" value="0">

                    <input type="Hidden" name="txtInvNotPaid" value="4848785.666879991">
                    <input type="Hidden" name="baseInvNotPaid" value="46703772557.118">

                    <input type="Hidden" name="txtSOApproved" value="55113214.79497244">
                    <input type="Hidden" name="baseSOApproved" value="530853542621.58">


                    <input type="Hidden" name="txtRemainingCredit" value="-59962000.46185243">
                    <input type="Hidden" name="baseRemainCredit" value="-577557315178.698">


                    <table border="0" id="tbl2">
                        <tbody>
                            <tr class="formtext">

                                <td style="border-top:1px solid black;border-right:1px solid black;border-left:1px solid black;border-bottom:1px solid black;">Credit Limit : <span id="idcreditLimit">(USD)</span><span id="creditLimit">0</span><br><br>
                                    Invoice Not Paid : <span id="idInvNotPaid">(USD)</span> <span id="InvNotPaid">4848785.666879991</span><br><br>
                                    Sales Order Approved : <span id="idSOApproved">(USD)</span> <span id="SOApproved">55113214.79497244</span>
                                    <hr>
                                    Remaining Credit :
                                    <a href="javascript://" onclick="arrNewPop[arrNewPop.length]=PopWindow('/samickerp/erp/eaccounting/sales/reports/creditlimit/view_report.cfm?rdoview=selected&amp;rdoType=0&amp;selCust='+document.frmNew.txtCustCode.value,'Preview','800','600','scrollbars=yes,status=yes,resizable=yes');" style="text-decoration:none;">
                                        <span id="idRemainingCredit">(USD)</span> <span id="RemainingCredit">-59962000.46185243</span>
                                    </a>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="cboPriceType">Price Type :</label>
                <select name="cboPriceType" id="cboPriceType">
                    <option value="FOB">Freight on Board</option>
                    <option value="CIF">Cost Insurance Freight</option>
                    <option value="CFR">Cost and Freight</option>
                </select>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="txtPiNumber">Pi Number * :</label>
                <input name="txtPiNumber" value="">
            </div>
        </div>
    </div>
    <!-- end kanan-->
</div>
<table cellpadding="1" cellspacing="1" border="0" width="50%">
    <tbody>
        <tr>
            <td valign="top" class="formtext">

                <fieldset name="1">
                    <legend>Currency Converter</legend>
                    <table width="100%" style="display:''" cellpadding="4" cellspacing="1" class="formbody" border="0" id="tblCurrConverter">
                        <tbody>
                            <tr id="trAmountUSD"></tr>
                            <tr id="trAmountUSD">
                                <td width="20">1 USD = <input name="txtCurr_USD" type="text" value="16911" size="15" maxlength="20" align="right" onblur="recalcTotal();" onkeypress="return isIntOnlyNew(event);" onfocus="this.select()" onkeyup="javascript:decimalinForMoney(this);"> IDR</td>
                            </tr>
                        </tbody>
                    </table>
                </fieldset>
            </td>
            <td valign="top" class="formtext">
                <fieldset name="1">
                    <legend>Tax Converter</legend>
                    <table width="100%" style="display:''" cellpadding="4" cellspacing="1" class="formbody" border="0" id="tblTaxConverter">
                        <tbody>
                            <tr id="trTaxUSD"></tr>
                            <tr id="trTaxUSD">
                                <td width="20">1 USD = <input name="txtTax_USD" type="text" value="16911 " size="15" maxlength="20" align="right" onblur="recalcTotal();" onkeypress="return isIntOnlyNew(event);" onfocus="this.select()" onkeyup="javascript:decimalinForMoney(this);"> IDR</td>
                            </tr>
                        </tbody>
                    </table>
                </fieldset>
            </td>
        </tr>
    </tbody>
</table>
<input type="hidden" name="txtCurr_IDR" value="1">
<input type="hidden" name="txtTax_IDR" value="1">
<tr>
    <td width="100%" colspan="2" style="border:1px solid blue;">
        <div style="width:100%; height:300px; overflow:hidden; position:relative;">
            <div style="width:100%; height:100%; overflow:auto; position:absolute;">
                <table width="100%" id="tbl_ID" class="formtext" cellpadding="2" cellspacing="1" border="0">
                    <tbody>
                        <tr>
                            <td align="center" class="formtitle"><input type="Checkbox" onclick="IsSelectAll(this)" name="chkAll"></td>
                            <td align="center" class="formtitle">Item Code</td>
                            <td align="center" class="formtitle">Description</td>
                            <td align="center" class="formtitle">Notes</td>
                            <td align="center" class="formtitle" style="display:none">Dimension</td>

                            <td align="center" class="formtitle">Color</td>
                            <td align="center" class="formtitle">Brand</td>
                            <td align="center" class="formtitle">Type</td>

                            <td align="center" class="formtitle">Qty</td>
                            <td align="center" class="formtitle">Unit Type</td>
                            <td align="center" class="formtitle">Qty 2</td>
                            <td align="center" class="formtitle">Unit Type 2</td>


                            <td align="center" class="formtitle" style="display:none">Reserved Qty</td>
                            <td align="center" class="formtitle" style="display:none">Unit Type</td>
                            <td align="center" class="formtitle" style="display:none">Reserved Qty 2</td>
                            <td align="center" class="formtitle" style="display:none">Unit Type 2</td>


                            <td align="center" class="formtitle">Unit Price <br>
                                <span id="idUnitPrice">(Converted)</span>
                            </td>

                            <td align="center" class="formtitle">Disc Value</td>

                            <td align="center" class="formtitle">Discount <br>(%)</td>


                            <td align="center" class="formtitle">Amount <br>
                                <span id="idAmount">(Converted)</span>
                            </td>
                            <td align="center" class="formtitle">Tax 1<br></td>
                            <td align="center" class="formtitle">Tax 2<br></td>

                            <td align="center" class="formtitle" colspan="2">Estimated Date</td>
                            <td align="center" class="formtitle" id="allocateTo"> Cost Center </td>


                        </tr>

                    </tbody>
                </table>
            </div>
        </div>
    </td>
</tr>