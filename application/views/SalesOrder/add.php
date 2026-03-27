<div class="row">
    <div class="col-md-6">
        <div class="row">
            <div class="col-md-12">
                <label for="SO_NUMBER">SO Number : </label>
                <input type="text" id="SO_NUMBER" name="SO_NUMBER">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="username">SO Tax Type :</label>
                <td align="Left">
                    <input type="Radio" name="txtSOtype" id="txtSOtype" value="1" onclick="SO_Switcher(this);" checked=""> Normal &nbsp;
                    <input type="Radio" name="txtSOtype" id="txtSOtype" value="0" onclick="SO_Switcher(this);"> VAT Include
                </td>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="username">Project Name :</label>
                <input type="text" id="selProject" name="selProject">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="username">Allocate To :</label>
                <td>
                    <input type="radio" name="rdoAllocate" value="0" onclick="changeType(this);">Project Component
                    &nbsp;&nbsp;
                    <input type="radio" name="rdoAllocate" value="1" onclick="changeType(this);" checked="">Cost Center
                </td>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="username">Document Source :</label>
                <td>
                    <input type="Radio" name="rbTypedoc" value="0" checked="" onclick="cleardata();document.frmNew.submit();"> Quotation
                    <input type="Radio" name="rbTypedoc" value="2" onclick="cleardata();document.frmNew.submit();"> Proforma Invoice
                    <input type="Radio" name="rbTypedoc" value="3" onclick="cleardata();document.frmNew.submit();"> Sales Contract
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
                </td>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label for="Customer">Customer * : </label>
                <input type="text" name="txtCustName" id="txtCustName" value="">
                <!-- HIDDEN VALUE -->
                <input type="hidden" name="txtCustCode" id="txtCustCode" value="">
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <td valign="top" nowrap="">Address</td>
                <td valign="top">:</td>
                <td id="AlamatCust">
                    <input type="hidden" name="txtCustAddress" value="">
                    <span id="CustAddress">
                        42212 Remington Ave Temecula CA 92590
                        USA
                        Atten Dennis Zager
                        Tel 4027707747
                    </span>
                </td>
            </div>
        </div>
        <div class="row mt-4">
            <div class="col-md-12">
                <label>Contact Person : </label>
                <input type="hidden" name="txtCPCode" value="8220">
                <input type="text" name="txtCPName" value="Dennis Zager">
            </div>
        </div>
    </div>