<div class="card card-flush overflow-hidden h-xl-100">
    <form name="frmNew" id="frmNew" action="" method="post">
        <div class="container-fluid py-3">
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="SO_NUMBER">SO Number :</label>
                        <div class="col-sm-8">
                            <input type="text" id="SO_NUMBER" name="SO_NUMBER" class="form-control form-control-sm" placeholder="SOL209<?= date('ym') ?>-XXXXXXX" readonly>
                            <input type="hidden" id="task" name="task" value="<?= $task ?>">
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtSOtype">So Tax Type :</label>
                        <div class="col-sm-8 pt-1">
                            <div class="custom-control custom-radio custom-control-inline custom-control-sm">
                                <input type="radio" name="txtSOtype" id="taxNormal" value="1" class="custom-control-input" checked="">
                                <label class="custom-control-label small" for="taxNormal">Normal</label>
                            </div>
                            <div class="custom-control custom-radio custom-control-inline custom-control-sm">
                                <input type="radio" name="txtSOtype" id="taxVAT" value="0" class="custom-control-input">
                                <label class="custom-control-label small" for="taxVAT">VAT Include</label>
                            </div>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="selProject">Project Name :</label>
                        <div class="col-sm-8">
                            <input type="text" id="selProject" name="selProject" class="form-control form-control-sm" placeholder="Project Name...">
                        </div>
                    </div>

                    <div class="form-group row">
                        <label class="col-sm-4 col-form-label col-form-label-sm font-weight-bold">Allocate To :</label>
                        <div class="col-sm-8 pt-1">
                            <div class="custom-control custom-radio custom-control-inline custom-control-sm">
                                <input type="radio" name="rdoAllocate" id="rdoProj" value="0" class="custom-control-input"
                                    <?= (isset($rdoAllocate) && $rdoAllocate == 0) ? 'checked' : '' ?>>
                                <label class="custom-control-label small" for="rdoProj">Project Component</label>
                            </div>

                            <div class="custom-control custom-radio custom-control-inline custom-control-sm">
                                <input type="radio" name="rdoAllocate" id="rdoCC" value="1" class="custom-control-input"
                                    <?= (!isset($rdoAllocate) || $rdoAllocate == 1) ? 'checked' : 'checked' ?>>
                                <label class="custom-control-label small" for="rdoCC">Cost Center</label>
                            </div>
                        </div>
                    </div>

                    <div class="form-group row">
                        <label class="col-sm-4 col-form-label col-form-label-sm font-weight-bold">Document Source :</label>
                        <div class="col-sm-8 pt-1">
                            <div class="custom-control custom-radio custom-control-inline custom-control-sm">
                                <input type="radio" name="rbTypedoc" id="docQuo" value="0" class="custom-control-input" checked>
                                <label class="custom-control-label small" for="docQuo">Quotation</label>
                            </div>

                            <div class="custom-control custom-radio custom-control-inline custom-control-sm">
                                <input type="radio" name="rbTypedoc" id="docPI" value="2" class="custom-control-input" disabled>
                                <label class="custom-control-label small text-muted" for="docPI">Proforma Invoice</label>
                            </div>

                            <div class="custom-control custom-radio custom-control-inline custom-control-sm">
                                <input type="radio" name="rbTypedoc" id="docSC" value="3" class="custom-control-input" disabled>
                                <label class="custom-control-label small text-muted" for="docSC">Sales Contract</label>
                            </div>

                            <div class="mt-2">
                                <div id="DivQuotation" class="mb-2">
                                    <input type="text" name="selQuotation" id="selQuotation"
                                        class="form-control form-control-sm"
                                        value="<?= $selQuotation ?>"
                                        placeholder="Input Quotation Number...">

                                    <?php if (!empty($SourceDate)): ?>
                                        <div class="mt-1 small text-danger font-italic">
                                            [Doc Source Date : <?= $SourceDate ?>]
                                        </div>
                                    <?php endif; ?>
                                </div>

                                <div id="DivProforma" class="mb-2" style="display: none;">
                                    <input type="text" name="selProforma" class="form-control form-control-sm bg-light"
                                        placeholder="Proforma Number (Disabled)" disabled>
                                </div>

                                <div id="DivSalesContract" style="display: none;">
                                    <input type="text" name="ddlSalesContract" class="form-control form-control-sm bg-light"
                                        placeholder="Contract Number (Disabled)" disabled>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtCustName">Customer * :</label>
                        <div class="col-sm-8">
                            <input type="text" name="txtCustName" id="txtCustName" class="form-control form-control-sm" placeholder="Customer...." readonly>
                            <input type="hidden" name="txtCustCode" id="txtCustCode" value="">
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtCustAddress">Address :</label>
                        <div class="col-sm-8">
                            <textarea name="txtCustAddress" id="txtCustAddress" class="form-control form-control-sm" rows="3" placeholder="Address..." readonly></textarea>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm">Tax File Number :</label>
                        <div class="col-sm-8 pt-2">
                            <input type="hidden" name="txtnpwp" id="txtnpwp" value="" placeholder="Tax File Number..." readonly>
                            <span id="CPTaxFileNumber" class="fw-bold text-dark" style="font-size: 0.85rem;">-</span>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtCPName">Contact Person :</label>
                        <div class="col-sm-8">
                            <input type="hidden" name="txtCPCode" id="txtCPCode" value="">
                            <input type="text" name="txtCPName" id="txtCPName" class="form-control form-control-sm" value="" placeholder="Contact Person..." readonly>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtCPAddress">Contact Address :</label>
                        <div class="col-sm-8">
                            <input type="text" name="txtCPAddress" class="form-control form-control-sm" value="" placeholder="Contact Address..." readonly>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtSPCode">Sales Person * :</label>
                        <div class="col-sm-8">
                            <select name="txtSPCode" id="txtSPCode" class="form-control form-control-sm select2-item" data-control="select2">
                                <option value="">-- Select Sales Person --</option>
                                <?php if (!empty($sales_person)): ?>
                                    <?php foreach ($sales_person as $sp): ?>
                                        <option value="<?= $sp->Emp_ID ?>"
                                            <?= (isset($qSales->Emp_ID) && $qSales->Emp_ID == $sp->Emp_ID) ? 'selected' : '' ?>>
                                            <?= $sp->name ?>
                                        </option>
                                    <?php endforeach; ?>
                                <?php endif; ?>
                            </select>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtMemo">Remarks :</label>
                        <div class="col-sm-8">
                            <textarea name="txtMemo" class="form-control form-control-sm" rows="3" placeholder="Remarks..."></textarea>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm">Bonded Area :</label>
                        <div class="col-sm-8 pt-1">
                            <div class="custom-control custom-checkbox custom-control-sm">
                                <input type="checkbox" name="chkKawasan" id="chkKawasan" value="1" class="custom-control-input">
                                <label class="custom-control-label small" for="chkKawasan">Yes</label>
                            </div>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="selSNGroup">SN Account :</label>
                        <div class="col-sm-8">
                            <select name="selSNGroup" class="form-control form-control-sm">
                                <option value="-1" disabled selected>NONE</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="selSIGroup">SI Account :</label>
                        <div class="col-sm-8">
                            <select name="selSIGroup" class="form-control form-control-sm">
                                <option value="-1" disabled selected>NONE</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtRevisionReason">Revision Reason :</label>
                        <div class="col-sm-8">
                            <textarea name="txtRevisionReason" class="form-control form-control-sm" rows="3" placeholder="Revision Reason..."></textarea>
                        </div>
                    </div>
                </div>

                <div class="col-md-6 border-left">
                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtSODate">SO Date :</label>
                        <div class="col-sm-8">
                            <input type="text" id="txtSODate" name="txtSODate" class="form-control form-control-sm date-picker" value="<?= date('Y-m-d') ?>">
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtInvDueDate">Due Date :</label>
                        <div class="col-sm-8">
                            <input type="text" id="txtInvDueDate" name="txtInvDueDate" class="form-control form-control-sm date-picker" value="<?= date('Y-m-d') ?>">
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtPONum">Cust PO Num :</label>
                        <div class="col-sm-8">
                            <input type="text" id="txtPONum" name="txtPONum" class="form-control form-control-sm" placeholder="Customer PO Number...">
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtPODate">Cust PO Date :</label>
                        <div class="col-sm-8">
                            <input type="text" id="txtPODate" name="txtPODate" class="form-control form-control-sm date-picker" value="<?= date('Y-m-d') ?>">
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm">Prod Month/Year :</label>
                        <div class="col-sm-8">
                            <div class="row no-gutters">
                                <div class="col-6 pr-1">
                                    <select name="txtProMonth" id="txtProMonth" class="form-control form-control-sm">
                                        <option value="" selected disabled>-- Month --</option>
                                        <option value="1">January</option>
                                        <option value="2">February</option>
                                        <option value="3">March</option>
                                        <option value="4">April</option>
                                        <option value="5">May</option>
                                        <option value="6">June</option>
                                        <option value="7">July</option>
                                        <option value="8">August</option>
                                        <option value="9">September</option>
                                        <option value="10">October</option>
                                        <option value="11">November</option>
                                        <option value="12">December</option>
                                    </select>
                                </div>
                                <div class="col-6 pl-1">
                                    <select name="txtProYear" id="txtProYear" class="form-control form-control-sm">
                                        <option value="" selected disabled>-- Year --</option>
                                        <?php
                                        $startYear   = 2024;
                                        $currentYear = (int)date('Y');
                                        $endYear     = $currentYear + 2;
                                        $savedYear = $this->input->post('txtProYear') ?? ($qSales->pro_year ?? "");
                                        for ($y = $startYear; $y <= $endYear; $y++) :
                                        ?>
                                            <option value="<?= $y ?>" <?= ($savedYear == $y) ? 'selected' : '' ?>>
                                                <?= $y ?>
                                            </option>
                                        <?php endfor; ?>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="selCurrency">SO Currency :</label>
                        <div class="col-sm-8">
                            <select name="selCurrency" id="selCurrency" class="form-control form-control-sm">
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

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="selTaxCurrency">Tax Currency :</label>
                        <div class="col-sm-8">
                            <select name="selTaxCurrency" id="selTaxCurrency" class="form-control form-control-sm">
                                <option value="IDR" selected="">IDR</option>
                                <option value="USD">USD</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="BaseCurr">Base Currency :</label>
                        <div class="col-sm-8">
                            <select name="BaseCurr" id="BaseCurr" class="form-control form-control-sm">
                                <option value="IDR" selected="">IDR</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="cboTerms">Payment Schedule :</label>
                        <div class="col-sm-8">
                            <input type="hidden" name="txtTerms" value="0">
                            <select name="cboTerms" id="cboTerms" class="form-control form-control-sm" onchange="lpage();">
                                <option value="NONE" selected="">NONE - 1 monthly (cash)</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="cboTermsNew">Payment Terms :</label>
                        <div class="col-sm-8">
                            <input type="hidden" name="txtTermsNew">
                            <select name="cboTermsNew" id="cboTermsNew" class="form-control form-control-sm" onchange="lpage();">
                                <option value="" selected="">None - 1 month (default)</option>
                                <option value="Term001">Cash - 30 days</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtDeliveryTerms">Delivery Terms :</label>
                        <div class="col-sm-8">
                            <textarea name="txtDeliveryTerms" class="form-control form-control-sm" rows="2" placeholder="Delivery Terms..."></textarea>
                        </div>
                    </div>

                    <!-- <div class="card mb-3 border-secondary">
                    <div class="card-header py-1 font-weight-bold small bg-light">Credit Info</div>
                    <div class="card-body p-2" style="font-size: 0.8rem;">
                        <input type="hidden" name="txtcreditlimit" value="0"><input type="hidden" name="baseCreditLimit" value="0">
                        <input type="hidden" name="txtInvNotPaid" value="4848785.666879991"><input type="hidden" name="baseInvNotPaid" value="46703772557.118">
                        <input type="hidden" name="txtSOApproved" value="55113214.79497244"><input type="hidden" name="baseSOApproved" value="530853542621.58">
                        <input type="hidden" name="txtRemainingCredit" value="-59962000.46185243"><input type="hidden" name="baseRemainCredit" value="-577557315178.698">

                        <div>Limit : <span id="idcreditLimit">(USD)</span> <span id="creditLimit">0</span></div>
                        <div>Inv Not Paid : <span id="idInvNotPaid">(USD)</span> <span id="InvNotPaid">4.848.785,66</span></div>
                        <div class="border-bottom pb-1">SO Approved : <span id="idSOApproved">(USD)</span> <span id="SOApproved">55.113.214,79</span></div>
                        <div class="pt-1">
                            Rem. Credit :
                            <a href="javascript://" onclick="arrNewPop[arrNewPop.length]=PopWindow('/samickerp/...','Preview','800','600','...');" class="font-weight-bold text-danger">
                                <span id="idRemainingCredit">(USD)</span> <span id="RemainingCredit">-59.962.000,46</span>
                            </a>
                        </div>
                    </div>
                </div> -->

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="cboPriceType">Price Type :</label>
                        <div class="col-sm-8">
                            <select name="cboPriceType" id="cboPriceType" class="form-control form-control-sm">
                                <option value="FOB" selected="">Freight on Board</option>
                                <option value="CIF">Cost Insurance Freight</option>
                                <option value="CFR">Cost and Freight</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group row mt-2">
                        <label class="col-sm-4 col-form-label col-form-label-sm" for="txtPiNumber">Pi Number * :</label>
                        <div class="col-sm-8">
                            <input name="txtPiNumber" id="txtPiNumber" class="form-control form-control-sm" value="" placeholder="PI Number...">
                        </div>
                    </div>
                </div>
            </div>

            <div class="row mt-3">
                <div class="col-md-3">
                    <fieldset class="border p-2">
                        <legend class="w-auto px-2 font-weight-bold small text-uppercase">Currency Converter</legend>
                        <div class="table-responsive">
                            <table class="table table-sm table-borderless mb-0" id="tblCurrConverter">
                            </table>
                        </div>
                    </fieldset>
                </div>

                <div class="col-md-3">
                    <fieldset class="border p-2">
                        <legend class="w-auto px-2 font-weight-bold small text-uppercase">Tax Converter</legend>
                        <div class="table-responsive">
                            <table class="table table-sm table-borderless mb-0" id="tblTaxConverter">
                            </table>
                        </div>
                    </fieldset>
                </div>
            </div>
            <input type="hidden" name="CurrencyRateList" id="CurrencyRateList" value="">

            <input type="hidden" name="txtCurr_<?= $_COOKIE['currencyid'] ?? 'IDR' ?>" value="1">
            <input type="hidden" name="txtTax_<?= $_COOKIE['currencyid'] ?? 'IDR' ?>" value="1">
            <div class="row mt-2">
                <div class="col-12">
                    <button type="button" id="btnPickItem" class="btn btn-sm btn-outline-primary">
                        <i class="fas fa-plus-circle"></i> [+] Multiple Item
                    </button>

                    <button type="button" id="btnRemoveItem" class="btn btn-sm btn-outline-danger">
                        <i class="fas fa-minus-circle"></i> [-] Remove Item
                    </button>
                </div>
            </div>

            <input type="hidden" name="hdnLstItemID" id="hdnLstItemID" value="">
            <div class="row mt-3">
                <div class="col-12 border p-0 shadow-sm" style="height: 480px; overflow:auto;">
                    <div class="table-responsive-lg">
                        <table class="table table-sm table-striped border mb-0 text-center" id="tbl_ID" style="font-size: 0.8rem;">
                            <thead style="background-color: #3B6D8C;">
                                <tr class="text-nowrap font-weight-bold text-white">
                                    <th><input type="Checkbox" name="chkAll" id="chkAll"></th>
                                    <th>Item Code</th>
                                    <th>Description</th>
                                    <th>Notes</th>
                                    <th style="display:none">Dim</th>
                                    <th>Color</th>
                                    <th>Brand</th>
                                    <th>Type</th>
                                    <th>Qty</th>
                                    <th>Unit</th>
                                    <th>Qty 2</th>
                                    <th>Unit 2</th>
                                    <th style="display:none">Res Qty</th>
                                    <th style="display:none">Unit</th>
                                    <th>Unit Price <br><span id="idUnitPrice" class="badge badge-info small">Conv</span></th>
                                    <th>Disc Val</th>
                                    <th>Disc%</th>
                                    <th>Amount <br><span id="idAmount" class="badge badge-info small">Conv</span></th>
                                    <th>Tax 1</th>
                                    <th>Tax 2</th>
                                    <th colspan="2">Est. Date</th>
                                    <th>CC</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="row mt-4">
                <div class="col-md-5">
                    <div class="card shadow-sm border mt-4">
                        <div class="card-header py-2">
                            <h6 class="card-title mb-0 small text-uppercase fw-bold">Payment Detail</h6>
                        </div>
                        <div class="card-body p-0">
                            <table class="table table-sm table-striped border mb-0" id="tblPayment">
                                <thead style="background-color: #3B6D8C;">
                                    <tr class="fw-bold fs-7 text-white">
                                        <th class="text-center" width="50">No</th>
                                        <th class="text-center">Invoice Date</th>
                                        <th class="text-center">Due Date</th>
                                        <th class="text-center">Amount (<span class="curr-label">USD</span>)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td class="text-center align-middle">1</td>
                                        <td>
                                            <input type="text" name="txtInvoiceDate1" class="form-control form-control-sm date-picker" value="<?= date('Y-m-d') ?>">
                                        </td>
                                        <td>
                                            <input type="text" name="txtDueDate1" class="form-control form-control-sm date-picker" value="<?= date('Y-m-d', strtotime('+30 days')) ?>">
                                        </td>
                                        <td>
                                            <input type="text" name="txtAmount1" id="txtAmount1" class="form-control form-control-sm text-end bg-light" readonly value="0.0000">
                                            <input type="hidden" name="hidPercentage1" id="hidPercentage1" value="100">
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="col-md-1">&nbsp;</div>
                <div class="col-md-5">
                    <div class="card shadow-sm border">
                        <div class="card-body p-4">
                            <table class="table table-sm table-borderless mb-0" style="font-size: 0.85rem;">
                                <tbody>
                                    <tr>
                                        <td class="fw-bold" width="40%">Total Qty</td>
                                        <td width="5%">:</td>
                                        <td>
                                            <input type="text" name="txtTotQty" id="txtTotQty" class="form-control form-control-sm text-end fw-bold bg-light" readonly value="0.0000">
                                        </td>
                                    </tr>

                                    <tr>
                                        <td class="fw-bold">Total Amount (<span class="curr-label">Converted</span>)</td>
                                        <!-- sesuai SO Currency/ Sel Currency -->
                                        <td>:</td>
                                        <td>
                                            <input type="text" name="txtTotAmount" id="txtTotAmount" class="form-control form-control-sm text-end bg-light" readonly value="0.0000">
                                        </td>
                                    </tr>

                                    <tr>
                                        <td class="fw-bold">
                                            Disc. Global
                                            <div class="input-group input-group-sm d-inline-flex ms-2" style="width: 70px;">
                                                <input type="number" id="idDiscall" name="txtDisctotal" class="form-control text-center p-1" value="0" max="100" oninput="if(value>100)value=100">
                                                <span class="input-group-text p-1">%</span>
                                            </div>
                                        </td>
                                        <td>:</td>
                                        <td>
                                            <input type="text" name="txtTotDisc" id="idTotalDiscall" class="form-control form-control-sm text-end bg-light" readonly value="0.0000">
                                        </td>
                                    </tr>

                                    <tr>
                                        <td class="fw-bold">Total Tax (+ IDR)</td>
                                        <td>:</td>
                                        <td>
                                            <input type="text" name="txtTotTaxConv" id="txtTotTaxConv" class="form-control form-control-sm text-end bg-light text-primary" readonly value="0.0000">
                                        </td>
                                    </tr>

                                    <tr>
                                        <td class="fw-bold">Total Deduction (- IDR)</td>
                                        <td>:</td>
                                        <td>
                                            <input type="text" name="txtTotDeductConv" id="txtTotDeductConv" class="form-control form-control-sm text-end bg-light text-danger" readonly value="0.0000">
                                        </td>
                                    </tr>

                                    <tr>
                                        <td class="fw-bold text-danger">Claim Deduction (<span class="curr-label">IDR</span>)</td>
                                        <td>:</td>
                                        <td>
                                            <input type="text" name="txt_cd_amount" id="txt_cd_amount" class="form-control form-control-sm text-end border-danger" value="0.00">
                                        </td>
                                    </tr>

                                    <tr id="idTaxHide2" style="display: none;" class="border-top">
                                        <td class="fw-bold fs-6 text-primary py-3">Grand Total (<span class="curr-label">Converted</span>)</td>
                                        <td class="py-3">:</td>
                                        <td class="py-3">
                                            <input type="text" name="txtGrandTotal" id="txtGrandTotal" class="form-control form-control-sm text-end fw-bolder fs-6 border-primary bg-primary text-white" readonly value="0.0000">
                                        </td>
                                    </tr>

                                    <tr>
                                        <td class="align-top pt-2">Claim Description</td>
                                        <td class="align-top pt-2">:</td>
                                        <td>
                                            <textarea name="txt_cd_desc" id="txt_cd_desc" class="form-control form-control-sm" rows="2" placeholder="Alasan pemotongan..."></textarea>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <table class="table">
                    <tr>
                        <td colspan="2" class="border-top py-3">
                            <div class="d-flex gap-2">
                                <button type="button"
                                    name="btnSubmit"
                                    class="btn btn-primary px-4"
                                    onclick="passingVars();">
                                    <i class="fas fa-save mr-1"></i> Save
                                </button>

                                <button type="button"
                                    name="btnConfirm"
                                    class="btn btn-success px-4"
                                    onclick="passingVars('YES');">
                                    <i class="fas fa-check-circle mr-1"></i> Confirm
                                </button>

                                <button type="button"
                                    name="btnCancel"
                                    class="btn btn-danger px-4"
                                    onclick="window.location.href='/samickerp/erp/eaccounting/index.cfm?HelpCategory_id=eAccSales&Help_Id=SalesOrder&FID=ERSTD07854&FUID=ERSTD0785401&menu=1';">
                                    <i class="fas fa-times mr-1"></i> Cancel
                                </button>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </form>
</div>