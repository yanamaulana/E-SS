<!------------------------------------------------------------------------------
APPLICATION......: SunFishERP 51
FID..............: -
FUID/SELACTIONID.: -
FILENAME.........: add.cfm
================================================================================
CREATED BY.......: - ??
CREATED DATE.....: - ??
================================================================================
DESCRIPTION......:  SO Tax type:
						1 = PPN Normal - belum termasuk dalam harga barang, jadi ada tambahan PPN 10% (FAKTUR PAJAK STANDARD)
						0 = PPN Incuded - sudah termasuk dalam harga barang (FAKTUR PAJAK SEDERHANA)
					
					Currency Converter
					- Base Curr 	= cookie.currencyid (IDR)
					- SO Curr 		= selCurrency			=> TCurrencyConverter  $100
					- Tax Curr 		= selTaxCurrency		=> TAccTaxConverter  $ 10 
================================================================================
REVISION.........: /* 27 September 2010 - randytia */
.................: change document selected use ajax and added txtdiscount1 for sales contract
					TXTESTIMATEDATESPLIT_ dihilangkan pada saat sales contract karena selalu undefined

REVISION.........: /* 30 September 2010 - randytia */
.................: Create URL For Remaining Credit

REVISION.........: /* 22 Oct 2010 - randytia */
.................: Change ##IDRW## to #IDRW#

REVISION.........: /* 26 Oct 2010 - randytia */
.................: Menambahkan Dimension untuk getprice dan getdiscount

REVISION.........: /* 27 October 2010 - Ivan Pujianto */
.................: Add item dimension selection
.................: Notes : enable to change item dimension without to re-pick item

REVISION.........: /* 29 October 2010 - Ivan Pujianto */
.................: Sales price and discount notification
.................: Notes : when price and discount set by system or user defined change the text box background color

REVISION.........: /* 03 Mei 2011 - NP */
.................: Free Item and Discount Total
------------------------------------------------------------------------------->

<cfoutput>
<html>
<head>

	<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
    <META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-STORE">
    <META HTTP-EQUIV="Pragma" CONTENT="NO-CACHE">
    <META HTTP-EQUIV="Expires" CONTENT="-1">

<style>
.inplabel {border:none;background-color:white;}
.inpdim {border:none;background-color:white;}
##divLookup
{
  width: 370;
  /*height: ;*/
  background: ##FFF;
  border: 2px solid ##000;
  color: ##FFF;
  position: absolute;
  text-align: center;
  padding: 5px;
  top: 50%;
  left: 50%;
  z-index: 2;
  display: none;
}
##divLookupContent
{
  width: 365;
  height: 137;
  z-index: 4;
  overflow-y: auto;
  scrollbar-arrow-color: blue;
  scrollbar-face-color: ##e7e7e7;
  scrollbar-3dlight-color: ##a0a0a0;
  scrollbar-darkshadow-color: ##888888;
}
##lblProgress
{
  width: 365;
  height: 137;
  z-index: 3;
  overflow-y: auto;
  scrollbar-arrow-color: blue;
  scrollbar-face-color: ##e7e7e7;
  scrollbar-3dlight-color: ##a0a0a0;
  scrollbar-darkshadow-color: ##888888;
}
##lblError
{
  width: 365;
  height: 137;
  z-index: 3;
}
</style>
<cfif task eq "save">
	<cfset varSecAccess = REQUEST.SFSecAccess.SecAccessFile(FILEACCESSCODE="ERSTD0785402", BACKURL="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/index.cfm?selListItem=1&menu=0")>
<cfelse>
	<cfset varSecAccess = REQUEST.SFSecAccess.SecAccessFile(FILEACCESSCODE="ERSTD0785403", BACKURL="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/index.cfm?selListItem=1&menu=0")>
</cfif>

<script language="JavaScript" src="#Application.stApp.Web_Path[vst_idx]#/include/js/allscripts.js"></script>
<script language="javascript" src="#Application.stApp.Web_Path[vst_idx]#/include/js/ajax_engine.js"></script>
<script language="javascript" src="#Application.stApp.Web_Path[vst_idx]#/include/js/jquery-1.4.1.js"></script>

<cfset LANGUAGELIST = "AmountAlloGtAmountMisc,paymentdetail,is_install,Discount,CurrencyConverter,InsufficientCredit,No,Remainingcredit,SO,Approved,SisterCompany,Yes,InvoiceNotPaid,QuotationNumber,CreditLimit,Rate,PriceList,RateType,CustomerRequired,Update, SNAccount,Select,SIAccount,ProformaInvoice,InputValidDate, KawasanBerikat,Yes,AutomaticSN,PleaseSetCurrencyConverter,customer, CurrentCurrency,NoQuotation, Memo, sales, SalesOrder, New, "
					& "qty2,UnitType,UnitType2,IncludedTax,Edit, TotalAmount, TotalTax,MultipleItem,Open,None, Tax, SOCurrency, TaxCurrency, TotalTerm,employ_commission,SOTaxType,DP,"
					& "TotalDeduction, TotalMiscellaneousCharge, DateReq, SellingPriceType, eAcc_PriceRetail, eAcc_PriceShop, eAcc_PriceDistributor, eAcc_PriceOther,PleaseInputETA,Normal,Disc,"
					& "SO_Number, CustomerPONumber, TaxNumber,DueDate,MiscChargeAllocation, SODate, CustomerPODate, Save, Cancel, eHRMConfirm,MemoRequired,PleaseInputETD,IncludedPPN,add,payment,SODateMustEarlierThanEstDate,PleaseSet,DeliveryDate,InvalidDate,InvalidAmount,Choose,QtyPurchaseAndReceivedNotEqual,"
					& "ItemCode,Description,AmountAlloGtAmountMisc,QTY,UnitPrice,Discount,Amount,Tax,Converted, contactPerson, salesPerson, selectCustomerRequired,Tot_AmountMustGreater,InvoiceMustGreater,PaymentTermAmount,DifferentFromGrandTotal,AlreadyHaveItem,PlsChooseDocSource,"
					& "selectContact, accountName, EdDateMustGTStDate, accountAddress, Search, ShowAll, Close, CHANGEITEMDIMENSION, CustomerAddress, ContactName, Address,PleaseInputSODate, EstimateDate,DueDate,MustBe,GreaterThen,SalesOrderDate,"
					& "contactAddress, Employee_ID,CreditInfo,doubleitem,for,and,dimension, color,eHRMEmployeeName, eHRMAltDate, SeleItem, itemName, eHRMProcessing, ExternalSalesCommission,InvoiceMustGreater,Donation,"
					& "Document, ETD, ETA, ETDbiggerthanETA,SomeItemAlreadyExist,Remarks,SODatebiggerthanETD,doubleitem,PleaseSelectSalesPerson,PaymentTerms,OthersDesc,DeliveryTerms,TaxIncludedInPrice,DeleteItem,ItemQty,First,"
					& "CreatedBy,creationdate,update,by,eHRMLastUpdate,TaxConverter,PleaseSelectProject,ProjectName,AllocateTo,ProjectComponent,ProfitCenter,AmountMiscGtTotalMisc,Remove,MiscellaneousCharge,Before,Continue,Configure,AlreadyHaveItem,DocSourceDate,"
					& "GrandTotal,ExtraPrice,PleaseInputCustPONum,Quotation,eHRMNone,PleaseSelectItem,FinishedGood,RawMaterial,Asset,SparePart,Contoh,DISNum,eAcc_SoleDistributor, DocSource, ProjectCostCalculation,Colour,AutomaticPO,IncludedPPN,Dimension,"
					& "Notes,Revise,QtyGreatZero,PriceGreatZero,PriceType,SelectItem,ReasonMustBeFill,WhenDeletingData,AnErrorHasOccured,SalesContract, AddItem, RemoveItem,DiscValue,PlsSelectItem,PlsSelectCustomer,PaymentSchedule,InvoiceDate,InvoiceDueDatemustbegreaterthanInvoiceDate,CostCenter,FreeItem,AddPurchaseMiscCharges,Name,Notes,AllocationType,RevisionReason, claimdeduction, eHRMType,Color,ItemBrand,ReservedQty,Unit,LowerThanRsvQty">
<CF_DO_V25_MULTILANGUAGE MESSAGEIDLIST="#LanguageList#"> 


<cfset mm = dateFormat(now(),"mm")>
<cfset dd = DaysInMonth(now())>
<cfset yy = year(now())>
<cfset jumrowloop = 0>
<cfset displayStyle = "display:none">
<!---
<cfparam name="selProject" default="0">
<cfparam name="rdoAllocate" default="0">
--->

<cfparam name="tax_minus"				default="0">
<cfparam name="tax_plus"				default="0">
<cfparam name="lstCurrency"				default="">
<cfparam name="hdnMatrixItem"			default="">
<cfparam name="txtExpDelDate"			default="">
<cfparam name="dcf_identity"			default="0">
<cfparam name="ddlSalesContract"		default="">
<cfparam name="converter"				default="">
<cfparam name="ListMisc"				default="">
<cfparam name="cboPriceType"			default="FOB">
<cfparam name="txtRevisionReason"		default="">

<cfparam name="claim_deduction_amount"	default="0.00">
<cfparam name="claim_deduction_desc"	default="">

<cfparam name="SNQty"					default="0">
<cfparam name="SNQty2"					default="0">

<cfif isDefined('rowcountMisc')>
	<cfparam name="jumrowloopMisc" default="#rowcountMisc#">
<cfelse>
	<cfparam name="jumrowloopMisc" default="0">
</cfif>

<cfset local.tmpSCNumber = "">
<cfif isDefined("form.ddlSalesContract")>
	<cfset local.tmpSCNumber = FORM['ddlSalesContract']>
</cfif>

<cfquery name="qLangName" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
 	SELECT Field_Table 
	FROM TLanguage
	WHERE language_id = #cookie.Lang_ID#
</cfquery>

<cfquery name="qcolor" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
	Select color_code,color_name from TgsColor
</cfquery>

<cfset strctColor = StructNew()>
<cfloop query="qColor">
	<cfset strctColor[qColor.color_code] = qColor.color_name>
</cfloop>
	
	
<cffunction name="funcFindChild">
	<cfargument name="ID" type="any" required="true">
	<cfquery datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#" name="qChild">
		SELECT CostCenter_ID, CostCenter_Code, CostCenter_Name_#qLangName.Field_Table# AS CostCenter_Name, Flag, Parent_Path, Depth
		FROM TAccCostCenter
		WHERE Company_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Cookie.CompanyID#" null="no">
		AND CC_Type = 'CC'
		AND Parent_ID = #arguments.ID#
		ORDER BY Display_Order ASC
	</cfquery>
	<cfloop query="qChild">
		<cfset QueryAddRow(qCostCenter)>
		<cfset QuerySetCell(qCostCenter,"CostCenter_ID",CostCenter_ID)>
		<cfset QuerySetCell(qCostCenter,"CostCenter_Code",CostCenter_Code)>
		<cfset QuerySetCell(qCostCenter,"CostCenter_Name",CostCenter_Name)>
		<cfset QuerySetCell(qCostCenter,"Flag",Flag)>
		<cfset QuerySetCell(qCostCenter,"Parent_Path",Parent_Path)>
		<cfset QuerySetCell(qCostCenter,"Depth",Depth)>
		<cfset funcFindChild(CostCenter_ID)>
	</cfloop>
</cffunction>

<cfquery datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#" name="qCostCenterHd">
	Select costcenter_id, CostCenter_Code, costcenter_name_#qLangName.Field_Table# as costcenter_name, flag, Parent_Path, Depth
	From TAccCostCenter
	WHERE 	TAccCostCenter.Company_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#COOKIE.COMPANYID#" null="no">
	AND TAccCostCenter.CC_Type = 'CC'
	AND TAccCostCenter.Parent_ID <> 0
	AND Depth = 1
	<!--- Order By Depth,Parent_ID, Display_Order --->
	ORDER BY <!--- CostCenter_Code ---> Display_Order	<!--- Di Ristra begini biar bisa ke order dengan header nya --->
</cfquery>
 
<cfset qCostCenter = QueryNew("CostCenter_ID, CostCenter_Code, CostCenter_Name, Flag, Parent_Path, Depth")>

<cfloop query="qCostCenterHd">
	<cfset QueryAddRow(qCostCenter)>
	<cfset QuerySetCell(qCostCenter,"CostCenter_ID",qCostCenterHd.CostCenter_ID)>
	<cfset QuerySetCell(qCostCenter,"CostCenter_Code",qCostCenterHd.CostCenter_Code)>
	<cfset QuerySetCell(qCostCenter,"CostCenter_Name",qCostCenterHd.CostCenter_Name)>
	<cfset QuerySetCell(qCostCenter,"Flag",qCostCenterHd.Flag)>
	<cfset QuerySetCell(qCostCenter,"Parent_Path",qCostCenterHd.Parent_Path)>
	<cfset QuerySetCell(qCostCenter,"Depth",qCostCenterHd.Depth)>
	<cfset funcFindChild(qCostCenterHd.CostCenter_ID)>
</cfloop>


<cfparam name="selCurrencyEditable" default="1">
<cfif task eq 'edit'>
<cfquery name="qCheckSN" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT * 
	FROM TAccSN_Item
	INNER JOIN TAccSN_Header ON TAccSN_Item.SN_Number = TAccSN_Header.SN_Number
	WHERE TAccSN_Item.SO_Number = '#SONum#'
	AND TAccSN_Header.Approval_Status <> 4
	AND isnull(TAccSN_Header.isVoid,0) = 0
</cfquery>
<cfif qCheckSN.RecordCount>
	<cfset selCurrencyEditable = 0>
</cfif>
</cfif>

<cfif isDefined ("form.selQuotation")>
	<cfquery name="qQ" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		select account_id from taccquotation_header where quotation_number = '#selQuotation#'
	</cfquery>
	
	<cfquery name="qSP" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT  THRMEmpPersonalData.Emp_ID, 
		tAccount.ACCOUNTTITLE_CODE,
		tAccount.ACCOUNT_NAME,
		isNull(THRMEMPPERSONALDATA.First_Name,'') + ' ' + isNull(THRMEMPPERSONALDATA.Middle_Name,'') + ' ' + isNull(THRMEMPPERSONALDATA.Last_Name,'') AS name,
		
		TSalesCustomer.SalesCustomerID,
		THRMEmpPersonalData.Effective_Date,
		TSalesCustomer.ACCOUNTID
		FROM
		  (	TSalesCustomer
				INNER JOIN tAccount ON TSalesCustomer.AccountID = tAccount.account_ID 
				INNER JOIN THRMEMPPERSONALDATA ON TSalesCustomer.EMP_ID = THRMEMPPERSONALDATA.EMP_ID 
			)
		WHERE (Terminate_Date >= #now()# OR  Terminate_Date IS  NULL)
		and TSalesCustomer.accountid = '#qQ.account_ID#'
		ORDER BY thrmemppersonaldata.Emp_ID ASC
	</cfquery>
</cfif>

<cfif isDefined ("form.selProforma")>
	<cfquery name="qQ" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		select account_id,pricetype from taccpi_header where pi_number = '#selProforma#'
	</cfquery>
	<cfquery name="qSP" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT  THRMEmpPersonalData.Emp_ID, 
		tAccount.ACCOUNTTITLE_CODE,
		tAccount.ACCOUNT_NAME,
		isNull(THRMEMPPERSONALDATA.First_Name,'') + ' ' + isNull(THRMEMPPERSONALDATA.Middle_Name,'') + ' ' + isNull(THRMEMPPERSONALDATA.Last_Name,'') AS name,
		
		TSalesCustomer.SalesCustomerID,
		THRMEmpPersonalData.Effective_Date,
		TSalesCustomer.ACCOUNTID
		FROM
		  (	TSalesCustomer
				INNER JOIN tAccount ON TSalesCustomer.AccountID = tAccount.account_ID 
				INNER JOIN THRMEMPPERSONALDATA ON TSalesCustomer.EMP_ID = THRMEMPPERSONALDATA.EMP_ID 
			)
		WHERE (Terminate_Date >= #now()# OR  Terminate_Date IS  NULL)
		and TSalesCustomer.accountid = '#qQ.account_ID#'
		ORDER BY thrmemppersonaldata.Emp_ID ASC
	</cfquery>
	<cfif task neq "edit">
		<cfset cboPriceType = "#qQ.PriceType#">
	</cfif>
</cfif>

<!--- QUOTATION --->
<cfquery name="qQuotation" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	<!---Select Quotation_Number, Quotation_Date, Account_Code, Account_Name,currency_id
	from   	TAccQuotation_Header, TAccount
	Where  	Quotation_Status = 3 
	AND    	Approval_Status = 3
	AND		Expired <> 1 <!--- cari doc yang active saja --->
	AND	   	TAccQuotation_Header.Account_ID =  TAccount.Account_ID
	and		quotation_type ='sales'
	and 	quotation_category ='#selCatType#'
    AND		TAccount.Cust_Status != 'RJC'
    And     TAccQuotation_Header.Company_ID = #COOKIE.CompanyID#
    And     TAccQuotation_Header.WH_ID = #COOKIE.Location_Id#--->
  
  <!--- IVN : 20 June 2010 Change Quotation due sales contract
  don't show quotation that has been created for sales contract --->
  SELECT 
    quh.Quotation_Number, 
    quh.Quotation_Date, 
    acc.Account_Code, 
    acc.Account_Name, 
    quh.Currency_id 
  FROM 
    TAccQuotation_Header quh 
    INNER JOIN TAccount acc 
    ON acc.Account_ID = quh.Account_ID 
  WHERE 
    quh.Quotation_Status = 3 
    AND quh.Approval_Status = 3 
    AND quh.Expired = 0 
    AND quh.quotation_type = 'sales' 
    AND quh.quotation_category = '#selCatType#' 
    AND acc.Cust_Status != 'RJC' 
    AND quh.Company_ID = #COOKIE.COMPANYID# 
    AND NOT EXISTS (
      SELECT 
        1 
      FROM 
        TACCSALESCONTRACT_HEADER sch 
      WHERE 
        sch.Quot_Number = quh.Quotation_Number
        AND sch.Approval_Status != 4 
    )
</cfquery>

<!--- Global Setting --->
<cfquery name="qSetting" datasource="#iif(isdefined('DSN'), 'DSN', 'Attributes.DSN')#">
	select * from TAccSetting
</cfquery>
<cfset ratetype = val(qsetting.ratetype_so)>
<cfset local.tmpSCItemSetting = qsetting.SalesContractItem>

<!--- add by RF, to read project cost calculation --->
<cfquery name="qPro" datasource="#iif(isdefined('DSN'), 'DSN', 'Attributes.DSN')#">
	SELECT
		project_code, currency_id, Project_Name, Account_Name
	FROM
		TaccProjectCalculation_Header, TAccount
	WHERE
    TaccProjectCalculation_Header.Account_ID = TAccount.Account_ID
    	And TaccProjectCalculation_Header.company_id = #cookie.companyid#
        and WH_Id = #COOKIE.LOCATION_ID#
</cfquery>

<cfquery name="qProformaInvoice" datasource="#iif(isdefined('DSN'), 'DSN', 'Attributes.DSN')#">
	SELECT
		pi_number, pi_date, currency_id, expdeliv_date, Taccount.account_name, PI_Date
	FROM
		TAccPI_header, Taccount
	WHERE
		TAccPI_header.company_id = #cookie.companyid#
        and TAccPI_header.WH_Id = #COOKIE.LOCATION_ID#
		and pi_status=3
		and Approval_status =3
		and TAccPI_header.account_id = Taccount.account_id
		and (expired = 0 or expired is null)
		and PI_Category ='#selCatType#' 
        <!--- randytia	Mei26-2010 -> tidak menampilkan customer yg sudah di reject --->
        AND		TAccount.Cust_Status != 'RJC'
</cfquery>

<!--- IVN : 18 June 2010 - SALES CONTRACT --->
<cfquery name="qSelectSalesContract" datasource="#REQUEST.DSN#">
  SELECT 
    sch.SC_Number, 
    sch.SC_Date,
    CASE ISNULL(acc.AccountTitle_Code, '')
      WHEN '' THEN 
        acc.Account_Name 
      ELSE 
        acc.AccountTitle_Code + ' ' + acc.Account_Name 
    END AS Account_Name 
  FROM 
    TACCSALESCONTRACT_HEADER sch 
    LEFT JOIN TACCOUNT acc 
      ON acc.Account_ID = sch.Account_ID 
  WHERE 
    sch.Company_ID = #COOKIE.COMPANYID# 
	AND acc.Cust_Status != 'RJC' 
    AND sch.Approval_Status = 3 
    AND sch.isInActive = 0 
    AND sch.ItemCategoryType = '#selCatType#' 
    <cfif IsDefined("REQUEST.vauthaccountfilter") AND REQUEST.vauthaccountfilter neq "">
      AND acc.Category_ID IN (#preservesinglequotes(REQUEST.vauthaccountfilter)#) 
	</cfif>
  ORDER BY 
    sch.CreationDateTime DESC
</cfquery>

<!--- Sales Person --->
<cfif val(qSetting.salesPerson) eq "1">
	<cfquery name="qEmpList" datasource="#iif(isdefined('DSN'), 'DSN', 'Attributes.DSN')#">
		SELECT 	THRMEmpPersonalData.Emp_ID, 
				isNull(First_Name,'') + ' ' + isNull(Middle_Name,'') + ' ' + isNull(Last_Name,'') AS name,
				THRMEmpPersonalData.Effective_Date
		FROM 	THRMEmpPersonalData 
		where exists(select 1 from thrmEmpCompany where Emp_ID = THRMEmpPersonalData.Emp_ID and thrmEmpCompany.Company_ID=#Cookie.COMPANYID#)
		AND	(Terminate_Date >= #now()# OR  Terminate_Date IS  NULL)
		AND 	isnull(THRMEmpPersonalData.isSalesPerson,0) = 1
		Order By THRMEmpPersonalData.First_Name ASC
	</cfquery>
</cfif>

<!--- Tax Curr --->
<cfquery name="qTaxCurrency" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 	Currency_id, Currency_Symbol
	FROM 	TCurrency
	WHERE 	Status = 1
	AND (Currency_id IN (SELECT Currency_id_1 FROM TAccTaxConverter WHERE TAccTaxConverter.Status = 1)
	OR Currency_id IN (SELECT Currency_id_2 FROM TAccTaxConverter WHERE TAccTaxConverter.Status = 1))
	Order by Currency_id
</cfquery>

<!--- SO Curr --->
<cfquery name="qCurrency" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 	Distinct Currency_id, Currency_Symbol
	FROM 	TCurrency
	WHERE 	Status = 1
	Order by Currency_id
</cfquery>

<!--- Tax Master Data --->
<cfquery name="qTaxType" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 	Distinct Tax_ID, Tax_Code, Tax_Name, Tax_Rate, Tax_operator
	FROM 	TaccTax
	ORDER BY Tax_Name
</cfquery>  

<!--- Curr Convert --->
<cfquery name="qTerms" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	Select * from TAccTermOfPayment_Header order by term
</cfquery>
<cfquery name="qTermsNew" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	Select * from TAccPaymentTerm
</cfquery>

<cfset lstTerms = valueList(qTerms.TOP_Code)>
<cfparam name="lstSNDoc" default="">

<!--- Mulai Query untuk ambil Data --->
<cfif task eq "Edit">

	<cfquery name="qGetSNDoc" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT TACCSN_HEADER.SN_Number 
	    from TAccSN_Item
		INNER JOIN TACCSN_HEADER 
			ON TACCSN_HEADER.SN_NUMBER=TACCSN_ITEM.SN_NUMBER
		WHERE TACCSN_ITEM.SO_NUMBER='#SONum#'		
		AND ISNULL(TACCSN_HEADER.ISVOID,0)=0
		AND TACCSN_HEADER.APPROVAL_STATUS <> 3
		AND TACCSN_HEADER.APPROVAL_STATUS <> 4
	</cfquery>
	
	<cfset lstSNDoc = ValueList(qGetSNDoc.SN_Number)>
								
	<cfquery name="qGetMisc" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT TAccSO_MiscCharge.*, TMiscCharge.MiscCharge_name  FROM TAccSO_MiscCharge
		INNER JOIN TMiscCharge ON TMiscCharge.MiscCharge_ID = TAccSO_MiscCharge.MiscCharge_ID
		WHERE SO_Number ='#SONum#'
	</cfquery>

	<cfif qGetMisc.recordcount neq 0>
		<cfset ListMisc = ",#valuelist(qGetMisc.MiscCharge_ID)#">
	</cfif>

	<cfquery name="qGetMiscDetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT * FROM TAccSO_MiscChargeAllocation
		WHERE SO_Number ='#SONum#'
	</cfquery>

	<cfquery name="qSales" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT 	isNULL(TAccSO_Header.Revision_Number,0) as Revision_Number,
                TAccSO_Header.SO_Number,TAccSO_Header.Tax_Code AS VAT_Tax_Code,
				TAccSO_Header.Quotation_Number,
				TAccSO_Header.project_code, 	
				TAccSO_Header.PO_NumCustomer,
				TAccSO_Header.PO_DateCustomer,			
				TAccSO_Header.SO_Date,
				TAccSO_Header.automaticsn,				
				TAccSO_Header.SO_Notes, 			
				TAccSO_Header.Account_ID, 		
				TAccSO_Header.Payment_Type, 					                                     
				TAccSO_Header.Company_ID, 			
				TAccSO_Header.Currency_ID,
				TAccSO_Header.Tax_Currency_ID, 
				TAccSO_Header.Approval_Status, 	
				TAccSO_Header.SO_Status, 	
				TAccSO_Header.SN_Status,
				TAccSO_Header.Invoice_Status,
				TAccSO_Header.Invoice_Amount,
				TAccSO_Header.Base_Invoice_Amount,   
				TAccSO_Header.Tax_Amount,
				TAccSO_Header.Base_Tax_Amount,
				TAccSO_Header.Due_Date,
				TAccSO_Header.Emp_ID,
				TAccSO_Header.Contact_ID,
				TAccSO_Header.SOType,  <!--- untuk membedakan SO PPN dan non PPN --->				
				TAccSO_Header.Terms,
				TAccSO_Header.DeliveryTerms,
				TAccSO_Header.Proforma_Number,
				isnull(TAccSO_Header.isSisterCompany,0) as isSisterCompany,
				isnull(TAccSO_Header.SisterCompany,0) as SisterCompany,
				Taccount.AccountTitle_Code,
				isnull(TAccSO_Header.ReviseCounter,0) as ReviseCounter,
				TAccount.Account_Name, 
				TAccSO_Header.sn_account_id,
				TAccSO_Header.si_account_id,
				isnull(TAccount.GroupID,0) as GroupID,
				TAccount.account_address1,
                TAccount.taxfilenumber,
				TContact.Contact_FirstName, 
				TContact.Contact_HomeAddress,
				TAccSO_Header.KawasanBerikat as KawasanBerikat,
				TAccSO_Header.CurrencyRateList,
				TAccSO_Header.Tax_CurrencyRateList,
				TAccSO_Header.Project_ID,
				TAccSO_Header.AllocateTo,
				isnull(TAccSO_Header.isOutlet,0) as isOutlet,
				isnull(TAccSO_Header.outlet_wh,0) as outlet_wh,
				isnull(Taccount.GroupID,0) as GroupID,	
				isNull(THRMEmpPersonalData.First_Name,'') + ' ' + isNull(.THRMEmpPersonalData.Middle_Name,'') + ' ' + isNull(THRMEmpPersonalData.Last_Name,'') AS Emp_name,
				CONVERT(varchar(50),TAccSO_Header.Creation_DateTime) AS Creation_DateTime_Display,
				CONVERT(varchar(50),TAccSO_Header.Last_Update) AS Last_Update_Display,
				(SELECT isNull(Emp.First_Name,'') + ' ' + isNull(Emp.Middle_Name,'') + ' ' + isNull(Emp.Last_Name,'') FROM THRMEmpPersonalData AS Emp WHERE Emp.User_ID=TAccSO_Header.Created_By) AS Created_By_Name,
				(SELECT isNull(Emp.First_Name,'') + ' ' + isNull(Emp.Middle_Name,'') + ' ' + isNull(Emp.Last_Name,'') FROM THRMEmpPersonalData AS Emp WHERE Emp.User_ID=TAccSO_Header.Update_By) AS Update_By_Name,
				TAccSO_Header.TransactionDiscountRate,
				TAccSO_Header.TransactionDiscountAmount ,
				TAccSO_Header.TransactionDiscountBaseAmount,
				TAccSO_Header.directpo,
				TAccSO_Header.isDonation,
				TAccSO_Header.isDP, 
                TAccSO_Header.SC_Number,
				TAccSO_Header.paymentterm_code,
				TAccSO_Header.PriceType,
				TAccSO_Header.reason_revision,

			<!--- b:CRF50912-07376 : add claim deduction field --->
				isNull(TAccSO_Header.claim_deduction_amount, 0.00) as claim_deduction_amount,
				TAccSO_Header.claim_deduction_desc,
			<!--- e:CRF50912-07376 : add claim deduction field --->
				TAccSO_Header.pi_number,
				TAccSO_Header.Production_month,
				TAccSO_Header.Production_year

		FROM 	TAccSO_Header
			Left Join TAccount On TAccount.Account_ID = TAccSO_Header.Account_ID
			Left Join TContact On TContact.Contact_ID = TAccSO_Header.Contact_ID
			Left Join THRMEmpPersonalData On THRMEmpPersonalData.Emp_ID = TAccSO_Header.Emp_ID 
		WHERE 	TAccSO_Header.Company_id = '#cookie.companyID#'
		AND 	SO_Number = '#SONum#'
	</cfquery>

	<cfset cboPriceType="#qSales.PriceType#">
    <cfset txtRevisionReason = "#qSales.reason_revision#">

	<cfparam name="txtHidSisterCompany" default ="#qSales.SisterCompany#"> 
	<cfparam name="isOutlet" default ="#qSales.isOutlet#"> 
	<cfparam name="outlet_wh" default ="#qSales.outlet_wh#"> 

	<cfif qSales.CurrencyRateList neq "">
		<cfloop list="#qSales.CurrencyRateList#" index="idx" delimiters=";">
			<cfset curr=listgetat(idx,1,"|")>
			<cfset convert=listgetat(idx,2,"|")>
			<cfset lstCurrency=listappend(lstCurrency,"Amount|#curr#|#convert#",";")>
		</cfloop>
	</cfif>

	<cfif qSales.Tax_CurrencyRateList neq "">
		<cfloop list="#qSales.Tax_CurrencyRateList#" index="idx" delimiters=";">
			<cfset curr=listgetat(idx,1,"|")>
			<cfset convert=listgetat(idx,2,"|")>
			<cfset lstCurrency=listappend(lstCurrency,"Tax|#curr#|#convert#",";")>
		</cfloop>
	</cfif>

	<cfset chkSisterCompany = qSales.isSisterCompany>
	<cfquery name="qEmpList2" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT  THRMEmpPersonalData.Emp_ID, 
		tAccount.ACCOUNTTITLE_CODE,
		tAccount.ACCOUNT_NAME,
		isNull(THRMEMPPERSONALDATA.First_Name,'') + ' ' + isNull(THRMEMPPERSONALDATA.Middle_Name,'') + ' ' + isNull(THRMEMPPERSONALDATA.Last_Name,'') AS name,
	
		TSalesCustomer.SalesCustomerID,
		THRMEmpPersonalData.Effective_Date,
		TSalesCustomer.ACCOUNTID
		FROM
		  (	TSalesCustomer
				INNER JOIN tAccount ON TSalesCustomer.AccountID = tAccount.account_ID 
				INNER JOIN THRMEMPPERSONALDATA ON TSalesCustomer.EMP_ID = THRMEMPPERSONALDATA.EMP_ID 
			)
		WHERE (Terminate_Date >= #now()# OR  Terminate_Date IS  NULL)
		and TSalesCustomer.accountid = '#qsales.account_ID#'
		ORDER BY thrmemppersonaldata.Emp_ID ASC
	</cfquery>

	<cfif qsales.GroupID eq 0>
		<cfquery name="qAccount" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			select account_ID,account_name,GroupID
			from taccount
			where account_id ='#qsales.account_id#'
		</cfquery>
	<cfelse>
		<cfquery name="qAccount" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			select account_ID,account_name,GroupID
			from taccount
			where GroupID ='#qsales.GroupID#'
		</cfquery>
	</cfif>
	
	<cfif selcattype eq "AST">
		<cfquery name="qsalesDetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			SELECT 		TAccSO_Detail.*, Asset_Desc as item_name, TItem.Item_Code, '' AS Dimension_Name
              <!---,ISNULL((Select Amount from TAccSO_MiscChargeAllocation where so_number = TAccSO_Detail.SO_Number
              AND Item_Code =  TItem.Item_Code
              ),0) AmountAllo --->
			 , '' AS item_description
			 , '' AS Item_Color
			 , '' AS Item_Size 
			FROM 		TAccSO_Detail 
			INNER JOIN 	TAccAssetInventory	ON 	TAccSO_Detail.Item_Code = TAccAssetInventory.asset_Code 
			WHERE 		TAccSO_Detail.SO_Number = '#SONum#'
			ORDER BY 	TAccSO_Detail.SODetail_ID
		</cfquery>	
	<cfelse>
		<cfquery name="qsalesDetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			SELECT 		TAccSO_Detail.*, 
			(SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TAccSO_Detail.Unit_Type) AS Unit_Desc
			,(SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TAccSO_Detail.Unit_Type2) AS Unit_Desc2
			,(SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TAccSO_Detail.Unit_Type) AS UnitType
			,(SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TAccSO_Detail.Unit_Type2) AS UnitType2
			,TItem.Item_Name,Titem.pricetype,TItem.Item_Code, ISNULL(itd.Dimension_Name, '') AS Dimension_Name 
  		<!---,ISNULL((Select Amount from TAccSO_MiscChargeAllocation where so_number = TAccSO_Detail.SO_Number
              AND Item_Code =  TAccSO_Detail.Item_Code AND Dimension_ID = TAccSO_Detail.Dimension_ID
              ),0) AmountAllo--->
			  , TItem.customfield1 AS item_description
			  , TItem.Item_Color
			  , TItem.Item_Size
			FROM 		TAccSO_Detail
			INNER JOIN 	TItem 	ON 	TAccSO_Detail.Item_Code = TItem.Item_Code
			INNER JOIN 	TAccSO_Header ON TAccSO_Header.SO_Number = TAccSO_Detail.SO_Number AND TAccSO_Header.Company_ID = #COOKIE.CompanyID# 
            LEFT JOIN TITEMDIMENSION itd ON itd.Dimension_ID = TAccSO_Detail.Dimension_ID 
			WHERE 		TAccSO_Detail.SO_Number = '#SONum#'
			AND TAccSO_Detail.IsFreeItem = 0
			ORDER BY 	TAccSO_Detail.SODetail_ID
		</cfquery>
		<cfquery name="qGetFreeItem" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			SELECT TAccSO_Detail.*, TItem.Item_Name,Titem.pricetype,TItem.Item_Code, ISNULL(itd.Dimension_Name, '') AS Dimension_Name 
			FROM 		TAccSO_Detail
			INNER JOIN 	TItem 	ON 	TAccSO_Detail.Item_Code = TItem.Item_Code
			INNER JOIN 	TAccSO_Header ON TAccSO_Header.SO_Number = TAccSO_Detail.SO_Number AND TAccSO_Header.Company_ID = #COOKIE.CompanyID# 
            LEFT JOIN TITEMDIMENSION itd ON itd.Dimension_ID = TAccSO_Detail.Dimension_ID 

			WHERE 		TAccSO_Detail.SO_Number = '#SONum#'
			AND TAccSO_Detail.IsFreeItem = 1
			ORDER BY 	TAccSO_Detail.SODetail_ID

		</cfquery>
	</cfif>
	 
	<!--- Hitung total qty --->
	<cfquery dbtype="query" name="qGetTotalQty">
		select sum(Qty) as TotQty
		from qSalesDetail
		where SO_Number = '#SONum#'
	</cfquery>
	<!--- end --->
	
	
	<!--- Add by AN --->
	<!--- get credit Limit --->
	<cfquery name="qGetCreditLimit" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT 	Credit_Limit
		FROM 	TAccTermsDefault
		WHERE 	TAccTermsDefault.Company_ID = #cookie.companyID#
		AND		TAccTermsDefault.Account_ID = #qsales.Account_ID#
	</cfquery>
	
	<!--- get NotPaidInvoice --->
	<cfquery name="qGetNotPaidSalInvoice" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT 	sum (base_invoice_amount+dbo.func_calculateByDelimiter(List_Base_TaxAmount)) - sum(base_dp_Amount+dbo.func_calculateByDelimiter(List_Base_DP_TaxAmount)) as TotalInvoiceNotPaid
		FROM	TAccSI_Header
		WHERE  	invoice_status != 'FP'
		AND 	isvoid = 0
		AND		account_id = #qsales.Account_ID# 
	</cfquery>
	
	<cfquery name="qGetNotPaidProInvoice" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT 	sum (base_invoice_amount+dbo.func_calculateByDelimiter(List_Base_TaxAmount)) - sum(base_dp_Amount+dbo.func_calculateByDelimiter(List_Base_DP_TaxAmount)) as TotalInvoiceNotPaid
		FROM	TAccProjectInvoice_Header
		WHERE  	invoice_status != 'FP'
		AND 	isvoid = 0
		AND		account_id = #qsales.Account_ID# 
	</cfquery>
	
	<!--- <cfquery name="qGetNotPaidInvoice" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		Select Sum(Base_Invoice_Amount) as TotalInvoiceNotPaid, sum(cast(isnull(dbo.func_calculatebydelimiter(list_Base_TaxAmount),0) as money)) as TotalTaxNotPaid
		From TaccSI_Header
		Where Account_ID = #qsales.Account_ID#
		And Company_Id = '#cookie.companyID#'
		And Base_Invoice_Amount > Paid_InvoiceAmount
		And list_Base_TaxAmount > List_Paid_TaxAmount
	</cfquery> --->
	
	<!--- get SOApproved --->
	<cfquery name="qGetSOSalApproved" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT 	sum(Base_Invoice_Amount+Base_Tax_Amount) as TotalAmountSOApproved<!--- , sum(cast(isnull(Base_Tax_Amount,0) as money)) as TotalTaxSOApproved --->
		FROM	TAccSO_Header
		WHERE 	approval_status  = 3
		AND isclose = 0 AND isnull(isnotactive,0) = 0
        and not exists(select 1 from TAccSI_Header where SO_Number = TAccSO_Header.SO_Number and TAccSI_Header.IsVoid=0)
		AND Account_ID =  #qsales.Account_ID#
	</cfquery>
	
	<cfquery name="qGetSOProApproved" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT	sum(Stage_BaseAmount + Tax_Amount1 * (Base_Tax_Amount/CASE Tax_Amount WHEN 0 THEN 1 ELSE Tax_Amount END) + 
				Tax_Amount2 * (Base_Tax_Amount/CASE Tax_Amount WHEN 0 THEN 1 ELSE Tax_Amount END))
				- (SELECT sum(Base_Invoice_Amount+dbo.func_calculateByDelimiter(list_base_taxamount))

		FROM	TAccProjectInvoice_Header 
		WHERE SO_Number = TAccSOProject_Header.SO_Number 
			AND (TAccProjectInvoice_Header.IsVoid = 0 OR TAccProjectInvoice_Header.IsVoid IS NULL))	as qGetSOApproved 

		FROM	TAccSOProject_Header, TAccSOProject_Detail, TAccProjectStageHeader
		WHERE approval_status  = 3
        <!--- and not exists(select 1 from TAccProjectInvoice_Header where SO_Number = TAccSOProject_Header.SO_Number and TAccProjectInvoice_Header.IsVoid=0) --->
			AND Account_ID =  #qSales.Account_ID# AND isnull(isnotactive,0) = 0
			AND TAccSOProject_Header.SO_Number = TAccSOProject_Detail.SO_Number
			AND TAccProjectStageHeader.StageCode = TAccSOProject_Detail.Stage_Code
			AND TAccProjectStageHeader.CompanyID = #Cookie.CompanyID#
			AND TAccProjectStageHeader.IsMilestone = 1
		GROUP BY TAccSOProject_Header.SO_Number
	</cfquery>

	<cfset newSOProApproved = 0>
	<cfloop query="qGetSOProApproved">
		<cfset newSOProApproved = val(newSOProApproved) + val(qGetSOApproved)>
	</cfloop>		

	<cfset Approval_Status	= #qsales.Approval_Status#>
	<cfset SO_Status		= #qsales.SO_Status#>

	<cfparam name="txtSONum" default="#SONum#">
	<cfif Len(trim(qsales.AccountTitle_Code)) gt 0>
		<cfparam name="txtCustName" default="#qsales.AccountTitle_Code#. #qsales.Account_Name#">
	<cfelse>
		<cfparam name="txtCustName" default="#qsales.Account_Name#">
	</cfif>
	
	<cfparam name="txtcreditlimit"		default="#qGetCreditLimit.Credit_Limit#">
	<cfparam name="txtInvNotPaid"		default="#val(qGetNotPaidSalInvoice.TotalInvoiceNotPaid)+val(qGetNotPaidProInvoice.TotalInvoiceNotPaid)#">
	<!--- <cfparam name="txtTaxNotPaid" 		default="#qGetNotPaidInvoice.TotalTaxNotPaid#"> --->
	<cfparam name="txtSOApproved"		default="#val(qGetSOSalApproved.TotalAmountSOApproved)+val(newSOProApproved)#">
	<!--- <cfparam name="txtTaxSOApproved" 	default="#qGetSOApproved.TotalTaxSOApproved#"> --->
	<cfset remain = val(txtcreditlimit) - val(txtInvNotPaid) - val(txtSOApproved)>
	<cfparam name="txtRemainingCredit" 	default="#NumberFormat(remain,".#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#">
	<cfparam name="baseCreditLimit" 	default="#qGetCreditLimit.Credit_Limit#">
	<cfparam name="baseInvNotPaid" 		default="#val(qGetNotPaidSalInvoice.TotalInvoiceNotPaid)+val(qGetNotPaidProInvoice.TotalInvoiceNotPaid)#">
	<!--- <cfparam name="baseTaxNotPaid" 		default="#qGetNotPaidInvoice.TotalTaxNotPaid#"> --->
	<cfparam name="baseSOApproved" 		default="#val(qGetSOSalApproved.TotalAmountSOApproved)+val(newSOProApproved)#">
	<!--- <cfparam name="baseTaxSOApproved" 	default="#qGetSOApproved.TotalTaxSOApproved#"> --->
	<cfparam name="baseRemainCredit" 	default="#remain#">
	<cfparam name="selQuotation"   		default="#qsales.quotation_number#">
	<cfif selQuotation eq 0><cfset selQuotation=""></cfif>
	<cfparam name="selPro"			 	default="#qSales.project_code#">
	<cfparam name="selProforma"			default="#qSales.Proforma_Number#">
	<cfif selProforma eq 0><cfset selProforma=""></cfif>
	<cfparam name="txtCustCode"			default="#qsales.Account_ID#">
	<cfparam name="txtCustAddress"		default="#qSales.account_Address1#">
	<cfparam name="txtnpwp"				default="#qSales.taxfilenumber#">		
	<cfparam name="txtCPName"			default="#qSales.Contact_FirstNAme#">		
	<cfparam name="txtCPCode"			default="#qSales.Contact_ID#">
	<cfparam name="txtCPAddress"		default="#qSales.Contact_HomeAddress#">
	<cfparam name="txtSPName" 			default="#qSales.Emp_Name#">
	<cfparam name="txtSPCode" 			default="#qSales.Emp_ID#">
	<cfparam name="txtPONum" 			default="#qsales.PO_NumCustomer#">
	<cfparam name="txtMemo"   			default="#qsales.SO_Notes#">
	<cfparam name="txtInvDueDate"   	default="#DateFormat(qsales.Due_Date,'mm/dd/yyyy')#">
	<cfparam name="txtSODate"   		default="#DateFormat(qsales.SO_Date,'mm/dd/yyyy')#">
	<cfparam name="txtPODate"   		default="#DateFormat(qsales.PO_DateCustomer,'mm/dd/yyyy')#">
	<cfparam name="selCurrency"   		default="#qsales.Currency_ID#">
	<cfparam name="selTaxCurrency"   	default="#qsales.Tax_Currency_ID#">
	<cfset tmp = #val(qsales.Invoice_Amount)# + #val(qsales.Tax_Amount)#>
	<cfparam name="txtGrandTotal"   	default="#tmp#">
	<cfparam name="txtTotAmount"   		default="#val(qsales.Invoice_Amount)#">
	<cfparam name="txtDisctotal"   		default="#val(qsales.TransactionDiscountRate)#">
	<cfparam name="txtTotDisc"   		default="#val(qsales.TransactionDiscountAmount)#">
	<cfparam name="txtTotTaxConv"   	default="#val(qsales.Tax_Amount)#"> 
	<cfparam name="txtDeliveryTerms"    default="#qSales.DeliveryTerms#">
	<cfparam name="txtSOnumnon"			default="#qSales.SO_Number#">
	<cfparam name="txtTerms"			default="#qSales.terms#">
	<cfparam name="kawasanberikat"      default ="0">
	<cfparam name="cboTerms"            default="#qSales.terms#">
	<cfparam name="selProject"			default="#qSales.Project_id#">
	<cfif selProject eq 0><cfset selProject=""></cfif>
	<cfparam name="rdoAllocate" 		default="#qSales.AllocateTo#">
	<cfparam name="cboTermsNew"         default="#qSales.paymentterm_code#">
	<cfparam name="txtTotQty"   		default="#val(qGetTotalQty.TotQty)#">
	<cfparam name="txtProMonth"   		default="#qSales.Production_month#">
	<cfparam name="txtProYear"   		default="#qSales.Production_year#">
	<cfparam name="txtPiNumber"   		default="#qSales.pi_number#">
	
	
<cfelse>
	<cfset Approval_Status=0>
	<cfset SO_Status = 1>    
   	<cfparam name="kawasanberikat" default ="0">
	<CF_DO_V30_ACCDOCUMENTNO TableName="TAccPattern" DocumentType="salesJournal" DocumentNo="SONum" Type="pattern" Companyid="#cookie.companyid#" LocationID="#COOKIE.LOCATION_ID#"> 
	<CF_DO_V30_ACCDOCUMENTNO TableName="TAccPattern" DocumentType="salesJournalnontax" DocumentNo="SONumnon" Type="pattern" Companyid="#cookie.companyid#" LocationID="#COOKIE.LOCATION_ID#">
	<cfparam name="txtSONum" 			default="#SONum#">
	<cfparam name="txtSOnumnon"			default="#SONumnon#"> 
	<cfparam name="txtcreditlimit"		default="0">
	<cfparam name="txtInvNotPaid"		default="0">
	<!--- <cfparam name="txtTaxNotPaid" 		default="0"> --->
	<cfparam name="txtSOApproved"		default="0">
	<!--- <cfparam name="txtTaxSOApproved" 	default="0"> --->
	<cfparam name="txtRemainingCredit" 	default="0">
	<cfparam name="baseCreditLimit" 	default="0">
	<cfparam name="baseInvNotPaid" 		default="0">
	<!--- <cfparam name="baseTaxNotPaid" 		default="0"> --->
	<cfparam name="baseSOApproved" 		default="0">
	<!--- <cfparam name="baseTaxSOApproved" 	default="0"> --->
	<cfparam name="baseRemainCredit" 	default="0">
	<cfparam name="txtCustName"			default="">
	<cfparam name="txtCustCode"			default="">
	<cfparam name="txtCustAddress"		default="">
    <cfparam name="txtnpwp"				default="">
	<cfparam name="txtCPName"			default="">
	<cfparam name="txtCPCode"			default="">		
	<cfparam name="txtCPAddress" 		default="">
	<cfparam name="txtSPName" 			default="">
	<cfparam name="txtSPCode" 			default="">
	<cfparam name="txtPONum" 			default="">
	<cfparam name="txtMemo"   			default="">
	<cfparam name="txtInvDueDate"   	default="">
	<cfparam name="txtHidSisterCompany" default ="0">
	<cfparam name="isOutlet" default ="0"> 
	<cfparam name="outlet_wh" default ="0"> 
	
	<cfparam name="txtSODate"   		default="#DateFormat(now(),"mm/dd/yyyy")#">
	<cfparam name="txtPODate"   		default="">
	
	<cfparam name="txtGrandTotal"   	default="0">
	<cfparam name="txtTotAmount"   		default="0">
	<cfparam name="txtTotQty"   		default="0">
	
	<cfparam name="txtDisctotal"   		default="0">
	<cfparam name="txtTotDisc"   		default="0">
	 
	<cfparam name="txtTotTaxConv"   	default="0">
	<cfparam name="txtDeliveryTerms" default="">
	<cfparam name="selQuotation" 		default="">
	<cfparam name="rbTypeDoc"			default="0">
	<cfparam name="selPro"		 		default="0">
	<cfparam name="txtTerms"			default="">
	<cfparam name="selProforma"			default="">
	<cfparam name="selProject"			default="">
	<cfparam name="rdoAllocate"			default="0">
	<cfparam name="cboTermsNew"         default="">
	
	<cfparam name="txtProMonth"   		default="">
	<cfparam name="txtProYear"   		default="">
	<cfparam name="txtPiNumber"   		default="">
    
	<!--- modified by RF, SO bisa dari Quotation atau dari project (20 agustus 2007) --->
	<cfif rbTypeDoc eq 0><!--- jika dari quotation --->
			<cfquery name="qdetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
				Select TAccQuotation_Header.Tax_Amount,
					TAccQuotation_Header.currency_id, 
					tax_currency_id, 
					currencyratelist, 
					tax_currencyratelist,
				   TACCQuotation_Detail.*,
				   TAccQuotation_Header.Account_id,TAccQuotation_Header.Tax_Code AS VAT_Tax_Code,
				   terms,
				   TAccQuotation_Header.Emp_id,
				   TAccQuotation_Header.Quotation_Notes as Terms,
				   TAccQuotation_Header.Remarks,
				   TAccQuotation_Header.Due_Date,
				   TAccQuotation_Header.QOtype as SOtype,
				   Taccount.AccountTitle_Code, 
				   TAccount.Account_name,
                   TAccount.TaxFileNumber,
				   TAccQuotation_Header.Account_Address,
				   Titem.Item_Name, 
				   Titem.pricetype,
				   Tcontact.Contact_id,
				   Tcontact.contact_firstname,
				   Tcontact.contact_middlename,
				   Tcontact.contact_LastName,
				   Tcontact.Contact_HomeAddress,
				   titem.generate_flag,
                   terms,
				   '' as parent_item,
				   '' as parent_path,
                   0 AS is_Install,
				   0 disc_type,
                   TAccount.KawasanBerikat as KawasanBerikat,
				   TACCQuotation_Detail.tax_code1,
					TACCQuotation_Detail.tax_code2,
				   THrmEmppersonalData.first_name + ' ' + THrmEmppersonalData.middle_name + ' ' + THrmEmppersonalData.Last_Name as name,

                 (SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TAccQuotation_Detail.Unit_Type) AS Unit_Desc
					,(SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TAccQuotation_Detail.Unit_Type) AS UnitType

					,(SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TAccQuotation_Detail.Unit_Type2) AS Unit_Desc2
					,(SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TAccQuotation_Detail.Unit_Type2) AS UnitType2
                    , ISNULL(itd.Dimension_Name, '') AS Dimension_Name 
                    , itd.Dimension_Id
					, TItem.customfield1 AS item_description
						, TItem.Item_Color
						, TItem.Item_Size
				From   TACCQuotation_Header 
				Inner Join TAccount ON  TAccount.Account_id = TAccQuotation_Header.Account_id
				LEFT  Join THrmEmppersonalData ON THrmEmppersonalData.emp_id = TAccQuotation_Header.Emp_id	
				Inner Join TACCQuotation_Detail ON TACCQuotation_Detail.Quotation_Number = TAccQuotation_Header.Quotation_Number
				Inner Join TItem ON  Titem.item_code =  TACCQuotation_Detail.Item_Code
				Left  Join TContact ON  TContact.contact_id = TAccQuotation_Header.account_contact 
                LEFT JOIN TITEMDIMENSION itd ON itd.Dimension_ID = TACCQuotation_Detail.Dimension_ID 
				where  TACCQuotation_Detail.Quotation_Number = '#selQuotation#'
				<cfif IsDefined("REQUEST.vauthaccountfilter") AND REQUEST.vauthaccountfilter neq "">
					AND	TAccount.Category_ID IN (#preservesinglequotes(REQUEST.vauthaccountfilter)#)
				</cfif>	
				<cfif IsDefined("REQUEST.vauthitemfilter") AND REQUEST.vauthitemfilter neq "">
					AND	Titem.item_code IN (#preservesinglequotes(REQUEST.vauthitemfilter)#)
				</cfif>	
order by TACCQuotation_Detail.detail_id
			</cfquery>	
            
            <cfquery name="qAccount" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
        		select account_ID,account_name,GroupID
        		from taccount
        		where account_id ='<cfif IsDefined("txtCustCode") and txtCustCode neq "">#txtCustCode#<cfelse>#qdetail.account_id#</cfif>'

        	</cfquery>
            <!---randytia	23-04-2010--->
            <!--- ambil detail tanpa loop??
			<cfset taxamount1 = qdetail.tax_amount1>
            <cfset taxamount2 = qdetail.tax_amount2>
            <cfif taxamount1 eq "">
            	 <cfset taxamount1 = 0>
            </cfif>
            <cfif taxamount2 eq "">
            <cfset taxamount2 = 0>
            </cfif>
            <cfset tax_plus = taxamount1 + taxamount2> --->
			<cfset tax_plus = qDetail.Tax_Amount>
	<cfelseif rbTypeDoc eq 1><!--- jika dari project --->
			<cfquery name="qdetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
				SELECT
					TaccProjectCalculation_Header.currency_id,
					TAccProjectCalculation_Header.currency_id as tax_currency_id,
					TaccProjectCalculation_Header.account_id,
					TaccProjectCalculation_Header.emp_id,
					TaccProjectCalculation_Header.project_name as remarks,
					TaccProjectCalculation_Header.start_date as due_date, '0' AS VAT_Tax_Code,
					Taccount.AccountTitle_Code, 
				    TAccount.Account_name,
					'' as terms,
					TAccount.account_address1 as account_address,
                    TAccount.TaxFileNumber,
					Titem.Item_Name, 
				    Titem.pricetype,
					TaccProjectCalculation_ItemDeliver.*,
					(0) as disc_PERCENTAGE,
					THrmEmppersonalData.first_name + ' ' + THrmEmppersonalData.middle_name + ' ' + THrmEmppersonalData.Last_Name as name,
					Tcontact.Contact_id,
				   	Tcontact.contact_firstname,
				   	Tcontact.contact_middlename,
					 '' tax_code1,
					 '' tax_code2,
				   	Tcontact.contact_LastName,
				   	Tcontact.Contact_HomeAddress,
					(1) as sotype,
					0 disc_type,
					titem.generate_flag,
					config_level,config_ratio,
				   '' as parent_item,
				   '' as parent_path,
                   TAccount.KawasanBerikat as KawasanBerikat,
                   
					<!--- <!--- add by meicy 20090910 --->

				   (SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TItem.Unit_Type_ID) AS Unit_Desc,
					(SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TPPICUnitConverter.Unit_Type_Id2) AS Unit_Desc2
					<!--- (SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TItem.Unit_Type_ID) AS Unit_Type,
					(SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TPPICUnitConverter.Unit_Type_Id2) AS Unit_Type2 --->
					<!--- end add by meicy --->--->
					<!--- Change By Leo --->
					,(SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TAccQuotation_Detail.Unit_Type) AS Unit_Desc
					,(SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TAccQuotation_Detail.Unit_Type) AS UnitType
					,(SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TAccQuotation_Detail.Unit_Type2) AS Unit_Desc2
					,(SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TAccQuotation_Detail.Unit_Type2) AS UnitType2
					<!--- End Leo --->
                    , ISNULL(itd.Dimension_Name, '') AS Dimension_Name 
                    , itd.Dimension_Id
					, TItem.customfield1 AS item_description
						, TItem.Item_Color
						, TItem.Item_Size
				FROM
					TaccProjectCalculation_Header
				Inner Join TAccount ON  TAccount.Account_id = TaccProjectCalculation_Header.Account_id
				inner join TaccProjectCalculation_ItemDeliver on TaccProjectCalculation_Header.project_code = TaccProjectCalculation_ItemDeliver.project_code
				left outer Join THrmEmppersonalData ON THrmEmppersonalData.emp_id = TaccProjectCalculation_Header.Emp_id
				Inner Join Titem on Titem.item_code = TaccProjectCalculation_ItemDeliver.item_code
				Left  Join TContact ON  TContact.contact_id = TaccProjectCalculation_Header.account_contact 
                LEFT JOIN TITEMDIMENSION itd ON itd.Dimension_ID = TaccProjectCalculation_ItemDeliver.Dimension_ID 
				where TaccProjectCalculation_Header.project_code = '#selPro#'
				<cfif IsDefined("REQUEST.vauthaccountfilter") AND REQUEST.vauthaccountfilter neq "">
					AND	TAccount.Category_ID IN (#preservesinglequotes(REQUEST.vauthaccountfilter)#)
				</cfif>
				<cfif IsDefined("REQUEST.vauthitemfilter") AND REQUEST.vauthitemfilter neq "">
					AND	Titem.item_code IN (#preservesinglequotes(REQUEST.vauthitemfilter)#)
				</cfif>	
				<!--- order by detail_id asc --->
			</cfquery>
	<cfelseif rbTypeDoc eq 2><!--- jika dari proforma Invoice --->
		<cfquery name="qdetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			SELECT TAccPI_Detail.PIDetail_ID,
            	TAccPI_Header.currency_id, TAccPI_Header.Tax_Code AS VAT_Tax_Code,
				TAccPI_Header.Tax_Currency_ID,
				TAccPI_Header.account_id,
				TAccPI_Header.PI_date,
				TAccPI_Header.emp_id,
        TAccPI_Detail.Item_Desc,
				Taccount.AccountTitle_Code, 
				TAccount.Account_name,
				TAccount.account_address1 as account_address, 
				TAccPI_Header.Approval_Status,
				TAccPI_Header.PI_Status,
				TAccPI_Header.Expired,
				TAccPI_Header.Quotation_Number,
				TAccPI_Header.QOType as SOType,
				TAccPI_Detail.Item_Code, 
				TAccPI_Detail.Item_desc as item_name, 
				TAccPI_Detail.qty,
                TAccPI_Detail.qty2,
				TAccPI_Detail.unitprice,
				TAccPI_Detail.disc_percentage,
				TAccPI_Detail.totalprice,
                TAccPI_Detail.Dimension_ID,
                TAccPI_Detail.Disc_Value,
				config_level,config_ratio,
				Titem.pricetype, 
				TAccount.AccountTitle_Code,
				TAccount.Account_Name,
                TAccount.TaxFileNumber,
				THrmEmppersonalData.first_name + ' ' + THrmEmppersonalData.middle_name + ' ' + THrmEmppersonalData.Last_Name as name,
				Tcontact.Contact_id,
			   	Tcontact.contact_firstname,
			   	Tcontact.contact_middlename,
			   	Tcontact.contact_LastName,
			   	Tcontact.Contact_HomeAddress,
                TAccount.KawasanBerikat as KawasanBerikat,
                <!---
				IVN : 18 November 2009 
				FOR INCLUDE / CONFIGURE ITEM 
				==============================================
				titem.generate_flag,
				   '' as parent_item,
				   '' as parent_path,
				--->
				TAccPI_Detail.generate_flag,
				TAccPI_Detail.parent_item,
				TAccPI_Detail.parent_path,
				TAccPI_Detail.config_level,
                TAccPI_Detail.config_ratio,
				<!--- TACCPI_Detail.Config_Order, --->
                terms,
				0 Config_Order,
                0 AS IS_INSTALL,
                0 disc_type,
				TACCPI_Detail.tax_code1,
				TACCPI_Detail.tax_code2,
                TAccPI_Detail.BASE_UNITPRICE,

				<!--- add by meicy 20090910 --->
				   (SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TItem.Unit_Type_ID) AS Unit_Desc,
					(SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TItem.Unit_Type_ID) AS Unit_Desc2,
					(SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TItem.Unit_Type_ID) AS Unit_Type,
					(SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TItem.Unit_Type_ID) AS Unit_Type2  
					<!--- end add by meicy --->
					<!--- Change By Leo
					(SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TAccQuotation_Detail.Unit_Type) AS Unit_Desc
					,(SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TAccQuotation_Detail.Unit_Type) AS UnitType
					,(SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TAccQuotation_Detail.Unit_Type2) AS Unit_Desc2
					,(SELECT Unit_Type_ID FROM TAccUnitType WHERE Unit_Type_ID = TAccQuotation_Detail.Unit_Type2) AS UnitType2
					End Leo --->


                    , ISNULL(itd.Dimension_Name, '') AS Dimension_Name 
                    , itd.Dimension_Id
					, TItem.customfield1 AS item_description
						, TItem.Item_Color
						, TItem.Item_Size
			FROM	TAccPI_Header 	
				Inner Join TAccount ON  TAccount.Account_id = TAccPI_Header.Account_id
				left outer Join THrmEmppersonalData ON THrmEmppersonalData.emp_id = TAccPI_Header.Emp_id
				Inner Join TAccPI_Detail on TAccPI_Header.pi_number = TAccPI_Detail.pi_number
				Inner Join Titem on Titem.item_code = TAccPI_Detail.item_code 
				Left  Join TContact ON  TContact.contact_id = TAccPI_Header.account_contact 
                LEFT JOIN TITEMDIMENSION itd ON itd.Dimension_ID = TAccPI_Detail.Dimension_ID 
			where TAccPI_Header.pi_number = '#selProforma#'
			<cfif IsDefined("REQUEST.vauthaccountfilter") AND REQUEST.vauthaccountfilter neq "">
					AND	TAccount.Category_ID IN (#preservesinglequotes(REQUEST.vauthaccountfilter)#)
				</cfif>
				<!--- <cfif IsDefined("REQUEST.vauthitemfilter") AND REQUEST.vauthitemfilter neq "">


					AND	Titem.item_code IN (#preservesinglequotes(REQUEST.vauthitemfilter)#)
				</cfif> --->	
			ORDER BY TAccPI_Detail.PIDetail_ID ASC
		</cfquery>
        
	<cfelseif rbTypeDoc eq 3>
	<!--- IVN : 18 June 2010 - SALES CONTRACT --->
      <cfquery name="qDetail" datasource="#REQUEST.DSN#">
        SELECT 
          sch.SC_Number, 
          sch.SC_Date, 
          sch.Account_ID, 
          <!---Angries 20101102 BUG51110-24046 --->
          scd.Disc_value,
          <!---end--->
          CASE ISNULL(acc.AccountTitle_Code, '')
            WHEN '' THEN 
              acc.Account_Name 
            ELSE 
              acc.AccountTitle_Code + ' ' + acc.Account_Name 
          END AS Account_Name, 
          acc.Account_Address1 AS Account_Address, 
          acc.Account_City_ID1 AS Account_City, 
          acc.Account_State_ID1 AS Account_State, 
          (SELECT Country_Name FROM TCOUNTRY WHERE TCOUNTRY.Country_ID = acc.Account_Country_ID1) AS Account_Country, 

          acc.Account_ZipCode1 AS Account_ZipCode, 
          acc.Account_Phone1 AS Account_Phone, 
          acc.Account_Fax1 AS Account_Fax, 
          acc.TaxFileNumber, 
          sch.Quot_Number, 
          quh.Due_Date AS Due_Date, 
          sch.StartContractDate, 
          sch.EndContractDate, 
          sch.SC_Status, 
          sch.Approval_Status, 
          sch.Approve_Date, 
          sch.isInActive, 
          sch.ItemCategoryType, 
          sch.Currency_ID, 
          sch.Tax_Currency_ID, 
          sch.Company_ID, 
          sch.WH_ID, 
          sch.Created_By, 
          (
            SELECT 
              CASE ISNULL(empd1.Middle_Name, '') 
                WHEN '' THEN 
                  empd1.First_Name + ' ' + empd1.Last_Name 
                ELSE 
                  empd1.First_Name + ' ' + empd1.Middle_Name + ' ' + empd1.Last_Name 
              END 
            FROM 
              THRMEMPPERSONALDATA empd1 
            WHERE 
              empd1.User_ID = sch.Created_By 
          ) AS Creator_Name, 
          sch.CreationDateTime, 
          sch.Update_By, 

          (
            SELECT 

              CASE ISNULL(empd2.Middle_Name, '') 
                WHEN '' THEN 
                  empd2.First_Name + ' ' + empd2.Last_Name 
                ELSE 
                  empd2.First_Name + ' ' + empd2.Middle_Name + ' ' + empd2.Last_Name 
              END 
            FROM 
              THRMEMPPERSONALDATA empd2 
            WHERE 
              empd2.User_ID = sch.Update_By 
          ) AS Updater_Name, 
          sch.LastUpdateTime, 
          sch.Notes, 
          sch.Tax_Amount, 
          sch.Base_TaxAmount, 
          sch.Amount, 
          sch.Base_Amount, 
          sch.CurrencyRateList, 
          sch.Tax_CurrencyRateList, 
          sch.TermCond, 
          sch.MaxSalesAmount, 
          sch.BaseMaxSalesAmount, 
          sch.ContractType AS SOType, 
          sch.Account_Contact, 
          sch.Contact_ID, 
          (
            SELECT 
              Contact_HomeAddress 
            FROM 
              TCONTACT ctc 
            WHERE 
              ctc.Contact_ID = sch.Contact_ID
          ) AS Contact_HomeAddress, 
          sch.Emp_ID, 
          (
            SELECT 
              CASE ISNULL(empd3.Middle_Name, '') 
                WHEN '' THEN 
                  empd3.First_Name + ' ' + empd3.Last_Name 
                ELSE 
                  empd3.First_Name + ' ' + empd3.Middle_Name + ' ' + empd3.Last_Name 
              END 
            FROM 
              THRMEMPPERSONALDATA empd3 
            WHERE 
              empd3.Emp_ID = sch.Emp_ID 
          ) AS Name, 
          sch.CustContractNumber, 
          sch.Tax_Code AS VAT_Tax_Code, 
          scd.Detail_ID, 
          scd.Item_Code, 
          itm.Item_Name, 
          scd.Item_Desc, 
          scd.Unit_Type, 
          (
            SELECT Unit_Name FROM TACCUNITTYPE utp1 WHERE utp1.Unit_Type_ID = scd.Unit_Type
          ) AS Unit_Desc, 
          scd.Qty, 
          scd.Unit_Type2, 
          (
            SELECT Unit_Name FROM TACCUNITTYPE utp2 WHERE utp2.Unit_Type_ID = scd.Unit_Type2
          ) AS Unit_Desc2, 
          scd.Qty2, 
          scd.UnitPrice, 
          scd.Base_UnitPrice, 
          scd.Disc_Percentage, 
          scd.Tax_Code1, 
          scd.Tax_Percentage1, 
          scd.Tax_Operator1, 
          scd.Tax_Amount1, 
          scd.Tax_Code2, 
          scd.Tax_Percentage2, 
          scd.Tax_Operator2, 
          scd.Tax_Amount2, 
          scd.TotalPrice, 
          scd.Base_TotalPrice, 
          scd.Parent_Item, 
          scd.Parent_Path, 
          scd.Generate_Flag, 
          scd.Config_Level, 
          scd.Config_Order, 
          scd.Config_Ratio, 
          itm.Currency_ID, 
          itm.PriceType, 
          0 AS Disc_Type, 
          scd.Dimension_ID, 
          '' as terms,
          ISNULL(itd.Dimension_Name, '') AS Dimension_Name 
		  	, itm.customfield1 AS item_description
			, itm.Item_Color
			, itm.Item_Size
        FROM 
          TACCSALESCONTRACT_HEADER sch 

          INNER JOIN TACCSALESCONTRACT_DETAIL scd 
            ON scd.SC_Number = sch.SC_Number 
          LEFT JOIN TACCOUNT acc 
            ON acc.Account_ID = sch.Account_ID 
          LEFT JOIN TACCQUOTATION_HEADER quh 
            ON quh.Quotation_Number = sch.Quot_Number 
          LEFT JOIN TITEM itm 
            ON itm.Item_Code = scd.Item_Code 
          LEFT JOIN TITEMDIMENSION itd 
            ON itd.Dimension_ID = scd.Dimension_ID 
        WHERE 
          sch.Company_ID = #COOKIE.COMPANYID# 
          AND sch.SC_Number = '#local.tmpSCNumber#' 
          <cfif IsDefined("REQUEST.vauthaccountfilter") AND REQUEST.vauthaccountfilter neq "">
            AND acc.Category_ID IN (#preservesinglequotes(REQUEST.vauthaccountfilter)#) 
          </cfif>
        ORDER BY 
          sch.CreationDateTime, scd.Detail_ID DESC
      </cfquery>
    </cfif>
    
    <cfparam name="cboTerms"  default="#qdetail.terms#">
    
	<cfif isDefined("qdetail.KawasanBerikat")><cfset kawasanberikat="#val(qdetail.KawasanBerikat)#"></cfif>
	<cfif qDetail.recordcount>

		<cfparam name="selCurrency" default ="#qDetail.Currency_ID#">
		<cfparam name="selTaxCurrency" default ="#qDetail.Tax_Currency_ID#">
	<cfelse>

		<cfparam name="selCurrency" default="#Cookie.CurrencyID#" >
        <cfparam name="selTaxCurrency" default="#Cookie.CurrencyID#" >
	</cfif>
	
	<cfif not isdefined("qAccount")>
	 <cfquery name="qAccount" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
   		select account_ID,account_name,GroupID
   		from taccount
   		where account_id = '<cfif IsDefined("txtCustCode") and txtCustCode neq "">#txtCustCode#<cfelse>#qdetail.account_id#</cfif>'
   	</cfquery>
	</cfif>
	
	<cfif qDetail.recordcount>
    	<cfquery name="qName" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
    		Select Account_name  as name from TAccount where Account_id = #qDetail.Account_id#
    	</cfquery>	
    

        <cfquery name="qGetCreditLimit" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
    		SELECT 	Credit_Limit
    		FROM 	TAccTermsDefault
    		WHERE 	TAccTermsDefault.Company_ID = #cookie.companyID#
    		AND		TAccTermsDefault.Account_ID = #qdetail.Account_ID#
    	</cfquery>
        
       	<cfquery name="qGetNotPaidSalInvoice" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
    		Select Sum(Base_Invoice_Amount+dbo.func_calculateByDelimiter(List_Base_TaxAmount)) - Sum(Base_DP_Amount+dbo.func_calculateByDelimiter(List_Base_DP_TaxAmount)) AS TotalInvoiceNotPaid
    		FROM	TAccSI_Header
    		WHERE  	invoice_status != 'FP'
    		AND 	isvoid = 0
    		AND		account_id = #qdetail.Account_ID#
    	</cfquery>
		
		<cfquery name="qGetNotPaidProInvoice" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
    		Select Sum(Base_Invoice_Amount+dbo.func_calculateByDelimiter(List_Base_TaxAmount)) - Sum(Base_DP_Amount+dbo.func_calculateByDelimiter(List_Base_DP_TaxAmount)) AS TotalInvoiceNotPaid
    		FROM	TAccProjectInvoice_Header
    		WHERE  	invoice_status != 'FP'

    		AND 	isvoid = 0
    		AND		account_id = #qdetail.Account_ID#
    	</cfquery>
		
		<!--- <cfquery name="qGetNotPaidInvoice" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			<!---Select Sum(Base_Invoice_Amount) as TotalInvoiceNotPaid, sum(cast(isnull(list_Base_TaxAmount,0) as money)) as TotalTaxNotPaid--->
			Select Sum(Base_Invoice_Amount) as TotalInvoiceNotPaid, sum(cast(isnull(dbo.func_calculatebydelimiter(list_Base_TaxAmount),0) as money)) as TotalTaxNotPaid
			From TaccSI_Header
			Where Account_ID = #qdetail.Account_ID#
			And Company_Id = '#cookie.companyID#'
			And Base_Invoice_Amount > Paid_InvoiceAmount
			And list_Base_TaxAmount > List_Paid_TaxAmount
		</cfquery> --->
    	        
        <cfquery name="qGetSOSalApproved" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
    		SELECT 	sum(Base_Invoice_Amount+Base_Tax_Amount) as TotalAmountSOApproved<!--- , sum(cast(isnull(Base_Tax_Amount,0) as money)) as TotalTaxSOApproved --->
			FROM	TAccSO_Header
			WHERE 	approval_status  = 3
			AND isclose = 0 AND isnull(isnotactive,0) = 0
	        and not exists(select 1 from TAccSI_Header where SO_Number = TAccSO_Header.SO_Number and TAccSI_Header.IsVoid=0)
			AND Account_ID =  #qdetail.Account_ID#
    	</cfquery>
		
		<cfquery name="qGetSOProApproved" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
    		SELECT 	sum(Stage_BaseAmount+Tax_Amount1*(Base_Tax_Amount/CASE Tax_Amount WHEN 0 THEN 1 ELSE Tax_Amount END)+Tax_Amount2*(Base_Tax_Amount/CASE Tax_Amount WHEN 0 THEN 1 ELSE Tax_Amount END)) 
					- (SELECT sum(Base_Invoice_Amount+dbo.func_calculateByDelimiter(list_base_taxamount)) FROM TAccProjectInvoice_Header WHERE SO_Number = TAccSOProject_Header.SO_Number AND (TAccProjectInvoice_Header.IsVoid = 0 OR TAccProjectInvoice_Header.IsVoid IS NULL))
					as qGetSOApproved 
			FROM	TAccSOProject_Header, TAccSOProject_Detail, TAccProjectStageHeader
			WHERE 	approval_status  = 3
	        <!--- and not exists(select 1 from TAccProjectInvoice_Header where SO_Number = TAccSOProject_Header.SO_Number and TAccProjectInvoice_Header.IsVoid=0) --->
			AND Account_ID =  #qdetail.Account_ID# AND isnull(isnotactive,0) = 0
			AND TAccSOProject_Header.SO_Number = TAccSOProject_Detail.SO_Number
			AND TAccProjectStageHeader.StageCode = TAccSOProject_Detail.Stage_Code
			AND TAccProjectStageHeader.CompanyID = #Cookie.CompanyID#
			AND TAccProjectStageHeader.IsMilestone = 1
			GROUP BY TAccSOProject_Header.SO_Number
    	</cfquery>
		
		<cfset newSOProApproved = 0>
		<cfloop query="qGetSOProApproved">
			<cfset newSOProApproved = val(newSOProApproved) + val(qGetSOApproved)>
		</cfloop>		
		
        <cfset txtcreditlimit = qGetCreditLimit.Credit_Limit>
        <cfset baseCreditLimit = qGetCreditLimit.Credit_Limit>           
        <cfset txtSOApproved= val(qGetSOSalApproved.TotalAmountSOApproved)+val(newSOProApproved)>
		<!--- <cfset txtTaxSOApproved = qGetSOApproved.TotalTaxSOApproved> --->
        <cfset baseSOApproved = val(qGetSOSalApproved.TotalAmountSOApproved)+val(newSOProApproved)>
		<!--- <cfset baseTaxSOApproved = qGetSOApproved.TotalTaxSOApproved> --->
        <cfset txtInvNotPaid = val(qGetNotPaidSalInvoice.TotalInvoiceNotPaid)+val(qGetNotPaidProInvoice.TotalInvoiceNotPaid)>
		<!--- <cfset txtTaxNotPaid = qGetNotPaidInvoice.TotalTaxNotPaid> --->
        <cfset baseInvNotPaid = val(qGetNotPaidSalInvoice.TotalInvoiceNotPaid)+val(qGetNotPaidProInvoice.TotalInvoiceNotPaid)>
		<!--- <cfset baseTaxNotPaid = qGetNotPaidInvoice.TotalTaxNotPaid> --->
        
        <cfset remain = val(txtcreditlimit) - val(txtInvNotPaid) - val(txtSOApproved)>
        <cfset txtRemainingCredit = NumberFormat(remain,".#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")>
        <cfset baseRemainCredit = remain>    
    </cfif>


</cfif>
 
<cfif isDefined("rdoAllocate") and val(rdoAllocate) eq "0">
	<cfquery name="qGetComponent" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT Comp_ID, Comp_Name FROM TAccProjectComp
	</cfquery>
<cfelseif isDefined("rdoAllocate") and val(rdoAllocate) eq "1">
	<cfquery name="qGetComponent" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT CostCenter_ID AS Comp_ID, CostCenter_Name_#qLangName.Field_Table# AS Comp_Name
		FROM TAccCostCenter
		<!--- WHERE NOT EXISTS (SELECT 1 FROM TAccCostCenter AS CC WHERE CC.Parent_ID = TAccCostCenter.CostCenter_ID) --->
		WHERE	1 = 1
		AND Company_ID = #COOKIE.CompanyID#
		AND CC_Type = 'CC'
	</cfquery>
</cfif>

<!---List Of Project--->
<cfquery name="qGetProject" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT Distinct Project_ID, Project_Code, Project_Name, Account_Name 
    FROM TAccProject_Header, TAccount
	WHERE TAccProject_Header.Company_ID = #COOKIE.CompanyID#
    And TAccProject_Header.Account_ID = TAccount.Account_ID
    <cfif task eq "Edit" and IsNumeric(selProject)>
    	ANd Project_ID = '#selProject#'
    </cfif>
</cfquery>
<cfif task eq "Edit">
	<cfif qGetProject.recordCount and IsNumeric(selProject)>
		<cfset selProject = qGetProject.Project_Code>
    </cfif>
</cfif>

<!--- end query data --->
<!--- tipe harga untuk customer yang dipilih --->
<cfquery name="qSellingType" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 		Selling_Price_Type
	FROM 		TAccount
	WHERE Account_ID = '#txtCustCode#'
</cfquery>
<cfif isDefined("qSales.KawasanBerikat")><cfset kawasanberikat="#val(qSales.KawasanBerikat)#"></cfif>
<cfinclude template="#Application.stApp.CFWeb_Path[1]##Application.stApp.SPT[VST_IDX]#include#Application.stApp.SPT[VST_IDX]#calendar#Application.stApp.SPT[VST_IDX]#sunfish_calendar.cfm">

<cfparam name="RBTYPEDOC" default="0">


<cfif task eq "Edit">
  <cfif qSales.SC_Number NEQ 0 AND qSales.SC_Number NEQ "">
    <cfset rbTypeDoc = 3>
  </cfif>
</cfif>

<cfset local.tmpFormInputAttribute = "">

<cfif rbTypeDoc EQ 3>
  <cfset local.tmpFormInputAttribute = "readonly">
</cfif>

<cfif task is "edit">
  <cfif qSales.SOtype IS 0>




    <cfset local.tmpDocType = 0>
  <cfelse>

    <cfset local.tmpDocType = 1>
  </cfif>
  
  <cfset local.tmpVatTaxCode = qSales.VAT_Tax_Code>
<cfelse>
  <cfif qDetail.SOtype IS 0>
    <cfset local.tmpDocType = 0>
  <cfelse>
    <cfset local.tmpDocType = 1>
  </cfif>
  
  <cfset local.tmpVatTaxCode = qDetail.VAT_Tax_Code>
</cfif>

<script language="javascript" type="text/javascript" src="#Application.stApp.Web_Path[VST_IDX]#/include/js/overlib_mini.js"></script>
<script language="javascript" type="text/javascript" src="#Application.stApp.Web_Path[VST_IDX]#/include/js/overlib_hideform_mini.js"></script>
<script language="javascript" type="text/javascript">
// Detect if the browser is IE or not.
// If it is not IE, we assume that the browser is NS.
var IE = document.all?true:false

// If NS -- that is, !IE -- then set up for mouse capture
if(!IE) document.captureEvents(Event.MOUSEMOVE)

// Set-up to use getMouseXY function onMouseMove
document.onmousemove = getMouseXY;

// Temporary variables to hold mouse x-y pos.s
var tempX = 0
var tempY = 0

// Main function to retrieve mouse x-y pos.s
function getMouseXY(e){
  if(IE){ // grab the x-y pos.s if browser is IE
    tempX = event.clientX + document.body.scrollLeft
    tempY = event.clientY + document.body.scrollTop
  }else{  // grab the x-y pos.s if browser is NS
    tempX = e.pageX
    tempY = e.pageY
  }  
  // catch possible negative values in NS4

  if(tempX < 0){tempX = 0}
  if(tempY < 0){tempY = 0}  
  
  return true
}

function showAllocation(opt){
		if(opt == 0)
			document.getElementById('Allocation').style.display = "none";
		else
			document.getElementById('Allocation').style.display = "";
}

function recalcTotal(flag){
	if(flag==null)
		flag=1;

	<!---randytia	21-04-2010--->	
	if(document.frmNew.txtDisctotal.value=="" || document.frmNew.txtDisctotal.value==null){
		document.frmNew.txtDisctotal.value=0;
	}

	calcAmountAll();
	calcTax();
	GetAmountGrand();

	if(flag){
		<!---predecimalin(document.frmNew.txtTotAmount); 
		predecimalin(document.frmNew.txtGrandTotal); 
		predecimalin(document.frmNew.txtTotTaxConv); 
		predecimalin(document.frmNew.txtTotDeductConv);
		predecimalin(document.frmNew.txtTotMiscCharge); --->
		decimalinForMoney(document.frmNew.txtTotAmount); 
		decimalinForMoney(document.frmNew.txtGrandTotal); 
		decimalinForMoney(document.frmNew.txtTotTaxConv); 
		decimalinForMoney(document.frmNew.txtTotDeductConv);
		decimalinForMoney(document.frmNew.txtTotMiscCharge);
	}
}

function showLookup(objRowID){
  var elem = document.getElementById('divLookup');
  
  elem.style.left = tempX;
  elem.style.top = tempY;
  
  elem.style.display = (elem.style.display == "block") ? "none" : "block";
  
  // if show detail then
  if(elem.style.display == 'block'){
	var tmpItemCode = document.getElementById('txtPartNo_' + objRowID);
	var tmpParentPath = document.getElementById('parent_path_' + objRowID);
	var tmpCurrencyID = document.getElementById('selCurrency');
	var tmpAccountID = document.getElementById('txtCustCode');
	var tmpPricingType = 'SALES';
	var tmpDocumentDate = document.getElementsByName('txtSODate').item(0);
	var tmpDocumentType = 'SalesOrder';
	var tmpQty = document.getElementById('txtQty_' + objRowID);
	var tmpPaymentTerm = document.getElementById('cboTerms');
	
	document.getElementById("lblProgress").style.display = '';
	document.getElementById("lblError").style.display = 'none';
	document.getElementById("divLookupContent").style.display = 'none';
	
	document.getElementById("tblLookupHeader").innerHTML = '';
	
	document.getElementById("tblLookupHeader").innerHTML = tmpItemCode.value + ' : Dimension Picker';
	
	document.getElementById("divLookupContent").innerHTML = '';
	
	document.getElementById("tblLookupButton").innerHTML = '';
	
	document.getElementById("tblLookupButton").innerHTML = '<input type="button" '
														 + 'name="btnCloseDiv" id="btnCloseDiv" '
														 + 'value="#DO_VAR["CLOSE"]#" '
														 + 'onclick="showLookup(0)" />';
	
	xmlHttp = GetXmlHttpObject();
	
	if(xmlHttp == null){
	  document.getElementById('lblProgress').style.display = 'none';
	  document.getElementById('txtLabel').style.display = 'none';
	  document.getElementById('txtLabel').innerHTML = '';
	  document.getElementById("tblLookupHeader").innerHTML = 'Error';
	  document.getElementById('lblError').style.display = '';
	  document.getElementById('lblError').innerHTML = 'This browser not support AJAX!';
	  document.getElementById('divLookupContent').style.display = 'none';
	  return;
	}
	
	document.getElementById('divLookupContent').innerHTML = '';
	
	var tmpURL = '#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/include/frmlookup_dimensionpicker.cfm?';
	
	tmpURL += 'itemcode=' + tmpItemCode.value
		   + '&parentpath=' + tmpParentPath.value
		   + '&CurrencyID=' + tmpCurrencyID.value
		   + '&AccountID=' + tmpAccountID.value
		   + '&PricingType=' + tmpPricingType
		   + '&DocumentDate=' + tmpDocumentDate.value
		   + '&DocumentType=' + tmpDocumentType
		   + '&Qty=' + tmpQty.value
		   + '&PaymentTerm=' + tmpPaymentTerm.value
		   + '&rowid=' + objRowID
		   + '&requestid=' + Math.random();
	
	xmlHttp.onreadystatechange = function(){
	  /*
		readyState : 
		  0 - Uninitialized
		  1 - Loading
		  2 - Loaded
		  3 - Interactive
		  4 - Complete
		
		status(number) / statusText(text / string) : 
		  ex. 404 = Not Found
		  ex. 200 = OK
		  ex.   0 = Unknown (Request timeout)
	  */
	  
	  switch(xmlHttp.readyState){
		case(1): 
		  if(document.getElementById('divLookupContent').style.display == 'none' || document.getElementById('lblError').style.display == 'none'){
			document.getElementById('lblProgress').style.display = '';
			document.getElementById('txtLabel').style.display = '';
			document.getElementById('txtLabel').innerHTML = 'Loading...';
			document.getElementById('lblError').style.display = 'none';
			document.getElementById('divLookupContent').style.display = 'none';
		  }
		  break;
		case(2): 
		  if(document.getElementById('divLookupContent').style.display == 'none' || document.getElementById('lblError').style.display == 'none'){
			document.getElementById('lblProgress').style.display = '';
			document.getElementById('txtLabel').style.display = '';
			document.getElementById('txtLabel').innerHTML = 'Loaded';
			document.getElementById('lblError').style.display = 'none';
			document.getElementById('divLookupContent').style.display = 'none';
		  }
		  break;
		case(3): 
		  // nothing changed
		  break;
		case(4):
		  if(xmlHttp.status == 200){
			document.getElementById('lblProgress').style.display = 'none';
			document.getElementById('txtLabel').style.display = 'none';
			document.getElementById('txtLabel').innerHTML = '';
			document.getElementById('lblError').style.display = 'none';
			document.getElementById('divLookupContent').style.display = '';
			document.getElementById("divLookupContent").innerHTML = xmlHttp.responseText;
			
			document.getElementById("tblLookupButton").innerHTML = '';
			
			document.getElementById("tblLookupButton").innerHTML = '<input type="button" '
																 + 'name="btnCloseDiv" id="btnCloseDiv" '
																 + 'value="#DO_VAR["CLOSE"]#" '
																 + 'onclick="showLookup()" />';
		  }else if(xmlHttp.status == 0){
			document.getElementById('lblProgress').style.display = 'none';
			document.getElementById('txtLabel').style.display = 'none';
			document.getElementById('txtLabel').innerHTML = '';
			document.getElementById("tblLookupHeader").innerHTML = 'Error';
			document.getElementById('lblError').style.display = '';
			document.getElementById('lblError').innerHTML = 'Network timeout!';
			document.getElementById('divLookupContent').style.display = 'none';
		  }else{
			document.getElementById('lblProgress').style.display = 'none';
			document.getElementById('txtLabel').style.display = 'none';
			document.getElementById('txtLabel').innerHTML = '';
			document.getElementById("tblLookupHeader").innerHTML = 'Error';
			document.getElementById('lblError').style.display = '';
			document.getElementById('lblError').innerHTML = xmlHttp.statusText;
			document.getElementById('divLookupContent').style.display = 'none';
		  }
		  break;
		default: 

		  document.getElementById('lblProgress').style.display = 'none';
		  document.getElementById('txtLabel').style.display = 'none';
		  document.getElementById('txtLabel').innerHTML = '';
		  document.getElementById("tblLookupHeader").innerHTML = 'Error';
		  document.getElementById('lblError').style.display = '';
		  document.getElementById('lblError').innerHTML = 'This browser not support AJAX!';
		  document.getElementById('divLookupContent').style.display = 'none';
		  break;
	  }
	}
	xmlHttp.open("GET", tmpURL, true);
	xmlHttp.send(null);
  }
}

function changeDimension(objParameter){
  var tmpDimensionID = objParameter.id;
  var tmpDimensionName = objParameter.getElementsByTagName('span')[0].innerHTML;
  var tmpDimensionColorName = objParameter.getElementsByTagName('span')[1].innerHTML;
  var tmpDimensionSizeName = objParameter.getElementsByTagName('span')[2].innerHTML;
  var tmpDimensionConfigurationName = objParameter.getElementsByTagName('span')[3].innerHTML;
  var tmpRowID = objParameter.getElementsByTagName('span')[4].innerHTML;
  var tmpItemPrice = objParameter.getElementsByTagName('span')[5].innerHTML;
  var tmpItemDiscValue = objParameter.getElementsByTagName('span')[6].innerHTML;
  var tmpItemDiscPercentage = objParameter.getElementsByTagName('span')[7].innerHTML;
  var tmpItemCode = document.getElementById('txtPartNo_' + tmpRowID);
  var tmpParentPath = document.getElementById('parent_path_' + tmpRowID);
  
  if(document.getElementById('txtDimensionID_' + tmpRowID)){
	var currDimensionID = document.getElementById('txtDimensionID_' + tmpRowID);

	var currDimensionName = document.getElementById('txtDimensionName_' + tmpRowID);
	
	if(currDimensionID.value !== tmpDimensionID){
	  if(validateDouble(tmpItemCode.value, tmpParentPath.value, tmpDimensionID)){
		alert("#DO_VAR['DoubleItem']# #DO_VAR['For']# " + tmpItemCode.value + " #DO_VAR['And']# #DO_VAR['Dimension']# " + tmpDimensionName);
		return;
	  }
	  
	  document.getElementById('txtDimensionID_' + tmpRowID).value = tmpDimensionID;
	  document.getElementById('txtDimensionName_' + tmpRowID).value = tmpDimensionName;
	  
	  document.getElementById('txtConvertedUnitPrice_' + tmpRowID).value = tmpItemPrice;
	  document.getElementById('txtDiscount1' + tmpRowID).value = tmpItemDiscPercentage;
	  document.getElementById('txtDisc_' + tmpRowID).value = tmpItemDiscValue;
	  
	  document.getElementById('txtConvertedUnitPrice_' + tmpRowID).style.backgroundColor = '##FCC';
	  document.getElementById('txtDiscount1' + tmpRowID).style.backgroundColor = '##FCC';
	  document.getElementById('txtDisc_' + tmpRowID).style.backgroundColor = '##FCC';
	  
	  calcAmount(tmpRowID);
	  getDiscount(tmpRowID);
	  setCurrTax();
	  setCurr();
	  recalcTotal();
	  calculateTermOfPayment();
	}
  }
  
  showLookup(0);
}

var arrNewPop = new Array();
var itemwindow=null;
var frmItem=null;
var frmGet=null;
function pickItem(ctype,quo){
	<!--- itemwindow=PopWindow('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/purchase/po/forms/pickitem.cfm?selCatType='+ctype+'&menu=sales&source=SO&selRFQ='+quo+'&sumber=sales&selCurrency='+document.frmNew.selCurrency.value+'&date='+document.frmNew.txtSODate.value+'&cboCP='+document.frmNew.txtCPCode.value+'&cboCustomer='+document.frmNew.txtCustCode.value,'Preview','500','500','scrollbars=yes,status=yes,resizable=yes'); ---><!--- selSIGroup --->
	itemwindow=window.open('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/purchase/po/forms/pickitem.cfm?selCatType='+ctype+'&menu=sales&source=SO&selRFQ='+quo+'&sumber=sales&selCurrency='+document.frmNew.selCurrency.value+'&date='+document.frmNew.txtSODate.value+'&cboCP='+document.frmNew.txtCPCode.value+'&cboCustomer='+document.frmNew.txtCustCode.value,'Preview','scrollbars=yes,status=yes,resizable=yes','500','500');
	arrNewPop[arrNewPop.length]=itemwindow;
}
function setvalue(sobj,sval,valeval,debug){
	if(sobj==null){
		if(valeval==1){
			val=eval(sval);

			if(val!=null)
				val=val.value;
		}else
			val=sval;
		if(val==null && debug){
			alert(sval);
			return;
		}else
			return val;
	}
	if(typeof(sobj)=="string"){
		if(sobj.search(/\./) > 0) 
			obj=eval(sobj);
		else
			obj=document.getElementById(sobj);
	}else
		obj=sobj;
	if(obj!=null){
		if(valeval==1){
			val=eval(sval);
			if(val!=null)
				val=val.value;
		}else
			val=sval;
		if(val==null && debug)
			alert(sval);
		else if(obj.value!=null)
			obj.value=val;
		else if(obj.innerHTML!=null)
			obj.innerHTML=val;
	}else if(debug)
		alert(sobj+"="+sval);
}
function RoundNDecimal(nval){
	return decformat(nval);
}
function getItem(meth){
    
	frmItem=itemwindow.document.frmSearch;
	frmGet=document.frmNew;
	if(frmItem==null)
		return;
	/*Get Customer Info*/
	frmGet.txtcreditlimit.value =  parseFloat(frmItem.CreditLimit.value.split(",").join(""));
	frmGet.baseCreditLimit.value =  parseFloat(frmItem.CreditLimit.value.split(",").join(""));
	document.getElementById('creditLimit').innerHTML = frmItem.CreditLimit.value;
	
	frmGet.txtInvNotPaid.value = parseFloat(frmItem.InvNotPaid.value.split(",").join(""));
	frmGet.baseInvNotPaid.value = parseFloat(frmItem.InvNotPaid.value.split(",").join(""));
	document.getElementById('InvNotPaid').innerHTML = frmItem.InvNotPaid.value;
	
	frmGet.txtSOApproved.value = parseFloat(frmItem.SOApproved.value.split(",").join(""));
	frmGet.baseSOApproved.value = parseFloat(frmItem.SOApproved.value.split(",").join(""));
	document.getElementById('SOApproved').innerHTML = frmItem.SOApproved.value;
	
	frmGet.isOutlet.value = frmItem.isOutlet.value;
	frmGet.outlet_wh.value = frmItem.outlet_wh.value;
	var RemainCredit  = parseFloat(frmGet.txtcreditlimit.value) - parseFloat(frmGet.txtInvNotPaid.value) - parseFloat(frmGet.txtSOApproved.value);
	frmGet.txtRemainingCredit.value =RemainCredit;
	frmGet.baseRemainCredit.value =RemainCredit;
    
    if(RemainCredit < 0){
      document.getElementById('RemainingCredit').innerHTML = '<b><font color="ff0000">'+decformat(RemainCredit)+'</font></b>';//RoundNDecimal(RemainCredit,#Application.stApp.decimaL_range[VST_IDX]#);//+decformat(RemainCredit);
	}else{
      document.getElementById('RemainingCredit').innerHTML = '<b>'+decformat(RemainCredit)+'</b>';//RoundNDecimal(RemainCredit,#Application.stApp.decimaL_range[VST_IDX]#);//+decformat(RemainCredit);
	}
	
	setvalue("CustName","frmItem.hdnAccName",1);
	setvalue("CustAddress","frmItem.hdnAccAddr",1);
	//setvalue("selCurrency","frmItem.hdnAccCurr",1);
	setvalue("frmGet.txtCustName","frmItem.hdnAccName",1);
	setvalue("frmGet.txtCustAddress","frmItem.hdnAccAddr",1);
	
	<cfif #selCurrencyEditable# neq 0>	
	if(frmGet.selCurrency.value != frmItem.hdnAccCurr.value){
		setvalue("selCurrency","frmItem.hdnAccCurr",1);
		setvalue("frmGet.selCurrency","frmItem.hdnAccCurr",1);
		addTaxCurreny();
		callselCOA();
	}
	</cfif>
	
	setvalue("frmGet.txtCustCode","frmItem.hdnAccCode",1);
	setvalue("frmGet.txtnpwp","frmItem.TCPTaxFileNumber",1);
	setvalue("frmGet.txtCPName","frmItem.TCPName",1);
	
	//setvalue("frmGet.cboTerms","frmItem.hdnTypePayment",1); <!---Pending--->

	
	if(frmItem.hdnBZ.value==1){
		frmGet.chkKawasan.checked = true;
		frmGet.chkKawasan.disabled = true;
	}else{
		frmGet.chkKawasan.checked = false;
		frmGet.chkKawasan.disabled = false;
	}
	var mobj=eval("frmItem.TCPName");
	if(mobj!=null){
		if(mobj.value != 0){
			document.getElementById('CPName').innerHTML = mobj.value;
			setvalue("frmGet.txtCPCode","frmItem.TCPCode",1);
			setvalue("frmGet.txtCPAddress","frmItem.TCPAddr",1);
		}else{
			document.getElementById('CPName').innerHTML = "";
			setvalue("frmGet.txtCPCode","");
			setvalue("frmGet.txtCPAddress","");
		}
	}
	mobj=eval("frmItem.TCPAddr");
	if(mobj!=null){
		if(mobj.value != undefined)
			document.getElementById('CPAddress').innerHTML = mobj.value;					
	}
    mobj=eval("frmItem.TCPTaxFileNumber");
	if(mobj!=null){
		if(mobj.value != undefined)
			document.getElementById('CPTaxFileNumber').innerHTML = mobj.value;					
	}
	mobj=eval("frmGet.txtTerms");
	if(mobj!=null){
		if(mobj.value==""){
			mobj.value=frmItem.txtTerms.value;
		}
	}

	accountgroup(frmItem.hdnAccGroup.value);
	<!---setvalue("frmGet.txtSPName","frmItem.hdnSalesName",1);

	setvalue("frmGet.txtSPCode","frmItem.hdnSalesCode",1);--->
	if(frmItem.hdnEmpList.value!="")
		sales_person(frmItem.hdnEmpList.value);
	
	/*Get selected Items*/
	var arrItem = new Array();
	var arrPick = new Array();
	var arrDup = new Array();
	var fcolor = 0;
	var newitem=null;
	var itemcode="";
	var itemlevel=null;
	var isprev=true;
	if(frmItem.chkItem.length!=null)
		arrItem=frmItem.chkItem;
	else
		arrItem[0]=frmItem.chkItem;
	for (var i=0;i<arrItem.length;i++){
		var ObjItem=arrItem[i];
		if(ObjItem.checked){
			if(validateDouble(ObjItem.value,eval("frmItem.hidppath_"+i).value,eval("frmItem.txtDimensionID_" + i).value)){
				arrDup.push(ObjItem.value);
				isprev=false;
			}else{
				arrPick.push(ObjItem.value);
				if(meth == 'C'){
					fcolor=setvalue(null,"frmItem.txtflc_"+i,1,1);
					newitem=setvalue(null,"frmItem.txtItemCode_"+i,1,1);
					cftype=(eval("frmItem.hidLevel_"+i)==null)?"parent":"child";
					if(cftype=="parent" || isprev){
						itemlevel=eval("frmItem.hidLevel_"+i);
						itemlevel=(itemlevel==null)?0:itemlevel.value;
						addRow(cftype,newitem,fcolor,itemlevel);/*mengapa sebelumnya diset NULL???*/
						idx = frmGet.rowCount.value;
						if(fcolor==1){
		//					addRowCol(newitem);
							setvalue("frmGet.hdnColorItem_"+idx,1);
						}
						setvalue("frmGet.hdnboard_"+idx,"frmItem.hdnboard_"+i,1);
						setvalue("frmGet.parent_item_"+idx,"frmItem.hidParent_"+i,1);
						setvalue("frmGet.parent_path_"+idx,"frmItem.hidppath_"+i,1);
						itemcode=setvalue(null,"frmItem.txtItemCode_"+i,1);
						setvalue("txtPartNo_"+idx,itemcode);

						setvalue("frmGet.txtPartNo_"+idx,itemcode);
						setvalue("txtPartNoMisc"+idx,itemcode);
						setvalue("frmGet.txtPartNoMisc"+idx,itemcode);
						setvalue("txtDesc_"+idx,"frmItem.txtItemName_"+i,1);
						
						
						setvalue("frmGet.txtDesc_"+idx,"frmItem.txtItemName_"+i,1);						
						setvalue("txtDescMisc"+idx,"frmItem.txtItemName_"+i,1);
						setvalue("frmGet.txtDescMisc"+idx,"frmItem.txtItemName_"+i,1);
						setvalue("frmGet.txtQty_"+idx,0);
		//				alert("ratio="+setvalue(null,"frmItem.hdnRatio_"+i,1));
						setvalue("frmGet.hdnRatio_"+idx,"frmItem.hdnRatio_"+i,1);
						<!---if(eval("itemwindow.document.frmSearch.disc_acc"))
							setvalue("frmGet.txtDiscount1"+idx,"itemwindow.document.frmSearch.disc_acc",1);
						else
							setvalue("frmGet.txtDiscount1"+idx,"frmItem.txtDiscount_"+i,1);--->
						eval("frmGet.txtDiscount1"+idx).value = 0;
						setvalue("frmGet.txtDiscv_"+idx,"frmItem.txtDiscountv_"+i,1);
						setvalue("frmGet.txtDiscType_"+idx,"frmItem.txtDiscountType_"+i,1);
						setvalue("frmGet.txtUnitType"+idx,"frmItem.txtUnit_"+i,1);	

						setvalue("frmGet.txtUnitId_"+idx,"frmItem.txtUnitId"+i,1);
						
						setvalue("frmGet.txtUnitType2"+idx,"frmItem.txtUnit2_"+i,1);
						setvalue("frmGet.txtUnitId2_"+idx,"frmItem.txtUnitId2X"+i,1);
						setvalue("frmGet.txtUnitConv1to2"+idx,"frmItem.txtUnitConv1to2"+i,1);
						
						
						setvalue("frmGet.txtSNUnitType"+idx,"frmItem.txtUnit_"+i,1);	
						setvalue("frmGet.txtSNUnitId_"+idx,"frmItem.txtUnitId"+i,1);						
						setvalue("frmGet.txtSNUnitType2"+idx,"frmItem.txtUnit2_"+i,1);
						setvalue("frmGet.txtSNUnitId2_"+idx,"frmItem.txtUnitId2X"+i,1);
						setvalue("frmGet.txtSNUnitConv1to2"+idx,"frmItem.txtUnitConv1to2"+i,1);
						
						setvalue("frmGet.txtDimensionID_" + idx,"frmItem.txtDimensionID_" + i, 1);
						setvalue("frmGet.txtDimensionName_" + idx,"frmItem.txtDimensionName_" + i, 1);
						setvalue("frmGet.txtDimensionIDMisc" + idx, "frmItem.txtDimensionID_" + i, 1);
						setvalue("frmGet.txtDimensionNameMisc" + idx, "frmItem.txtDimensionName_" + i, 1);
						
						<!--- Custom Samick --->				
					  	setvalue("frmGet.txtColorItem_" + idx, "frmItem.txtColorItem_" + i, 1);
					  	setvalue("txtColorItem_" + idx, "frmItem.txtColorItem_" + i, 1);
					  	setvalue("frmGet.txtBrandItem_" + idx, "frmItem.txtBrandItem_" + i, 1);
					  	setvalue("txtBrandItem_" + idx, "frmItem.txtBrandItem_" + i, 1);
					  	setvalue("frmGet.txtTypeItem_" + idx, "frmItem.txtTypeItem_" + i, 1);	
					  	setvalue("txtTypeItem_" + idx, "frmItem.txtTypeItem_" + i, 1);
						
						setvalue("frmGet.txtColorItemMisc_" + idx, "frmItem.txtColorItem_" + i, 1);
					  	setvalue("txtColorItemMisc_" + idx, "frmItem.txtColorItem_" + i, 1);
					  	setvalue("frmGet.txtBrandItemMisc_" + idx, "frmItem.txtBrandItem_" + i, 1);
					  	setvalue("txtBrandItemMisc_" + idx, "frmItem.txtBrandItem_" + i, 1);
					  	setvalue("frmGet.txtTypeItemMisc_" + idx, "frmItem.txtTypeItem_" + i, 1);	
					  	setvalue("txtTypeItemMisc_" + idx, "frmItem.txtTypeItem_" + i, 1);	
					  	<!--- end Custom Samick --->
						
						//setvalue("frmGet.txtConvertedUnitPrice_"+idx,"frmItem.txtPrice_"+i,1);
						eval("frmGet.txtConvertedUnitPrice_"+idx).value = 0;
						
						if(eval("frmItem.hdnUseTax").value == 'yes'){
								setvalue("frmGet.selTax1_"+idx,"frmItem.hdnTermTax",1);
						}
						

						mobj=eval("frmItem.hdnMatrixItem_"+idx);
						if(mobj!=null){
							setvalue("frmGet.hdnMatrixItem_"+idx,"frmItem.hdnMatrixItem_"+i,1);
							setvalue("frmGet.hidFree_"+idx,1);
							setvalue("frmGet.hidQtyFree_"+idx,"frmItem.hidQtyFree_"+i,1);

							setvalue("frmGet.hdnEventQty_"+idx,"frmItem.hdnEventQty_"+i,1);
							setvalue("frmGet.hdnEventPrice_"+idx,"frmItem.hdnEventPrice_"+i,1);
							setvalue("frmGet.hdnEventDiscAmount_"+idx,"frmItem.hdnEventDiscAmount_"+i,1);
							setvalue("frmGet.hdnEventDiscPercent_"+idx,"frmItem.hdnEventDiscPercent_"+i,1);
						}
						setvalue("frmGet.hid_generate_flag_"+idx,"frmItem.hidGenerate_"+i,1);

						setvalue("frmGet.txtCurrencyID_"+idx,"frmItem.txtCurrencyID_"+i,1);
						setvalue("frmGet.txtOriginPrice_"+idx,"frmItem.txtPrice_"+i,1);
						setvalue("frmGet.txtExtra_"+idx,0);
						setvalue("frmGet.txtPriceType_"+idx,"frmItem.hdnPriceType_"+i,1);
						mobj=eval("frmGet.txtPriceType_"+idx);
						if(mobj!=null){
							if(mobj.value==1){
							 	eval("frmGet.txtConvertedUnitPrice_"+idx).readOnly = true;
							}else if(mobj.value==2){
							 	eval("frmGet.txtConvertedUnitPrice_"+idx).readOnly = false;
							}else if(mobj.value==3){
							 	eval("frmGet.txtConvertedUnitPrice_"+idx).value = 0;
							}
						}
						parent_code_js = setvalue(null,"frmItem.txtItemCode_"+i,1);
						
						pulp = eval("frmGet.hid_generate_flag_"+idx).value;
						if(pulp == 2){
							eval("frmGet.txtConvertedUnitPrice_"+idx).value = 0;
							eval("frmGet.txtDisc_"+idx).value = 0;
							eval("frmGet.txtConvertedUnitPrice_"+idx).readOnly = true;
							eval("frmGet.txtDisc_"+idx).readOnly = true;
						}
						
						ObjItem.checked=false;
						isprev=true;
						/* baru sampai sini !!!*/
					}
				}
			}
		}
	}
//	callselCOA(); //what's it for?
	if(arrDup.length){
		alert("#DO_VAR['SomeItemAlreadyExist']#");
	}
}

function addRowCurrency(table,typeofTransation,currency){
	objTbl = document.getElementById(table)
	newTR = objTbl.insertRow(objTbl.rows.length)
	tmpID = "tr"+typeofTransation+currency;
	 
	newTR.id = tmpID
	var checkExists=0;
	
	objTbl = document.getElementById(table)
	newTR = objTbl.insertRow(objTbl.rows.length)
	tmpID = "tr"+typeofTransation+currency;
	newTR.id = tmpID
	
	newTD = newTR.insertCell(0)
	newTD.width = "20";
	newTD.Align = "center";
	
	if(typeofTransation =="Amount"){
		if(eval("document.frmNew.txtCurr_"+currID) ==null){ 
			newTD.innerHTML = "1"+" "+currID+" = "+" <input name=\"txtCurr_"+currID+"\" type=\"text\" <cfif ratetype eq 2>value=\"0\"<cfelse>value=\""+currConverter+"\"</cfif> <cfif ratetype eq "0">readonly  class='inplabel'</cfif> size=\"15\" maxlength=\"20\" align=\"right\" align=\"right\" onBlur=\"recalcTotal();\" onKeyPress=\"return isIntOnlyNew(event);\" onFocus=\"this.select()\" onKeyUp=\"javascript:decimalinForMoney(this);\">"+" "+"#cookie.currencyid#";
 		}
	}else{
		if(eval("document.frmNew.txtTax_"+currID) ==null){
			newTD.innerHTML = "1"+" "+currID+" = "+" <input name=\"txtTax_"+currID+"\" type=\"text\" <cfif ratetype eq 2>value=\"0\"<cfelse>value=\""+currConverter+"\"</cfif> <cfif ratetype eq "0">readonly  class='inplabel'</cfif> size=\"15\" maxlength=\"20\" align=\"right\" align=\"right\" onBlur=\"recalcTotal();\" onKeyPress=\"return isIntOnlyNew(event);\" onFocus=\"this.select()\" onKeyUp=\"javascript:decimalinForMoney(this);\">"+" "+"#cookie.currencyid#";
 		}
	}  
}

function createElementCurrency(valCurr){
	var baseCurrency='#cookie.currencyid#'
	converter=valCurr;
	varsplit = ";"; 
	bagi = converter.split(varsplit); 
	cnt = document.getElementById('tbl_ID').rows.length - 1
	 
	objTblCurr = document.getElementById('tblCurrConverter') 
	for (var i=objTblCurr.rows.length; i>0; i--){
		objTblCurr.deleteRow(i-1); 
	}
	 
	objTblTax = document.getElementById('tblTaxConverter')
	for (i=objTblTax.rows.length; i>0; i--){
		objTblTax.deleteRow(i-1);
	} 
	
	for(i=0;i<(bagi.length);i++){
		awal = converter.split(varsplit)[i];
	 	typeofTransation=awal.split("|")[0]; 
		currID=awal.split("|")[1];
		currConverter=awal.split("|")[2]; 
		
		if(typeofTransation=="Amount" && (currID != baseCurrency)){
			addRowCurrency('tblCurrConverter',typeofTransation,currID); 
		}else if(typeofTransation=="Tax" && (currID != baseCurrency)){ 
			addRowCurrency('tblTaxConverter',typeofTransation,currID);
		} 
	}  
}
 
function refreshAjax(){ 
	frm = document.frmNew;

	var lstCurrency=""; 
	curr = frm.selCurrency.options[frm.selCurrency.selectedIndex].value;
	taxcurr= frm.selTaxCurrency.options[frm.selTaxCurrency.selectedIndex].value;  
	lstCurrency = lstCurrency+'Amount|'+curr+';'+'Tax|'+taxcurr+';'+'Tax|'+curr;
	

	var brsbaru = document.getElementById('tbl_ID').rows.length - 1;
	var item="";
	
	if(brsbaru > 0){
		for (idx=1; idx<=brsbaru; idx++){ 
			if(eval("document.frmNew.txtPartNo_"+idx)){
			 	if(eval("document.frmNew.hid_generate_flag_"+idx)!=null){
                item= item+idx+'|'+eval("document.frmNew.txtPartNo_"+idx).value + '|' + +eval("document.frmNew.hid_generate_flag_"+idx).value;
                }else{
                item= item+idx+'|'+eval("document.frmNew.txtPartNo_"+idx).value + '|' + 0;                
                }
                
				item= item +';'
                <cfif selQuotation eq "" and selProforma eq "" and ddlSalesContract eq "" and task neq "Edit">
                getPrice(idx);
                getDiscount(idx);
				
                </cfif>
                
			}
		}
		<cfif selQuotation eq "" and selProforma eq "" and ddlSalesContract eq "" and task neq "Edit">
			getDiscountTotal();
			getFreeItemTotal();
		</cfif>

		for (idx=1; idx<=brsbaru; idx++){
			if(eval("document.frmNew.txtCurrencyID_"+idx) !=null && eval("document.frmNew.txtCurrencyID_"+idx).value != "" && eval("document.frmNew.txtPriceType_"+idx) != null && eval("document.frmNew.txtPriceType_"+idx).value =="1"){ 
				typeOfTransaction = 'Amount'
				lstCurrency= lstCurrency+";"+typeOfTransaction+"|"+eval("document.frmNew.txtCurrencyID_"+idx).value; 
				typeOfTransaction = 'Tax'
				lstCurrency= lstCurrency+";"+typeOfTransaction+"|"+eval("document.frmNew.txtCurrencyID_"+idx).value; 
				lstCurrency=lstCurrency+";" ; 
			}
		}
		
	}
	document.frmNew.lstCurrency.value=lstCurrency;
	document.frmNew.lstItem.value=item;
}
  
function callselCOA(){ 
	refreshAjax(); //alert (document.frmNew.lstItem.value);
	var xurl="#Application.stApp.Web_Path[VST_IDX]#/include/ajax/sales/so/converter.cfm?ts="+escape(new Date())+'&tgl='+document.frmNew.txtSODate.value+'&lstCurrency='+document.frmNew.lstCurrency.value+'&lstItem='+document.frmNew.lstItem.value+'&selCurrency='+document.frmNew.selCurrency.value+'&selAccount='+document.frmNew.txtCustCode.value;
	loadXMLDoc(xurl)
}

function callselCOA2(){ 
	refreshAjax(); 
	url = "#Application.stApp.Web_Path[VST_IDX]#/include/ajax/sales/so/converter.cfm?ts="+escape(new Date())+'&tgl='+document.frmNew.txtSODate.value+'&lstCurrency='+document.frmNew.lstCurrency.value+'&lstItem='+document.frmNew.lstItem.value+'&selCurrency='+document.frmNew.selCurrency.value+'&selAccount='+document.frmNew.txtCustCode.value;
	loadXMLDoc(url)
}

function calcPrice(result){  
	varsplit="~";  
	position = parseInt(result.split(varsplit)[0]);
	RespectivePrice= result.split(varsplit)[1];
	pricingtype = result.split(varsplit)[2];

	OriginCurr = result.split('~')[3];
	Originprice = result.split('~')[4];
	BasePrice = result.split('~')[5]; //alert (result)
	
	 if(eval("document.frmNew.txtPartNo_"+position) != null){
 		
		if(eval("document.frmNew.txtPriceType_"+position) != null)
            eval("document.frmNew.txtPriceType_"+position).value = pricingtype;		  
        if(eval("document.frmNew.txtCurrencyID_"+position) != null)        
            eval("document.frmNew.txtCurrencyID_"+position).value = OriginCurr; 
		if(eval("document.frmNew.HidBase_ConvertedUnitPrice_"+position) != null)        
		    eval("document.frmNew.HidBase_ConvertedUnitPrice_"+position).value = BasePrice; 
	}
	//calcAmountAll(); 
	//calcTax();
	//GetAmountGrand();   
}


function processReqChange(){
	if(req.readyState == 4){
		if(req.status == 200){   
			var tmpElement= req.responseText;
			elementCurrency=tmpElement.split("*")[0]; 
			 if(tmpElement.split("*").length >0 ){ 

				for (var i=1;i<(tmpElement.split("*").length);i++){ 
					elementPrice= tmpElement.split("*")[i]; 
					calcPrice(elementPrice);
				}

			} 
			createElementCurrency(elementCurrency); 
			<cfif task eq "edit">
				converter_value();
			</cfif>
			recalcTotal();
			<cfif task eq "Save">
				<cfif isDefined ("form.selQuotation") or isDefined ("form.selProforma")>
					calculateTermOfPayment();
				</cfif>
			</cfif>
			document.frmNew.listTempCurrency.value = elementCurrency;  
		}
		<!---else alert("There was a problem processing the data: \n" + req.statusText);--->
	}
}
 
</script>

<script type="text/javascript">
<!-- update by Anita 14/04/2008-->
<!--- DecimalFormat --->
	
	function deci(angka){
		angka = String(angka);
		if(angka.indexOf('.') > -1){ a = angka.split('.')[0] ; dec = angka.split('.')[1]
		}else{ a = angka; dec = -1; }
		b = a.replace(/[^\d]/g,"");
		c = "";
		panjang = b.length;
		j = 0;
		for (i = panjang; i > 0; i--){
			j = j + 1;
			if(((j % 3) == 1) && (j != 1)) c = b.substr(i-1,1) + "," + c;
			else c = b.substr(i-1,1) + c;
		}
		if(dec == -1) return c;
		else return (c + '.' + dec); 
	}
	
	
	function isIntOnly_X(){ 
		return ((event.keyCode == 46) || (event.keyCode >= 48) && (event.keyCode <= 57))
	}
	
	function deletecommaperiod(str,type){
		var A = new Array();
		if((type=="both") || (type=="comma")){	
			A = str.split(",");
			str = A.join("");
		}
		if((type=="both") || (type=="period")){
			A = str.split(".");	
			str = A.join("");
		}
		return str;
	}
	
function decimalin(ini){
	/*ini.value=decformat(ini.value.replace(/,/g,""));

	return;
	bil2 = deletecommaperiod(ini.value,'both')
	bil3 = "" 
	j = 0
	for (var i=bil2.length-1;i>=0;i--){
		j = j + 1;
		//if(j == 3)
		if(j == #(Application.stApp.decimaL_range[VST_IDX]+1)#){
			bil3 = "." + bil3
		}
		//else if((j >= 9) && ((j % 3) == 0))
		else if( (j>=#4+Application.stApp.decimaL_range[VST_IDX]#) && ( ((j-(#Application.stApp.decimaL_range[VST_IDX]#-2))%3) == 0) ){
			if(i!=0 || bil2.charAt(i) != '-'){		
				bil3 = "," + bil3
			}	
		}
		bil3 = bil2.charAt(i) + "" + bil3 ;
	}
	ini.value = bil3 ;
    */
		/*
	if(ini.value == '') ini.value = 0;
	ini.value = ini.value.split("-").join("");
	if(ini != null){
		if(ini.value.indexOf('.') >= 0){ // bukan bilangan bulat		
			
			var pembagi = 1;
			for(var i=0;i<#Application.stApp.decimaL_range[VST_IDX]# ; i++)
				pembagi = pembagi * 10;
			var z = ini.value.split(".")[1] ;
			var strz = 0 + "." + z ;
			strz = parseFloat(strz);
			strz = strz * pembagi ;
			
			var y = Math.round(strz) ;			
			var stry = String(y);
			
			for(i=stry.length;i<#Application.stApp.decimaL_range[VST_IDX]#;i++)
				stry = "0" + stry ;
			
			
			ini.value =ini.value.split(".")[0] + "." + stry ;	
			
		}else{ // bilangan bulat
			var z = parseInt(ini.value);
			z = z + "." ;
			for(var i=0;i<#Application.stApp.decimaL_range[VST_IDX]# ; i++)
				z = z + "0";
			ini.value = z;
		}
	}
	
    if(ini.value.indexOf('.') > -1){
	 a = ini.value.split('.')[0] ; dec = ini.value.split('.')[1]
	}else{
	 a = ini.value; dec = -1; 
	}
	b = a.replace(/[^\d]/g,"");
	c = "";
	panjang = b.length;
	j = 0;
	for (i = panjang; i > 0; i--){
		j = j + 1;
		if(((j % 3) == 1) && (j != 1)) c = b.substr(i-1,1) + "," + c;
		else c = b.substr(i-1,1) + c;
	}
	if(dec == -1) ini.value = c;
	else ini.value = c + '.' + dec;
	*/
	    if(ini.value.indexOf('.') > -1){ a = ini.value.split('.')[0] ; dec = ini.value.split('.')[1]
		}else{ a = ini.value; dec = -1; }
		b = a.replace(/[^\d]/g,"");
		c = "";
		panjang = b.length;
		j = 0;
		for (i = panjang; i > 0; i--){
			j = j + 1;
			if(((j % 3) == 1) && (j != 1)) c = b.substr(i-1,1) + "," + c;
			else c = b.substr(i-1,1) + c;
		}
		if(dec == -1) ini.value = c;
		else ini.value = c + '.' + dec;

}
	
function predecimalin(ini){
	return;
	if(ini != null){
		if(ini.value.indexOf('.') >= 0){ // bukan bilangan bulat
			if(ini.value.length - ini.value.indexOf('.') == #Application.stApp.decimaL_range[VST_IDX]#){ // berarti ada satu angka di belakang titik desimal
				ini.value = ini.value + "0"
				decimalin(ini)
			}else{
				decimalin(ini)
			}	
		}else{ // bilangan bulat

			ini.value = ini.value + "#repeatString("0",Application.stApp.decimaL_range[VST_IDX])#";
			decimalin(ini)
		}
	}
	}
<!-- ========================================================= -->


</script>

<script language="JavaScript">
 
// ************************************* //
// ** Array Employee for Sales Person ** //
// ************************************* //
arrEmp = new Array()
<cfif val(qsetting.salesperson) eq "1">
	<cfloop index='i' from='1' to='#qEmpList.RecordCount#'>
		arrEmp[#evaluate(i-1)#] = new Array()
		arrEmp[#evaluate(i-1)#]['empID'] = "#qEmpList.Emp_ID[i]#";
		arrEmp[#evaluate(i-1)#]['empName'] = "<cfif len(qEmpList.Name[i]) gt 15>#left(qEmpList.Name[i], 15)# ...<cfelse>#qEmpList.Name[i]#</cfif>";
		arrEmp[#evaluate(i-1)#]['fullEmpName'] = '#qEmpList.Name[i]#';
		arrEmp[#evaluate(i-1)#]['effectiveDate'] = '#DateFormat(qEmpList.Effective_Date[i],"mm/dd/yyyy")#';
	</cfloop>
</cfif>


function popSales(isVisible){
	hideAllSelect(isVisible)
	if(isVisible == 'yes'){				
		document.getElementById('divSales').style.left 	= tempX;
		document.getElementById('divSales').style.top 	= tempY;
		document.getElementById('divSales').style.display = 'block';
	}else document.getElementById('divSales').style.display = 'none';
}
		
function hideAllSelect(isVisible){
	objAllSel = document.getElementsByTagName('select');

	for(i=0; i<objAllSel.length; i++){
		if(isVisible == 'yes') 
			objAllSel[i].style.visibility = 'hidden';
		else 
			objAllSel[i].style.visibility = '';
	}			
}
		
function hoover(thisobj){





	thisobj.style.backgroundColor = '##A1B4D8'
	thisobj.style.color = 'white'	
	thisobj.style.fontWeight = 'normal'
	thisobj.style.cursor = 'hand'
}
		
function unHoover(thisobj){
	thisobj.style.backgroundColor = 'white'		
	thisobj.style.color = 'black'	
	thisobj.style.fontWeight = 'normal'
}
		
function subdate(fromdate,todate){
	varsplit = "/";
	var hasil = 0;
	x = valid_dateformat(fromdate);
	y = valid_dateformat(todate);
	
	var inpDate1 = new Array();
	var inpDate2 = new Array();
	
	var inpDate1 = x.split(varsplit);
	var inpDate2 = y.split(varsplit);
	
	var day1 = inpDate1[1];//tgl FROM
	var month1 = inpDate1[0];//bulan FROM
	var year1 = inpDate1[2];//tahun FROM
	var day2 = inpDate2[1];//tgl TO
	var month2 = inpDate2[0];//bulan TO
	var year2 = inpDate2[2];//tahun TO
	var selisihyear = year2 - year1;
	var selisihmonth = month2 - month1;
	var selisihday = day2 - day1;
	var m;
	var y;
	var dummonth;
	var dumyear;
	
	if(selisihyear > 0){
		dumyear = year1;
		for(y = 1;y <= selisihyear;y++){
			hasil = hasil + get_max_day_inyear(dumyear);
			dumyear++;
			if(y == selisihyear){ selisihyear =0; break; return hasil;}
		}
		return hasil;
	}
			
	if(selisihmonth > 0){
		dummonth = month1;
		dumyear = year1;
		//alert(selisihmonth);
		for(m = 1;m <= selisihmonth;m++){
			hasil = hasil + get_max_day_inmonth(dummonth,dumyear);
			//alert(hasil);
			dummonth++;
			if(dummonth == 13){
				//alert('masuk sini');
				dummonth = 1;
				dumyear++;
			}
			if(m == selisihmonth){selisihmonth =0 ;break; return hasil;}
		}
		return hasil;
	}
	if((selisihday == 0) && (selisihmonth == 0) && (selisihyear == 0)){hasil = 0; return hasil;}else{hasil = hasil + selisihday + 1;return hasil;}
}


function selectSales(thisobj){
	totday = 0;
	frmNew.txtSPCode.value = thisobj.id;
	// get the name of Customer's Contact
	<cfif val(qsetting.salesperson) eq "1">
		for (var i=0; i<arrEmp.length; i++){
			if(arrEmp[i]['empID'] == thisobj.id){
				frmNew.txtSPName.value = arrEmp[i]['fullEmpName'];
				if(new Date(frmNew.txtSODate.value) > new Date(arrEmp[i]['effectiveDate'])){totday = subdate(arrEmp[i]['effectiveDate'],frmNew.txtSODate.value); break;}else{totday =subdate(arrEmp[i]['effectiveDate'],frmNew.txtSODate.value); break;}
			}
		}
	 
	</cfif>
	popSales('no');
}
		
function populateSales(isAll){
	if(isAll == 'all'){
		txtSearch = '';
		frmNew.txtSalesSearch.value = ''
	}else{
		txtSearch = frmNew.txtSalesSearch.value.toUpperCase();
	}
	objSalesRec = document.getElementById('tblDataSales')
	
	// delete all rows
	for (var i=objSalesRec.rows.length; i>0; i--)
		objSalesRec.deleteRow(i-1);
	
	// populate data according search criteria
	for (i=arrEmp.length-1; i>=0; i--){
		if(arrEmp[i]['fullEmpName'].toUpperCase().indexOf(txtSearch)>=0 || arrEmp[i]['empID'].toUpperCase().indexOf(txtSearch)>=0){
			newTR = objSalesRec.insertRow(objSalesRec.length);
			newTR.id = arrEmp[i]['empID']
			newTR.onmouseover = new Function('hoover(this)');
			newTR.onmouseout = new Function('unHoover(this)');
			newTR.onclick = new Function('selectSales(this)')
			
			newTD = newTR.insertCell(0);
			newTD.className = 'formtext'

			newTD.style.width = '137px'
			newTD.innerHTML = arrEmp[i]['empID']
			
			newTD = newTR.insertCell(1);
			newTD.className = 'formtext'
			newTD.style.width = '137px'
			newTD.innerHTML = arrEmp[i]['empName']
		}
	}				
}

function isInt(){
	return ((event.keyCode >= 48) && (event.keyCode <= 57) || (event.keyCode == 46));
}

function checkEvent(index){
	var baseCurrency ='#cookie.currencyid#'
	//alert(parseFloat(eval('document.frmNew.txtQty'+index).value));
	txthdneventprice=parseFloat(eval('document.frmNew.hdnEventPrice'+index).value);
	txthdneventqty=parseFloat(eval('document.frmNew.hdnEventQty'+index).value);
	txthdneventdisc=parseFloat(eval('document.frmNew.hdnEventDiscAmount'+index).value);
	txthdneventdiscpercent=parseFloat(eval('document.frmNew.hdnEventDiscPercent'+index).value);

	if(txthdneventprice==0 && txthdneventqty==0 && txthdneventdisc==0 && txthdneventdiscpercent==0){
		//alert("wiw");
	}else{
	//alert(parseFloat(eval('document.frmNew.hdnEventQty'+index).value));

		if(document.frmNew.selCurrency.value == baseCurrency){
			if(parseFloat(eval('document.frmNew.txtQty_'+index).value) >= parseFloat(eval('document.frmNew.hdnEventQty'+index).value)){
	
				//eval('document.frmNew.txt)
				//alert(parseFloat(eval('document.frmNew.txtdisc'+index).value));
				//alert(parseFloat(eval('document.frmNew.hdnEventDiscAmount'+index).value));
				//eval('document.frmNew.txtDisc'+index).value = eval('document.frmNew.hdnEventDiscAmount'+index).value;
				eval('document.frmNew.txtConvertedUnitPrice'+index).value = eval('document.frmNew.hdnEventPrice'+index).value;
					if(txthdneventdiscpercent <=0){
							txtConvertedUnitPrice = parseFloat(eval('document.frmNew.txtConvertedUnitPrice'+index).value);
							hdnEventDiscAmount = parseFloat(eval('document.frmNew.hdnEventDiscAmount'+index).value);
							eval('document.frmNew.txtDisc_'+index).value = (hdnEventDiscAmount / txtConvertedUnitPrice) * 100;
							
						}else{
							eval('document.frmNew.txtDisc_'+index).value =txthdneventdiscpercent;
							
							}
				//alert(eval('document.frmNew.hdnEventDiscPercent'+index).value);
				//eval('document.frmNew.txtDisc'+index).value = eval('document.frmNew.hdnEventDiscPercent'+index).value;
			}
		}else{
			txtConvertedUnitPrice = eval('document.frmNew.txtConvertedUnitPrice'+index);
			hdnEventPrice = parseFloat(eval('document.frmNew.hdnEventPrice'+index).value);
			txtSORate=1
			//txtSORate = parseFloat(eval('document.frmNew.txtSORate').value);
			txtConvertedUnitPrice.value = hdnEventPrice / txtSORate;
			//eval('document.frmNew.txtConvertedUnitPrice'+index).value=parseFloat(eval('document.frmNew.hdnEventPrice'+index).value)/parseFloat(eval('document.frmNew.txtSORate').value);
			if(txthdneventdiscpercent <=0){
			eval('document.frmNew.txtDisc_'+index).value = (parseFloat(eval('document.frmNew.hdnEventDiscAmount'+index).value) / parseFloat(eval('document.frmNew.txtConvertedUnitPrice'+index).value)) * 100;
			}else{
							eval('document.frmNew.txtDisc_'+index).value =txthdneventdiscpercent;
						}
		
		
		}

	//alert(eval("document.frmNew.hdnEventQty"+index).value)
	//alert(parseFloat(index));
	/*
	document.frmNew.hdnEventQty
	document.frmNew.hdnEventPrice

	document.frmNew.hdnEventDiscAmount
	document.frmNew.hdnEventDiscPercent
	*/
	}
}


String.prototype.repeat = function( num ){
    return new Array( num + 1 ).join( this );
}

function addRow(thetype,icode,fcolor,ilvl){
	<!---alert("Jalan");--->
	if(document.frmNew.chkAll.length > 1)
		document.frmNew.chkAll[0].checked = false;
	else
		document.frmNew.chkAll.checked = false;
	if(ilvl==null) ilvl=0;
	document.frmNew.rowCount.value = parseInt(document.frmNew.rowCount.value) + 1
	var cnt =  document.frmNew.rowCount.value;
	objTbl = document.getElementById("tbl_ID")
	newTR = objTbl.insertRow(objTbl.rows.length)
	newTR.id = "tr"+cnt
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.width = "20";
	newTD.Align = "center";
	newTD.style.verticalAlign="top";
	
	<!--- newTD.innerHTML = '<input type="checkbox" value="'+cnt+'" name="chk"  onClick="pickThis(this)">' --->
	if(thetype == "child"){
		newTD.innerHTML = ' <input type="Hidden" name="parent_item_'+cnt+'" value=""><input type="Hidden" name="parent_path_'+cnt+'" id="parent_path_'+cnt+'" value="">';
	}else{
		cntorder++;
		newTD.innerHTML = '<input type="checkbox" name="chk" id="chk" value="'+cnt+'" onClick="tickItem(this,'+cnt+')"><input type="Hidden" name="parent_item_'+cnt+'" value=""><input type="Hidden" name="parent_path_'+cnt+'" id="parent_path_'+cnt+'" value="">';
	}
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "left";
	newTD.noWrap = true;
	newTD.style.verticalAlign="top";

	var scolor=(fcolor==1?' <img src="#Application.stApp.Upload_Path[1]#/eaccounting/images/color.gif" alt="Colour" align="absmiddle" onClick="getColour(document.frmNew.txtPartNo_'+cnt+'.value,'+cnt+')" name="imgPick'+cnt+'" id="imgPick'+cnt+'" style="display: \'\'">':'')
	var vhidnode=scolor+'<input type="hidden" name="hdnMatrixItem_'+cnt+'"><input type="hidden" name="hdnEventQty_'+cnt+'"><input type="hidden" name="hdnEventPrice_'+cnt+'"><input type="hidden" name="hdnEventDiscAmount_'+cnt+'"><input type="hidden" name="hdnEventDiscPercent_'+cnt+'"><input type="Hidden" name="hidQtyFree_'+cnt+'">';
	if(thetype == "child"){
		newTD.innerHTML = '<input type="checkbox" value="'+cnt+'" name="chk" id="chk" disabled onClick="tickItem(this,'+cnt+')">'+('     '.repeat(parseInt(ilvl)))+'<img src="#Application.stApp.Upload_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/lastnode.gif" border="0"> <input type="text" name="txtPartNo_'+cnt+'" id="txtPartNo_'+cnt+'" value="" class="inplabel" width="10" size="15" readonly>'+vhidnode+'<input type="Hidden" name="hdnLevel_'+cnt+'" value="'+(parseInt(ilvl)+1)+'"">';
	}else{
		newTD.innerHTML = '<input type="text" name="txtPartNo_'+cnt+'" id="txtPartNo_'+cnt+'" value="" class="inplabel" width="10" size="15" readonly>'+vhidnode+'<input type="Hidden" name="hdnLevel_'+cnt+'" value="0"">';
	}
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "left";
	newTD.noWrap = true;
	newTD.style.verticalAlign="top";
	newTD.innerHTML = '<span id="txtDesc_'+cnt+'"></span><input type="hidden" name="txtDesc_'+cnt+'" value=""><input type="hidden" name="hdnColorItem_'+cnt+'"><br><span  id="color_'+cnt+'"></span><input type="hidden" name="hdncolor_'+cnt+'" id="hdncolor_'+cnt+'" value=""><input type="hidden" name="hdndorder_'+cnt+'" value="'+cntorder+'">';
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "left";
	newTD.noWrap = true;
	newTD.style.verticalAlign="top";
	newTD.innerHTML = '<input type="text" name="txtNotes_'+cnt+'" value="">';
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "left";
	newTD.noWrap = true;
	newTD.style.verticalAlign="top";
	newTD.style.display="none";
	newTD.innerHTML = '<a'
					+ ' href="javascript:void(0);"'
					+ ' onClick="showLookup(' + cnt + ')"'
					+ ' style="text-decoration: none;"><img'
					+ ' id="imbPickDimension_' + cnt + '" border="0" style="display: ;"'
					+ ' src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/dimension_picker.gif"'
					+ ' onmouseover="return overlib(\'#DO_VAR['CHANGEITEMDIMENSION']#\');"'
					+ ' onmouseOut="return nd();" width="15" height="13" /></a> ';
	newTD.innerHTML += '<input type="text" name="txtDimensionName_' + cnt + '" id="txtDimensionName_' + cnt + '" value="" class="inplabel" readonly/>';
	newTD.innerHTML += '<input type="hidden" name="txtDimensionID_' + cnt + '" id="txtDimensionID_' + cnt + '" value="" />';
	
	<!--- Custom Samick --->	
	newTD = newTR.insertCell(newTR.cells.length);
	newTD.align = "left";
	newTD.vAlign = "top";
	newTD.noWrap = true;
	newTD.innerHTML = '<span id="txtColorItem_'+cnt+'"></span><input type="hidden" name="txtColorItem_'+cnt+'" id="txtColorItem_'+cnt+'" value="" size="20" width="30" readonly />';	
	
	newTD = newTR.insertCell(newTR.cells.length);
	newTD.align = "left";
	newTD.vAlign = "top";
	newTD.noWrap = true;
	newTD.innerHTML = '<span id="txtBrandItem_'+cnt+'"></span><input type="hidden" name="txtBrandItem_'+cnt+'" id="txtBrandItem_'+cnt+'" value="" size="20" width="30" readonly />';	
	
	newTD = newTR.insertCell(newTR.cells.length);
	newTD.align = "left";
	newTD.vAlign = "top";
	newTD.noWrap = true;	
	newTD.innerHTML = '<span id="txtTypeItem_'+cnt+'"></span><input type="hidden" name="txtTypeItem_'+cnt+'" id="txtTypeItem_'+cnt+'" value="" size="20" width="30" readonly />';	
	
	<!--- end custom Samick --->
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.style.verticalAlign="top";
	

	if(thetype == "child"){
		newTD.innerHTML = '<input type="text" id="txtQty_'+cnt+'" name="txtQty_'+cnt+'" class="inpdim" readonly style="text-align:right" value="" size="4" maxlength="10">'	// onblur="calcAmount('+cnt+'); recalcTotal();"
	}else{
		newTD.innerHTML = '<input type="text" id="txtQty_'+cnt+'" name="txtQty_'+cnt+'" '+(fcolor==1?'class="inpdim" readonly':'')+' style="text-align:right" value="" size="4"  maxlength="10" onChange="qty_ratio('+cnt+', this);getPrice('+cnt+'); getDiscount('+cnt+');" onblur="calcAmount('+cnt+'); recalcTotal(); getDiscountTotal();getFreeItemTotal(); decimalinForMoney(this);" onKeyPress="return isIntOnlyNew(event);" >'
	}
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.innerHTML = '<input type="hidden" name="txtUnitId_'+cnt+'" size="10" value="" readonly><input type="hidden" name="txtUnitId2_'+cnt+'" size="10" value="" readonly><input type="text" style="text-align:left" name="txtUnitType'+cnt+'" value="" size="10" readonly class="inpdim">';
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	
	//if(thetype == "child"){
		newTD.innerHTML = '<input type="text" name="txtQty2_'+cnt+'"  class="inpdim" readonly style="text-align:right" value="0" size="4"  maxlength="10">'	

		//newTD.innerHTML = '<input type="text" name="txtQty2_'+cnt+'" style="text-align:right" value="" size="4" maxlength="10">'	
	//}else{
		//newTD.innerHTML = '<input type="text" name="txtQty2_'+cnt+'" style="text-align:right" value="" size="4" maxlength="10" onblur="qty_ratio2('+cnt+', this);">'
	//}
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.innerHTML = '<input type="text" style="text-align:left" name="txtUnitType2'+cnt+'" value="" size="10" readonly class="inpdim"><input type="hidden" style="text-align:left" name="txtUnitConv2to1'+cnt+'" value="" readonly><input type="hidden" style="text-align:left" name="txtUnitConv1to2'+cnt+'" value="" readonly>';
	
	
	//Custom Samick
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";	
	newTD.style.verticalAlign="top";
	<cfif task eq "save">
	newTD.style.display = "none";
	</cfif>
	newTD.innerHTML = '<input type="text" name="txtSNQty_'+cnt+'"  class="inpdim" readonly style="text-align:right" value="0" size="4"  maxlength="10">'	
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	<cfif task eq "save">
	newTD.style.display = "none";
	</cfif>
	newTD.innerHTML = '<input type="hidden" name="txtSNUnitId_'+cnt+'" size="10" value="" readonly><input type="hidden" name="txtSNUnitId2_'+cnt+'" size="10" value="" readonly><input type="text" style="text-align:left" name="txtSNUnitType'+cnt+'" value="" size="10" readonly class="inpdim">';
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	<cfif task eq "save">
	newTD.style.display = "none";
	</cfif>
	newTD.innerHTML = '<input type="text" name="txtSNQty2_'+cnt+'"  class="inpdim" readonly style="text-align:right" value="0" size="4"  maxlength="10">'	

	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	<cfif task eq "save">
	newTD.style.display = "none";
	</cfif>
	newTD.innerHTML = '<input type="text" style="text-align:left" name="txtSNUnitType2'+cnt+'" value="" size="10" readonly class="inpdim"><input type="hidden" style="text-align:left" name="txtSNUnitConv2to1'+cnt+'" value="" readonly><input type="hidden" style="text-align:left" name="txtSNUnitConv1to2'+cnt+'" value="" readonly>';
	//end custom Samick
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.style.verticalAlign="top";
	//if(thetype == "child"){
		//newTD.innerHTML = '<input type="text" style="text-align:right" name="txtConvertedUnitPrice_'+cnt+'" value="" size="12" maxlength="15" onblur="calcAmount('+cnt+'); recalcTotal();"  readonly class="inplabel">' <!--- updated --->
	//}else{
		newTD.innerHTML = '<input type="text" style="text-align:right" name="txtConvertedUnitPrice_'+cnt+'" id="txtConvertedUnitPrice_'+cnt+'" value="" size="12" maxlength="15" onblur="calcAmount('+cnt+'); recalcTotal(); decimalinForMoney(this);calculateTermOfPayment();getDiscountTotal();getFreeItemTotal();" onKeyPress="return isIntOnlyNew(event);" onChange="changeBGcolor(this);getDiscountTotal();getFreeItemTotal();recalcTotal();calculateTermOfPayment();" >' <!--- updated --->
	//}
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.style.verticalAlign="top";
	newTD.innerHTML = '<input type="hidden" name="txtDiscType_'+cnt+'" value=""><input type="hidden" name="txtDiscv_'+cnt+'" value=""><input type="text" style="text-align:right" onChange="changeBGcolor(this);" name="txtDisc_'+cnt+'" id="txtDisc_'+cnt+'" value="0" size="10" width="4" onblur="calcAmount('+cnt+'); recalcTotal();calcAmountAll();decimalinForMoney(this);calculateTermOfPayment();">'
	
	<!---add by NP Agts 2010 -- sales trade agreement--->
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.style.verticalAlign="top";
	newTD.innerHTML = '<input type="hidden" name="txtDiscount2'+cnt+'" value=""><input type="text" style="text-align:right" onChange="changeBGcolor(this);checkDiscAll(this)" name="txtDiscount1'+cnt+'" id="txtDiscount1'+cnt+'" value="0" size="10" width="4" onblur="calcAmount('+cnt+'); recalcTotal();calculateTermOfPayment(); ">'
	<!---end--->

	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.style.verticalAlign="top";
	newTD.innerHTML = '<input type="text" style="text-align:right"  name="txtConvertedAmount_'+cnt+'" readonly class="inplabel" value="" size="12" width="10">' <!--- updated --->
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.style.verticalAlign="top";

	newTD.innerHTML = '<select name="selTax1_'+cnt+'" id="selTax1_'+cnt+'" onchange="calcAmount('+cnt+'); calcTax(); GetAmountGrand(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);calculateTermOfPayment(); "><option value="0|0|0">None</option><cfloop query="qTaxType"><option value="#Tax_Code#|#Tax_rate#|#Tax_Operator#">#Tax_Name#</option></cfloop></select>'
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.style.verticalAlign="top";
	newTD.innerHTML = '<select name="selTax2_'+cnt+'" id="selTax2_'+cnt+'" onchange="calcAmount('+cnt+'); recalcTotal();calculateTermOfPayment();"><option value="0|0|0">None</option><cfloop query="qTaxType"><option value="#Tax_Code#|#Tax_rate#|#Tax_Operator#">#Tax_Name#</option></cfloop></select>';
	
	buildSelTax(cnt);
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.style.display = 'none'
	newTD.innerHTML = '<input type="hidden" name="txtOthers_'+cnt+'" value="" size="20" width="10" onblur="calcAmount('+cnt+'); ">';
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.noWrap = true;
	newTD.style.verticalAlign="top";
	if(thetype != "child"){
		<cfset dtmvalue2 ="#DateFormat(now(),"mm/dd/yyyy")#">
		//<!--- <cfset dtmvalue2 =""> --->
	//	newTD.innerHTML = '<input type="text" id="txtEstimateDate_'+cnt+'" name="txtEstimateDate_'+cnt+'" value="#dtmvalue2#" size="10" width="10" onblurX="calcAmount('+cnt+'); calcAmountAll(); calcTax(); setCurr(); setCurrTax()"><input type="hidden" name="txtEstimateDateSplit_'+cnt+'" id="txtEstimateDateSplit_'+cnt+'" value=""/>';
		//newTD.innerHTML = SunFishERP_DateTimePicker('txtEstimateDate_'+cnt, '#dtmvalue2#',null,1) + '<input type="hidden" name="txtEstimateDateSplit_'+cnt+'" id="txtEstimateDateSplit_'+cnt+'" value=""/>'+'<span id="lnkEstimateDateSplit'+cnt+'"></span>';
		dtp_Identity = cnt+#dcf_Identity#;
		newTD.innerHTML = "<input value='' type=hidden name=txtEstimateDateSplit_"+cnt+" id=txtEstimateDateSplit_"+cnt+"><input id=Picker"+dtp_Identity+"_selecteddates value='#dtmvalue2#' type=hidden name=txtEstimateDate_"+cnt+" id=txtEstimateDate_"+cnt+"><input id=Picker"+dtp_Identity+"_visibledate type=hidden name=Picker"+dtp_Identity+"_visibledate><input onblur='return ComponentArt_Calendar_PickerOnBlur(this)' onkeydown='return ComponentArt_Calendar_PickerOnKeyDown(event,this)' ondragstart='return ComponentArt_Calendar_PickerOnDragStart(this)' id=Picker"+dtp_Identity+"_picker onmouseup='return ComponentArt_Calendar_PickerOnMouseUp(this)' onselectstart='return ComponentArt_Calendar_PickerOnSelectStart(this);' class=picker onfocus='return ComponentArt_Calendar_PickerOnFocus(this)' onkeypress='return ComponentArt_Calendar_PickerOnKeyPress(event,this)' onkeyup='return ComponentArt_Calendar_PickerOnKeyUp(this)' onmousedown='return ComponentArt_Calendar_PickerOnMouseDown(this)' size=17 name=Picker"+dtp_Identity+"_picker onselect='return ComponentArt_Calendar_PickerOnSelect(this)'><DIV style='DISPLAY: none' id=Picker"+dtp_Identity+"></DIV> <IMG id=calendar_button"+dtp_Identity+" onclick='ShowCalendar(\""+dtp_Identity+"\")' align=absMiddle src='#Application.stApp.Upload_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/date.gif'><input id=Calendar"+dtp_Identity+"_selecteddates type=hidden name=Calendar"+dtp_Identity+"_selecteddates><input id=Calendar"+dtp_Identity+"_visibledate type=hidden name=Calendar"+dtp_Identity+"_visibledate><DIV style='DISPLAY: none' id=Calendar"+dtp_Identity+" class=calendar></DIV><br><span id='lnkEstimateDateSplit"+cnt+"'></span>";
		<cfif isdate(dtmvalue2)>
		objSelectedDates = new Date('#dtmvalue2#');
		<cfelse>
		objSelectedDates = [];
		</cfif>
//		var ndxdate=dtp_Identity;
		ComponentArt_Init_Picker();
		ComponentArt_Init_Calendar();
	}
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.style.verticalAlign="top";
	if(thetype != "child"){
		//newTD.innerHTML = '<a style="display:block" href="javascript:void(0)" onclick="splitETA(\''+cnt+'\',\''+dtp_Identity+'\')"><img src="#Application.stApp.Web_Path[1]#/eaccounting/images/list.gif" alt="Multiple" align="absmiddle" border="0"></a>';
		newTD.innerHTML = '<a style="display:block" href="javascript:void(0)" onclick="splitETA(\''+cnt+'\',\''+dtp_Identity+'\')"><img src="#Application.stApp.Web_Path[1]#/eaccounting/images/list.gif" alt="Multiple" align="absmiddle" border="0"></a>';
	}
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.style.verticalAlign="top";
	newTD.innerHTML = '<select name="selComponent_'+cnt+'"><option value="0">..::[#DO_VAR["eHRMNone"]#]::..</option><cfloop query="qGetComponent"><option value="#Comp_ID#">#JSStringFormat(Comp_Name)#</option></cfloop></select>';

	/*newTD = newTR.insertCell(17)
	newTD.align = "center";
	newTD.style.verticalAlign="top";
	if(thetype != "child"){
		newTD.innerHTML = '<input type="checkbox" name="chkinstall_'+cnt+'" value="" size="20" width="30" style="border: none">'; 
	}*/
	//untuk yang hidden
	newTD = newTR.insertCell(newTR.cells.length)

	newTD.align = "center";
//	newTD.style.display = 'none';
	var vhidinp = '<input type="hidden" name="HidBase_ConvertedUnitPrice_'+cnt+'" value="0" size="10" width="10">';
	vhidinp += '<input type="hidden" name="HidBase_ConvertedAmount_'+cnt+'" value="0" size="10" width="10">';
	vhidinp += '<input type="hidden" name="txtTaxAmount1_'+cnt+'" value="0" size="10" width="10">';
	vhidinp += '<input type="hidden" name="hidBase_TaxAmount1_'+cnt+'" value="0" size="10" width="10">';
	vhidinp += '<input type="hidden" name="txtTaxAmount2_'+cnt+'" value="0" size="10" width="10">';
	vhidinp += '<input type="hidden" name="hidBase_TaxAmount2_'+cnt+'" value="0" size="10" width="10">';
	vhidinp += '<input type="hidden" name="txtCS_'+cnt+'" value="">';
	vhidinp += '<input type="hidden" name="txtCurrencyID_'+cnt+'" value="">';
	vhidinp += '<input type="hidden" style="text-align:right"   name="txtExtra_'+cnt+'" value="" size="10" width="7" onblur="calcAmount('+cnt+'); recalcTotal(); decimalinForMoney(this);" onKeyPress="return isIntOnlyNew(event);">';
	vhidinp += '<input type="hidden" name="txtOriginPrice_'+cnt+'" value="">';
	vhidinp += '<input type="hidden" name="txtPriceType_'+cnt+'" value="">';
	vhidinp += '<input type="hidden" name="txtConverter_'+cnt+'" value="">';
	vhidinp += '<input type="hidden" name="HidBase_ConvertedUnitPrice2_'+cnt+'" value="" size="10" width="10">';
	vhidinp += '<input type="hidden" name="hid_generate_flag_'+cnt+'" value="0">';//'+(thetype == "child"?"":"3")+'
	vhidinp += '<input type="hidden" name="hdnRatio_'+cnt+'" value="">'; //untuk ratio child - kelvin
	vhidinp += '<input type="hidden" name="hidFree_'+cnt+'" value="0">'; //untuk penanda free item - kelvin
	newTD.innerHTML = vhidinp;
	
	//untuk keperluan delete - kelvin - 29 Aug 08
	document.frmNew.hidTransfer.value = parseInt (document.frmNew.hidTransfer.value) + 1;
	document.frmNew.hidCountTransfer.value = parseInt (document.frmNew.hidCountTransfer.value) + 1;
    convertCL();
		
	<!--- addRow MiscCharge Allocation --->
	
	document.forms[0].rowCountMiscAllo.value = parseInt(document.forms[0].rowCountMiscAllo.value) + 1
	cnt =  document.forms[0].rowCountMiscAllo.value 

	objTblMiscAllo = document.getElementById('tbl_MiscAllo')
	newTR = objTblMiscAllo.insertRow(objTblMiscAllo.rows.length)
	newTR.id = "tr"+cnt

	

	newTD = newTR.insertCell(newTR.cells.length);
	newTD.width = "20";
	newTD.align = "center";
	newTD.vAlign = "top";
	if(thetype == "child"){
		newTD.innerHTML = '&nbsp;<input type="checkbox" value="'+cnt+'" name="chkAllo" id="chkAllo" disabled onClick="tickItem(this,'+cnt+')"><input type="Hidden" name="parent_item'+cnt+'" value=""><input type="Hidden" name="parent_path'+cnt+'" id="parent_path'+cnt+'" value="">';
	}else{
		newTD.innerHTML = '<input type="checkbox" value="'+cnt+'" name="chkAllo" id="chkAllo" disabled onClick="tickItem(this,'+cnt+')"><input type="Hidden" name="parent_item'+cnt+'" value=""><input type="Hidden" name="parent_path'+cnt+'" id="parent_path'+cnt+'" value="">';
	}

	newTD = newTR.insertCell(newTR.cells.length);
	newTD.align = "left";
	newTD.vAlign = "top";
	newTD.noWrap = true;
	
	if(thetype == "child"){
	  newTD.innerHTML = '<input type="text" '
		+ 'name="txtPartNoMisc'+cnt+'" id="txtPartNoMisc'+cnt+'" '
		+ 'value="" class="inplabel" width="10" size="15" readonly />'
		+ '<input type="hidden" '
		+ 'name="hdnLevelMisc'+cnt+'" id="hdnLevelMisc'+cnt+'"'
		+ ' value="'+(parseInt(ilvl)+1)+'" />';
	}else{
	  newTD.innerHTML = '<input type="text" '
		+ 'name="txtPartNoMisc'+cnt+'" id="txtPartNoMisc'+cnt+'" '
		+ 'value="" class="inplabel" width="10" size="15" readonly />'
		+ '<input type="hidden" '
		+ 'name="hdnLevelMisc'+cnt+'" id="hdnLevel'+cnt+'"'
		+ ' value="0" />';
	}
	
	newTD = newTR.insertCell(newTR.cells.length);
	newTD.align = "left";
	newTD.vAlign = "top";
	newTD.noWrap = true;
	newTD.innerHTML = '<span id="txtDescMisc'+cnt+'"></span><input type="hidden" name="txtDescMisc'+cnt+'" id="txtDescMisc'+cnt+'" value="" size="20" width="30" readonly />';
	
	
	newTD = newTR.insertCell(newTR.cells.length);
	newTD.align = "left";
	newTD.vAlign = "top";
	newTD.noWrap = true;
	newTD.style.display="none";
	newTD.innerHTML = '<a'
					+ ' href="javascript:void(0);"'
					+ ' onClick="showLookup(' + cnt + ')"'
					+ ' style="text-decoration: none;"><img'
					+ ' id="imbPickDimension_' + cnt + '" border="0" style="display: ;"'
					+ ' src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/dimension_picker.gif"'
					+ ' onmouseover="return overlib(\'#DO_VAR['CHANGEITEMDIMENSION']#\');"'
					+ ' onmouseOut="return nd();" width="15" height="13" /></a>&nbsp;';
	newTD.innerHTML += '<input type="text" name="txtDimensionNameMisc'+cnt+'" id="txtDimensionNameMisc'+cnt+'" value="" class="inplabel" readonly />';
	newTD.innerHTML += '<input type="hidden" name="txtDimensionIDMisc'+cnt+'" id="txtDimensionIDMisc'+cnt+'" value="" />';
	
	var scolor=(fcolor==1?'<img src="#Application.stApp.Upload_Path[1]#/eaccounting/images/pickinvoice.gif" width="14" height="14" border="0" alt="Click to pick colour" onClick="getColour('+cnt+',document.frmNew.chkwarna'+cnt+'.value,\'frmNew\',document.frmNew.txtPartNo'+cnt+'.value)" onMouseOver="hover(this, \'pickinvoice_v.gif\')" onMouseOut="hover(this, \'pickinvoice.gif\')" name="imgPick'+cnt+'" id="imgPick'+cnt+'" style="display: \'\'; cursor:pointer;">':'');
	
	var vhidnode=scolor+'&nbsp;<input type="hidden" name="hdnMatrixItem'+cnt+'"><input type="hidden" name="hdnEventQty'+cnt+'"><input type="hidden" name="hdnEventPrice'+cnt+'"><input type="hidden" name="hdnEventDiscAmount'+cnt+'"><input type="hidden" name="hdnEventDiscPercent'+cnt+'"><input type="Hidden" name="hidQtyFree'+cnt+'"><input type="hidden" name="flagwarna'+cnt+'" id="flagwarna'+cnt+'" value="" /><input type="hidden" name="chkwarna'+cnt+'" id="chkwarna'+cnt+'" value="0" size="20" width="30" style="border: none" readonly />';
	
	<!--- Custom Samick --->	
	newTD = newTR.insertCell(newTR.cells.length);
	newTD.align = "left";
	newTD.vAlign = "top";
	newTD.noWrap = true;
	newTD.innerHTML = '<span id="txtColorItemMisc_'+cnt+'"></span><input type="hidden" name="txtColorItemMisc_'+cnt+'" id="txtColorItemMisc_'+cnt+'" value="" size="20" width="30" readonly />';	
	
	newTD = newTR.insertCell(newTR.cells.length);
	newTD.align = "left";
	newTD.vAlign = "top";
	newTD.noWrap = true;
	newTD.innerHTML = '<span id="txtBrandItemMisc_'+cnt+'"></span><input type="hidden" name="txtBrandItemMisc_'+cnt+'" id="txtBrandItemMisc_'+cnt+'" value="" size="20" width="30" readonly />';	
	
	newTD = newTR.insertCell(newTR.cells.length);
	newTD.align = "left";
	newTD.vAlign = "top";
	newTD.noWrap = true;	
	newTD.innerHTML = '<span id="txtTypeItemMisc_'+cnt+'"></span><input type="hidden" name="txtTypeItemMisc_'+cnt+'" id="txtTypeItemMisc_'+cnt+'" value="" size="20" width="30" readonly />';	
	
	<!--- end custom Samick --->
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.innerHTML = '<input type="text" name="txtConvertedAmountMisc2_'+cnt+'" style="text-align:right" value="" size="20" width="30" readonly>';	
	
	newTD = newTR.insertCell(newTR.cells.length)
	newTD.align = "center";
	newTD.innerHTML = '<input type="hidden" name="hidTotalMiscNonUD_'+cnt+'" style="text-align:right" value="" size="20" width="30" readonly>';	
	

}

var colcounter=1;
function addRowCol(itemid){
	if(document.frmNew.chkAll.length > 1)
		document.frmNew.chkAll[0].checked = false;
	else
		document.frmNew.chkAll.checked = false;
	//document.frmNew.rowCount.value = parseInt(document.frmNew.rowCount.value) + 1 // IND , Jika add row colour, rowCount tidak di tambahkan
	cnt =  document.frmNew.rowCount.value;
	itemid=cnt;//itemid+"_"+cnt;//colcounter

	objTbl = document.getElementById('tbl_ID');
	newTRCol = objTbl.insertRow(objTbl.rows.length);
	newTRCol.id = "tr"+itemid+"_"+cnt;
	
	newTDCol = newTRCol.insertCell(0)
	newTDCol.width = "20";
	newTDCol.Align = "center";
	newTDCol.innerHTML = " ";
	
	newTDCol = newTRCol.insertCell(1)
	newTDCol.width = "20";
	newTDCol.Align = "center";
	newTDCol.colSpan = "3";
	newTDCol.innerHTML = '<span  id="color_'+itemid+'"></span><input type="hidden" name="hdncolor_'+itemid+'" id="hdncolor_'+itemid+'" value="">'

	newTDCol = newTRCol.insertCell(2)
	newTDCol.width = "20";
	newTDCol.Align = "center";
	newTDCol.innerHTML = " ";

	newTDCol = newTRCol.insertCell(1)
	newTDCol.width = "20";
	newTDCol.Align = "center";
	newTDCol.innerHTML = '<span  id="colorqty_'+itemid+'"></span>'
	colcounter++;
} 

//------------------------- SET CHILD QTY DENGAN EVENT PRICING CONDITION--------------------------- KELVIN, 1 SEPT 08
//untuk set qty child - kelvin - 27 Aug 08
function set_qty(theparent, theinp){	var theqty = parseFloat(theinp.value);
	if(eval("document.frmNew.hidFrabortee"+theparent).value == 1)//bila free item
	{
		if(theqty >= parseFloat (eval("document.frmNew.hdnEventQty"+theparent).value))//bila jumlah mencukupi untuk dapat free item
		{
			for(i=1; i<=document.frmNew.rowCount.value; i++){
				if(eval("document.frmNew.hid_parent_item_"+i)){
					curParentItem = eval("document.frmNew.hid_parent_item_"+i).value;
					curItem = eval("document.frmNew.txtPartNo_"+theparent).value;
					if(curItem == curParentItem){
						if(eval("document.frmNew.txtQty"+i)){
							childQty = eval("document.frmNew.txtQty"+i);
							childQty.value = parseFloat (eval("document.frmNew.hidQtyFree_"+theparent).value);
							eval("document.frmNew.txtDisc_"+theparent).value = parseFloat (eval("document.frmNew.hdnEventDiscPercent_"+theparent).value);
							
						}
					}
				}
			}
		}else{	
			for(i=1; i<=document.frmNew.rowCount.value; i++){
				if(eval("document.frmNew.hid_parent_item_"+i)){
					curParentItem = eval("document.frmNew.hid_parent_item_"+i).value;
					curItem = eval("document.frmNew.txtPartNo_"+theparent).value;
					if(curItem == curParentItem){
						if(eval("document.frmNew.txtQty"+i)){
							childQty = eval("document.frmNew.txtQty"+i);
							childQty.value = 0;
							eval("document.frmNew.txtDisc_"+theparent).value = 0;
						}
					}
				}
			}
		}
	}else{//bila child biasa
		var theChk = theinp.form.chk;
		if(theChk != null){
			if(theChk.length != null){
				for(i=theparent; i<theChk.length; i++){
					if(theChk[i].disabled){
						var elmqty=eval("theinp.form.txtQty_"+i);
						var elmrto=eval("theinp.form.hdnRatio_"+i);
						if(elmqty!=null && elmrto!=null){
							elmqty.value = parseFloat(elmrto.value) * theqty;
						}
					}else
						break;
				}
			}
		}
	/*for(i=1; i<=document.frmNew.rowCount.value; i++)//mengambil semua baris yg ada
	{
			if(eval("document.frmNew.hid_parent_item_"+i))//bila ada child yg sesuai namanya
		{
				curParentItem = eval("document.frmNew.parent_item_"+i).value;
				curItem = eval("document.frmNew.txtPartNo_"+theparent).value;
				if(curItem == curParentItem)//bila child yg dimaksud adalah kepunyaan theparent
				{
					if(eval("document.frmNew.txtQty_"+i)){
						childQty = eval("document.frmNew.txtQty"+i);
						childQty.value = theqty * eval("document.frmNew.hdnRatio_"+i).value;
					}
				}


			}
		}*/
		}
	}
function qty_ratio(theparent,theinp){
	if(isNaN(theinp.value.split(",").join("")))
		theinp.value=0;

	var theqty = parseFloat(theinp.value.split(",").join(""));
	
	/* andiJ. 05Mar'10, bermasalah ketika item cuman 1 baris, length jadi undefined, pakai getElementsByName saja
	var theChk = theinp.form.chk; */
	var theChk = document.getElementsByName("chk");
	
	if(theChk != null){
		if(theChk.length != null){
			for (var j=0; j<theChk.length; j++){
				if(theChk[j].value==theparent){
					var eleta=eval("theinp.form.txtEstimateDateSplit_"+theparent);
					if(eleta!=null)
						eleta.value="";
					var eleta=document.getElementById("lnkEstimateDateSplit"+theparent);
					if(eleta!=null)
						eleta.innerHTML="";
					break;
				}
			}
			
			var elmqty1=eval("theinp.form.txtQty_"+theparent);
			var unitconv1to2 = eval("document.frmNew.txtUnitConv1to2"+theparent).value;
			var unitconv1to2 = eval("document.frmNew.txtUnitConv1to2"+theparent).value;
			//var unitconv2to1 = eval("document.frmNew.txtUnitConv2to1"+idx).value;
			if(unitconv1to2 == "") //kalau belum diset converter nya maka skala pengalinya 1
			{
				var unitconv1to2 = 1;
			}
			//if(unitconv2to1 == "") //kalau belum diset converter nya maka skala pengalinya 1
			//{
				//var unitconv2to1 = 1;
			//}
			eval("document.frmNew.txtQty2_"+theparent).value = parseFloat(elmqty1.value.split(",").join("")) * parseFloat(unitconv1to2);
			//objQty = frmNew['txtQty2_'+theparent]
			//predecimalin(objQty)
			
			thechild=theparent;
			
			for(i=j+1; i<theChk.length; i++){
				thechild++;
				if(theChk[i].disabled){
					var elmqtyparent=eval("theinp.form.txtQty_"+(thechild-1));
					//theqty	 = elmqtyparent.value;	
					var elmqty=eval("theinp.form.txtQty_"+thechild);
					var elmrto=eval("theinp.form.hdnRatio_"+thechild);
					if(elmqty!=null && elmrto!=null){
//						alert(i+" = "+elmqty.value+" = "+parseFloat(elmrto.value)+"("+elmrto.value+") * "+theqty);
						var newvalue=parseFloat(elmrto.value) * theqty;
						if(newvalue!=elmqty.value){
							elmqty.value = parseFloat(elmrto.value) * theqty;
							
							var unitconv1to2 = eval("document.frmNew.txtUnitConv1to2"+thechild).value;
							//var unitconv2to1 = eval("document.frmNew.txtUnitConv2to1"+idx).value;
							if(unitconv1to2 == "") //kalau belum diset converter nya maka skala pengalinya 1
							{
								var unitconv1to2 = 1;
							}
							//if(unitconv2to1 == "") //kalau belum diset converter nya maka skala pengalinya 1
							//{
								//var unitconv2to1 = 1;
							//}
							eval("document.frmNew.txtQty2_"+thechild).value = parseFloat(elmqty.value.split(",").join("")) * parseFloat(unitconv1to2);
							//objQty2 = frmNew['txtQty2_'+thechild] 
							//predecimalin(objQty2)
							
//							setvalue("theinp.form.hdncolor_"+(i+1),"");
//							setvalue("color_"+(i+1),"");
						}
					}
				}else
					break;
			}
		}
	}
}


//Bentuknya adalah emp_id|name, by Farizal untuk tipe sales person dari setting customer
function clrSelect(obj){
	for(i=(obj.length-1);i>=0;i--){
		obj.options[i] = null;
	}
}

<cfif val(qSetting.salesPerson) neq "1">
function sales_person(lstEmp){
	 
	 target = document.frmNew.txtSPCode;
	 clrSelect(target);
	 varsplit=",";
	 bagi = lstEmp.split(varsplit);
	 
	 for(i=0;i<(bagi.length);i++){
	 	awal = lstEmp.split(varsplit)[i];
	 	emp_name = awal.split('|')[0];
	 	emp_id = awal.split('|')[1];
	 	target.options[i]=new Option(emp_id,emp_name);
	 }	 
}
</cfif>

function accountgroup(member){
	target_SN = document.frmNew.selSNGroup;
	target_SI = document.frmNew.selSIGroup;
	clrSelect(target_SN);
	clrSelect(target_SI);
	varsplit=";";
	bagi = member.split(varsplit);
	 //alert(member);
	for(i=0;i<(bagi.length);i++){
	 	awal = member.split(varsplit)[i];
	 	account_id = awal.split('~')[0];
	 	account_name = awal.split('~')[1];
	 	target_SN.options[i]=new Option(account_name ,account_id);
		target_SI.options[i]=new Option(account_name ,account_id);

	 }

     
      for(j=0;j<target_SN.length;j++){
        if(target_SN.options[j].value == document.frmNew.txtCustCode.value){
            target_SN.options[j].selected = true;
        }
     }
     for(k=0;k<target_SI.length;k++){
        if(target_SI.options[k].value == document.frmNew.txtCustCode.value){
            target_SI.options[k].selected = true;
        }
     }
}

var selectedRows = 0
function pickThis (thisobj){

	//alert(thisobj);
	var TblObj = document.getElementById('tbl_ID');
	var NumOfRows = TblObj.rows.length-1 // minus 1 because it's the header
	if(thisobj!= ''){
		if(thisobj.checked) selectedRows++;
		else selectedRows--;	
	}
	if(selectedRows==NumOfRows) document.frmNew.chkAll.checked = true;
		else document.frmNew.chkAll.checked = false;
}

function pickThisMisc (thisobj){

	//alert(thisobj);
	var TblObj = document.getElementById('tbl_Misc');
	var NumOfRows = TblObj.rows.length-1 // minus 1 because it's the header
	if(thisobj!= ''){
		if(thisobj.checked) selectedRows++;
		else selectedRows--;	
	}
	if(selectedRows==NumOfRows) document.frmNew.chkAllMisc.checked = true;
		else document.frmNew.chkAllMisc.checked = false;
}
 
function tickItem(thisChk,idt){
	var theChk = thisChk.form.chk;
	var len = theChk.length;
	var allChk=thisChk.form.chkAll;
	var x = 0;
	var refsub=null;
	if(theChk != null){
		if(len != null){
			//move until idt
			for (var j=0; j<len; j++){
				if(theChk[j].checked) x++;
				if(theChk[j].value==idt){

					refsub=j;
					break;
				}

			}
			var ceksub=true;


			for(var i=j+1; i<len; i++){
				if(ceksub){
					
					if(theChk[i].disabled)
					{	
						theChk[i].checked=theChk[refsub].checked;
					}
					else{
						ceksub=false;
					}
				}
				if(theChk[i].checked) x++;
			}
			allChk.checked = (x >= len);
		}else allChk.checked = theChk.checked;
	}
}

function IsSelectAll(thisobj){
	var chkObjs = document.getElementsByName('chk');
	if(thisobj.checked){
		for (var i=0; i < chkObjs.length; i++){
			
					chkObjs[i].checked = true;
					selectedRows = document.getElementById('tbl_ID').rows.length-1;
				
		}				
	}else{
		for (i=0; i < chkObjs.length; i++){
			chkObjs[i].checked = false;
			selectedRows = 0
		}
	}
}

function IsSelectAllMisc(thisobj){
	var chkObjs = document.getElementsByName('chkMisc');
	if(thisobj.checked){
		for (var i=0; i < chkObjs.length; i++){
			chkObjs[i].checked = true;
			selectedRows = document.getElementById('tbl_Misc').rows.length-1;
		}				
	}else{
		for (i=0; i < chkObjs.length; i++){
			chkObjs[i].checked = false;
			selectedRows = 0
		}
	}
}

//modified version for delete rows by TW: 2009-12-07
function delRow(tblID,type){
	objTbl = document.getElementById(tblID);
	objTbl2 = document.getElementById('tbl_MiscAllo');
	var objChk = document.getElementsByName('chk');
	var objChk2 = document.getElementsByName('chkAllo');
	
	try { 
		if(objTbl==null || objChk==null)
			return;
	if(objChk.length==null || objChk.length==0){ //one row only
			if(objChk.checked || type==2){
			
			if(parseFloat(eval("document.frmNew.txtSNQty_"+objChk.value).value) > 0){
				alert("Cannot delete item " + eval("document.frmNew.txtPartNo_"+objChk.value).value +" , already SN");
			}else{
			
				var elinv1 = eval("document.frmNew.txtQty_"+objChk.value);
				if(elinv1!=null)
					elinv1.value="0";
					
				var elinv2 = eval("document.frmNew.txtConvertedUnitPrice_"+objChk.value);
				if(elinv2!=null)
					elinv2.value="0";
					
				var elinv3 = eval("document.frmNew.HidBase_ConvertedUnitPrice_"+objChk.value);
				if(elinv3!=null)
					elinv3.value="0";
					
				var elinv4 = eval("document.frmNew.txtConvertedAmount_"+objChk.value);
				if(elinv4!=null)
					elinv4.value="0";
					
				var elinv5 = eval("document.frmNew.txtDisc_"+objChk.value);
				if(elinv5!=null)
					elinv5.value="0";
				
				var elinv6 = eval("document.frmNew.HidBase_ConvertedAmount_"+objChk.value);
				if(elinv6!=null)
					elinv6.value="0";
					
				var elinv7 = eval("document.frmNew.txtTaxAmount1_"+objChk.value);
				if(elinv7!=null)
					elinv7.value="0";
					
				var elinv8 = eval("document.frmNew.txtTaxAmount2_"+objChk.value);
				if(elinv8!=null)
					elinv8.value="0";
				
				var elinv9 = eval("document.frmNew.txtSNQty_"+objChk.value);
				if(elinv9!=null)
					elinv9.value="0";
					
				var otr=objChk.parentNode.parentNode;
				otr.parentNode.removeChild(otr);
				
				var otr2=objChk2.parentNode.parentNode;
				otr2.parentNode.removeChild(otr2);
				document.frmNew.hidCountTransfer.value = parseInt(document.frmNew.hidCountTransfer.value) - 1;
			
			}
				
			}
		}else{
			var j=0;
			
			do {
				if(eval("document.frmNew.txtPartNo_"+objChk[j].value)){ 
					if(objChk[j].checked || type==2){
					
					if(parseFloat(eval("document.frmNew.txtSNQty_"+objChk[j].value).value) > 0){
						alert("Cannot delete item " + eval("document.frmNew.txtPartNo_"+objChk[j].value).value +" , already SN");
						j++;
					}else{
					
						var elinv1 = eval("document.frmNew.txtQty_"+objChk[j].value);
						if(elinv1!=null)
							elinv1.value="0";
							
						var elinv2 = eval("document.frmNew.txtConvertedUnitPrice_"+objChk[j].value);
						if(elinv2!=null)
							elinv2.value="0";
							

						var elinv3 = eval("document.frmNew.HidBase_ConvertedUnitPrice_"+objChk[j].value);
						if(elinv3!=null)
							elinv3.value="0";
							
						var elinv4 = eval("document.frmNew.txtConvertedAmount_"+objChk[j].value);
						if(elinv4!=null)
							elinv4.value="0";
							
						var elinv5 = eval("document.frmNew.txtDisc_"+objChk[j].value);
						if(elinv5!=null)
							elinv5.value="0";
							
						var elinv6 = eval("document.frmNew.txtDiscount2"+objChk[j].value);
						if(elinv6!=null)
							elinv6.value="0";
						//alert(j);
						
						var elinv7 = eval("document.frmNew.HidBase_ConvertedAmount_"+objChk[j].value);
						if(elinv7!=null)
							elinv7.value="0";
							
						var elinv8 = eval("document.frmNew.txtTaxAmount1_"+objChk[j].value);
						if(elinv8!=null)
							elinv8.value="0";
	
						var elinv9 = eval("document.frmNew.txtTaxAmount2_"+objChk[j].value);
						if(elinv9!=null)
							elinv9.value="0";
						
						var elinv10 = eval("document.frmNew.txtSNQty_"+objChk[j].value);
						if(elinv10!=null)
							elinv10.value="0";
							
						var otr=objChk[j].parentNode.parentNode;
						otr.parentNode.removeChild(otr);
						
						var otr2=objChk2[j].parentNode.parentNode;
						otr2.parentNode.removeChild(otr2);
						
						document.frmNew.hidCountTransfer.value = parseInt(document.frmNew.hidCountTransfer.value) - 1;
						
						}
						
						
					}else
						j++;
				}else
						j++;
			}
			while (j<objChk.length)

		
		}
	} catch(e){ 
		alert("#DO_VAR['AnErrorHasOccured']# #DO_VAR['WhenDeletingData']#"); 
	} 
	
	<cfif rbTypeDoc IS 3>
	  buildList();
	</cfif>
	
	document.frmNew.chkAll.checked = false;
	recalcTotal();
	getDiscountTotal();
	getFreeItemTotal();
	calculateTermOfPayment();
	
}



//updated by kelvin 29 Aug 08
function delRow_(tblID,type){
	objTbl = document.getElementById(tblID)
	objChk = document.getElementsByName('chk');
	var obj = objChk.length;
	
	if(type == 1){
		for (var i=objChk.length-1; i>=0; i--){
			if(objChk[i].checked){
				var len = parseInt (document.frmNew.hidTransfer.value) - 1;
				var delCount = 0;
				


				//mengambil semua nilai chk yg ada
				for (m=len; m>=0; m--){
					if(document.frmNew.chk[m]){
						if(document.frmNew.chk[m].value == objChk[i].value)//jika nilai chk sama dengan checkbox yg dipilih
						{
							var parent = document.frmNew.chk[m].value;
							
							//mengambil semua nilai chk yg ada
							for (k=len; k>=0; k--){
								var child = k + 1;
								if(eval ("document.frmNew.txtPartNo_" + parent)){
									
									if(eval ("document.frmNew.hid_parent_item_" + child)){
										
										if(eval ("document.frmNew.hid_parent_item_" + child).value == eval ("document.frmNew.txtPartNo_" + parent).value)//jika parent item-nya sama dengan item
											delCount = delCount + 1;
									}
								}
		
							}
						}
					}
				}
				
				for (del = 0; del < delCount; del++){

					if(objTbl.rows[i + 2])
					objTbl.deleteRow(i + 2);
				}
		
				if(objTbl.rows[i + 1])
				objTbl.deleteRow(i+1);
			}
		}
	}else{
		for (var i=objChk.length-1; i>=0; i--){ 
			objTbl.deleteRow(i+1) 
		}
	}
	frmNew.chkAll.checked = false;
	recalcTotal();
	calculateTermOfPayment();
}

 
/*
masih test - bisa dihapus
function setMemo(obj){

	frmNew.txtMemo.value = "sales Order: " + obj.options[obj.selectedIndex].text;
	frmNew.submit();
}
function prepaid(){
	if(frmNew.chkPrepaid.checked) document.getElementById('prepaidImg').style.visibility = 'visible';
	else document.getElementById('prepaidImg').style.visibility = 'hidden';
}*/


function checkDouble(){
   var curItem, duplicate;
   duplicate = false;
   for(i=1; i<=document.frmNew.rowCount.value; i++){
      if(eval("document.frmNew.txtPartNo_"+i)){
        curItem = eval("document.frmNew.txtPartNo_"+i).value;
				curDimensionItem = eval("document.frmNew.txtDimensionID_"+i).value;
				if(curParentItem!=null)
					curParentItem.value = i;
				
				if(eval("document.frmNew.chkwarna_"+i)){
					for(j=1; j<=document.frmNew.rowCount.value; j++){
						if(i!=j){
							if(eval("document.frmNew.txtPartNo_"+j)){
								tmpItem = eval("document.frmNew.txtPartNo_"+j).value;
								tmpItemparent = eval("document.frmNew.parent_path_"+j).value;
								tmpDimensionItem = eval("document.frmNew.txtDimensionID_"+j).value;
								
								if(curItem == tmpItem && curParentItem == tmpItemparent && curDimensionItem == tmpDimensionItem){
									duplicate = true
									break;
								}
							}
						}
					}
					
					if(duplicate) return true;
				}
      }
   }
    return false;
}	 	
function validateDouble(vcode,objParentPath,objDimensionID){
	if(document.getElementById("chk") == null || vcode == null)
		return false;
	var thechk = new Array();
	var duplicate = false;
	if(document.frmNew.chk.length != null)
		thechk = document.frmNew.chk;
	else
		thechk[0] = document.frmNew.chk;
	for (var i = 0; i < thechk.length; i++){
		if(!thechk[i].disabled){ // check only main item (in case of configure)
			var elitem1 = eval("document.frmNew.txtPartNo_"+thechk[i].value);
			var elParent1 = eval("document.frmNew.parent_path_"+thechk[i].value);
			var elDimension1 = eval("document.frmNew.txtDimensionID_"+thechk[i].value);
			
			if(elitem1 != null && elParent1 != null && elDimension1 != null){
				if(elitem1.value == vcode && elParent1.value == objParentPath && elDimension1.value == objDimensionID){
					duplicate = true;
					break;
				}
			}
		}
	}
	return duplicate;
}

function cekRevisi(){

	if(deletespaces(frmNew.txtRevisionReason.value).length == 0){
		alert('#Do_Var["ReasonMustBeFill"]#');
		return false;
	}else{
		passingVars();
	}
}

function passingVars(IsConfirm){
//	alert('test : ' + IsConfirm);

//	recalcTotal(0);  di comment karena bila perhitungan term dan total berbeda tidak bisa di save..BUG51211-45337
	var TblObj			= document.getElementById('tbl_ID');
	var NumOfRows		= TblObj.rows.length-1 // minus 1 because it's the header
	var TblObjTerm		= document.getElementById('tblPayment');
	var NumOfRowsTerm	= TblObjTerm.rows.length-1 // minus 1 because it's the header

//	CRF50912-07376 : add new claim deduction field --------------!-------------------
	var cd_amount		= document.forms[0].txt_cd_amount;
	var cd_desc			= document.forms[0].txt_cd_desc;

	<cfif val(qSetting.RemaingCreditRule) eq 1>
		if(parseFloat(document.frmNew.txtRemainingCredit.value) < 0){				
			alert("#DO_VAR['InsufficientCredit']#");
			return false;				
		}
	<cfelse>
		if(parseFloat(document.frmNew.txtRemainingCredit.value) < 0){				
			alert("#DO_VAR['InsufficientCredit']#");		
		}
	</cfif>

	var flagUD = 0;

	for(i = 1; i <= frmNew.hidTransferMisc.value; i++){
		if(eval("frmNew.selAllocationType"+i)){
			var AlloType = eval("frmNew.selAllocationType"+i).value;
			if(AlloType == 4){		
				flagUD++;
			}	
		}
	}

	if(flagUD > 0){
		var TotalMiscTemp = 0;
		for(i=1; i<=frmNew.hidTransferMisc.value;  i++){
			TotalMiscTemp = TotalMiscTemp + parseFloat(frmNew['txtConvertedAmountMisc2_'+i].value.split(",").join(""));
		}

		if(TotalMiscTemp > parseFloat(frmNew.txtTotMiscCharge.value.split(",").join(""))){
			alert('#DO_VAR['AmountAlloGtAmountMisc']#');
			return false;
		}
	}

	//RHP: item bisa diset dengan harga 0; gratis
	//andiJ, 17Mar'10: validate for qty > 0, and price > 0
	//if(NumOfRows>2){
		row = parseInt(document.forms[0].rowCount.value);
		//alert(row)
		for(r=1; r<=row; r++){
			if(document.getElementById('tr' + r)){
				if(eval("document.forms[0].txtQty_"+r) && eval("document.forms[0].txtConvertedUnitPrice_"+r)){
					if(eval("document.forms[0].txtQty_"+r).value < 1){
						alert("#DO_VAR['QtyGreatZero']#"); eval("document.forms[0].txtQty_"+r).focus(); return false;
					//}else if(eval("document.forms[0].txtConvertedUnitPrice_"+r).value < 1){
						//alert("#DO_VAR['PriceGreatZero']#"); eval("document.forms[0].txtConvertedUnitPrice_"+r).focus(); return false;
					}
					
					<!--- Custom Samick --->
					<cfif qSetting.EnableSORevision eq 1>
						
						if(parseFloat(eval("document.forms[0].txtQty_"+r).value)  < parseFloat(eval("document.forms[0].txtSNQty_"+r).value)  ) {
								//alert( eval("document.forms[0].txtPartNo_" + r).value +' : '+ parseFloat(eval("document.forms[0].txtQty_"+r).value) +' < ' + parseFloat(eval("document.forms[0].txtSNQty_"+r).value) );
								alert(eval('document.forms[0].txtPartNo_' + r).value + " #DO_VAR["LowerThanRsvQty"]#");
								return false;
							}
					</cfif>
				}
				
				
				if(validateDouble(eval('document.forms[0].txtPartNo_' + r).value, '', eval("document.forms[0].txtDimensionID_" + r).value)){
					alert("#DO_VAR['DoubleItem']# #DO_VAR['For']# " + eval('document.forms[0].txtPartNo_' + r).value + " #DO_VAR['And']# #DO_VAR['Dimension']# " + eval("document.forms[0].txtDimensionName_" + r).value);
					return false;
				}
			}
		}
	//}
	// end

	<cfif task neq "Edit">
	if(deletespaces(frmNew.txtCustName.value).length == 0){
		alert('#Do_Var["CustomerRequired"]#');
		return false;
	}
	</cfif>

	if(deletespaces(frmNew.txtSPCode.value).length == 0 || frmNew.txtSPCode.value =="0"){
		alert('#Do_Var["PleaseSelectSalesPerson"]#');
		return false;
	}else if(deletespaces(frmNew.txtSODate.value).length == 0){
		alert('#Do_Var["PleaseInputSODate"]#');

	}else if(!check_date(frmNew.txtSODate.value,"/")){
		alert ("#DO_VAR['InputValidDate']#");
		frmNew.txtSODate.select();
	}else if(new Date(frmNew.txtInvDueDate.value) < new Date(frmNew.txtSODate.value)){
		alert("#Do_Var["DueDate"]# #Do_Var["MustBe"]# #Do_Var["GreaterThen"]# #Do_Var["SalesOrderDate"]#");
		frmNew.txtInvDueDate.select();
	}else if(frmNew.SourceDate.value!="" && (new Date(frmNew.txtSODate.value) < new Date(frmNew.SourceDate.value))){
		alert("#Do_Var["SalesOrderDate"]# #Do_Var["MustBe"]# #Do_Var["GreaterThen"]# #Do_Var["DocSourceDate"]#");
		frmNew.txtInvDueDate.select();		
	}	
	<!---<cfif task eq "Save">
		else if(new Date(frmNew.txtInvDueDate.value) < new Date(frmNew.txtSODate.value) && document.frmNew.txtSOtype[0].checked == true){
			alert ("#Do_Var["InvoiceMustGreater"]#");
			frmNew.txtInvDueDate.select();
		}
	</cfif>--->

	/*
	else if(frmNew.txtTotAmount.value == 0){
		alert('#Do_Var["Tot_AmountMustGreater"]#');
		frmNew.txtTotAmount.focus();
	}*/
	else if(NumOfRows<1){
		alert('#Do_Var["PleaseSelectItem"]#');
	}
	else if(NumOfRowsTerm < 1){
		alert('#Do_Var["Add"]# #Do_Var["Payment"]#!');
	}
	else if(!chkPPN()){
		alert('#Do_Var["Choose"]# PPN!');
		//comment by Angries 20101025 BUG51010-23324 because error js can't focus tp the control because it is invisible, not enabled,etc
		//document.frmNew.ddlTaxIncluded.focus();
	}
	else if(frmNew.txtProMonth.value == ""){
		alert('Please Select Production Month');
		frmNew.txtProMonth.focus();
		
	}
	else if(frmNew.txtProYear.value == ""){
		alert('Please Select Production Year');
		frmNew.txtProYear.focus();
		
	}
	else if(frmNew.txtPiNumber.value == ""){
		alert('Please enter PI Number');
		frmNew.txtPiNumber.focus();
		
	}
	else if(chkPaymentTerm()){
		if(!validateETA()){
			alert('#Do_Var["PleaseSet"]# #Do_Var["DeliveryDate"]#');
			return false;
		}

		for(i=1;i<=document.frmNew.hdnTerm.value;i++){
			if(new Date(eval("document.frmNew.txtDueDate"+i).value) < new Date(eval("document.frmNew.txtInvoiceDate"+i).value)){
				alert('#DO_VAR["InvoiceDueDatemustbegreaterthanInvoiceDate"]#');
				return false;
			}	
		}

		for(idx=1; idx<=NumOfRows; idx++){
			if(eval("document.frmNew.txtEstimateDate_"+idx)){
				var DateTo = eval("document.frmNew.txtEstimateDate_"+idx)//frmNew['txtEstimateDate_'+idx]
	
				if(new Date(DateTo.value) < new Date(document.forms[0].txtSODate.value)){
					alert("#DO_VAR["SODateMustEarlierThanEstDate"]#");
					return false;
				}
			}
		} 

	<!--- Validasi Misc --->
		var stat			= 0;
		var countMisc		= eval("document.frmNew.hidTransferMisc").value;
		var countMiscDetail	= eval("document.frmNew.hidTransfer").value;
		var totalMisc		= parseFloat(eval("document.frmNew.txtTotMiscCharge").value);
		var totalAllo		= 0;

		if(countMisc != 0){
			for(j=1;j<=countMiscDetail;j++){
				if(frmNew['txtConvertedAmountMisc2_'+j]!=null){
					var Amount_ = frmNew['txtConvertedAmountMisc2_'+j].value.split(",").join("");
					var totalAllo = totalAllo + parseFloat(Amount_);
				}
			}
		}

		if(Round2Decimal(totalAllo) != Round2Decimal(totalMisc) && countMisc != 0){
			alert ("#DO_VAR['AmountMiscGtTotalMisc']#");
			return false;
		}
		else{
			if(isLock(document.frmNew.txtSODate) == true){
			//	b:CRF50912-07376 : add new claim deduction field --------------!-------------------
				if(isNaN(cd_amount.value.split(',').join(''))){
					alert('Claim Deduction amount must be in numeric');
					cd_amount.value = 0;
					cd_amount.focus();

					return false; // auto break, will not continue to process the logic below
				}
				else{
					if(parseFloat(cd_amount.value.split(',').join('')) > 0 && cd_desc.value == ''){
						alert('Please input Claim Deduction description');
						cd_desc.focus();
						return false; // auto break, will not continue to process the logic below
					}
				}
			//	e:CRF50912-07376 : add new claim deduction field --------------!-------------------

				if(eval("document.forms[0].btnSubmit"))
				frmNew.btnSubmit.disabled = true;
				if(eval("document.forms[0].btnConfirm"))
				frmNew.btnConfirm.disabled = true;
				frmNew.chkKawasan.disabled = false;
				
				frmNew.hidCurrRow.value = document.frmNew.rowCount.value;
				frmNew.txtconfirm.value = IsConfirm;

				frmNew.action = '#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/sales/so/queries/qadd.cfm?' + 
								'<cfif task eq "Edit">SONum=#SONum#</cfif>';
				frmNew.submit();
			}
		}
	}
}

function reload_page(){
	var countMisc = document.frmNew.hidCountMisc.value;
	if(countMisc > 0){
			showAllocation(1);
	}else{
			showAllocation(0);
	}
	
	if(frmNew.selQuotation.value!="" && isLock(document.frmNew.txtSODate) == true){
		<cfset vartemplate = "index.cfm">
		<cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785402&menu=1">	
		frmNew.action = '#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&selCatType=#selCatType#';
		frmNew.method = 'post';
		frmNew.submit();
	}
	
	if(frmNew.selProforma.value!="" && isLock(document.frmNew.txtSODate) == true){
		<cfset vartemplate = "index.cfm">
		<cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785402&menu=1">	
		frmNew.action = '#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&selCatType=#selCatType#';
		frmNew.method = 'post';
		frmNew.submit();
	}
	
	if(frmNew.ddlSalesContract.value!="" && isLock(document.frmNew.txtSODate) == true){
		<cfset vartemplate = "index.cfm">
		<cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785402&menu=1">	
		frmNew.action = '#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&selCatType=#selCatType#';
		frmNew.method = 'post';
		frmNew.submit();
	}
}
	
function ItemLookUp(thisobj){
	var TblObj = document.getElementById('tbl_ID');
	if(thisobj.value == 'barcode') 
		TblObj.firstChild.firstChild.cells[1].innerHTML = 'BarCode'
	else if(thisobj.value == 'itemcode')
		TblObj.firstChild.firstChild.cells[1].innerHTML = 'Item Code'
}

function validateETA(){

	for (var idx=1; idx<=document.frmNew.rowCount.value; idx++){
		<!--- vobj=document.getElementById("txtEstimateDateSplit_" + idx); --->
		vobj=eval("document.forms[0].txtEstimateDateSplit_" + idx);
		if(vobj!=null){
			<!--- var obj = document.getElementById("txtEstimateDateSplit_" + idx).value; --->
			var obj = eval("document.forms[0].txtEstimateDateSplit_" + idx).value;
			<!--- var objQty = document.getElementById("txtQty_" + idx).value.split(",").join(""); --->
			var objQty = eval("document.forms[0].txtQty_" + idx).value.split(",").join("");
//			alert(obj);
		if(obj!=""){
			var arr = obj.split(",");
			var qty = 0;
			for (var counter=0;counter < arr.length;counter++){
				if(arr[counter].split("|").length==2){
					qty = qty + parseFloat(arr[counter].split("|")[1]);
				}
			}
			if(objQty != qty){
					<!--- document.getElementById("txtQty_" + idx).focus();
					document.getElementById("txtQty_" + idx).select(); --->
					eval("document.forms[0].txtQty_" + idx).focus();
					eval("document.forms[0].txtQty_" + idx).select();
					alert('#DO_VAR['QtyPurchaseAndReceivedNotEqual']#');
				return false;
			}
		}
	}
	}
	return true;

}

//Setting Currency ex. (IDR), (USD)

<!--- Event Pricing --->
<!--- <script type="text/javascript"> --->
	var eventItems = new Array();
	function addItemEvent(params){
		eventItems.push(params);
		//alert(eventItems[eventItems.length -1]);
		<!--- format = {item_code, qty, price, } --->
	}

<cfquery name="qEvents" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	select * from tacceventpricing ep
	inner join tacceventpricing_wh epwh on ep.event_id = epwh.event_id
	where epwh.wh_id = #cookie.location_id#
	and status = 1 and company_id = #cookie.companyid#
</cfquery>

	// FUNGSI Event Pricing
	var events = new Array();
	<cfloop query="qEvents">
		events[#event_id#] = new Array();
		events[#event_id#]['name'] = '#event_name#';
		events[#event_id#]['start'] = new Date('#dateformat(event_start,"mm-dd-yyyy")#');

		events[#event_id#]['end'] = new Date('#dateformat(event_end,"mm-dd-yyyy")#');
	</cfloop>
	//alert(events[1]['start'] + ' to ' + events[1]['end']); --->
</script>
<!---<cfquery name="FormAdd" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#" dbtype="ODBC">
	SELECT * FROM TDO_ACTION
    WHERE Action_ID=2051
</cfquery>
<CF_DO_V25_PARAMPARSE QUERY_NAME="#FormAdd#">--->



<script>

function chkPPN(){
//modified by Angries 20101025 BUG51010-23324 dikasih kondisi karena pembacaan dari SO Contract tidak ada radio button
	<cfif rbTypeDoc IS 3>
		return true;
	<cfelse>
		 for (var xtc = 0; xtc < document.frmNew.txtSOtype.length; xtc++){
			if(document.frmNew.txtSOtype[xtc].checked){
			  if(document.frmNew.txtSOtype[xtc].value == 0) // IF DOCUMENT IS VAT INCLUDE
			  {
				if(document.frmNew.ddlTaxIncluded.value == "0|0"){
				  return false;
				}else{
				  return true;
				}
			  }else{
				return true;
			  }
			  
			  break;
			}
		  }
	</cfif>
}

function setCurrTax(){
    frm = document.frmNew;
	var theCurrency = frm.selTaxCurrency.options[frm.selTaxCurrency.selectedIndex].value;
	 
	document.getElementById('idTotalTax').innerHTML = "#DO_VAR['TotalTax']# " + "(" + theCurrency + ")";
	document.getElementById('idTotalDeduction').innerHTML = "#DO_VAR['TotalDeduction']# " + "(" + theCurrency + ")";
}

<cfquery name="qCurrConvert" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 		TCurrencyConverter.Currency_id_1,
				TCurrencyConverter.Currency_id_2,
				TCurrencyConverter.Scale,
                TCurrencyConverter.start_date
	FROM 		TCurrencyConverter
	WHERE 		TCurrencyConverter.Status = 1
	AND			TCurrencyConverter.Company_ID = '#Cookie.CompanyID#'
</cfquery>

//masukin semua Currency Rate untuk item ke dalam javascript
var ArrCurrItem = new Array();

<cfloop index="id" from="1" to="#qCurrConvert.RecordCount#">

    ArrCurrItem[#evaluate(id-1)#] = new Array();

	ArrCurrItem[#evaluate(id-1)#]['CurrIDFrom'] = "#UCase(qCurrConvert.Currency_id_1[id])#"  
	ArrCurrItem[#evaluate(id-1)#]['CurrIDTo'] = "#UCase(qCurrConvert.Currency_id_2[id])#"  
	ArrCurrItem[#evaluate(id-1)#]['CurrRateItem'] = "#qCurrConvert.Scale[id]#"  
    ArrCurrItem[#evaluate(id-1)#]['CurrStartDate'] = "#dateformat(qCurrConvert.Start_date[id],'mmmm d, yyyy')#"  
</cfloop>

<!--- add by AN  --->
function convertCL(){
    
	baseCurrency = '#cookie.currencyid#';
	SOCurrency = document.frmNew.selCurrency.options[document.frmNew.selCurrency.selectedIndex].value;
	objCL = document.frmNew.baseCreditLimit;
	newobjCL = document.frmNew.txtcreditlimit;
	objInvNotPaid  = document.frmNew.baseInvNotPaid;
	newobjInvNotPaid  = document.frmNew.txtInvNotPaid;
	objSOApproved = document.frmNew.baseSOApproved;
	newobjSOApproved = document.frmNew.txtSOApproved;
	objRemainingCredit = document.frmNew.baseRemainCredit;
	newobjRemainingCredit = document.frmNew.txtRemainingCredit;

	//alert (newobjRemainingCredit.value + '==>1');
	
    
	for (x=0; x<ArrCurrItem.length; x++){
		//alert("( "+ArrCurrItem[x]['CurrIDFrom']+" == "+baseCurrency+" ) && ( "+ArrCurrItem[x]['CurrIDTo']+" == "+SOCurrency+" ) && ( "+new Date(ArrCurrItem[x]['CurrStartDate'])+" < "+new Date(document.frmNew.txtSODate.value)+" ) ")
		if((ArrCurrItem[x]['CurrIDFrom'] == baseCurrency) && (ArrCurrItem[x]['CurrIDTo'] == SOCurrency) && (new Date(ArrCurrItem[x]['CurrStartDate']) < new Date(document.frmNew.txtSODate.value))){ 
			Rate = ArrCurrItem[x]['CurrRateItem'];
			
			newobjCL.value = Rate * parseFloat(objCL.value.split(',').join(''));
			newobjInvNotPaid.value = Rate * parseFloat(objInvNotPaid.value.split(',').join(''));

			newobjSOApproved.value = Rate * parseFloat(objSOApproved.value.split(',').join(''));
			newobjRemainingCredit.value = Rate * parseFloat(objRemainingCredit.value.split(',').join(''));			
			//alert (newobjRemainingCredit.value + '==>2');
			//predecimalin(newobjCL);

			//predecimalin(newobjInvNotPaid);
			//predecimalin(newobjSOApproved);
			//predecimalin(newobjRemainingCredit);
			document.getElementById('creditLimit').innerHTML = newobjCL.value;
			document.getElementById('InvNotPaid').innerHTML = newobjInvNotPaid.value;
			document.getElementById('SOApproved').innerHTML = newobjSOApproved.value;
			document.getElementById('RemainingCredit').innerHTML = newobjRemainingCredit.value;
			
			break;
		}
	}
		
	//alert (objRemainingCredit.value);
	
}

function setCurr(){
    frm = document.frmNew;
	var theCurrency = frm.selCurrency.options[frm.selCurrency.selectedIndex].value;
	//document.getElementById('idUnitPrice').innerHTML = "(" + theCurrency + ")";
       document.getElementById('idUnitPrice').innerHTML = "(" + theCurrency + ")";

	document.getElementById('idAmount').innerHTML = "(" + theCurrency + ")";
	document.getElementById('idTotalAmount').innerHTML = "#DO_VAR['TotalAmount']# " + " (" + theCurrency + ")";
	document.getElementById('idcreditLimit').innerHTML = "(" + theCurrency + ")";
	document.getElementById('idInvNotPaid').innerHTML = "(" + theCurrency + ")";
	document.getElementById('idSOApproved').innerHTML = "(" + theCurrency + ")";
	document.getElementById('idRemainingCredit').innerHTML = "(" + theCurrency + ")";
	convertCL(); 
	 
	document.getElementById('idGrandTotal').innerHTML = "#DO_VAR['GrandTotal']# " + "(" + theCurrency + ")";
}
</script>
</head>
<body onUnload="doCloseChild(arrNewPop)" onLoad="callselCOA();">
<div id="divLookup" style="width:500px;height:200px;position:absolute;display:none;border:2px solid black;background-color:white;z-index:1000;overflow:auto">
  <table border="0" align="center" width="100%" id="tblLookup" style="display: ;" class="formtext">
    <tr>
      <td id="tblLookupHeader" align="center" style="border-bottom: ##036 dotted thin; font-weight: bold;"></td>
    </tr>
    
    <tr>
      <td align="center" valign="top">
        <div id="lblProgress" style="display: none;"><img
         src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/green_rot.gif" /><br 
         /><span id="txtLabel" style="color: ##66CC00"><b>loading...</b></span></div>
        
        <div id="lblError" style="display: none;"></div>
        
        <div id="divLookupContent" style="display: none;">
		<!--- [## AJAX GENERATED FIELD] --->
        </div>
      </td>
    </tr>
    
    <tr>
      <td id="tblLookupButton" align="center" style="border-top: ##036 dotted thin;"></td>
    </tr>
  </table>
</div>

<cfset vartemplate = "index.cfm">
<cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785402&menu=1">	
<form name="frmNew" action="" method="post">
<cfif task eq "Edit"><input type="Hidden" name="SONUM" value="#SONUM#"></cfif>

<input type="Hidden" name="task" 	value="#task#">
<input type="Hidden" name="txtDiscID" 	value="">
<input type="Hidden" name="selCatType" value="#selCatType#">
 
<table width="100%" align="center" class="formtitle" cellpadding="1" border="0">
<tr>
	<td><IMG src="#Application.stApp.Upload_Path[1]#/doadminsite/money2.gif" width="18" height="18" border="0" alt="">#DO_VAR['sales']# | #DO_VAR['SalesOrder']# | <cfif selCatType eq "FG">#DO_VAR["FinishedGood"]# <cfelseif selCatType eq "RM">#DO_VAR["RawMaterial"]# <cfelseif selCatType eq "AST">#Do_Var["Asset"]# <cfelseif selCatType eq "SP">#Do_Var["SparePart"]# </cfif>| 
		<cfif task eq "Edit">#DO_VAR['Edit']#<cfelse>#DO_VAR['New']#</cfif>
	</td>
	<cfif task eq "Edit" and qSales.ReviseCounter gte 1>
		<td align="right">
			<font color="##FF0000"><strong>
				<em>Revised [#qSales.ReviseCounter#] - Approval Status = 
				<cfif qSales.Approval_Status eq 0>
					#DO_VAR['New']#
				<cfelseif qSales.Approval_Status eq 1>
					#DO_VAR['Checked']#
				<cfelseif qSales.Approval_Status eq 2>
					#DO_VAR['Awaiting']#
				<cfelseif qSales.Approval_Status eq 3>
					#DO_VAR['Approved']#
				<cfelseif qSales.Approval_Status eq 4>
					#DO_VAR['Rejected']#
				<cfelseif qSales.Approval_Status eq 5>
					#DO_VAR['Revising']#
				</cfif></em>
			</strong></font>
		</td>
	<cfelse>
		 <td>&nbsp;</td>
	</cfif>
</tr>
<tr>
	<td colspan="2">
		<table width="100%" border="0" align="center" class="formbody">
		<tr>
			<td width="50%" valign="top">
				<table class="formtext" border="0" width="100%">
				<tr height="22">
					<td id="SO_FOC_Label" nowrap>#DO_VAR["SO_Number"]#</td>
					<cfset objNewUnitPrice = "">					
					<td>: </td>
					<td id="SO_FOC_Pattern"><b>#txtSONum#</b></td>
				</tr>
				<tr>
					<td>#DO_VAR["SOTaxType"]#</td>			
					<td valign="middle">:</td>
					<td align="Left">
					<cfif rbTypeDoc IS 3>
                      <cfif local.tmpDocType IS 0>
                        <input type="hidden" name="txtSOtype" id="txtSOtype" value="0" checked />#DO_VAR["TaxIncludedInPrice"]#
                      <cfelse>
                        <input type="hidden" name="txtSOtype" id="txtSOtype" value="1" checked />#DO_VAR["Normal"]#
                      </cfif>
                    <cfelse>
                    	<input type="Radio" name="txtSOtype" id="txtSOtype" value="1" onClick="SO_Switcher(this);" <cfif(task eq "save" and qDetail.SOtype eq 1) or (task eq "save" and qDetail.RecordCount eq 0)>checked<cfelseif task eq "Edit"><cfif qSales.SOType eq 1>checked</cfif></cfif> /> #DO_VAR["Normal"]# &nbsp;
						<input type="Radio" name="txtSOtype" id="txtSOtype" value="0" onClick="SO_Switcher(this);" <cfif task eq "save" and qDetail.SOtype eq 0>checked<cfelseif task eq "Edit"><cfif qSales.SOType eq 0>checked</cfif></cfif> /> #DO_VAR["TaxIncludedInPrice"]#
                    </cfif>
                    </td>
				</tr>
                
                <!--- IVN : 23 April 2010
				Add PPN Selection for VAT --->
                <tr id="trIncludedPPN" style="display: #Iif(local.tmpDocType IS 0, DE(''), DE('none'))#;">
                  <td>#DO_VAR['IncludedPPN']# *</td>
                  <td>:</td>
                  <td><cfscript>
					obj = createObject("component", "#Application.ComponentPath#.sunfisherp.setup.setupglobalsetting");
					objDummy = createObject("component", "#Application.ComponentPath#.sunfisherp.utility.cfdummy");
					
					try
					{
					  dtsTaxInclude = obj.getTax(varIncluded: true);
					}
					catch(Any err){
					  objDummy.cfdump(err.message);
					}
				  </cfscript>
                  
				  <cfif rbTypeDoc IS 3>
					<cfif local.tmpDocType eq 0>
                      <cfif dtsTaxInclude.recordcount>

                        <cfloop query="dtsTaxInclude">
                          <cfif local.tmpVatTaxCode EQ dtsTaxInclude.Tax_Code>
                            #dtsTaxInclude.Tax_Code#<input type="hidden" class="inplabel" readonly="readonly"
                             name="ddlTaxIncluded" id="ddlTaxIncluded" value="#dtsTaxInclude.Tax_Code#|#dtsTaxInclude.Tax_Rate#" />
                          </cfif>
                        </cfloop>
                      <cfelse>
                        -<input type="hidden" class="inplabel" readonly="readonly"
                         name="ddlTaxIncluded" id="ddlTaxIncluded" value="0|0" />
                      </cfif>

                    <cfelse>
                      -<input type="hidden" class="inplabel" readonly="readonly"
                       name="ddlTaxIncluded" id="ddlTaxIncluded" value="0|0" />
                    </cfif>

                  <cfelse>
                    <select name="ddlTaxIncluded" id="ddlTaxIncluded" onChange="calcTax();">
                      <option value="0|0">-&nbsp;Select&nbsp;-</option>
                      
                      <cfif dtsTaxInclude.recordcount>
                        <cfloop query="dtsTaxInclude">
                          <option value="#dtsTaxInclude.Tax_Code#|#dtsTaxInclude.Tax_Rate#"
                          <cfif task EQ "save" AND qDetail.VAT_Tax_Code EQ dtsTaxInclude.Tax_Code>
                            SELECTED

                          <cfelseif task EQ "edit" AND qSales.VAT_Tax_Code EQ dtsTaxInclude.Tax_Code>
                            SELECTED
                          </cfif>
                          >#dtsTaxInclude.Tax_Code#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </cfif></td>
                </tr>
                
				<tr>
					<td>#DO_VAR['ProjectName']#</td>
					<td>:</td>
					<td>
						<!--- <select name="selProject" onChange="checkRow(this);">
							<option value="0">#DO_VAR['PleaseSelectProject']#</option>
							<cfloop query="qGetProject">
								<option title="#qGetProject.Project_Code# #CHR(13)# Project Name : #qGetProject.Project_Name# #CHR(13)# #qGetProject.Account_Name#" value="#qGetProject.Project_ID#" <cfif selProject eq qGetProject.Project_ID>selected</cfif>>#qGetProject.Project_Code# - #qGetProject.Project_Name#</option>
							</cfloop>
						</select> --->
						<cfif task eq "save">
	                        <input name="selProject" id="selProject" type="text" 
	                        onKeyUp="switched('Project',this)" size="25" 
	                        maxlength="25" onClick="switched('Project',this)" 
	                        onKeyPress="return onEnter(event);" value="#selProject#">
	                        <a style="cursor:pointer" onClick="setObjField('selProject','divAjaxLookupProject'); onEvent();" title="GO">
	                        	<IMG src="#Application.stApp.Web_Path[1]#/images/quicksearch.jpg"
	                            alt="#DO_VAR['SEARCH']#" border="0" width="18" height="18" />
	                        </a>
	                        <br>
	                        <DIV id="divAjaxLookupProject" 
							style="width:500px;height:200px;position:absolute;display:none;border:2px solid black;background-color:white;z-index:1000;overflow:auto"></DIV>

						<cfelse>
							#selProject#
							<input type="hidden" name="selProject" value="#selProject#" readonly />
						</cfif>
                    </td>
				</tr>
				<tr>
					<td>#DO_VAR["AllocateTo"]#</td>
					<td>:</td>
					<td>
						<input type="radio" name="rdoAllocate" value="0" onClick="changeType(this);" <cfif rdoAllocate eq 0>checked</cfif>>#DO_VAR['ProjectComponent']#
						&nbsp;&nbsp;
						<input type="radio" name="rdoAllocate" value="1" onClick="changeType(this);" <cfif rdoAllocate eq 1>checked</cfif>>#DO_VAR['CostCenter']#					</td>
				</tr>
				 
				 <tr valign="top">
					<td>#DO_VAR['DocSource']#</td>			
					<td valign="top">:</td>
					<td>
                           

						<cfif task eq "save">
								<input type="Radio" name="rbTypedoc" value="0" <cfif rbTypedoc eq 0>checked</cfif> onClick="cleardata();document.frmNew.submit();"> #DO_VAR['Quotation']#
								<input type="Radio" name="rbTypedoc" value="2" <cfif rbTypedoc eq 2>checked</cfif> onClick="cleardata();document.frmNew.submit();"> #DO_VAR['ProformaInvoice']#
								<input type="Radio" name="rbTypedoc" value="3" <cfif rbTypedoc eq 3>checked</cfif> onClick="cleardata();document.frmNew.submit();"> #DO_VAR['SalesContract']#
								
								<cfif rbTypedoc eq 0>
									<cfquery name="qGetDocSourceDate" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">

										SELECT * from TACCQUOTATION_HEADER
										WHERE quotation_number = '#selQuotation#'
									</cfquery>
									<cfset SourceDate = "#DateFormat(qGetDocSourceDate.Quotation_Date, 'mm/dd/yyyy')#">
								<cfelseif rbTypedoc eq 2>
									<cfquery name="qGetDocSourceDate" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
										SELECT * from taccpi_header
										WHERE pi_number = '#selProforma#'
									</cfquery>
									<cfset SourceDate = "#DateFormat(qGetDocSourceDate.PI_Date, 'mm/dd/yyyy')#">
								<cfelseif rbTypedoc eq 3>
									<cfquery name="qGetDocSourceDate" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
										SELECT * from TACCSALESCONTRACT_HEADER
										WHERE sc_number = '#local.tmpSCNumber#'
									</cfquery>
									<cfset SourceDate = "#DateFormat(qGetDocSourceDate.SC_Date, 'mm/dd/yyyy')#">
								</cfif>

								<br>
								<br> <!--- after reload calcAmountAll() may not be loaded --->

								<DIV id="DivQuotation" <cfif rbTypedoc eq 0>style="display: ;"<cfelse>style="display: none;"</cfif>>
									<input name="selQuotation" id="selQuotation" type="text" 
									onKeyUp="switched('Quo',this)" size="25" 
									maxlength="25" onClick="switched('Quo',this)" 
									onKeyPress="return onEnter(event);" value="#selQuotation#">
									<a style="cursor:pointer" onClick="setObjField('selQuotation','divAjaxLookupQuo'); onEvent();" title="GO">
										<IMG src="#Application.stApp.Web_Path[1]#/images/quicksearch.jpg" 
										alt="#DO_VAR['SEARCH']#" border="0" width="18" height="18" />
									</a>
									<br>
									<DIV id="divAjaxLookupQuo" 
									style="width:500px;height:200px;position:absolute;display:none;border:2px solid black;background-color:white;z-index:1000;overflow:auto">
									</DIV>
								</DIV>
							<cfif selQuotation neq "">
								<font color="red"><i>[#DO_VAR['DocSourceDate']# : #DateFormat(SourceDate, 'dd mmm yyyy')#]</i></font>
							</cfif>			
								
								
								<!--- <select id="selQuotation" name="selQuotation" onChange="document.frmNew.btnSubmit.disabled=true;reload_page();calcAmountAll();" <cfif rbTypedoc eq 0>style="display: ;"<cfelse>style="display: none;"</cfif>>
									<option value="0"<cfif selQuotation eq 0>selected</cfif>>..::[#DO_VAR['eHRMNone']#]::..
									<cfloop query="qQuotation">
										<option title="#Quotation_Number# #CHR(13)# #DateFormat(Quotation_Date,'mm/dd/yyyy')# #CHR(13)# #Account_Name#" value="#Quotation_Number#" <cfif selQuotation eq Quotation_Number>Selected</cfif>>#Quotation_Number# (#Account_name#)
									</cfloop>
								</select> --->
								
								<select id="selPro" name="selPro" onChange="if(eval('document.forms[0].btnSubmit'))document.frmNew.btnSubmit.disabled=true;reload_page();calcAmountAll();" <cfif rbTypedoc eq 1>style="display: ;"<cfelse>style="display: none;"</cfif>>
									<option value="0"<cfif selPro eq 0>selected</cfif>>..::[#DO_VAR['eHRMNone']#]::..
									<cfloop query="qPro">
										<option title="#project_Code# #CHR(13)# #project_Name# #CHR(13)# #Account_Name#" value="#project_Code#" <cfif selPro eq project_Code>Selected</cfif>>#project_Code# - #project_Name#
									</cfloop>
								</select>
								
								<DIV id="DivProforma" <cfif rbTypedoc eq 2>style="display: ;"<cfelse>style="display: none;"</cfif>>
									<input name="selProforma" id="selProforma" type="text" 
									onKeyUp="switched('Proforma',this)" 
									size="25" maxlength="25" 
									onClick="switched('Proforma',this)" 
									onKeyPress="return onEnter(event);" value="#selProforma#">
									<a style="cursor:pointer" onClick="setObjField('selProforma','divAjaxLookupProforma'); onEvent();" title="GO">
										<IMG src="#Application.stApp.Web_Path[1]#/images/quicksearch.jpg" 
										alt="#DO_VAR['SEARCH']#" border="0" width="18" height="18" />
									</a>
									<br>
									<DIV id="divAjaxLookupProforma" style="width:500px;height:200px;position:absolute;display:none;border:2px solid black;background-color:white;z-index:1000;overflow:auto"></DIV>
								</DIV>
								<cfif selProforma neq ""><font color="red"><i>[#DO_VAR['DocSourceDate']# : #DateFormat(SourceDate, 'dd mmm yyyy')#]</i></font></cfif>							
								<!--- <select id="selProforma" name="selProforma" onChange="document.frmNew.btnSubmit.disabled=true;reload_page();calcAmountAll();" <cfif rbTypedoc eq 2>style="display: ;"<cfelse>style="display: none;"</cfif>>
									<option value="0"<cfif selProforma eq 0>selected</cfif>>..::[#DO_VAR['eHRMNone']#]::..
									<cfset n=0>
									<cfloop query="qProformaInvoice">
										<option title="#pi_number# #CHR(13)# #pi_Date# #CHR(13)# #Account_Name#" value="#pi_number#" <cfif selProforma eq pi_number>Selected</cfif>>#pi_number# (#Account_Name#)
									</cfloop>
								</select> --->
								
								<DIV id="DivSalesContract" style="display: #Iif(rbTypedoc eq 3, DE(''), DE('none'))#;">
									<input name="ddlSalesContract" id="ddlSalesContract" type="text" 
									onKeyUp="switched('SalesContract',this)" size="25" maxlength="25" 
									onClick="switched('SalesContract',this)" 
									onKeyPress="return onEnter(event);" value="#local.tmpSCNumber#">
									<a style="cursor:pointer" onClick="setObjField('ddlSalesContract','divAjaxLookupSalesContract'); 
									onEvent();" title="GO">
										<IMG src="#Application.stApp.Web_Path[1]#/images/quicksearch.jpg" 
										alt="#DO_VAR['SEARCH']#" border="0" width="18" height="18" />
									</a>
									<br>
									<DIV id="divAjaxLookupSalesContract" style="width:500px;height:200px;position:absolute;display:none;border:2px solid black;background-color:white;z-index:1000;overflow:auto"></DIV>
								</DIV>
							<cfif ddlSalesContract neq ""><font color="red"><i>[#DO_VAR['DocSourceDate']# : #DateFormat(SourceDate, 'dd mmm yyyy')#]</i></font></cfif>
								<!--- <select name="ddlSalesContract" id="ddlSalesContract"
								onChange="document.frmNew.btnSubmit.disabled=true;reload_page();calcAmountAll();" 
								style="display: #Iif(rbTypedoc eq 3, DE(''), DE('none'))#;">
								<option value="0" #Iif(local.tmpSCNumber EQ 0 OR local.tmpSCNumber EQ "", DE('selected'), DE(''))#>..::[#DO_VAR['eHRMNone']#]::..</option>
								<cfset n=0>
								
								<cfloop index="xtc" from="1" to="#qSelectSalesContract.recordcount#">
									<option value="#qSelectSalesContract.SC_Number[xtc]#"
									#Iif(local.tmpSCNumber EQ qSelectSalesContract.SC_Number[xtc], DE('selected'), DE(''))#
									>#qSelectSalesContract.SC_Number[xtc]#&nbsp;(#qSelectSalesContract.Account_Name[xtc]#)						
								</cfloop>
								</select> --->
						<cfelse>
						
							<cfif qSales.Quotation_number neq 0 AND len(trim(qSales.Quotation_number))>
								#qSales.Quotation_Number# &nbsp;<font color="red"><i>[#DO_VAR['DocSourceDate']# : #DateFormat(qQuotation.quotation_date, 'dd mmm yyyy')#]</i></font>
								<input type="Hidden" name="SelQuotation" value="#qSales.Quotation_Number#">
								<cfquery name="qGetDocSourceDate" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
									SELECT * from TACCQUOTATION_HEADER
									WHERE quotation_number = '#selQuotation#'
								</cfquery>
 								<cfset SourceDate = "#DateFormat(qGetDocSourceDate.Quotation_Date, 'mm/dd/yyyy')#">
							<cfelseif qSales.project_code neq 0 AND len(trim(qSales.project_code))>
								#qSales.project_code#
								<input type="Hidden" name="SelPro" value="#qSales.project_code#">
							<cfelseif qSales.proforma_number neq 0 AND len(trim(qSales.proforma_number))>
								#qSales.proforma_number# &nbsp;<font color="red"><i>[#DO_VAR['DocSourceDate']# : #DateFormat(qProformaInvoice.PI_Date, 'dd mmm yyyy')#]</i></font>
								<input type="Hidden" name="selProforma" value="#qSales.proforma_number#">
								<cfquery name="qGetDocSourceDate" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
									SELECT * from taccpi_header
									WHERE pi_number = '#selProforma#'
								</cfquery>
			    				<cfset SourceDate = "#DateFormat(qGetDocSourceDate.PI_Date, 'mm/dd/yyyy')#">
							<cfelseif qSales.SC_Number NEQ 0  AND len(trim(qSales.SC_Number))>
								#qSales.SC_Number# &nbsp;<font color="red"><i>[#DO_VAR['DocSourceDate']# : #DateFormat(qSelectSalesContract.SC_Date, 'dd mmm yyyy')#]</i></font> 
								<input type="Hidden" name="ddlSalesContract" value="#qSales.SC_Number#">
								<cfquery name="qGetDocSourceDate" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
									SELECT * from TACCSALESCONTRACT_HEADER
									WHERE sc_number = '#ddlSalesContract#'
								</cfquery>
			    				<cfset SourceDate = "#DateFormat(qGetDocSourceDate.SC_Date, 'mm/dd/yyyy')#">
                            <cfelse>
									-- #DO_VAR['NoQuotation']#--
									<input type="Hidden" name="SelQuotation" value="">
									<input type="Hidden" name="SelPro" value="0">
									<input type="Hidden" name="selProforma" value="">
                                    <input type="Hidden" name="ddlSalesContract" value="">
									<cfset SourceDate = "">
							</cfif>
                            
							<cfif rbTypedoc eq 0>
                            <input type="hidden" name="rbTypedoc" value="0" />
							<cfelseif rbTypedoc eq 1 AND (selPro neq 0 OR Len(Trim(selProject)) NEQ 0)>
							<input type="hidden" name="rbTypedoc" value="1" />
                            <cfelseif rbTypedoc eq 2>
                            <input type="hidden" name="rbTypedoc" value="2" />
                            <cfelseif rbTypedoc eq 3>
                            <input type="hidden" name="rbTypedoc" value="3" />
                            </cfif>
						</cfif>
						<input type="hidden" name="SourceDate" value="#SourceDate#">
						<br/>					
					</td>
				</tr>  
				<tr>
						
						<cfif #rbTypedoc# eq 2>
							<cfquery name="qProformaInvoice2" dbtype="query">
								SELECT ExpDeliv_Date, pi_number
								FROM qProformaInvoice
								WHERE pi_number = '#selProforma#'
							</cfquery>
							<cfif qProformaInvoice2.recordcount>
								<cfparam name="txtExpDelDate" default="#qProformaInvoice2.ExpDeliv_date#">
							<cfelse>

								<cfparam name="txtExpDelDate" default="">									
							</cfif>
							<td > Expected Delivery Date </td>
							<td > : </td>
							<td>
								<cfset dtmValue4 = DateFormat(#qProformaInvoice2.ExpDeliv_date#,"mm/dd/yyyy")>
								<script type="text/javascript"> SunFishERP_DateTimePicker('txtExpDelDate', '#dtmValue4#', 'onblur="callselCOA();"'); </script>
								<cfset dcf_Identity=dcf_Identity+1>							</td>					
						<cfelse>
							<cfparam name="txtExpDelDate" default="">
						</cfif>
				</tr>
				<script>
					function changeDisplay(source){
						if(parseFloat(source) == 0){
							document.getElementById("selQuotation").style.display = "";
							document.getElementById("selProforma").style.display = "none";
							document.getElementById("selPro").style.display = "none"; 
						}else if(parseFloat(source) == 1){
							document.getElementById("selPro").style.display = "";
							document.getElementById("selQuotation").style.display = "none";
							document.getElementById("selProforma").style.display = "none";
						}else if(parseFloat(source) == 2){
							document.getElementById("selProforma").style.display = "";
							document.getElementById("selQuotation").style.display = "none";
							document.getElementById("selPro").style.display = "none";	
						}
						delRow('tbl_ID',2); 
					}
				</script> 
				<tr height="22">

					<td>#DO_VAR['customer']# *</td> 
					<td valign="middle">:</td>
					<td>
						<input type="hidden" name="txtCustName" <cfif task eq "save">value="<cfif rbTypeDoc eq 0 and selQuotation neq "">#qDetail.Account_Name#<cfelseif rbTypeDoc eq 1 and (selPro neq 0 OR Len(Trim(selProject)) NEQ 0)>#qDetail.Account_Name#<cfelseif rbTypeDoc eq 2 and selProforma neq "">#qDetail.Account_Name#<cfelseif rbTypeDoc eq 3 and ddlSalesContract neq "">#qDetail.Account_Name#<cfelseif isdefined('txtCustName')>#txtCustName#</cfif>"<cfelse>value="#qSales.Account_Name#"</cfif>>
						<input type="hidden" name="txtCustCode" id="txtCustCode" <cfif task eq "Save">value="<cfif rbTypeDoc eq 0 and selQuotation neq "">#qDetail.Account_ID#<cfelseif rbTypeDoc eq 1 and (selPro neq 0 OR Len(Trim(selProject)) NEQ 0)>#qDetail.Account_ID#<cfelseif rbTypeDoc eq 2 and selProforma neq "">#qDetail.Account_ID#<cfelseif rbTypeDoc eq 3 and ddlSalesContract neq "">#qDetail.Account_ID#<cfelseif isdefined('txtCustCode')>#txtCustCode#</cfif>"<cfelse>value="#qSales.Account_ID#"</cfif>>
						<span id="CustName" style="display:''">
							<!--- <cfif TXTCUSTNAME neq "">
                                #TXTCUSTNAME#
                            <cfelse> --->								
								<cfif task eq "Edit">
                                    #qSales.Account_Name#
                                <cfelse>
                                    <cfif rbTypeDoc eq 0 and selQuotation neq "">
                                        #qDetail.Account_Name#
                                    <cfelseif rbTypeDoc eq 1 and (selPro neq 0 OR Len(Trim(selProject)) NEQ 0)>
                                     
                                        #qDetail.Account_Name#
                                    <cfelseif rbTypeDoc eq 2 and selProforma neq "">

                                        #qDetail.Account_Name#
                                    <cfelseif rbTypeDoc eq 3 and ddlSalesContract neq "">

                                        #qDetail.Account_Name#
                                     <cfelseif txtCustName neq "">
                                    	#txtCustName#
                                    <cfelse>                                    	
                                        <em><font color="##9A9A9A">-#DO_VAR['SelectItem']#-</font></em>
                                    </cfif>
                                </cfif>                                
                           <!--- </cfif> --->

						</span>					</td>

				</tr>
				<tr height="22">
					<td valign="top" nowrap>#DO_VAR['CustomerAddress']#</td> 
					<td valign="top">:</td>
					<td id="AlamatCust">
						<input type="hidden" name="txtCustAddress" <cfif task eq "save">value="<cfif rbTypeDoc eq 0 and selQuotation neq "">#qDetail.Account_Address#<cfelseif rbTypeDoc eq 1 and (selPro neq 0 OR Len(Trim(selProject)) NEQ 0)>#qDetail.Account_Address#<cfelseif rbTypeDoc eq 2 and selProforma neq "">#qDetail.Account_Address#<cfelseif rbTypeDoc eq 3 and ddlSalesContract neq "">#qDetail.Account_Address#</cfif>"<cfelse>value="#qSales.Account_Address1#"</cfif>>
						<span id="CustAddress" style="display:''">
                        	<!--- <cfif TXTCUSTADDRESS neq "">
                                #TXTCUSTADDRESS#
                            <cfelse> --->
								<cfif task eq "Edit">
                                    #qSales.account_address1#
                                <cfelse>
                                    <cfif rbTypeDoc eq 0 and selQuotation neq "">
                                        #qDetail.Account_Address#
                                    <cfelseif rbTypeDoc eq 1 and (selPro neq 0 OR Len(Trim(selProject)) NEQ 0)>
                                        #qDetail.Account_Address#
                                    <cfelseif rbTypeDoc eq 2 and selProforma neq "">
                                        #qDetail.Account_Address#
                                    <cfelseif rbTypeDoc eq 3 and ddlSalesContract neq "">
                                    	#qDetail.Account_Address#
                                    <cfelseif txtCustAddress neq "">
                                    	#txtCustAddress#
                                    <cfelse>
                                        <em><font color="##9A9A9A">-#DO_VAR['SelectItem']#-</font></em>
                                    </cfif>
                                </cfif>
                            <!--- </cfif> --->
						</span>					</td>
				</tr>
                
                <tr height="22">
					<td>#DO_VAR['TaxNumber']#</td>
					<td>:</td>
					<td>
                     <input type="hidden" name="txtnpwp" <cfif task eq "save">value="<cfif rbTypeDoc eq 0 and selQuotation neq "">#qDetail.TaxFileNumber#<cfelseif rbTypeDoc eq 1 and (selpro neq 0 OR Len(Trim(selProject)) NEQ 0)> #qDetail.TaxFileNumber#<cfelseif rbTypeDoc eq 2 and selproforma neq "">#qDetail.TaxFileNumber#<cfelseif rbTypeDoc eq 3 and ddlSalesContract neq "">#qDetail.TaxFileNumber#<cfelseif IsDefined("txtnpwp") and txtnpwp neq "">#txtnpwp#</cfif>"<cfelse>value="#qSales.TaxFileNumber#"</cfif>>
					 <span id="CPTaxFileNumber" style="display:''">
						<!--- <cfif TXTNPWP neq "">
                            #TXTNPWP#
                        <cfelse> --->
							<cfif task eq "Edit">
                                #qSales.TaxFileNumber#
                            <cfelse>
                                <cfif rbTypeDoc eq 0 and selQuotation neq "">
                                    #qDetail.TaxFileNumber#
                                <cfelseif rbTypeDoc eq 1 and (selPro neq 0 OR Len(Trim(selProject)) NEQ 0)>
                                    #qDetail.TaxFileNumber#
                                <cfelseif rbTypeDoc eq 2 and selProforma neq "">
                                    #qDetail.TaxFileNumber#
                                <cfelseif rbTypeDoc eq 3 and ddlSalesContract neq "">
                                    #qDetail.TaxFileNumber#
                                <cfelseif txtnpwp neq "">
                                    	#txtnpwp#
                                <cfelse>
                                    <em><font color="##9A9A9A">-#DO_VAR['SelectItem']#-</font></em>
                                </cfif>
                            </cfif>	
                       <!--- </cfif> --->
					 </span><!--- #txtnpwp# --->                    </td>
				</tr>
                
				<tr height="22">
					<td nowrap>#DO_VAR['ContactPerson']#</td>
					<td>:</td>
					<td>
						<input type="hidden" name="txtCPName" <cfif task eq "Save">value="<cfif rbTypeDoc eq 0 and selQuotation neq "">#qDetail.contact_firstname# #qDetail.contact_middlename# #qDetail.contact_LastName# <cfelseif rbTypeDoc eq 1 and (selpro neq 0 OR Len(Trim(selProject)) NEQ 0)> #qDetail.contact_firstname# #qDetail.contact_middlename# #qDetail.contact_LastName# <cfelseif rbTypeDoc eq 2 and selproforma neq ""> #qDetail.contact_firstname# #qDetail.contact_middlename# #qDetail.contact_LastName#<cfelseif rbTypeDoc eq 3 and ddlSalesContract neq "">#qDetail.Account_Contact#<cfelseif IsDefined("txtCPName") and txtCPName neq "">#txtCPName#</cfif>"<cfelse>value="#qSales.Contact_FirstName#"</cfif>>
						<input type="hidden" name="txtCPCode" <cfif task eq "Save">value="<cfif rbTypeDoc eq 0 and selQuotation neq "">#qDetail.Contact_ID#<cfelseif rbTypeDoc eq 1 and (selpro neq 0 OR Len(Trim(selProject)) NEQ 0)>#qDetail.Contact_ID#<cfelseif rbTypeDoc eq 2 and selproforma neq "">#qDetail.Contact_ID#<cfelseif rbTypeDoc eq 3 and ddlSalesContract neq "">#qDetail.Contact_ID#<cfelseif IsDefined("txtCPCode") and txtCPCode neq "">#txtCPCode#</cfif>"<cfelse>value="#qSales.Contact_ID#"</cfif>>
						<span id="CPName" style="display:''">
                        <!--- <cfif txtCPName neq "">
                            #txtCPName#
                        <cfelse> --->
							<cfif task eq "Edit">
								#qSales.Contact_FirstName#
							<cfelse>
								<cfif rbTypeDoc eq 0 and selQuotation neq "">
									#qDetail.contact_firstname# #qDetail.contact_middlename# #qDetail.contact_LastName#
								<cfelseif rbTypeDoc eq 1 and (selPro neq 0 OR Len(Trim(selProject)) NEQ 0)>
									#qDetail.contact_firstname# #qDetail.contact_middlename# #qDetail.contact_LastName#
								<cfelseif rbTypeDoc eq 2 and selProforma neq "">
									#qDetail.contact_firstname# #qDetail.contact_middlename# #qDetail.contact_LastName#
								<cfelseif rbTypeDoc eq 3 and ddlSalesContract neq "">
                                    #qDetail.Account_Contact#
                                     <cfelseif txtCPName neq "">
                                    	#txtCPName#
                                <cfelse>
									<em><font color="##9A9A9A">-#DO_VAR['SelectItem']#-</font></em>
								</cfif>
							</cfif>
                        <!--- </cfif> --->
						</span>					</td>
				</tr>
				<tr height="22">

					<td nowrap>#DO_VAR['contactAddress']#</td> 
					<td valign="middle">:</td>
					<td id="AlamatContact"> 
					<input type="hidden" name="txtCPAddress" <cfif task eq "save">value="<cfif rbTypeDoc eq 0 and selQuotation neq "">#qDetail.Contact_HomeAddress#<cfelseif rbTypeDoc eq 1 and (selpro neq 0 OR Len(Trim(selProject)) NEQ 0)> #qDetail.Contact_HomeAddress#<cfelseif rbTypeDoc eq 2 and selproforma neq "">#qDetail.Contact_HomeAddress#<cfelseif rbTypeDoc eq 3 and ddlSalesContract neq "">#qDetail.Contact_HomeAddress#<cfelseif IsDefined("TXTCPAddress") and TXTCPAddress neq "">#TXTCPAddress#</cfif>"<cfelse>value="#qSales.Contact_HomeAddress#"</cfif>>
					<span id="CPAddress" style="display:''">
                    <!--- <cfif TXTCPAddress neq "">
                            #TXTCPAddress#
                        <cfelse> --->
						<cfif task eq "Edit">
							#qSales.Contact_HomeAddress#
						<cfelse>
							<cfif rbTypeDoc eq 0 and selQuotation neq "">
								#qDetail.Contact_HomeAddress#
							<cfelseif rbTypeDoc eq 1 and (selPro neq 0 OR Len(Trim(selProject)) NEQ 0)>
								#qDetail.Contact_HomeAddress#
							<cfelseif rbTypeDoc eq 2 and selProforma neq "">
								#qDetail.Contact_HomeAddress#
							<cfelseif rbTypeDoc eq 3 and ddlSalesContract neq "">
                                #qDetail.Contact_HomeAddress#
                                			<cfelseif txtCPAddress neq "">
						            	#txtCPAddress#
                            <cfelse>
								<em><font color="##9A9A9A">-#DO_VAR['SelectItem']#-</font></em>
							</cfif>
						</cfif>	
                    <!--- </cfif> --->
					</span>					</td>
				</tr>
				<cfif val(qSetting.salesPerson) eq "1">
				<tr height="22">
					<td nowrap>#DO_VAR['SalesPerson']# *</td>
					<td>:</td>
					<td>
						<input type="Text" name="txtSPName" size="40" maxlength="100" 
						<cfif task eq "Save">
							<cfif txtSPName eq "">
                                value="#qdetail.Name#"
                            <cfelse>
                                value="#txtSPName#"
                            </cfif>		
						<cfelse>
							value="#txtSPName#"
						</cfif> readonly class="inplabel">
						 <a href="javascript:popSales('yes')"> 
						<IMG src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/user.gif" width="19" height="19" border="0" alt="#DO_VAR['SalesPerson']#" align="middle"></a>
						<input type="hidden" name="txtSPCode" 
						<cfif task eq "Save">

							<cfif txtSPCode eq "">
                                value="#qdetail.Emp_id#"

                            <cfelse>

                                value="#txtSPCode#"
                            </cfif>		
						<cfelse>
							value="#txtSPCode#"
						</cfif>>					</td>
				</tr>
				<cfelse>
					<tr height="22">
					<td nowrap>#DO_VAR['SalesPerson']# *</td>
					<td>:</td>
					<td> <cfif task eq "save">
						<select name="txtSPCode">
						<cfif isDefined ("form.selQuotation") or isDefined ("form.selProforma")>
							<option value="">#DO_VAR['None']#</option>
							<cfloop query="qSP">
								<option value="#qSP.Emp_ID#">#qSP.name#</option>
							</cfloop>
						<cfelse>
							<option value="">#DO_VAR['None']#</option>
						</cfif>
						</select>
					<cfelse>
							
						<select name="txtSPCode">
							<cfif qEmpList2.recordcount>
								<cfloop query="qEmpList2">
									<option value="#Emp_ID#" <cfif qsales.emp_id eq qEmpList2.emp_id>selected</cfif>># name#</option>
								</cfloop>	
							<cfelse>
								<option value="">#DO_VAR['None']#</option>
							</cfif>
						</select>
					</cfif>
				</cfif>

			<!--- andiJ. 17Mar'10, for add?
			<cfif task eq "Edit">
				<tr class="formtext">
					<td height="22" nowrap>#DO_VAR["SellingPriceType"]#</td>
					<td>:</td>
					<td>												
						<cfif qSellingType.Selling_Price_Type eq "Retail">
							#DO_VAR["eAcc_PriceRetail"]#
						<cfelseif qSellingType.Selling_Price_Type eq "Shop">
							#DO_VAR["eAcc_PriceShop"]#
						<cfelseif qSellingType.Selling_Price_Type eq "Distributor">
							#DO_VAR["eAcc_PriceDistributor"]#
						<cfelseif qSellingType.Selling_Price_Type eq "Other">

							#DO_VAR["eAcc_PriceOther"]#
						<cfelseif qSellingType.Selling_Price_Type eq "SoleDistributor">
							#DO_VAR["eAcc_SoleDistributor"]#



						</cfif>
					</td>
				</tr>
			</cfif> --->
				<tr height="22">
					<td>#Do_var['Remarks']#</td>
					<td>:</td>
					<td colspan="2" class="formtext">
						<textarea name="txtMemo" cols="50" rows="7">#txtMemo#</textarea>
					</td>
				</tr>
				<tr height="22">
					<td>#Do_var['KawasanBerikat']#</td>
					<td>:</td>
					<td colspan="2" class="formtext"><input type="checkbox" name="chkKawasan" <cfif kawasanberikat eq "1"> checked </cfif>value="1"> #DO_VAR["Yes"]#</tr>
				
				<cfif qAccount.RecordCount>
                    <cfif qAccount.GroupID eq 0>
                        <cfquery datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#" name="qAccGroup">
                        	SELECT Account_Id, Account_Name
								from taccount
								where account_id = '#qAccount.Account_ID#'
                        </cfquery>
                    <cfelse>
    					<cfquery datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#" name="qAccGroup">
    						SELECT Account_Id, Account_Name
    						FROM TAccount
    						WHERE GroupID IN (
    							SELECT ISNULL(GroupID,0)
    							FROM TAccount
    							WHERE Account_ID = #qAccount.Account_ID#
    							)
    						AND Company_ID = '#Cookie.CompanyID#'
    					</cfquery>
                    </cfif>
				<cfelse>
					<cfquery datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#" name="qAccGroup">
						SELECT '-1' AS Account_ID, '#DO_VAR['None']#' AS Account_Name

					</cfquery>
				</cfif>
				
				<tr height="22">
					<td>#Do_var['SNAccount']#</td>
					<td>:</td>
					<td colspan="2" class="formtext"> 
					<cfif task eq "save">
                    	<cfparam name="selSNGroup" default="qAccount.account_id">
						<select name="selSNGroup">
							<!--- <option value="">None</option> --->
                            <cfloop query="qAccGroup">
								<option value="#qAccGroup.account_ID#" <cfif qAccGroup.account_ID eq selSNGroup>selected</cfif>>#account_name# 
							</cfloop>
						</select>
					<cfelse> 
						<select name="selSNGroup">
							<cfloop query="qAccGroup">

								<option value="#qAccGroup.account_ID#" <cfif qsales.sn_account_id eq qAccGroup.account_id>selected</cfif>>#account_name# 
							</cfloop>
						</select>
				  </cfif>				</tr>
				 <tr height="22">
					<td>#Do_var['SIAccount']#</td>
					<td>:</td>
					<td colspan="2" class="formtext">
					<cfif task eq "save">
                    	<cfparam name="selSIGroup" default="qAccount.account_id">
						<select name="selSIGroup">
							<!--- <option value="">None</option> --->
                            <cfloop query="qAccGroup">
								<option value="#qAccGroup.account_ID#" <cfif qAccGroup.account_ID eq selSIGroup>selected</cfif>>#account_name# 
							</cfloop>
						</select>
					<cfelse>
						<select name="selSIGroup">
							<cfloop query="qAccGroup">
								<option value="#qAccGroup.account_ID#" <cfif qsales.si_account_id eq qAccGroup.account_id>selected</cfif>>#account_name# 
							</cfloop> 
						</select>
					</cfif>					</td>						
				</tr> 
				 
				<!---  andiJ. 17Mar'10, for add?
				<cfif task eq "edit">
					<tr height="22">
						<td>#Do_var['SisterCompany']#</td>
						<td>:</td>
						<td colspan="2" class="formtext"><cfif chkSisterCompany eq "1">#DO_VAR["Yes"]#<cfelse>#DO_VAR["No"]#</cfif></td>
					</tr>
				</cfif> --->
				</table>			</td>
			<input type="hidden" name="txtHidSisterCompany" value="#txtHidSisterCompany#">
			<!---<div class="warning" style="background:##CC9966; border:solid ##FF0000">
			Maintenance...<br />--->
			<input type="hidden" name="lstCurrency" value="#lstCurrency#">
<!---			</div>
--->			<input type="hidden" name="listTempCurrency" value=""> 
			<input type="hidden" name="lstItem" value="">





			<input type="hidden" name="isOutlet" value="#isOutlet#">
			<input type="hidden" name="outlet_wh" value="#outlet_wh#">
			
			<td valign="top" width="50%">
				<table border="0" width="100%" class="formtext">
				<tr height="22">
					<td nowrap>#DO_VAR["SODate"]# *</td>
					<td nowrap colspan="2">: 
					<cfparam name="txtSODate" default="#dateformat(now(),"mm/dd/yyyy")#">
					<script type="text/javascript">SunFishERP_DateTimePicker('txtSODate','#iif(isDefined("Form.txtSODate"),"Form.txtSODate",DE(txtSODate))#','onblur="lpage();"');</script>
				  <cfset dcf_Identity=dcf_Identity+1>				</tr>
				<cfif rbTypeDoc eq "2">
				 	<!--- <tr height="22" id="duedate" style="display: none"> --->
					<tr height="22" id="duedate" style="display: ">
						<td nowrap>#DO_VAR["DueDate"]#</td>
						<td nowrap colspan="2">: 
							<cfif task eq "Save" AND not (isDefined("txtInvDueDate") AND len(trim(txtInvDueDate)))>
								<cfset dtmValue = #DateFormat(now(),"mm/dd/yyyy")#>
							<cfelse>
								<cfset dtmValue = #DateFormat(txtInvDueDate,"mm/dd/yyyy")#>
							</cfif>
							<cfif dtmValue eq "">
								<cfquery name="qGetTerms" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
									SELECT * FROM TAccPaymentTerm WHERE paymentterm_code = '#cboTermsNew#'
								</cfquery>
								<cfif qGetTerms.recordcount eq 0>
									<cfset term_type = "m">
									<cfset term_duration = 1>
								<cfelse>
									<cfset term_type = qGetTerms.paymentterm_type>
									<cfif term_type eq "w"><cfset term_type = "ww"></cfif>
									<cfif term_type eq "y"><cfset term_type = "yyyy"></cfif>
									<cfset term_duration = qGetTerms.paymentterm_duration>
								</cfif>
								<cfset dtmValue = DateFormat(DateAdd(term_type,term_duration,txtSODate),"mm/dd/yyyy")>
							</cfif>
							<script type="text/javascript">SunFishERP_DateTimePicker('txtInvDueDate','#dtmValue#','onblur="changepaymentdate();"');</script>
							<cfset dcf_Identity=dcf_Identity+1></td>
					</tr> 
				 <cfelse>
				 	<!--- <tr height="22" id="duedate" style="display: none"> --->

					<tr height="22" id="duedate" style="display: ">
						<td nowrap>#DO_VAR["DueDate"]#</td>
						<td nowrap colspan="2">: 
							<cfif task eq "Save" AND not (isDefined("txtInvDueDate") AND len(trim(txtInvDueDate)))>
								<cfset dtmValue = #DateFormat(qdetail.Due_Date,"mm/dd/yyyy")#>
							<cfelse>
								<cfset dtmValue = #DateFormat(txtInvDueDate,"mm/dd/yyyy")#>
							</cfif>
							<cfif dtmValue eq "">

								<cfquery name="qGetTerms" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">

									SELECT * FROM TAccPaymentTerm WHERE paymentterm_code = '#cboTermsNew#'
								</cfquery>
								<cfif qGetTerms.recordcount eq 0>
									<cfset term_type = "m">
									<cfset term_duration = 1>
								<cfelse>
									<cfset term_type = qGetTerms.paymentterm_type>
									<cfif term_type eq "w"><cfset term_type = "ww"></cfif>
									<cfif term_type eq "y"><cfset term_type = "yyyy"></cfif>
									<cfset term_duration = qGetTerms.paymentterm_duration>
								</cfif>
								<cfset dtmValue = DateFormat(DateAdd(term_type,term_duration,txtSODate),"mm/dd/yyyy")>
							</cfif>
							<script type="text/javascript">SunFishERP_DateTimePicker('txtInvDueDate','#dtmValue#','onblur="changepaymentdate();"');</script>
							<cfset dcf_Identity=dcf_Identity+1>						</td>
					</tr> 
				</cfif>
				
				<tr height="22" id="ponum">
					<td nowrap>#DO_VAR["CustomerPONumber"]#</td>
					<td colspan="2">: <input type="Text" name="txtPONum" style="width:114px" maxlength="255" value="#txtPONum#"></td>
				</tr>
				
				<tr height="22" id="podate">
					<td nowrap>#DO_VAR["CustomerPODate"]#</td>
					<td nowrap colspan="2"> : 
						<cfif txtPODate eq ""><cfset txtPODate = txtSODate></cfif>
						<script type="text/javascript">SunFishERP_DateTimePicker('txtPODate','#DateFormat(txtPODate,"mm/dd/yyyy")#','onChange ="cekValue()"');</script>

						<cfset dcf_Identity=dcf_Identity+1>					</td>
				</tr>
				<tr height="22" id="podate">
					<cfset monthList = "1-January,2-February,3-March,4-April,5-May,6-June,7-July,8-August,9-September,10-October,11-November,12-December">
					<td nowrap>Production Month & Year</td>
					<td nowrap colspan="2"> : 	
						<select name="txtProMonth" id="txtProMonth">
							<option value="" <cfif "" eq txtProMonth>selected</cfif>> --select month--</option>
							<cfloop list="#monthList#" index="idxmonth">
								<option value="#listfirst(idxmonth,'-')#" <cfif listfirst(idxmonth,'-') eq txtProMonth>selected</cfif>> #listlast(idxmonth,'-')#</option>
							</cfloop>
						</select>
					<cfset yearList = "2024,2025,2026,2027,2028,2029,2030">
						<select name="txtProYear" id="txtProYear">
							<option value="" <cfif "" eq txtProYear>selected</cfif>> --select year--</option>
							<cfloop list="#yearList#" index="idxyear">
								<option value="#idxyear#" <cfif idxyear eq txtProYear>selected</cfif>> #listlast(idxyear)#</option>
							</cfloop>
						</select>
						
					</td>
				</tr>
                <script>
					function addTaxCurreny(){	
						var obj = document.forms[0].selTaxCurrency;
						for(i=(obj.length-1);i>=0;i--){
							obj.options[i] = null;
						}
						
						var Curr = document.forms[0].selCurrency.value; 
						obj.length = 2;
						obj.options[0] = new Option('#cookie.currencyid#', '#cookie.currencyid#');  
						obj.options[1] = new Option(Curr, Curr);  
					}
				</script>
				<tr height="22">
					<td nowrap>#DO_VAR["SOCurrency"]#</td>
					<td colspan="2">:
						
					
						<cfif task eq "edit" and val(qSales.isSisterCompany) eq "1">
							<select name="selCurrency" id="selCurrency" onChange="addTaxCurreny();callselCOA();setCurr();lpage();" <cfif #selCurrencyEditable# eq 0>disabled</cfif>>
							<cfloop query="qCurrency">
								<option value="#Currency_ID#" <cfif qsales.currency_id eq currency_id>selected</cfif>>#Currency_Symbol#</option>
							</cfloop>
							</select>
						<cfelse>
							<select name="selCurrency" id="selCurrency" onChange="addTaxCurreny();callselCOA();setCurr();lpage();" <cfif #selCurrencyEditable# eq 0>disabled</cfif>>
							<cfif rbTypeDoc IS 3>
								<cfif task is "edit">
									<option value="#qSales.Currency_ID#">#qSales.Currency_ID#</option>
								<cfelse>
									<cfif qDetail.RecordCount AND Len(Trim(qDetail.Currency_ID))>
										<option value="#qDetail.Currency_ID#">#qDetail.Currency_ID#</option>
									<cfelse>
										<cfloop query="qCurrency">
											<option value="#Currency_ID#" <cfif selCurrency eq qCurrency.Currency_ID>SELECTED</cfif>>#Currency_Symbol#</option>
										</cfloop>
									</cfif>
								</cfif>
							<cfelse>
								<cfloop query="qCurrency">
									<option value="#Currency_ID#" <cfif selCurrency eq qCurrency.Currency_ID>SELECTED</cfif>>#Currency_Symbol#</option>
								</cfloop>
							</cfif>
							</select>
						</cfif>
					</td>
				</tr>
				<tr height="22">
					<td nowrap>#DO_VAR["TaxCurrency"]#</td>
					<td colspan="2">: 
					 	<select name="selTaxCurrency" id="selTaxCurrency" onChange="refreshAjax();lpage();" <cfif #selCurrencyEditable# eq 0>disabled</cfif>>
							<cfif rbTypeDoc IS 3>

                              <cfif task is "edit">
                                <option value="#qSales.Tax_Currency_ID#">#qSales.Tax_Currency_ID#</option>
                              <cfelse>
							  	<cfif qDetail.RecordCount AND Len(Trim(qDetail.Tax_Currency_ID))>
                                	<option value="#qDetail.Tax_Currency_ID#">#qDetail.Tax_Currency_ID#</option>
								<cfelse>
									<cfloop query="qCurrency">
                                    	<cfif #Currency_ID# eq #cookie.CurrencyID# || #Currency_ID# eq #selCurrency# >
                                              <option value="#Currency_ID#"
                                               <cfif selTaxCurrency eq qCurrency.Currency_ID>SELECTED</cfif>
                                               >#Currency_Symbol#</option>
                                        </cfif>
	                              	</cfloop>
								</cfif>
                              </cfif>
                            <cfelse>
                              <cfloop query="qCurrency">
                              	<cfif #Currency_ID# eq #cookie.CurrencyID# || #Currency_ID# eq #selCurrency#>
                                  <option value="#Currency_ID#"
                                   <cfif selTaxCurrency eq qCurrency.Currency_ID>SELECTED</cfif>
                                   >#Currency_Symbol#</option>
                                 </cfif>
                              </cfloop>
                            </cfif>
						</select></td>
				</tr>				
				<tr height="22">
					<td nowrap>#Do_var['CurrentCurrency']#</td>
					<td colspan="2">: #cookie.CurrencyID#</td>
				</tr>
				<script>
					function lpage(){
						<cfset vartemplate = "index.cfm">
						<cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785402&menu=1">	
						frmNew.action = '#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&selCatType=#selCatType#&cbotermChange=1&txtCustCode='+document.frmNew.txtCustCode.value
						frmNew.method = 'post';
						frmNew.submit();
					}
				</script>
               	
                <cfif task eq "save">
                 <cfif not isDefined('url.cbotermChange')>
                 	<cfset cboTerms = qdetail.terms>
                 <cfelseif isDefined('url.cbotermChange') and cbotermChange eq 1 and isdefined("form.cboTerms")>
                 	<cfset cboTerms = form.cboTerms>
				 <cfelse>
				 	<cfset cboTerms = "">
                 </cfif>
                </cfif>
				<tr>
					<td>#Do_var['PaymentSchedule']#</td>
					<td colspan="2">:
						<!--- <textarea name="txtTerms" cols="40" rows="3">#txtTerms#</textarea> --->
						<input type="Hidden" name="txtTerms">                               
                        
                        <cfif isDefined("FORM.cboTerms")>                                             
                            <cfif isdefined("qDetail") and qDetail.recordcount neq 0 and not isDefined('url.cbotermChange')>
                                <cfset local.cboTerms = qDetail.Terms>
                            <cfelse>
                                <cfset local.cboTerms = FORM['cboTerms']>
                            </cfif>    
            			<cfelse>
                            <cfif isDefined("URL.TASK") AND URL['TASK'] EQ "EDIT">
            				  <cfset local.cboTerms = cboTerms>
            				<cfelse>
            				  <cfset local.cboTerms = qTerms.TOP_Code>
                            </cfif>
            			</cfif>
                        
                        <cfif local.cboTerms eq ''>
                        	<cfset local.cboTerms = qTerms.TOP_Code>
                        </cfif>

						<select name="cboTerms" id="cboTerms" onChange="lpage();">							
							<cfloop query="qTerms">
								<option value="#qTerms.TOP_Code#" <cfif cboTerms eq qTerms.TOP_Code>selected</cfif>>
									#qTerms.TOP_desc# - #qTerms.Term# #qTerms.Term_Type# (#qTerms.TOP_Type#)
								</option>
							</cfloop>
						</select>
                        
					</td>
				</tr>
				<tr>
					<td>#Do_var['PaymentTerms']#</td>
					<td colspan="2">: 
						<!--- <textarea name="txtTerms" cols="40" rows="3">#txtTerms#</textarea> --->
						<input type="Hidden" name="txtTermsNew">
						<select name="cboTermsNew" id="cboTermsNew" onChange="lpage();">
							<option value="" <cfif cboTermsNew eq "">selected</cfif>>#DO_VAR['None']# - 1 month (default)
							<cfloop query="qTermsNew">
								<option value="#qTermsNew.paymentterm_code#" <cfif cboTermsNew eq qTermsNew.paymentterm_code>selected</cfif>>#qTermsNew.paymentterm_description# - #qTermsNew.paymentterm_duration# <cfif qTermsNew.paymentterm_type eq "d">day<cfelseif qTermsNew.paymentterm_type eq "w">week<cfelseif qTermsNew.paymentterm_type eq "m">month<cfelseif qTermsNew.paymentterm_type eq "y">year</cfif><cfif qTermsNew.paymentterm_duration gt 1>s</cfif></option>
							</cfloop>
						</select>

					</td>
				</tr>
				<tr>
					<td>#Do_var['DeliveryTerms']#</td>
					<td colspan="2">: 
						<textarea name="txtDeliveryTerms" cols="40" rows="3">#txtDeliveryTerms#</textarea>
					</td>
				</tr>
				
				<!---untuk sementara di hilangkan dulu,
				karena untuk membuat otomatis sn, diperlukan informasi warehouse ,bin dan serial number [jika di perlukan]--->
				<tr style="display:none">
					<td>#DO_VAR['AutomaticSN']#</td>					
					<td colspan="2">:&nbsp;<input type="Checkbox" name="cbautosn" value="1"
					<cfif task eq "edit">
						<cfif val(qSetting.AutomaticSN) eq 1 and qsales.automaticsn eq 1> disabled checked<cfelse>disabled</cfif>
					 
					<cfelse>
						<cfif val(qSetting.AutomaticSN) eq 0>disabled<cfelseif val(qSetting.AutomaticSN) eq 1>disabled checked</cfif>
					</cfif>
					
					>&nbsp;#DO_VAR['Yes']#</td>
				</tr>
                
                <!--- <cfquery name="qPaymentDP" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                 <!---  SELECT 
                    * 
                  FROM 
                    TACCDUEDATE 

                  WHERE 
                    TACCDUEDATE.TRXID = '#SONUM#' 
                    AND TACCDUEDATE.TYPE = 'SO' 
                    AND TACCDUEDATE.COMPANYID = '#COOKIE.COMPANYID#'
                    AND TACCDUEDATE.DP_Flag = 1 --->
					select * from TACCCUSTOMERPAYMENT
					where TRX_NUMBER = '#SONUM#' 
					and DOC_TYPE = 'SO'
					and COMPANY_ID = #COOKIE.COMPANYID#
                </cfquery> --->
                
                <!--- <tr>
					<td>#DO_VAR['DP']#</td>
                    <td>: <!--- andiJ. 17Mar'10, tambah field isDP di SO header, jadi dipisah dr payment, karena saat ini apabila downpayment selalu checked, apabila qPaymentDP ada result
						<input type="checkbox" name="chkDP" value="true" #Iif(qPaymentDP.recordcount IS 1, DE('checked'), DE(''))#> --->
						<input type="checkbox" name="chkDP" value="true" <cfif isDefined("qSales.isDP")>#Iif(qSales.isDP eq 1, DE('checked'), DE(''))#</cfif>>&nbsp;#DO_VAR['Yes']#</td>
				</tr> --->
                
                <!--- <cfif task eq "edit">
                  <!--- <cfquery name="qDonation" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                    SELECT 
                      isDonation
                    FROM 
                      TACCSO_HEADER 
                    WHERE 
                      TACCSO_HEADER.SO_Number = '#SONUM#'
                  </cfquery> --->
                  
                  <tr>
                      <td>#DO_VAR['Donation']#</td>
                      <td>: <input type="checkbox" name="chkDonation" value="true" #Iif(qSales.isDonation IS 1, DE('checked'), DE(''))#>&nbsp;#DO_VAR['Yes']#</td>
                  </tr>
                <cfelse>
                  <tr>
                      <td>#DO_VAR['Donation']#</td>
                      <td>: <input type="checkbox" name="chkDonation" value="true" />&nbsp;#DO_VAR['Yes']#</td>
                  </tr>
                </cfif> --->
                <!--- <tr>
                      <td>#DO_VAR['AutomaticPO']#</td>
                      <td>: <input type="checkbox" id="chkdirectPO" name="chkdirectPO" <cfif isdefined("qSales.directpo")><cfif qSales.directpo eq 1>value="1" checked</cfif></cfif>>&nbsp;#DO_VAR['Yes']#</td>
                  </tr>
				<tr> --->
					<td>#DO_VAR['CreditInfo']#</td>					
					<td colspan="2">&nbsp;
							<input type="Hidden" name="txtcreditlimit" value="#txtcreditlimit#">
							<input type="Hidden" name="baseCreditLimit" value="#txtcreditlimit#">

							<input type="Hidden" name="txtInvNotPaid" value="#txtInvNotPaid#">
							<input type="Hidden" name="baseInvNotPaid" value="#txtInvNotPaid#">
							<!--- <input type="Hidden" name="txtTaxNotPaid" value="#txtInvNotPaid#">
							<input type="Hidden" name="baseTaxNotPaid" value="#txtInvNotPaid#"> --->
							<input type="Hidden" name="txtSOApproved" value="#txtSOApproved#">
							<input type="Hidden" name="baseSOApproved" value="#txtSOApproved#">
							<!--- <input type="Hidden" name="txtTaxSOApproved" value="#txtSOApproved#">
							<input type="Hidden" name="baseTaxSOApproved" value="#txtSOApproved#"> --->

							<input type="Hidden" name="txtRemainingCredit" value="#txtRemainingCredit#">
							<input type="Hidden" name="baseRemainCredit" value="#txtRemainingCredit#">
							<!--- <CF_DO_V30_CONVERTCURRENCY BASECURRENCY="#COOKIE.CURRENCYID#" CONVERTCURRENCY="#selCurrency#" BASEVALUE="#txtcreditlimit#" CURRRESULT="txtcreditlimit" Companyid="#cookie.companyid#" >
							<CF_DO_V30_CONVERTCURRENCY BASECURRENCY="#COOKIE.CURRENCYID#" CONVERTCURRENCY="#selCurrency#" BASEVALUE="#txtInvNotPaid#" CURRRESULT="txtInvNotPaid" Companyid="#cookie.companyid#" >
							<CF_DO_V30_CONVERTCURRENCY BASECURRENCY="#COOKIE.CURRENCYID#" CONVERTCURRENCY="#selCurrency#" BASEVALUE="#txtSOApproved#" CURRRESULT="txtSOApproved" Companyid="#cookie.companyid#" >
							<CF_DO_V30_CONVERTCURRENCY BASECURRENCY="#COOKIE.CURRENCYID#" CONVERTCURRENCY="#selCurrency#" BASEVALUE="#txtRemainingCredit#" CURRRESULT="txtRemainingCredit" Companyid="#cookie.companyid#" > --->
							<CF_DO_V25_CURRCONVERTER varname="txtcreditlimit" Currency_1="#COOKIE.CURRENCYID#" CURRENCY_2="#selCurrency#" value="#txtcreditlimit#">
							<CF_DO_V25_CURRCONVERTER varname="txtInvNotPaid" Currency_1="#COOKIE.CURRENCYID#" CURRENCY_2="#selCurrency#" value="#txtInvNotPaid#">
							<!--- <CF_DO_V25_CURRCONVERTER varname="txtTaxNotPaid" Currency_1="#COOKIE.CURRENCYID#" CURRENCY_2="#selCurrency#" value="#txtTaxNotPaid#"> --->
							<CF_DO_V25_CURRCONVERTER varname="txtSOApproved" Currency_1="#COOKIE.CURRENCYID#" CURRENCY_2="#selCurrency#" value="#txtSOApproved#">
							<!--- <CF_DO_V25_CURRCONVERTER varname="txtTaxSOApproved" Currency_1="#COOKIE.CURRENCYID#" CURRENCY_2="#selCurrency#" value="#txtTaxSOApproved#"> --->
							<CF_DO_V25_CURRCONVERTER varname="txtRemainingCredit" Currency_1="#COOKIE.CURRENCYID#" CURRENCY_2="#selCurrency#" value="#txtRemainingCredit#">
						<table border="0" id="tbl2">
							<tr class="formtext">
								<cfset notPaid = val(txtInvNotPaid)>
								<cfset soApproved = val(txtSOApproved)>
								<td style="border-top:1px solid black;border-right:1px solid black;border-left:1px solid black;border-bottom:1px solid black;">#DO_VAR['CreditLimit']# :  <span id="idcreditLimit">(#selCurrency#)</span><span id="creditLimit"> #NumberFormat(txtcreditlimit,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#</span><br><br>
									#DO_VAR['InvoiceNotPaid']# : <span id="idInvNotPaid">(#selCurrency#)</span> <span id="InvNotPaid">#NumberFormat(notPaid,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#</span><br><br>
									#DO_VAR['SO']# #DO_VAR['Approved']# : <span id="idSOApproved">(#selCurrency#)</span> <span id="SOApproved">#NumberFormat(soApproved,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#</span>
									<hr>									
									#DO_VAR['RemainingCredit']# : 
                                    <a href="javascript://" onClick="arrNewPop[arrNewPop.length]=PopWindow('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/sales/reports/creditlimit/view_report.cfm?rdoview=selected&rdoType=0&selCust='+document.frmNew.txtCustCode.value,'Preview','800','600','scrollbars=yes,status=yes,resizable=yes');" style="text-decoration:none;">
                                    <span id="idRemainingCredit">(#selCurrency#)</span> <span id="RemainingCredit"><b>
									<cfif txtRemainingCredit lt 0><font color="ff0000"></cfif>
                                    #NumberFormat(txtRemainingCredit,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#
									<cfif txtRemainingCredit lt 0></font></cfif></b></span>
                                    </a>
                                    </td>
							</tr>
						</table>					</td>
				</tr>	
				 <tr>
				 	<td>#DO_VAR["PriceType"]#</td>
						<td>:<!--- Penambahan tipe harga (CRF50912-07334)
										FOB : Tanpa insurance dan freight
										CIF : Dengan insurance dan freight
										CFR : Hanya dengan freight							
										--->
										<select name="cboPriceType" id="cboPriceType">								
												<option value="FOB" <cfif cboPriceType eq "FOB">selected</cfif>>Freight on Board</option>								 
												<option value="CIF" <cfif cboPriceType eq "CIF">selected</cfif>>Cost Insurance Freight</option>
											 	<option value="CFR" <cfif cboPriceType eq "CFR">selected</cfif>>Cost and Freight</option> 									 
			                            </select>
						</td> 
				 </tr>
		
				<tr>
				 	<td>Pi Number *</td>
						<td>: <input name="txtPiNumber" value="#txtPiNumber#">
						</td> 
				 </tr>
				<!--- <tr height="22" id="TaxInclude" <cfif(task eq "save" and qDetail.SOtype eq 1) or (task eq "save" and qDetail.RecordCount eq 0)> style="display:none" <cfelse> style="display:none" </cfif>>
					<td>#Do_var['IncludedTax']#</td>
					
					<td  class="formtext" align="left">
						:&nbsp;<select name="selTaxInclude">
							<cfif qTaxType.recordcount>
								<cfloop query="qTaxType">
									<cfif tax_operator eq "+">
										<option value="#tax_code#">#tax_name# #tax_rate#
									</cfif>
								</cfloop>
							</cfif>
						</select>					</td>
				</tr> --->	
				</table>			
				</td>
				
		 </tr> 
		
		<!--- Custom for Samick --->
		<tr <cfif qSetting.EnableSORevision neq 1>style="display:none"</cfif>>
			<td width="50%" valign="top" colspan="2"> 
				<table cellpadding="1" cellspacing="1" border="0" width="50%" > 
					<tr>
					<td class="formtext">#Do_var['RevisionReason']#</td>	
					<td class="formtext">:</td>					
					<td colspan="2" class="formtext" valign="center">
						<textarea name="txtRevisionReason" cols="50" rows="7">#txtRevisionReason#</textarea>					
					</td>
					</tr>	
				</table>			
             </td>
		</tr>
					
		<!--- end ---> 
		
		<tr>
			<td width="50%" valign="top" colspan="2"> 
				<table cellpadding="1" cellspacing="1" border="0" width="50%" > 
					<tr>
						<td valign="top" class="formtext"> 

							<fieldset name="1">
								<legend>#DO_VAR["CurrencyConverter"]#</legend>
								<table width="100%" style="display:''" cellpadding="4" cellspacing="1" class="formbody" border="0" id="tblCurrConverter">
								</table>
							</fieldset>						
                        </td>						
						<td valign="top" class="formtext"> 
							<fieldset name="1"><legend>#DO_VAR["TaxConverter"]#</legend>
								<table width="100%" style="display:''" cellpadding="4" cellspacing="1" class="formbody" border="0" id="tblTaxConverter">
								</table>
							</fieldset>
                        </td>
					</tr>
				</table>			
             </td>
		</tr>
		<input type="hidden" name="txtCurr_#cookie.currencyid#" value="1">
		<input type="hidden" name="txtTax_#cookie.currencyid#" value="1">
		<tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>

		
		<tr>
			<td><cfif rbTypeDoc EQ 3>
                  <cfif local.tmpSCItemSetting IS 1>
                    <script language="javascript" type="text/javascript">
					  function pickSCItem(objDocNumber, objDocItem){
						var strURL = '#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/'
						           + 'sales/so/forms/frmscpickitem.cfm?DocNumber=' + objDocNumber + '&DocItem=' + objDocItem;
								   
						<!--- var itemwindow = PopWindow(strURL, 'wndPickItem', '500', '500', 'scrollbars=yes,status=no,resizable=yes'); --->
						var itemwindow = window.open(strURL, 'wndPickItem', 'scrollbars=yes,status=no,resizable=yes', '500', '500');
						arrNewPop[arrNewPop.length] = itemwindow;
					  }
					  
					  function buildList(){
						var objItem = document.forms[0].hdnLstItemID;
												
						objItem.value = '';
						
						for(i = 1; i <= document.frmNew.rowCount.value; i++){
						  if(eval("document.frmNew.txtPartNo_"+i)){
							tmpItemID = eval("document.frmNew.hdnSCDetailID_"+i).value;
							
							if(objItem.value == ''){
							  objItem.value = tmpItemID;
							}else{
							  objItem.value += ',' + tmpItemID;
							}
						  }
						}
						
						document.forms[0].action = '';
						document.forms[0].submit();

					  }
					</script>
                    
                    <a class="link"
                     href="javascript:void(0);" 
                     onClick="pickSCItem(document.frmNew.ddlSalesContract.value, document.frmNew.hdnLstItemID.value);" 
                     onMouseOver="window.status='#DO_VAR['AddItem']#';return true;" 
                     onMouseOut="window.status='';">[+]&nbsp;#DO_VAR['AddItem']#</a>&nbsp;
					 <a class="link" 
                     href="javascript:void(0);" 
                     onClick="delRow('tbl_ID',1);" 
                     onMouseOver="window.status='#DO_VAR['RemoveItem']#';return true;" 
                     onMouseOut="window.status='';">[-]&nbsp;#DO_VAR['RemoveItem']#</a>
                  </cfif>
                <cfelse>
                <a href="javascript://" onClick="pickItem('#selCatType#','#selQuotation#');" style="text-decoration:none;">
					[+ <em>#DO_VAR['MultipleItem']#</em>]				</a>
	 			<a href="javascript:delRow('tbl_ID',1)" title="Delete Row" onMouseOver="window.status='Delete Row'; return true;" onMouseOut="window.status=''; return true;">[-]</a>
                </cfif></td>
			<td>&nbsp;</td>

		</tr>
		<tr>
			<td width="100%" colspan="2" style="border:1px solid blue;"><DIV style="width:100%; height:300px; overflow:hidden; position:relative;">
			  <DIV style="width:100%; height:100%; overflow:auto; position:absolute;">
                <table width="100%" id="tbl_ID" class="formtext" cellpadding="2" cellspacing="1" border="0">
                  <tr>
                    <td align="center" class="formtitle"><input type="Checkbox" onClick="IsSelectAll(this)" name="chkAll"></td>
                    <td align="center" class="formtitle">#DO_VAR["ItemCode"]#</td>
                    <td align="center" class="formtitle">#DO_VAR["Description"]#</td>
					 <td align="center" class="formtitle">#DO_VAR["Notes"]#</td>
                    <td align="center" class="formtitle" style="#displayStyle#">#DO_VAR["Dimension"]#</td>
					<!--- Custom Samick --->
					<td align="center" class="formtitle">#DO_VAR["Color"]#</td>
					<td align="center" class="formtitle">#DO_VAR["ItemBrand"]#</td>
					<td align="center" class="formtitle">#DO_VAR["eHRMType"]#</td>
					<!--- end Custom Samick --->
                    <td align="center" class="formtitle">#DO_VAR["Qty"]#</td>
                    <td align="center" class="formtitle">#DO_VAR['UnitType']#</td>
                    <td align="center" class="formtitle">#DO_VAR['Qty']# 2</td>
                    <td align="center" class="formtitle">#DO_VAR['UnitType']# 2</td>
					
					<!--- Revisi SO harus bisa meskipun sudah ada Shipping Inst dan SN ---->
					<td align="center" class="formtitle" <cfif task eq "save">style="display:none"</cfif>>#DO_VAR["ReservedQty"]#</td>
                    <td align="center" class="formtitle" <cfif task eq "save">style="display:none"</cfif>>#DO_VAR['UnitType']#</td>
                    <td align="center" class="formtitle" <cfif task eq "save">style="display:none"</cfif>>#DO_VAR['ReservedQty']# 2</td>
                    <td align="center" class="formtitle" <cfif task eq "save">style="display:none"</cfif>>#DO_VAR['UnitType']# 2</td>
					<!--- end --->
					
                    <td align="center" class="formtitle">#DO_VAR["UnitPrice"]# <br>
                        <span id="idUnitPrice">(#DO_VAR["Converted"]#)</span></td>
                    <!---add by Np Agts 2010 -- sales trade agreement--->
                    <td align="center" class="formtitle">#DO_VAR["DiscValue"]#</td>
                    <!---end--->
                    <td align="center" class="formtitle">#DO_VAR["Discount"]# <br>(%)</td>

                   <!--- <td align="center" class="formtitle">#DO_VAR["ExtraPrice"]# <br></td>--->
                    <td align="center" class="formtitle">#DO_VAR["Amount"]# <br>
                        <span id="idAmount">(#DO_VAR["Converted"]#)</span></td>
                    <td align="center" class="formtitle">#DO_VAR["Tax"]# 1<br></td>
                    <td align="center" class="formtitle">#DO_VAR["Tax"]# 2<br></td>
                    <!--- <td align="center" class="formtitle">#DO_VAR["OthersDesc"]#</td> --->
                    <td align="center" class="formtitle" colspan="2">#do_var['estimatedate']#</td>
                    <td align="center" class="formtitle" id="allocateTo"><cfif rdoAllocate eq 0>
                      #DO_VAR['ProjectComponent']#
                          <cfelse>
                      #DO_VAR['CostCenter']#
                    </cfif></td>
                    <!--- <td align="center" class="formtitle">#DO_VAR['Colour']#</td> --->
                    <!--- <td align="center" class="formtitle">#DO_VAR['is_install']#</td> --->
                  </tr>
                  <cfset dorder=0>
                  <cfif rbTypeDoc NEQ 3>
					<cfif Task eq "save">
                      <cfif qdetail.recordcount>
                          <cfloop index="i" from="1" to="#qDetail.RecordCount#">
							
								<cfquery name="qGetSNQty" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
									SELECT TACCSN_ITEM.ITEM_CODE,
										   SUM(TACCSN_ITEM.QTY) AS SN_QTY 
								    from TAccSN_Item
									INNER JOIN TACCSN_HEADER 
										ON TACCSN_HEADER.SN_NUMBER=TACCSN_ITEM.SN_NUMBER
									WHERE TACCSN_ITEM.SO_NUMBER='#SONum#'
									AND TACCSN_ITEM.ITEM_CODE='#qDetail.Item_Code[i]#'
									AND TACCSN_ITEM.DIMENSION_ID='#qDetail.Dimension_ID[i]#'
									AND ISNULL(TACCSN_HEADER.ISVOID,0)=0
									AND TACCSN_HEADER.APPROVAL_STATUS <> 4
									<cfif #lstSNDoc# neq "">
									AND TACCSN_HEADER.SN_NUMBER NOT IN (#listqualify(lstSNDoc,"'")#)
									</cfif>
									GROUP BY TACCSN_ITEM.ITEM_CODE
								</cfquery>
							  
							  	<cfquery name="qGetShipInstQty" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">									
									select SUM(TAccShippingInst_Detail.Qty) AS SI_Qty 
									from 
									TAccShippingInst_Detail
									inner join TAccShippingInst_Header 
										ON TAccShippingInst_Detail.ShipInst_Number=TAccShippingInst_Header.ShipInst_Number
									where TAccShippingInst_Header.doc_status <> 2
									AND TAccShippingInst_Header.doc_status <> 3
									AND TAccShippingInst_Detail.Item_Code='#qDetail.Item_Code[i]#'
									AND TAccShippingInst_Detail.Dimension_ID='#qDetail.Dimension_ID[i]#'	
									AND TAccShippingInst_Detail.SO_Number='#SONum#'
									AND isnull(TAccShippingInst_Header.isClose,0)=0
									GROUP BY TAccShippingInst_Detail.Item_Code								
							  	</cfquery>
								
								<cfset SNQty = val(qGetSNQty.SN_Qty) + val(qGetShipInstQty.SI_Qty)>
									
                            <tr id="tr#i#">
                              <td align="center" class="formtext" style="vertical-align:top"><cfif val(qDetail.config_level[i]) eq 0>
                                <input type="Checkbox" name="chk" onClick="tickItem(this,#i#)" value="#i#"> <!---<cfif val(SNQty) gt 0>disabled</cfif>--->
                                <cfset dorder=dorder+1>
                              </cfif>
                                  <cfset prt=Iif(val(qDetail.config_level[i]),"qDetail.parent_item[i]",0)>
                                  <cfset ppath=Iif(val(qDetail.config_level[i]),"qDetail.parent_path[i]",0)>
                                  <input type="Hidden" name="parent_item_#i#" value="#prt#">
                                  <input type="Hidden" name="parent_path_#i#" id="parent_path_#i#" value="#ppath#">                          </td>
                              <td align="left" class="formtext" style="vertical-align:top" nowrap><cfif val(qDetail.config_level[i])>
                                <input type="Checkbox" name="chk" onClick="tickItem(this,#i#)" disabled value="#i#">
                                #repeatstring("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",qDetail.config_level[i]-1)#&nbsp;&nbsp;<IMG src="#Application.stApp.Upload_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/lastnode.gif" border="0">&nbsp;
                                </cfif>
                                  <input type="text" name="txtPartNo_#i#" id="txtPartNo_#i#" value="#qDetail.Item_Code[i]#" class="inplabel" width="10" size="15" readonly>
                                &nbsp;
                                  <input type="hidden" name="hdnLevel_#i#" value="#qDetail.config_level[i]#">
                                  <input type="hidden" name="hdnRatio_#i#" value="#qDetail.config_ratio[i]#">
                                  <cfquery name="qConvertUnit1to2" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                            SELECT * FROM TPPICUnitConverter
                                            WHERE Status = 1
                                            AND Unit_Type_ID1='#qDetail.Unit_Type[i]#'
                                            AND Unit_Type_ID2='#qDetail.Unit_Type2[i]#'
                                        </cfquery>
                                  <cfquery name="qConvertUnit2to1" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                            SELECT * FROM TPPICUnitConverter
                                            WHERE Status = 1
                                            AND Unit_Type_ID1='#qDetail.Unit_Type2[i]#'
                                            AND Unit_Type_ID2='#qDetail.Unit_Type[i]#'
                                        </cfquery>
                                  <!---<cfdump var="#qConvertUnit2to1#">--->
                                  <input type="Hidden" name="txtUnitConv1to2#i#" size="10" value="#qConvertUnit1to2.Scale#">
                                  <input type="Hidden" name="txtUnitConv2to1#i#" size="10" value="#qConvertUnit2to1.Scale#">
                                  <input type="hidden" name="hdnMatrixItem_#i#">
                                  <input type="hidden" name="hdnEventQty_#i#">
                                  <input type="hidden" name="hdnEventPrice_#i#">
                                  <input type="hidden" name="hdnEventDiscAmount_#i#">
                                  <input type="hidden" name="hdnEventDiscPercent_#i#">
                                  <input type="Hidden" name="hidQtyFree_#i#">                          </td>
							  	  
                              <td align="left" class="formtext" nowrap style="vertical-align:top">#htmleditformat(qDetail.Item_Name[i])#

                                <input type="hidden" name="txtDesc_#i#" value="#htmleditformat(qDetail.Item_Name[i])#" size="20" maxlength="30" valign="center" readonly>
                                <br>
                                  <cfset colorlist ="">
                                  <input type="Hidden" id="hdncolor_#i#" name="hdncolor_#i#" value="">
                                  <input type="Hidden" name="hdnColorItem_#i#" value="0">
                                  <input type="hidden" name="hdndorder_#i#" value="#dorder#"></td>
                              <td align="left" class="formtext" nowrap>
							  	 <input type="text" name="txtNotes_#i#" value="#qDetail.notes[i]#">
							  </td>
                              <td align="left" class="formtext" nowrap style="vertical-align:top;#displayStyle#"><a
                               href="javascript:void(0);"
                               onClick="showLookup(#i#);" 
                               style="text-decoration: none;"><img 
                               id="imbPickDimension_#i#" border="0" style="display: ;" 
                               src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/dimension_picker.gif" 


                               onmouseover="return overlib('#DO_VAR['CHANGEITEMDIMENSION']#');" 
                               onMouseOut="return nd();" width="15" height="13" /></a>&nbsp;<input type="text"
                               name="txtDimensionName_#i#" id="txtDimensionName_#i#" 
                               value="#HTMLEDITFORMAT(qDetail.Dimension_Name[i])#" 
                               class="inplabel" readonly /><input type="hidden" 
                               name="txtDimensionID_#i#" id="txtDimensionID_#i#" 
                               value="#qDetail.Dimension_ID[i]#" /></td>
							   
							   <!--- Custom Samick --->
								<td align="left" valign="top" class="formtext">
									<span id="txtColorItem_#i#">
									<cfif len(qDetail.item_color[i]) AND structkeyexists(strctColor,qDetail.item_color[i])>
										#HTMLEDITFORMAT(strctColor[qDetail.item_color[i]])#
									</cfif>
									</span>
									<input type="hidden" name="txtColorItem_#i#" id="txtColorItem_#i#" 
									<cfif len(qDetail.item_color[i]) AND structkeyexists(strctColor,qDetail.item_color[i])>
										value="#HTMLEDITFORMAT(strctColor[qDetail.item_color[i]])#"
									<cfelse>
										value=""	
									</cfif>
									size="20" width="30" readonly />
								</td>
								<td align="left" valign="top" class="formtext">
								<span id="txtBrandItem_#i#">#HTMLEDITFORMAT(qDetail.Item_size[i])#</span>
								<input type="hidden" name="txtBrandItem_#i#" id="txtBrandItem_#i#" value="#HTMLEDITFORMAT(qDetail.Item_size[i])#" size="20" width="30" readonly />
								</td>
								<td align="left" valign="top" class="formtext">
								<span id="txtTypeItem_#i#">#HTMLEDITFORMAT(qDetail.Item_description[i])#</span>
								<input type="hidden" name="txtTypeItem_#i#" id="txtTypeItem_#i#" value="#HTMLEDITFORMAT(qDetail.Item_description[i])#" size="20" width="30" readonly />
								</td>
							  <!--- end Custom Samick --->
                              
                              <td align="center" class="formtext" style="vertical-align:top"><!--- #numberformat(val(qDetail.Qty[i]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")# --->
                                 <input type="text"  style="text-align:right" id="txtQty_#i#" name="txtQty_#i#" 
                                        <cfif val(qDetail.config_level[i])> class="inpdim" readonly <cfelse> onBlur="getPrice(#i#); getDiscount(#i#);getDiscountTotal();getFreeItemTotal();qty_ratio('#i#', this);setCurrTax(); setCurr(); calcAmount(#i#); recalcTotal(); decimalinForMoney(this);calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);" onChange="getPrice(#i#); getDiscount(#i#);qty_ratio('#i#', this);getDiscountTotal();getFreeItemTotal();"</cfif>
                                        value="#val(qDetail.Qty[i])#" size="4"  maxlength="10"  valign="center" >                          </td>
                              <td align="center" class="formtext" style="vertical-align:top"><input type="text" name="txtUnitType#i#" size="10" value="#qDetail.Unit_Desc[i]#" readonly class="inpdim">                          </td>
                              <!---
                                <td align="center" class="formtext">
                                    <input type="text"  style="text-align:right"  name="txtQty2_#i#"  value="#numberformat(val(qDetail.Qty2[i]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="4" maxlength="10" valign="center" readonly  onBlur="getQty(1);setCurrTax(); setCurr();calcAmount(#i#);  calcAmountAll(); calcTax(); GetAmountGrand(); predecimalin(document.frmNew.txtTotAmount); predecimalin(document.frmNew.txtGrandTotal); predecimalin(document.frmNew.txtTotTaxConv); predecimalin(document.frmNew.txtTotDeductConv);" onKeyUp="decimalinForMoney(this);" onKeyPress="event.returnValue=isIntOnly();">
                                </td>
                                                  --->
                              <cfif not isdefined("qDetail.Qty2")>
                                <cfquery name="qDua" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
                                          SELECT Scale FROM TPPICUnitConverter
                                          WHERE Status = 1
                                          AND Unit_Type_ID1='#qDetail.Unit_Type[i]#'
                                          And Unit_Type_ID2='#qDetail.Unit_Type2[i]#'
                                   </cfquery>
                                <cfif qDua.recordcount>
                                  <cfset Qty2=qDetail.Qty[i]*val(qDua.Scale)>
                                  <cfelse>
                                  <cfset Qty2=qDetail.Qty[i]>
                                </cfif>
                                <cfelse>
                                <cfset Qty2=qDetail.Qty2[i]>
                              </cfif>
                              <td align="center" class="formtext" style="vertical-align:top"><!--- <cfif val(qDetail.config_level[i])>
                                        <input type="text"  style="text-align:right"  name="txtQty2_#i#" readonly class="inpdim"  value="#numberformat(val(Qty2),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="4" maxlength="10" valign="center">
                                    <cfelse>
                                        <input type="text"  style="text-align:right"  name="txtQty2_#i#"  value="#numberformat(val(Qty2),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="4" maxlength="10" valign="center"  onBlur="qty_ratio2(#i#, this);"  onKeyPress="return isIntOnlyNew(event);">						
                                    </cfif> --->
                                  <input type="text"  style="text-align:right"  name="txtQty2_#i#" readonly class="inpdim"  value="#numberformat(val(Qty2),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="4" maxlength="10"  valign="center">                          </td>
                              <td align="center" class="formtext" style="vertical-align:top"><input type="text" name="txtUnitType2#i#" size="10" value="#qDetail.Unit_Desc2[i]#" readonly class="inpdim">                          </td>
                              <cfset ItemQty = val(qDetail.Qty[i])>
							  
							  
							  
							  <!--- SN Qty --->							  
							  	
							  <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
                                 <input type="text"  style="text-align:right" id="txtSNQty_#i#" name="txtSNQty_#i#" class="inpdim" readonly value="#val(SNQty)#" size="4"  maxlength="10"  valign="center" >                          
							  </td>
                              <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
							  	 <input type="text" name="txtSNUnitType#i#" size="10" value="#qDetail.Unit_Desc[i]#" readonly class="inpdim">
							  </td>
                             
                              <!---<cfif not isdefined("SNQty2")>--->
                                <cfquery name="qDua" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
                                          SELECT Scale FROM TPPICUnitConverter
                                          WHERE Status = 1
                                          AND Unit_Type_ID1='#qDetail.Unit_Type[i]#'
                                          And Unit_Type_ID2='#qDetail.Unit_Type2[i]#'
                                   </cfquery>
                                <cfif qDua.recordcount>
                                  <cfset SNQty2=SNQty*val(qDua.Scale)>
                                <cfelse>
                                  <cfset SNQty2=SNQty>
                                </cfif>
							  <!---	
                              <cfelse>
                                <cfset SNQty2=SNQty2>
                              </cfif> --->
                              <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif> >
                                  <input type="text"  style="text-align:right"  name="txtSNQty2_#i#" readonly 
								  class="inpdim"  value="#numberformat(val(SNQty2),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" 
								  size="4" maxlength="10"  valign="center">
						       </td>
                              <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
							  <input type="text" name="txtSNUnitType2#i#" size="10" value="#qDetail.Unit_Desc2[i]#" readonly class="inpdim"> 
							  </td>                              
							  <!--- end SN Qty --->
							  
							  
                              <td align="center" class="formtext" style="vertical-align:top"><input type="text"  style="text-align:right" 

                                        name="txtConvertedUnitPrice_#i#" id="txtConvertedUnitPrice_#i#" 
                                        value="#Numberformat(val(qDetail.UnitPrice[i]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" 
                                        size="12" maxlength="15" valign="center" 

                                        <cfif val(qDetail.generate_flag[i]) eq 2>
                                        readonly class="inplabel"
                                        <cfelse>
                                        onblur="setCurrTax(); setCurr();calcAmount(#i#); recalcTotal();getDiscountTotal();getFreeItemTotal(); calculateTermOfPayment();" 
                                        onKeyPress="return isIntOnlyNew(event);"
                                         onChange="changeBGcolor(this);getDiscountTotal();getFreeItemTotal();recalcTotal();calculateTermOfPayment();"
                                        </cfif>>
                                  <!--- <input type="text"  style="text-align:right" name="txtConvertedUnitPrice#i#" value="#Numberformat(val(qDetail.base_UnitPrice[i]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="12" <cfif qDetail.pricetype[i] eq "1">readonly</cfif> maxlength="15" valign="center"  onblur="setCurrTax(); setCurr();calcAmount(#i#);  calcAmountAll(); calcTax(); GetAmountGrand(); predecimalin(document.frmNew.txtTotAmount); predecimalin(document.frmNew.txtGrandTotal); predecimalin(document.frmNew.txtTotTaxConv); predecimalin(document.frmNew.txtTotDeductConv);" onKeyPress="return isIntOnlyNew(event);" onKeyUp="decimalinForMoney(this);"> --->
                                  <input type="hidden" name="HidBase_ConvertedUnitPrice_#i#" value="">                          </td>
                              <cfset normal_price = val(qDetail.UnitPrice[i])>
                              <cfset disc = "">
                              <cfset discountv	= "">
                              <cfset precious = normal_price * ItemQty>
                              <!--- <cfif #qDetail.Disc_Percentage[i]# neq "" and listlen(qDetail.Disc_Percentage[i],"~") eq listlen(qDetail.disc_type[i],"~")>
                                        <cfset discvalue = qDetail.Disc_Percentage[i]>
                                        <cfset disctype = qDetail.disc_type[i]>
                                        
                                        <cfset counter = 0>
                                        <cfloop list="#discvalue#" index="discv" delimiters="~">
                                            <cfset counter = counter + 1>
                                            <cfset disct = ListGetAt(disctype,counter,"~")>
                                            <cfif disct eq 2>
                                                <cfset disc = "#discv#%">
                                                <cfset precious = precious - (precious * discv/100)>
                                            <cfelseif disct eq 1>
                                                <cfset disc = "(-#DecimalFormat(discv)#)">
                                                <cfset precious = precious - discv>
                                            <cfelseif disct eq 3>
                                                <cfset disc = "">
                                                <cfset discountv = "">
                                                <cfset harga_item = discv>
                                                <cfset precious = discv * itemqty>
                                                <!--- <cfset discount_value_curr = "">
                                                <cfset discount_type_curr = ""> --->
                                            </cfif>
                                                        
                                            <cfif len(discountv)>

                                                <cfset discountv = discountv & "+" &  disc>
                                            <cfelse>
                                                <cfset discountv = disc>
                                            </cfif>
                                                    
                                            <cfif discountv eq ""><cfset discountv = "-"></cfif>
                                            <!--- <cfset discount_value_curr = ListAppend(discount_value_curr,discv,"~")>
                                            <cfset discount_type_curr = ListAppend(discount_type_curr,disct,"~")> ---> 
                                        </cfloop>
                                        <cfset discount_percent = discountv>
                                    </cfif> --->
                              <!---add by NP Agts 2010 -- sales trade agreement --->
                              <td align="center" class="formtext" style="vertical-align:top">
									<input type="text" style="text-align:right" onChange="changeBGcolor(this); " name="txtDisc_#i#" id="txtDisc_#i#" value="#NumberFormat(qDetail.Disc_Value[i])#" class="inpdim" size="10" maxlength="10" valign="center" onBlur="calcAmount(#i#); recalcTotal();calcAmountAll();calculateTermOfPayment();">
                                    <input type="hidden" name="hdnDisc_#i#" value="#qDetail.Disc_Value[i]#">
                              </td>
                              <!---end--->
                              <td align="center" class="formtext" style="vertical-align:top">
                                  <!--- randytia 26-07-2010 ---><input type="text" style="text-align:right" onChange="changeBGcolor(this);checkDiscAll(this);" name="txtDiscount1#i#" id="txtDiscount1#i#" value="#qDetail.Disc_Percentage[i]#" size="10" maxlength="10" valign="center" onBlur="calcAmount(#i#); recalcTotal();calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);" ><!--- class="inpdim" ---><!--- end --->
                                  <input type="hidden" name="txtDiscv_#i#" value="#qDetail.Disc_Percentage[i]#">
                                  <input type="hidden" name="txtDiscType_#i#" value="#qDetail.disc_type[i]#">

                                  <input type="hidden" style="text-align:left" name="txtUnitId_#i#" value="#val(qDetail.Unit_Type[i])#" readonly>
                                  <input type="hidden" style="text-align:left" name="txtUnitId2_#i#" value="#val(qDetail.Unit_Type2[i])#" readonly>                              </td>
                              
                                  
           							<!--- extra price tidak disebutkan di penawaran, jadi kalao data diambil dari quotation, tidak ada extra price --->
                                  <!--- <input type="text" readonly  style="text-align:right" name="txtExtra#i#" value="#NumberFormat(0,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="10" maxlength="15" valign="center"  onblur="setCurrTax(); setCurr();calcAmount(#i#);  calcAmountAll(); calcTax(); GetAmountGrand(); predecimalin(document.frmNew.txtTotAmount); predecimalin(document.frmNew.txtGrandTotal); predecimalin(document.frmNew.txtTotTaxConv); predecimalin(document.frmNew.txtTotDeductConv);" onKeyUp="decimalinForMoney(this);" onKeyPress="return isIntOnlyNew(event);"> --->
                                  <input type="hidden" style="text-align:right" name="txtExtra_#i#" value="#NumberFormat(0,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="10" maxlength="15" valign="center"  onBlur="setCurrTax(); setCurr();calcAmount(#i#);  recalcTotal();decimalinForMoney(this);calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);">                        
                              <!--- <input type="hidden" readonly  style="text-align:right" name="txtExtra_#i#" value="#NumberFormat(0,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="10" maxlength="15" valign="center"  onblur="setCurrTax(); setCurr();calcAmount(#i#);  recalcTotal();decimalinForMoney(this);" onKeyPress="return isIntOnlyNew(event);"> --->
                              <td align="center" class="formtext" style="vertical-align:top"><input type="text"  style="text-align:right" name="txtConvertedAmount_#i#" value="#NumberFormat(val(qDetail.TotalPrice[i]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="12" maxlength="15" valign="center" readonly class="inplabel" >
                                  <input type="hidden" name="HidBase_ConvertedAmount_#i#" value="">                          </td>
                              <td align="center" class="formtext" style="vertical-align:top"><cfset tax1=qDetail.Tax_Code1[i]>
                                  <select name="selTax1_#i#" id="selTax1_#i#" onChange="calcAmount(#i#); calcTax(); GetAmountGrand(); setCurrTax(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);calculateTermOfPayment();">
                                    <option value="0|0|+">#DO_VAR["None"]#
                                      <cfloop query="qTaxType">
                                                                <cfset temp="#Tax_Code#|#NumberFormat(Tax_Rate,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#Tax_operator#">
                                                                <option value="#temp#" <cfif tax1 eq Tax_Code>selected</cfif>>
                                        #Tax_Name#
                                      </cfloop>
                                  </select>
                                  <input type="hidden" name="txtTaxAmount1_#i#" <cfif isdefined("qDetail.tax_amount1")> value="#qDetail.tax_amount1[qdetail.currentrow]#" <cfelse> value="0"</cfif>>
                                  <input type="hidden" name="hidBase_TaxAmount1_#i#" <cfif isdefined("qDetail.base_tax_amount")> value="#qDetail.base_tax_amount[qdetail.currentrow]#" <cfelse> value="0"</cfif>>                          </td>
                              <td align="center" class="formtext" style="vertical-align:top"><cfset tax2=qDetail.Tax_Code2[i]>
                                  <select name="selTax2_#i#" id="selTax2_#i#" onChange="calcAmount(#i#); calcTax(); GetAmountGrand(); setCurrTax(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);calculateTermOfPayment();">

                                    <option value="0|0|+">#DO_VAR["None"]#
                                      <cfloop query="qTaxType">
                                                                <cfset temp="#Tax_Code#|#NumberFormat(Tax_Rate,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#Tax_operator#">
                                                                <option value="#temp#" <cfif tax2 eq Tax_Code>selected</cfif>>
                                        #Tax_Name#
                                      </cfloop>

                                  </select>
                                  <input type="hidden" name="txtTaxAmount2_#i#" value="0">
                                  <input type="hidden" name="hidBase_TaxAmount2_#i#" value="0">                          </td>
                              <!--- <td align="center" class="formtext">
                                        <input type="Text" name="txtOthers#i#" size="20" maxlength="50">
                                    </td> ---->
                              <input type="hidden" name="txtOthers_#i#" size="20" maxlength="50">
                              <td align="center" class="formtext" style="vertical-align:top" nowrap><!--- <input type="Text" id="txtEstimateDate_#i#" name="txtEstimateDate#i#" size="10">&nbsp;
                                        <img src="#Application.stApp.Upload_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/date.gif" onMouseUp="getCalendarFor(document.frmNew.txtEstimateDate#i#)">
             --->
                                  <cfset Local.ETAText = ""/>
                                  <cfset Local.ETAItem = ""/>
                                  <cfset Local.ETAValue = ""/>
                                  <cfif isDefined("qsalesDetail") and val(qDetail.config_level[i]) eq 0>
                                    <cfset dtmValue = #DateFormat(qDetail.EstimateDate[i],"mm/dd/yyyy")#>
                                    <script type="text/javascript">SunFishERP_DateTimePicker('txtEstimateDate_#i#','#dtmValue#');</script>
                                    <cfset dcf_Identity=dcf_Identity+1>
                                    <cfquery name="qGetETA" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                                 select distinct TAccSO_ETA.*  from TAccSO_ETA
                                                                                              
                                                where TAccSO_ETA.SO_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SONum#"/>
                                                and TAccSO_ETA.Item_Code=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qDetail.Item_Code[i]#"/>
                                                and dimension_id = #qDetail.dimension_id[i]#
                                            </cfquery>
                                    <cfif qGetETA.recordCount>
                                      <cfset Local.ETAText = ""/>
                                    </cfif>
                                    <cfloop query="qGetETA">
                                      <cfset Local.ETAItem = DateFormat(qGetETA.EstimateDate,"mm/dd/yyyy") & "|" & qGetETA.Qty />

                                      <cfset Local.ETAValue = ListAppend(Local.ETAValue,Local.ETAItem) />
                                      <cfset Local.ETAText = Local.ETAText & "<span style='display:block;font-size:8pt'>" & DateFormat(qGetETA.EstimateDate,"dd/mm/yyyy") & " : " & qGetETA.Qty &  "</span>"/>
                                    </cfloop>
                                  <cfelse>
                                  	<cfset dtmValue = #DateFormat(now(),"mm/dd/yyyy")#>
                                    <script type="text/javascript">SunFishERP_DateTimePicker('txtEstimateDate_#i#','#dtmValue#');</script>
                                  </cfif>
                                  <input type="hidden" name="txtEstimateDateSplit_#i#" id="txtEstimateDateSplit_#i#" value="#Local.ETAValue#" />
																	<cfif task eq 'edit'>
                                 		 <input type="hidden" name="txtSODate" id="txtSODate" value="#qSales.SO_Date#" />
                                  </cfif>
                                  <span id="lnkEstimateDateSplit#i#">#Local.ETAText#</span> </td>
                              <td class="formtext" style="vertical-align:top"><cfif val(qDetail.config_level[i]) eq 0>
                                <a name="lnkEstimateDateSplit#i#" style="display:block" href="javascript:void(0)" onClick="splitETA(#i#,#dcf_Identity#)"><IMG src="#Application.stApp.Web_Path[1]#/eaccounting/images/list.gif" alt="Multiple" align="absmiddle" border="0"></a>
                                <cfelse>

                                &nbsp;

                              </cfif></td>
                              <td align="center" class="formtext" style="vertical-align:top"><select name="selComponent_#i#">
                                  <option value="0">..::[#DO_VAR['eHRMNone']#]::..</option>
                                  <cfloop query="qGetComponent">
                                    <option value="#qGetComponent.Comp_ID#">#Comp_Name#</option>
                                  </cfloop>
                                </select>                          </td>
                              <!--- <td align="center" class="formtext" style="vertical-align:top">
                                        <cfif val(qDetail.config_level[i]) eq 0><input type="Checkbox" name="chkinstall_#i#" value="#qDetail.is_install[i]#" <cfif qDetail.is_install[i] eq 1> checked </cfif>><cfelse>&nbsp;</cfif>
                                    </td> --->

                            </tr>
                            <input type="hidden" name="txtCurrencyID_#i#" value="#qDetail.currency_id[i]#">
                            <input type="hidden" name="txtPriceType_#i#" value="#qDetail.pricetype[i]#">
                            <input type="hidden" name="txtOriginPrice_#i#" value="#qDetail.UnitPrice[i]#">
                            <input type="hidden" name="HidBase_ConvertedUnitPrice_#i#" value="#val(qDetail.unitprice[i])#">
                            <input type="hidden" name="HidBase_ConvertedUnitPrice2_#i#" value="#val(qDetail.unitPrice[i])#">
                            <input type="hidden" name="txtCS_#i#" value="">
                            <input type="hidden" name="hid_generate_flag_#i#" value="#val(qDetail.generate_flag[i])#">
                            <!---
                                JADI DOUBLE2 BOSS ... DI ATAS UDAH ADA KOK DI BUAT LAGI ?? bvnbv
								Nyantai aj ngomongnya bos, gak usah nyolot!!!!!!!
                                
                                <input type="hidden" name="parent_item_#i#" value="#qDetail.parent_item[i]#">	
                                <input type="hidden" name="parent_path_#i#" value="#qDetail.parent_path[i]#">--->
                            <cfset jumrowloop = jumrowloop + 1>
                          </cfloop>
                        <cfelse>
                        <cfif isdefined("rowCount")>
                          <cfloop from="1" to="#rowCount#" index="idrw">
                            <cfif isdefined("HDNLEVEL_#idrw#")>
							
							<cfquery name="qGetSNQty" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
									SELECT TACCSN_ITEM.ITEM_CODE,
										   SUM(TACCSN_ITEM.QTY) AS SN_QTY 
								    from TAccSN_Item
									INNER JOIN TACCSN_HEADER 
										ON TACCSN_HEADER.SN_NUMBER=TACCSN_ITEM.SN_NUMBER
									WHERE TACCSN_ITEM.SO_NUMBER='#SONum#'
									AND TACCSN_ITEM.ITEM_CODE='#qDetail.Item_Code[idrw]#'
									AND TACCSN_ITEM.DIMENSION_ID='#qDetail.Dimension_ID[idrw]#'
									AND ISNULL(TACCSN_HEADER.ISVOID,0)=0
									AND TACCSN_HEADER.APPROVAL_STATUS <> 4
									<cfif #lstSNDoc# neq "">
									AND TACCSN_HEADER.SN_NUMBER NOT IN (#listqualify(lstSNDoc,"'")#)
									</cfif>
									GROUP BY TACCSN_ITEM.ITEM_CODE
								</cfquery>
							  
							  	<cfquery name="qGetShipInstQty" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">									
									select SUM(TAccShippingInst_Detail.Qty) AS SI_Qty 
									from 
									TAccShippingInst_Detail
									inner join TAccShippingInst_Header 
										ON TAccShippingInst_Detail.ShipInst_Number=TAccShippingInst_Header.ShipInst_Number
									where TAccShippingInst_Header.doc_status <> 2
									AND TAccShippingInst_Header.doc_status <> 3
									AND TAccShippingInst_Detail.Item_Code='#qDetail.Item_Code[idrw]#'
									AND TAccShippingInst_Detail.Dimension_ID='#qDetail.Dimension_ID[idrw]#'	
									AND TAccShippingInst_Detail.SO_Number='#SONum#'
									AND isnull(TAccShippingInst_Header.isClose,0)=0
									GROUP BY TAccShippingInst_Detail.Item_Code								
							  	</cfquery>
								
								<cfset SNQty = val(qGetSNQty.SN_Qty) + val(qGetShipInstQty.SI_Qty)>
								
                            <tr id="tr#idrw#">
                              <td align="center" class="formtext" style="vertical-align:top"><cfif val(evaluate("HDNLEVEL_#idrw#")) eq 0>
                                <input type="Checkbox" name="chk" onClick="tickItem(this,#idrw#)" value="#idrw#"> <!---<cfif val(SNQty) gt 0>disabled</cfif>--->

                                <cfset dorder=dorder+1>
                              </cfif>
                                  <cfset prt = "0">

                                <cfset ppath = "0">
                                  <cfif val(evaluate("HDNLEVEL_#idrw#"))>
                                    <cfset prt = evaluate("PARENT_ITEM_#idrw#")>
                                  </cfif>
                                  <cfif val(evaluate("HDNLEVEL_#idrw#"))>
                                    <cfset prt = evaluate("parent_path_#idrw#")>
                                  </cfif>
                                  <input type="Hidden" name="parent_item_#idrw#" value="#prt#">

                                  <input type="Hidden" name="parent_path_#idrw#" id="parent_path_#idrw#" value="#ppath#">                            </td>
                              <td align="left" class="formtext" style="vertical-align:top" nowrap><cfif val(evaluate("HDNLEVEL_#idrw#"))>
                                <input type="Checkbox" name="chk" onClick="tickItem(this,#idrw#)" disabled value="#idrw#">
                                #repeatstring("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",val(evaluate("HDNLEVEL_#idrw#")))#&nbsp;&nbsp;<IMG src="#Application.stApp.Upload_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/lastnode.gif" border="0">&nbsp;
                                </cfif>
                                  <input type="text" name="txtPartNo_#idrw#" id="txtPartNo_#idrw#" value="#evaluate('txtPartNo_#idrw#')#" class="inplabel" width="10" size="15" readonly>
                                &nbsp;
                                  <input type="hidden" name="hdnLevel_#idrw#" value="#val(evaluate('HDNLEVEL_#idrw#'))#">
                                  <input type="hidden" name="hdnRatio_#idrw#" value="#val(evaluate('HDNRATIO_#idrw#'))#">
                                  <cfquery name="qConvertUnit1to2" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                          SELECT * FROM TPPICUnitConverter
                                          WHERE Status = 1
                                          AND Unit_Type_ID1='#evaluate("TXTUNITID_#idrw#")#'
                                          AND Unit_Type_ID2='#evaluate("TXTUNITID2_#idrw#")#'
                                      </cfquery>
                                  <cfquery name="qConvertUnit2to1" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                          SELECT * FROM TPPICUnitConverter
                                          WHERE Status = 1
                                          AND Unit_Type_ID1='#evaluate("TXTUNITID2_#idrw#")#'
                                          AND Unit_Type_ID2='#evaluate("TXTUNITID_#idrw#")#'
                                      </cfquery>
                                  <input type="Hidden" name="txtUnitConv1to2#idrw#" size="10" value="#qConvertUnit1to2.Scale#">
                                  <input type="Hidden" name="txtUnitConv2to1#idrw#" size="10" value="#qConvertUnit2to1.Scale#">
                                  <input type="hidden" name="hdnMatrixItem_#idrw#">
                                  <input type="hidden" name="hdnEventQty_#idrw#">
                                  <input type="hidden" name="hdnEventPrice_#idrw#">
                                  <input type="hidden" name="hdnEventDiscAmount_#idrw#">
                                  <input type="hidden" name="hdnEventDiscPercent_#idrw#">
                                  <input type="Hidden" name="hidQtyFree_#idrw#">                            </td>
                              <td align="left" class="formtext" nowrap style="vertical-align:top">#evaluate('txtdesc_#idrw#')#
                                <input type="hidden" name="txtDesc_#idrw#" value="#htmleditformat(evaluate('txtdesc_#idrw#'))#" size="20" maxlength="30" valign="center" readonly>
                                <br>
                                  <cfset colorlist ="">
                                  <input type="Hidden" id="hdncolor_#idrw#" name="hdncolor_#idrw#" value="">
                                  <input type="Hidden" name="hdnColorItem_#idrw#" value="0">
                                  <input type="hidden" name="hdndorder_#idrw#" value="#dorder#">                            </td>
                              
							  <td align="left" class="formtext" nowrap style="vertical-align:top">
							  	 <input type="text" name="txtNotes_#idrw#" value="#htmleditformat(evaluate('txtNotes_#idrw#'))#">
							  </td>
                              <td align="left" class="formtext" nowrap style="vertical-align:top;#displayStyle#"><a
                               href="javascript:void(0);"
                               onClick="showLookup(#idrw#);" 
                               style="text-decoration: none;"><img 
                               id="imbPickDimension_#idrw#" border="0" style="display: ;" 
                               src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/dimension_picker.gif" 
                               onmouseover="return overlib('#DO_VAR['CHANGEITEMDIMENSION']#');" 
                               onMouseOut="return nd();" width="15" height="13" /></a>&nbsp;<input type="text"
                               name="txtDimensionName_#idrw#" id="txtDimensionName_#idrw#" 
                               value="#HTMLEDITFORMAT(evaluate("txtDimensionName_#idrw#"))#" 
                               class="inplabel" readonly /><input type="hidden" 
                               name="txtDimensionID_#idrw#" id="txtDimensionID_#idrw#" 
                               value="#evaluate("txtDimensionID_#idrw#")#" /></td>
							   
							   <!--- Custom Samick --->
								<td align="left" valign="top" class="formtext">
									<span id="txtColorItem_#idrw#">
									<cfif len(qDetail.item_color[idrw]) AND structkeyexists(strctColor,qDetail.item_color[idrw])>
										#HTMLEDITFORMAT(strctColor[qDetail.item_color[idrw]])#
									</cfif>
									</span>
									<input type="hidden" name="txtColorItem_#idrw#" id="txtColorItem_#idrw#" 
									<cfif len(qDetail.item_color[idrw]) AND structkeyexists(strctColor,qDetail.item_color[idrw])>
										value="#HTMLEDITFORMAT(strctColor[qDetail.item_color[idrw]])#"
									<cfelse>
										value=""	
									</cfif>
									size="20" width="30" readonly />
								</td>
								<td align="left" valign="top" class="formtext">
								<span id="txtBrandItem_#idrw#">#HTMLEDITFORMAT(qDetail.Item_size[idrw])#</span>
								<input type="hidden" name="txtBrandItem_#idrw#" id="txtBrandItem_#idrw#" value="#HTMLEDITFORMAT(qDetail.Item_size[idrw])#" size="20" width="30" readonly />
								</td>
								<td align="left" valign="top" class="formtext">
								<span id="txtTypeItem_#idrw#">#HTMLEDITFORMAT(qDetail.Item_description[idrw])#</span>
								<input type="hidden" name="txtTypeItem_#idrw#" id="txtTypeItem_#idrw#" value="#HTMLEDITFORMAT(qDetail.Item_description[idrw])#" size="20" width="30" readonly />
								</td>
							  <!--- end Custom Samick --->
                              
                              <td align="center" class="formtext" style="vertical-align:top"><!--- #numberformat(val(qDetail.Qty[idrw]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")# --->
                                  <input type="text" style="text-align:right" id="txtQty_#idrw#" name="txtQty_#idrw#" 
                                      <cfif val(evaluate("HDNLEVEL_#idrw#"))> class="inpdim" readonly <cfelse> onBlur="getPrice(#idrw#); getDiscount(#idrw#);getDiscountTotal();getFreeItemTotal();qty_ratio('#idrw#', this);setCurrTax(); setCurr(); calcAmount(#idrw#); recalcTotal(); decimalinForMoney(this);" onKeyPress="return isIntOnlyNew(event);" onChange="getPrice(#idrw#); getDiscount(#idrw#);getDiscountTotal();getFreeItemTotal();qty_ratio('#idrw#', this);"</cfif>
                                      value="#val(evaluate('txtQty_#idrw#'))#" size="4"  maxlength="10"></td>
                              <td align="center" class="formtext" style="vertical-align:top"><input type="text" name="txtUnitType#idrw#" size="10" value="#evaluate('txtUnitType#idrw#')#" readonly class="inpdim">                            </td>
                              <cfif not isdefined("txtQty2_#idrw#")>
                                <cfquery name="qDua" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
                                        SELECT Scale FROM TPPICUnitConverter
                                        WHERE Status = 1
                                          AND Unit_Type_ID1='#evaluate("TXTUNITID_#idrw#")#'
                                          AND Unit_Type_ID2='#evaluate("TXTUNITID2_#idrw#")#'
                                 </cfquery>
                                <cfif qDua.recordcount>
                                  <cfset Qty2=qDetail.Qty[idrw]*val(qDua.Scale)>
                                  <cfelse>
                                  <cfset Qty2=qDetail.Qty[idrw]>
                                </cfif>
                                <cfelse>
                                <cfset Qty2=qDetail.Qty2[idrw]>
                              </cfif>
                              <td align="center" class="formtext" style="vertical-align:top"><input type="text"  style="text-align:right"  name="txtQty2_#idrw#" readonly class="inpdim"  value="#numberformat(val(evaluate('txtQty2_#idrw#')),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="4" maxlength="10"  valign="center">                            </td>
                              <td align="center" class="formtext" style="vertical-align:top"><input type="text" name="txtUnitType2#idrw#" size="10" value="#evaluate('txtUnitType2#idrw#')#" readonly class="inpdim">                            </td>

                              <cfset ItemQty = val(evaluate("TXTQTY_#idrw#"))>
							  
							  
							  <!--- SN Qty --->							  
							  	
							  <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
                                 <input type="text"  style="text-align:right" id="txtSNQty_#idrw#" name="txtSNQty_#idrw#" class="inpdim" readonly value="#val(SNQty)#" size="4"  maxlength="10"  valign="center" >                          
							  </td>
                              <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
							  	 <input type="text" name="txtSNUnitType#idrw#" size="10" value="#qDetail.Unit_Desc[idrw]#" readonly class="inpdim">
							  </td>
                             
                              <!---<cfif not isdefined("SNQty2")>--->
                                <cfquery name="qDua" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
                                          SELECT Scale FROM TPPICUnitConverter
                                          WHERE Status = 1
                                          AND Unit_Type_ID1='#qDetail.Unit_Type[idrw]#'
                                          And Unit_Type_ID2='#qDetail.Unit_Type2[idrw]#'
                                   </cfquery>								   
                                <cfif qDua.recordcount>
                                  <cfset SNQty2=SNQty*val(qDua.Scale)>
                                <cfelse>
                                  <cfset SNQty2=SNQty>
                                </cfif>
							
							  <!---	
                              <cfelse>
                                <cfset SNQty2=SNQty2>
                              </cfif>
							  --->
                              <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
                                  <input type="text"  style="text-align:right"  name="txtSNQty2_#idrw#" readonly 
								  class="inpdim"  value="#numberformat(val(SNQty2),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" 
								  size="4" maxlength="10"  valign="center">                          </td>
                              <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
							  <input type="text" name="txtSNUnitType2#idrw#" size="10" value="#qDetail.Unit_Desc2[idrw]#" readonly class="inpdim"> 
							  </td>                              
							  <!--- end SN Qty --->
							  
                              <td align="center" class="formtext" style="vertical-align:top"><input type="text"  style="text-align:right" 
                                      name="txtConvertedUnitPrice_#idrw#" id="txtConvertedUnitPrice_#idrw#" 
                                      value="#Numberformat(replace(evaluate('txtConvertedUnitPrice_#idrw#'),",","","ALL"),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" 
                                      size="12" maxlength="15" valign="center" 
                                      <cfif val(evaluate('hid_generate_flag_#idrw#')) eq 2>
                                      readonly class="inplabel"
                                      <cfelse>
                                      onblur="setCurrTax(); setCurr();calcAmount(#idrw#);  recalcTotal();getDiscountTotal();getFreeItemTotal(); decimalinForMoney(this);calculateTermOfPayment();" 
                                      onKeyPress="return isIntOnlyNew(event);"
                                       onChange="changeBGcolor(this);getDiscountTotal();getFreeItemTotal();recalcTotal();calculateTermOfPayment();"
                                      </cfif>>
                                  <input type="hidden" name="HidBase_ConvertedUnitPrice_#idrw#" value=""></td>
                              <cfset normal_price = val(evaluate('txtConvertedUnitPrice_#idrw#'))>
                              <cfset disc = "">
                              <cfset discountv	= "">
                              <cfset precious = normal_price * ItemQty>
                              
                              <td align="center" class="formtext" style="vertical-align:top">
                                  <!--- randytia 26-07-2010 ---><input type="text" style="text-align:right" onChange="changeBGcolor(this);" name="txtDisc_#idrw#" id="txtDisc_#idrw#" value="#evaluate('txtDisc_#idrw#')#"  size="10" maxlength="10" valign="center" onBlur="calcAmount(#idrw#); recalcTotal();calcAmountAll();calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);" ><!--- class="inpdim" ---><!--- end --->
                                  <input type="hidden" name="txtDiscv_#idrw#" value="#evaluate('txtDiscv_#idrw#')#">
                                  <input type="hidden" name="txtDiscType_#idrw#" value="#evaluate('txtDiscType_#idrw#')#">
                                  <input type="hidden" style="text-align:left" name="txtUnitId_#idrw#" value="#val(evaluate('txtUnitId_#idrw#'))#" readonly>
                                  <input type="hidden" style="text-align:left" name="txtUnitId2_#idrw#" value="#val(evaluate('txtUnitId2_#idrw#'))#" readonly></td>
                             <!--- add by NP Agts 2010 -- sales trade agreement--->
                              <td style="vertical-align:top">
								<input type="text" style="text-align:right" onChange="changeBGcolor(this);" name="txtDiscount1#idrw#" id="txtDiscount1#idrw#" value="#evaluate('txtDiscount1#idrw#')#" size="10" maxlength="5" valign="center" onBlur="calcAmount(#idrw#); recalcTotal();calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);">
                               <!--- <input type="hidden" style="text-align:right" name="txtDiscount2#idrw#" value="#evaluate('txtDiscount2#idrw#')#">--->
							 </td>
                             <!---end--->   
                                                
                              <td align="center" class="formtext" style="vertical-align:top"><input type="text"  style="text-align:right" name="txtConvertedAmount_#idrw#" value="#NumberFormat(val(evaluate('txtConvertedAmount_#idrw#')),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="12" maxlength="15" valign="center" readonly class="inplabel" >
                                 	<input type="hidden" style="text-align:right" name="txtExtra_#idrw#" value="#NumberFormat(replace(evaluate('txtExtra_#idrw#'),",","","ALL"),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="10" maxlength="15" valign="center"  onBlur="setCurrTax(); setCurr();calcAmount(#idrw#);  recalcTotal();decimalinForMoney(this);calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);">  
                                  <input type="hidden" name="HidBase_ConvertedAmount_#idrw#" value="#evaluate('HidBase_ConvertedAmount_#idrw#')#">                            </td>
                              <td align="center" class="formtext" style="vertical-align:top"><cfset tax1=listfirst(evaluate("SELTAX1_#idrw#"),"|")>
                                  <select name="selTax1_#idrw#" id="selTax1_#idrw#" onChange="calcAmount(#idrw#); calcTax(); GetAmountGrand(); setCurrTax(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);calculateTermOfPayment();">
                                    <option value="0|0|+">#DO_VAR["None"]#
                                      <cfloop query="qTaxType">
                                                                <cfset temp="#Tax_Code#|#NumberFormat(Tax_Rate,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#Tax_operator#">
                                                                <option value="#temp#" <cfif tax1 eq Tax_Code>selected</cfif>>
                                        #Tax_Name#
                                      </cfloop>

                                  </select>
                                  <input type="hidden" name="txtTaxAmount1_#idrw#" <cfif isdefined("txtTaxAmount1_#idrw#")> value="#val(evaluate('txtTaxAmount1_#idrw#'))#" <cfelse> value="0"</cfif>>

                                  <input type="hidden" name="hidBase_TaxAmount1_#idrw#" <cfif isdefined("hidBase_TaxAmount1_#idrw#")> value="#val(evaluate('hidBase_TaxAmount1_#idrw#'))#" <cfelse> value="0"</cfif>>                            </td>
                              <td align="center" class="formtext" style="vertical-align:top"><cfset tax2=listfirst(evaluate("SELTAX2_#idrw#"),"|")>
                                  <select name="selTax2_#idrw#" id="selTax2_#idrw#" onChange="calcAmount(#idrw#); calcTax(); GetAmountGrand(); setCurrTax(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);calculateTermOfPayment();">
                                    <option value="0|0|+">#DO_VAR["None"]#
                                      <cfloop query="qTaxType">
                                                                <cfset temp="#Tax_Code#|#NumberFormat(Tax_Rate,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#Tax_operator#">
                                                                <option value="#temp#" <cfif tax2 eq Tax_Code>selected</cfif>>
                                        #Tax_Name#
                                      </cfloop>
                                  </select>
                                  <input type="hidden" name="txtTaxAmount2_#idrw#" value="#val(evaluate('txtTaxAmount2_#idrw#'))#">
                                  <input type="hidden" name="hidBase_TaxAmount2_#idrw#" value="#val(evaluate('hidBase_TaxAmount2_#idrw#'))#">                            </td>
                              <input type="hidden" name="txtOthers_#idrw#" size="20" maxlength="50">
                              <td align="center" class="formtext" style="vertical-align:top" nowrap><cfset Local.ETAText = ""/>
                                  <cfset Local.ETAItem = ""/>
                                  <cfset Local.ETAValue = ""/>
                                  <cfif isDefined("TXTESTIMATEDATESPLIT_#idrw#") and val(evaluate("HDNLEVEL_#idrw#")) eq 0>
                                    <cfif Len(Trim(Evaluate("txtEstimateDateSplit_#idrw#"))) neq 0>
										<cfset dtmValue = #DateFormat(listgetat(ListLast(evaluate('TXTESTIMATEDATESPLIT_#idrw#'),","),1,"|"),"mm/dd/yyyy")#>
									<cfelse>
										<cfset dtmValue = #DateFormat(Evaluate("txtEstimateDate_#idrw#"),"mm/dd/yyyy")#>
									</cfif>
                                    <script type="text/javascript">SunFishERP_DateTimePicker('txtEstimateDate_#idrw#','#dtmValue#');</script>
                                    <cfset dcf_Identity=dcf_Identity+1>
                                    <cfquery name="qGetETA" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                              <!---  select distinct TAccSO_ETA.*  from TAccSO_ETA
                                              where SO_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SONum#"/>
                                              and Item_Code=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qDetail.Item_Code[idrw]#"/> --->
                                              
                                                 select distinct TAccSO_ETA.*  from TAccSO_ETA
                                                                                              
                                                where TAccSO_ETA.SO_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SONum#"/>
                                                and TAccSO_ETA.Item_Code=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qDetail.Item_Code[idrw]#"/> 
                                                and dimension_id = #val(qDetail.dimension_id[idrw])#
                                          </cfquery>
                                    <cfif len(trim(evaluate('TXTESTIMATEDATESPLIT_#idrw#')))>
                                      <cfset Local.ETAText = ""/>
                                    </cfif>
                                    <cfloop list="#evaluate('TXTESTIMATEDATESPLIT_#idrw#')#" index="ioo">
                                      <cfset Local.ETAItem = ioo>
                                      <cfset Local.ETAValue = ListAppend(Local.ETAValue,Local.ETAItem) />
                                      <cfset Local.ETAText = Local.ETAText & "<span style='display:block;font-size:8pt'>" & DateFormat(listfirst(listgetat(ioo,1,"|")),"dd/mm/yyyy") & " : " & listlast(listgetat(ioo,2,"|")) &  "</span>"/>
                                    </cfloop>
                                  </cfif>
                                  <input type="hidden" name="txtEstimateDateSplit_#idrw#" id="txtEstimateDateSplit_#idrw#" value="#Local.ETAValue#" />
                                  <span id="lnkEstimateDateSplit#idrw#">#Local.ETAText#</span> </td>
                              <td class="formtext" style="vertical-align:top"><cfif val(evaluate("HDNLEVEL_#idrw#")) eq 0>
                                <a name="lnkEstimateDateSplit#idrw#" style="display:block" href="javascript:void(0)" onClick="splitETA(#idrw#,#dcf_Identity#)"><IMG src="#Application.stApp.Web_Path[1]#/eaccounting/images/list.gif" alt="Multiple" align="absmiddle" border="0"></a>
                                <cfelse>
                                &nbsp;
                              </cfif></td>
                              <td align="center" class="formtext" style="vertical-align:top"><select name="selComponent_#idrw#">
                                  <option value="0">..::[#DO_VAR['eHRMNone']#]::..</option>
                                  <cfloop query="qGetComponent">
                                    <option value="#qGetComponent.Comp_ID#">#Comp_Name#</option>
                                  </cfloop>
                                </select>                            </td>
                            </tr>

                            <input type="hidden" name="txtCurrencyID_#idrw#" value="#evaluate('txtCurrencyID_#idrw#')#">

                            <input type="hidden" name="txtPriceType_#idrw#" value="#evaluate('txtPriceType_#idrw#')#">
                            <input type="hidden" name="txtOriginPrice_#idrw#" value="#evaluate('txtOriginPrice_#idrw#')#">
                            <input type="hidden" name="HidBase_ConvertedUnitPrice_#idrw#" value="#val(evaluate('HidBase_ConvertedUnitPrice_#idrw#'))#">
                            <input type="hidden" name="HidBase_ConvertedUnitPrice2_#idrw#" value="#val(evaluate('HidBase_ConvertedUnitPrice2_#idrw#'))#">

                            <input type="hidden" name="txtCS_#idrw#" value="#evaluate('txtCS_#idrw#')#">
                            <input type="hidden" name="hid_generate_flag_#idrw#" value="#val(evaluate('hid_generate_flag_#idrw#'))#">
                            <cfset jumrowloop = jumrowloop + 1>
                            </cfif>
                          </cfloop>
                        </cfif>
                      </cfif>
                      <cfelse>
                      <cfif isdefined("rowcount") and  qsalesDetail.recordCount neq rowcount>
                                                                                 

                            <cfloop from="1" to="#rowCount#" index="i">
                                <tr id="tr#i#">
                                  <td align="center" class="formtext" style="vertical-align:top">

                                    <cfif val(evaluate('hdnLevel_#i#')) eq 0>
                                        <input type="Checkbox" name="chk" onClick="tickItem(this,#i#)" value="#i#">                                             
                                    </cfif>                                
                                      <input type="Hidden" name="parent_item_#i#" value="#evaluate('parent_item_#i#')#">
                                      <input type="Hidden" name="parent_path_#i#" id="parent_path_#i#" value="#evaluate('parent_path_#i#')#">
                                      <input type="Hidden" name="hidFree_#i#" value="0">                        
                                  </td>

                                  <td align="left" class="formtext" nowrap style="vertical-align:top">
                                    <cfif val(evaluate('hdnLevel_#i#'))>
                                    <input type="Checkbox" name="chk" onClick="tickItem(this,#i#)" disabled value="#i#">
                                    #repeatstring("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",evaluate('hdnLevel_#i#')-1)#
                                    <IMG src="#Application.stApp.Upload_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/lastnode.gif" border="0">&nbsp;
                                    </cfif>
                                      <input type="text" name="txtPartNo_#i#" id="txtPartNo_#i#" value="#evaluate('txtPartNo_#i#')#" class="inplabel" readonly size="15" maxlength="20">
                                      <input type="hidden" name="hdnLevel_#i#" value="#evaluate('hdnLevel_#i#')#">
                                      <input type="hidden" name="hdnRatio_#i#" value="#evaluate('hdnRatio_#i#')#">
                                      <input type="hidden" name="hdnMatrixItem_#i#">
                                      <input type="hidden" name="hdnEventQty_#i#">
                                      <input type="hidden" name="hdnEventPrice_#i#">
                                      <input type="hidden" name="hdnEventDiscAmount_#i#">
                                      <input type="hidden" name="hdnEventDiscPercent_#i#">
                                      <input type="Hidden" name="hidQtyFree_#i#">                                      
                                      <input type="Hidden" name="txtUnitConv1to2#i#" size="10" value="#evaluate('txtUnitConv1to2#i#')#">
                                      <input type="Hidden" name="txtUnitConv2to1#i#" size="10" value="#evaluate('txtUnitConv2to1#i#')#">
                                      <cfset Itemcode = evaluate('txtPartNo_#i#')>                        </td>
                                  <td align="left" class="formtext" nowrap style="vertical-align:top">#htmleditformat(evaluate('txtDesc_#i#'))#
                                    <input type="Hidden" name="txtDesc_#i#" value="#htmleditformat(evaluate('txtDesc_#i#'))#" size="20" maxlength="30" valign="center" readonly>
                                    <br>
                                      <cfset colorlist ="">
                                      <input type="Hidden" name="hdncolor_#i#" value="#evaluate('hdncolor_#i#')#">
                                      <input type="hidden" name="hdndorder_#i#" value="#evaluate('hdndorder_#i#')#">                        
                                  </td>
								  <td align="left" class="formtext" nowrap style="vertical-align:top">
							  	 	<input type="text" name="txtNotes_#i#" value="#htmleditformat(evaluate('txtNotes_#i#'))#">
							  	  </td>
                                  <td align="left" class="formtext" nowrap style="vertical-align:top;#displayStyle#"><a
                                   href="javascript:void(0);"
                                   onClick="showLookup(#i#);" 
                                   style="text-decoration: none;"><img 
                                   id="imbPickDimension_#i#" border="0" style="display: ;" 
                                   src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/dimension_picker.gif" 
                                   onmouseover="return overlib('#DO_VAR['CHANGEITEMDIMENSION']#');" 
                                   onMouseOut="return nd();" width="15" height="13" /></a>&nbsp;<input type="text"
                                   name="txtDimensionName_#i#" id="txtDimensionName_#i#" 
                                   value="#HTMLEDITFORMAT(evaluate('txtDimensionName_#i#'))#" 

                                   class="inplabel" readonly /><input type="hidden" 
                                   name="txtDimensionID_#i#" id="txtDimensionID_#i#" 
                                   value="#evaluate('txtDimensionID_#i#')#" />
                                   </td>
                                  
								   <!--- Custom Samick --->
									<td align="left" valign="top" class="formtext">
										<span id="txtColorItem_#i#">
										<cfif len("txtColorItem_#i#") AND structkeyexists(strctColor,"txtColorItem_#i#")>
											#HTMLEDITFORMAT(strctColor["txtColorItem_#i#"])#
										</cfif>
										</span>
										<input type="hidden" name="txtColorItem_#i#" id="txtColorItem_#i#" 
										<cfif len("txtColorItem_#i#") AND structkeyexists(strctColor,"txtColorItem_#i#")>
											value="#HTMLEDITFORMAT(strctColor['txtColorItem_#i#'])#"
										<cfelse>
											value=""	
										</cfif>
										size="20" width="30" readonly />
									</td>
									<td align="left" valign="top" class="formtext">
									<span id="txtBrandItem_#i#">#HTMLEDITFORMAT("txtBrandItem_#i#")#</span>
									<input type="hidden" name="txtBrandItem_#i#" id="txtBrandItem_#i#" value="#HTMLEDITFORMAT('txtBrandItem_#i#')#" size="20" width="30" readonly />
									</td>
									<td align="left" valign="top" class="formtext">
									<span id="txtTypeItem_#i#">#HTMLEDITFORMAT("txtTypeItem_#i#")#</span>
									<input type="hidden" name="txtTypeItem_#i#" id="txtTypeItem_#i#" value="#HTMLEDITFORMAT('txtTypeItem_#i#')#" size="20" width="30" readonly />
									</td>
								  <!--- end Custom Samick --->
								  
                                  <td align="center" class="formtext" style="vertical-align:top">

                                      <input type="text" style="text-align:right" id="txtQty_#i#" name="txtQty_#i#"
                                      <cfif  val(evaluate('hdnLevel_#i#'))> class="inpdim" readonly </cfif>
                                      value="#NumberFormat(evaluate('txtQty_#i#'),".#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="4"  maxlength="10"  valign="center" >
                                      <cfset ItemQty	= val(evaluate('txtQty_#i#'))>
                                  </td>
                                  <td align="center" class="formtext" style="vertical-align:top">
                                  <input type="text" name="txtUnitType#i#" size="10" value="#evaluate('txtUnitType#i#')#" readonly class="inpdim">                        
                                  </td>
                                  <td align="center" class="formtext" style="vertical-align:top">
                                      <input type="text"  style="text-align:right"  name="txtQty2_#i#" readonly class="inpdim"  value="#numberformat(val(evaluate('txtQty2_#i#')),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="4"  maxlength="10"  valign="center"  onBlur="getQty(1);setCurrTax(); setCurr();calcAmount(#i#);  calcAmountAll(); calcTax(); GetAmountGrand(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);decimalinForMoney(this);" onKeyPress="return isIntOnlyNew(event);">                        </td>
                                  <td align="center" class="formtext" style="vertical-align:top"><input type="text" name="txtUnitType2#i#" size="10" value="#evaluate('txtUnitType2#i#')#" readonly class="inpdim">                        </td>
                                  <cfif val(rbTypeDoc) eq 0>
                                    <cfif isdefined ("selQuotation") and selQuotation neq "">
                                      <cfif qQuotation.currency_id neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                      <cfelse>
                                      <cfif evaluate('txtCurrencyID_#i#') neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                    </cfif>
                                    <cfelseif val(rbTypeDoc) eq 1>
                                    <cfif isdefined ("selPro") and (selPro neq 0 OR Len(Trim(selProject)) NEQ 0)>
                                      <cfif qPro.currency_id neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                      <cfelse>
                                      <cfif evaluate('txtCurrencyID_#i#') neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                    </cfif>
                                    <cfelseif val(rbTypeDoc) eq 2>
                                    <cfif isdefined ("selProforma") and selProforma neq "">


                                      <cfif qProformaInvoice.currency_id neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                      <cfelse>
                                      <cfif evaluate('txtCurrencyID_#i#') neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                    </cfif>
                                    <cfelseif val(rbTypeDoc) eq 3>
                                    <cfif isdefined ("ddlSalesContract") and ddlSalesContract neq "">
                                      <cfif qSelectSalesContract.Currency_ID neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                      <cfelse>
                                      <cfif evaluate('txtCurrencyID_#i#') neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                    </cfif>
                                  </cfif>
                                  <td align="center" class="formtext" style="vertical-align:top">
                                        <input type="text"  style="text-align:right" name="txtConvertedUnitPrice_#i#" id="txtConvertedUnitPrice_#i#" 
                                          <cfif flag eq "0">
                                              value="#numberformat(val(evaluate('txtConvertedUnitPrice_#i#')),",.#repeatstring("_",application.stapp.decimal_range[vst_idx])#")#" 
                                              <cfset normal_price = val(evaluate('txtConvertedUnitPrice_#i#'))>
                                          <cfelseif flag eq "1">
                                              value="#numberformat(val(evaluate('txtConvertedUnitPrice_#i#')),",.#repeatstring("_",application.stapp.decimal_range[vst_idx])#")#"
                                              <cfset normal_price = val(evaluate('txtConvertedUnitPrice_#i#'))>
                                          </cfif>size="12" maxlength="15" valign="center" 
                                          <cfif val(evaluate('hid_generate_flag_#i#')) neq 3>onBlur="setCurrTax(); setCurr();calcAmount(#i#);  recalcTotal(); decimalinForMoney(this);calculateTermOfPayment();" onChange="changeBGcolor(this);" onKeyPress="return isIntOnlyNew(event);"<cfelse>readonly class="inplabel"</cfif>>
                                      <input type="hidden" name="HidBase_ConvertedUnitPrice_#i#" value="#evaluate('HidBase_ConvertedUnitPrice_#i#')#">                        
                                  </td>
                                 
                                  <cfset precious = normal_price * itemqty>
                                 <td align="center" class="formtext" style="vertical-align:top">
                                      <input type="text" style="text-align:right" onChange="changeBGcolor(this);" name="txtDisc_#i#" id="txtDisc_#i#" value="#evaluate('txtDisc_#i#')#"  size="10" maxlength="10" valign="center" onBlur="calcAmount(#i#); recalcTotal();calcAmountAll();calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);"><!--- class="inpdim" ---><!--- end --->
                                      <input type="hidden" name="txtDiscv_#i#" value="#evaluate('txtDiscv_#i#')#">
                                      <input type="hidden" name="txtDiscType_#i#" value="#evaluate('txtDiscType_#i#')#">
                                      <input type="hidden" style="text-align:left" name="txtUnitId_#i#" value="#val(evaluate('txtUnitId_#i#'))#" readonly>
                                      <input type="hidden" style="text-align:left" name="txtUnitId2_#i#" value="#val(evaluate('txtUnitId2_#i#'))#" readonly>                        
                                 </td>
                                 <td style="vertical-align:top">
        							<input type="text" onChange="changeBGcolor(this);checkDiscAll(this);" name="txtDiscount1#i#" id="txtDiscount1#i#" value="#evaluate('txtDiscv_#i#')#" size="10" style="text-align:right" onBlur="calcAmount(#i#); recalcTotal();calculateTermOfPayment();">
                                    <input type="hidden" name="txtDiscount2#i#" value="">
        						</td>
                                <!---end--->

                                  <td align="center" class="formtext" style="vertical-align:top"><input type="text"  style="text-align:right" name="txtConvertedAmount_#i#" value="#NumberFormat(val(precious),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="12" maxlength="15" valign="center" readonly class="inplabel">
                                      <input type="hidden" name="HidBase_ConvertedAmount_#i#" value="">    
                                      <input type="hidden" style="text-align:right" name="txtExtra_#i#" value="#NumberFormat(evaluate('txtExtra_#i#'),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="10" maxlength="15" valign="center"  onBlur="setCurrTax(); setCurr();calcAmount(#i#);  recalcTotal();decimalinForMoney(this);calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);">                    
                                  </td>
                                  <td align="center" class="formtext" style="vertical-align:top">
                                 
                                      <select name="selTax1_#i#" id="selTax1_#i#" onChange="calcAmount(#i#); calcTax(); GetAmountGrand(); setCurrTax(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);calculateTermOfPayment();">
                                        <option value="0|0|+" <cfif ListFindNOcase(EVALUATE("selTax1_#i#"),0,"|") eq 1>SELECTED</cfif>>#DO_VAR["None"]#
                                          <cfloop query="qTaxType">
                                                            <cfset temp="#Tax_Code#|#Numberformat(Tax_Rate,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#Tax_operator#">
                                                            <option value="#temp#" <cfif CompareNoCase(EVALUATE("selTax1_#i#"),temp) eq 0>SELECTED</cfif>>
                                            #Tax_Name#
                                          </cfloop>
                                      </select>
                                      
                                      <input type="hidden" name="txtTaxAmount1_#i#" value="#evaluate('txtTaxAmount1_#i#')#">
                                      <input type="hidden" name="hidBase_TaxAmount1_#i#" value="#evaluate('hidBase_TaxAmount1_#i#')#">                        
                                  </td>
                                  <td align="center" class="formtext" style="vertical-align:top">
                                     
                                      <select name="selTax2_#i#" id="selTax2_#i#" onChange="calcAmount(#i#); calcTax(); GetAmountGrand(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);calculateTermOfPayment();">
                                        <option value="0|0|+" <cfif ListFindNOcase(EVALUATE("selTax2_#i#"),0,"|") eq 1>SELECTED</cfif>>#DO_VAR["None"]#
                                          <cfloop query="qTaxType">

                                                            <cfset temp="#Tax_Code#|#Numberformat(Tax_Rate,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#Tax_operator#">
                                                            <option value="#temp#" <cfif CompareNoCase(EVALUATE("selTax2_#i#"),temp) eq 0>SELECTED</cfif>>
                                            #Tax_Name#
                                          </cfloop>
                                      </select>
                                      <input type="hidden" name="txtTaxAmount2_#i#" value="#evaluate('txtTaxAmount2_#i#')#">
                                      <input type="hidden" name="hidBase_TaxAmount2_#i#" value="#evaluate('hidBase_TaxAmount2_#i#')#">                        
                                      <input type="hidden" name="txtOthers_#i#" size="20" maxlength="50" value="#evaluate('txtOthers_#i#')#">
                                  </td>
                                  <td align="center" class="formtext" style="vertical-align:top" nowrap>
                                      <cfset Local.ETAText = ""/>                            
                                      <input type="Hidden" name="txtEstimateDateSplit_##" id="txtEstimateDateSplit_#i#" value="#evaluate('txtEstimateDateSplit_#i#')#" />
                                      <span id="lnkEstimateDateSplit#i#">#Local.ETAText#</span> </td>
                                  <td class="formtext" style="vertical-align:top">
                                      <cfif val(evaluate('hdnLevel_#i#')) eq 0>
                                        <a name="lnkEstimateDateSplit#i#" style="display:block" href="javascript:void(0)" onClick="splitETA(#i#,#dcf_Identity#)"><IMG src="#Application.stApp.Web_Path[1]#/eaccounting/images/list.gif" alt="Multiple" align="absmiddle" border="0"></a>
                                      <cfelse>
                                        &nbsp;
                                      </cfif>
                                  </td>
                                  <td align="center" class="formtext" style="vertical-align:top">
                                    <select name="selComponent_#i#">
                                      <option value="0">..::[#DO_VAR['eHRMNone']#]::..</option>
                                      <cfloop query="qGetComponent">
                                        <option value="#qGetComponent.Comp_ID#" <cfif evaluate('selComponent_#i#') eq qGetComponent.Comp_ID>selected</cfif>>#Comp_Name#</option>
                                      </cfloop>
                                    </select>                        
                                  </td>
                                  <td align="center" class="formtext" style="vertical-align:top">
                                  <!--- <cfif val(evaluate('hdnLevel_#i#')) eq 0>
                                      <input type="Checkbox" name="chkinstall_#i#" value="#val(evaluate('chkinstall_#i#'))#" 
                                          <cfif #val(evaluate("chkinstall_#i#"))# eq 1> checked </cfif>
                                      >
                                  </cfif> --->
                                      <input type="hidden" name="txtCurrencyID_#i#" value="#evaluate('txtCurrencyID_#i#')#">
                                      <input type="hidden" name="txtPriceType_#i#" value="#val(evaluate('txtPriceType_#i#'))#">
                                      <input type="hidden" name="txtOriginPrice_#i#" value="#val(evaluate('txtConvertedUnitPrice_#i#'))#">
                                      <input type="hidden" name="HidBase_ConvertedUnitPrice_#i#" value="#val(evaluate('HidBase_ConvertedUnitPrice_#i#'))#">
                                      <input type="hidden" name="HidBase_ConvertedUnitPrice2_#i#" value="#val(evaluate('HidBase_ConvertedUnitPrice2_#i#'))#">
                                      <input type="Hidden" name="txtCS_#i#" value="">
                                      <input type="Hidden" name="hid_generate_flag_#i#" value="#val(evaluate('hid_generate_flag_#i#'))#">
                                      <input type="Hidden" name="hdnColorItem_#i#" value="0">                        

                                  </td>
                                </tr>            
                                <cfset jumrowloop = jumrowloop + 1>                  
                              </cfloop>
                      
                      <cfelse>
                              <cfloop index="i" from="1" to="#qsalesDetail.recordCount#">
							  
							  		<cfquery name="qGetSNQty" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
									SELECT TACCSN_ITEM.ITEM_CODE,
										   SUM(TACCSN_ITEM.QTY) AS SN_QTY 
								    from TAccSN_Item
									INNER JOIN TACCSN_HEADER 
										ON TACCSN_HEADER.SN_NUMBER=TACCSN_ITEM.SN_NUMBER
									WHERE TACCSN_ITEM.SO_NUMBER='#SONum#'
									AND TACCSN_ITEM.ITEM_CODE='#qSalesDetail.Item_Code[i]#'
									AND TACCSN_ITEM.DIMENSION_ID='#qSalesDetail.Dimension_ID[i]#'
									AND ISNULL(TACCSN_HEADER.ISVOID,0)=0
									AND TACCSN_HEADER.APPROVAL_STATUS <> 4
									<cfif #lstSNDoc# neq "">
									AND TACCSN_HEADER.SN_NUMBER NOT IN (#listqualify(lstSNDoc,"'")#)
									</cfif>
									GROUP BY TACCSN_ITEM.ITEM_CODE
								</cfquery>
							  
							  	<cfquery name="qGetShipInstQty" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">									
									select SUM(TAccShippingInst_Detail.Qty) AS SI_Qty 
									from 
									TAccShippingInst_Detail
									inner join TAccShippingInst_Header 
										ON TAccShippingInst_Detail.ShipInst_Number=TAccShippingInst_Header.ShipInst_Number
									where TAccShippingInst_Header.doc_status <> 2
									AND TAccShippingInst_Header.doc_status <> 3
									AND TAccShippingInst_Detail.Item_Code='#qSalesDetail.Item_Code[i]#'
									AND TAccShippingInst_Detail.Dimension_ID='#qSalesDetail.Dimension_ID[i]#'	
									AND TAccShippingInst_Detail.SO_Number='#SONum#'
									AND isnull(TAccShippingInst_Header.isClose,0)=0
									GROUP BY TAccShippingInst_Detail.Item_Code								
							  	</cfquery>
								
								<cfset SNQty = val(qGetSNQty.SN_Qty) + val(qGetShipInstQty.SI_Qty)>
								
                                <tr id="tr#i#">
                                  <td align="center" class="formtext" style="vertical-align:top"><cfif val(qSalesDetail.config_level[i]) eq 0>
                                    <input type="Checkbox" name="chk" onClick="tickItem(this,#i#)" value="#i#"> <!---<cfif SNQty gt 0>disabled</cfif>--->
                                    <cfset dorder=dorder+1>
        
                                  </cfif>
                                      <cfset prt=Iif(val(qSalesDetail.config_level[i]),"qSalesDetail.parent_item[i]",0)>
                                      <cfset ppath=Iif(val(qSalesDetail.config_level[i]),"qSalesDetail.parent_path[i]",0)>
                                      <input type="Hidden" name="parent_item_#i#" value="#prt#">
                                      <input type="Hidden" name="parent_path_#i#" id="parent_path_#i#" value="#ppath#">
                                      <input type="Hidden" name="hidFree_#i#" value="0">                        </td>
                                  <td align="left" class="formtext" nowrap style="vertical-align:top"><cfif val(qSalesDetail.config_level[i])>
                                    <input type="Checkbox" name="chk" onClick="tickItem(this,#i#)" disabled value="#i#">
                                    #repeatstring("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",qsalesDetail.config_level[i]-1)#<IMG src="#Application.stApp.Upload_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/lastnode.gif" border="0">&nbsp;
                                    </cfif>

                                      <input type="text" name="txtPartNo_#i#" id="txtPartNo_#i#" value="#qsalesDetail.Item_Code[i]#" readonly size="15" maxlength="20" class="inplabel">
                                      <input type="hidden" name="hdnLevel_#i#" value="#qsalesDetail.config_level[i]#">
                                      <input type="hidden" name="hdnRatio_#i#" value="#qsalesDetail.config_ratio[i]#">
                                      <input type="hidden" name="hdnMatrixItem_#i#">
                                      <input type="hidden" name="hdnEventQty_#i#">
                                      <input type="hidden" name="hdnEventPrice_#i#">
                                      <input type="hidden" name="hdnEventDiscAmount_#i#">
                                      <input type="hidden" name="hdnEventDiscPercent_#i#">
                                      <input type="Hidden" name="hidQtyFree_#i#">
                                      <cfquery name="qGetUT" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                        select * from TItem 
                                        join TAccUnitType ON TItem.unit_type_id = TAccUnitType.unit_type_id
                                        where item_code = '#qsalesDetail.item_code#'
                                      </cfquery>
                                      
                                      <cfquery name="qConvertUnit1to2" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                          SELECT * FROM TPPICUnitConverter
                                          WHERE Status = 1
                                          <cfif #qsalesDetail.Unit_Type[i]# NEQ "" and #qsalesDetail.Unit_Type[i]# NEQ 0>
                                            AND Unit_Type_ID1=#qsalesDetail.Unit_Type[i]#
                                          <cfelse>
                                            AND Unit_Type_ID1=#qGetUT.Unit_Type_Id#
                                          </cfif>
                                          <cfif #qsalesDetail.Unit_Type2[i]# NEQ "" and #qsalesDetail.Unit_Type2[i]# NEQ 0>
                                            AND Unit_Type_ID2=#qsalesDetail.Unit_Type2[i]#
                                          <cfelse>
                                            AND Unit_Type_ID2=#qGetUT.Unit_Type_Id#
                                          </cfif>
                                      </cfquery>
                                      <cfquery name="qConvertUnit2to1" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                          SELECT * FROM TPPICUnitConverter
                                          WHERE Status = 1
                                          <cfif #qsalesDetail.Unit_Type[i]# NEQ "" and #qsalesDetail.Unit_Type[i]# NEQ 0>
                                            AND Unit_Type_ID1=#qsalesDetail.Unit_Type[i]#
                                          <cfelse>
                                            AND Unit_Type_ID1=#qGetUT.Unit_Type_Id#
                                          </cfif>
                                          <cfif #qsalesDetail.Unit_Type2[i]# NEQ "" and #qsalesDetail.Unit_Type2[i]# NEQ 0>
                                            AND Unit_Type_ID2=#qsalesDetail.Unit_Type2[i]#
                                          <cfelse>
                                            AND Unit_Type_ID2=#qGetUT.Unit_Type_Id#
                                          </cfif>
                                      </cfquery>
                                      <!---<cfdump var="#qConvertUnit2to1#">--->
                                      <input type="Hidden" name="txtUnitConv1to2#i#" size="10" value="#qConvertUnit1to2.Scale#">
                                      <input type="Hidden" name="txtUnitConv2to1#i#" size="10" value="#qConvertUnit2to1.Scale#">
                                      <cfset Itemcode = qsalesDetail.Item_Code[i]>                        </td>
                                  <td align="left" class="formtext" nowrap style="vertical-align:top">#htmleditformat(qsalesDetail.Item_name[i])#
                                    <input type="Hidden" name="txtDesc_#i#" value="#htmleditformat(qsalesDetail.Item_name[i])#" size="20" maxlength="30" valign="center" readonly>
                                    <br>
                                      <cfset colorlist ="">
                                      <input type="Hidden" name="hdncolor_#i#" value="">
                                      <input type="hidden" name="hdndorder_#i#" value="#dorder#">                        </td>
                                  <!--- #NumberFormat(val(qsalesDetail.Qty[i]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")# --->
                                  <td align="left" class="formtext" nowrap style="vertical-align:top">
							  	 	<input type="text" name="txtNotes_#i#" value="#htmleditformat(qsalesDetail.Notes[i])#">
							  	  </td>
                                  <td align="left" class="formtext" nowrap style="vertical-align:top;#displayStyle#"><a

                                   href="javascript:void(0);"
                                   onClick="showLookup(#i#);" 
                                   style="text-decoration: none;"><img 
                                   id="imbPickDimension_#i#" border="0" style="display: ;" 
                                   src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/dimension_picker.gif" 
                                   onmouseover="return overlib('#DO_VAR['CHANGEITEMDIMENSION']#');" 
                                   onMouseOut="return nd();" width="15" height="13" /></a>&nbsp;<input type="text"
                                   name="txtDimensionName_#i#" id="txtDimensionName_#i#" 
                                   value="#HTMLEDITFORMAT(qSalesDetail.Dimension_Name[i])#" 
                                   class="inplabel" readonly /><input type="hidden" 
                                   name="txtDimensionID_#i#" id="txtDimensionID_#i#" 
                                   value="#qSalesDetail.Dimension_ID[i]#" /></td>
                                  
								   <!--- Custom Samick --->
									<td align="left" valign="top" class="formtext">
										<span id="txtColorItem_#i#">
										<cfif len(qSalesDetail.item_color[i]) AND structkeyexists(strctColor,qSalesDetail.item_color[i])>
											#HTMLEDITFORMAT(strctColor[qSalesDetail.item_color[i]])#
										</cfif>
										</span>
										<input type="hidden" name="txtColorItem_#i#" id="txtColorItem_#i#" 
										<cfif len(qSalesDetail.item_color[i]) AND structkeyexists(strctColor,qSalesDetail.item_color[i])>
											value="#HTMLEDITFORMAT(strctColor[qSalesDetail.item_color[i]])#"
										<cfelse>
											value=""	
										</cfif>
										size="20" width="30" readonly />
									</td>
									<td align="left" valign="top" class="formtext">
									<span id="txtBrandItem_#i#">#HTMLEDITFORMAT(qSalesDetail.Item_size[i])#</span>
									<input type="hidden" name="txtBrandItem_#i#" id="txtBrandItem_#i#" value="#HTMLEDITFORMAT(qSalesDetail.Item_size[i])#" size="20" width="30" readonly />
									</td>
									<td align="left" valign="top" class="formtext">
									<span id="txtTypeItem_#i#">#HTMLEDITFORMAT(qSalesDetail.Item_description[i])#</span>
									<input type="hidden" name="txtTypeItem_#i#" id="txtTypeItem_#i#" value="#HTMLEDITFORMAT(qSalesDetail.Item_description[i])#" size="20" width="30" readonly />
									</td>
								  <!--- end Custom Samick --->
							  
                                  <td align="center" class="formtext" style="vertical-align:top">
                                  <input type="text" style="text-align:right" id="txtQty_#i#" name="txtQty_#i#"
                                      <cfif  val(qSalesDetail.config_level[i])> class="inpdim" readonly <cfelse> onBlur="getPrice(#i#); getDiscount(#i#);getDiscountTotal();getFreeItemTotal();qty_ratio(#i#, this);<cfif qsalesDetail.parent_path neq ''></cfif> setCurrTax(); setCurr(); calcAmount(#i#); recalcTotal(); decimalinForMoney(this);" onKeyPress="return isIntOnlyNew(event);" onChange="getPrice(#i#); getDiscount(#i#);getDiscountTotal();getFreeItemTotal();qty_ratio(#i#, this);"</cfif>
                                      value="#NumberFormat(qsalesDetail.Qty[i],".#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="4" maxlength="10">
                                      <cfset ItemQty	= val(qsalesDetail.Qty[i])></td>
                                  <td align="center" class="formtext" style="vertical-align:top"><input type="text" name="txtUnitType#i#" size="10" <cfif #qsalesDetail.Unit_Type[i]# NEQ "" and #qsalesDetail.Unit_Type[i]# NEQ 0>value="#qSalesDetail.Unit_Desc[i]#"<cfelse>value="#qGetUT.Unit_Name#"</cfif> readonly class="inpdim">                        </td>
                                  <!---
                                  <td align="center" class="formtext">
                                      <input type="text"  style="text-align:right"  name="txtQty2_#i#"  value="#numberformat(val(qDetail.Qty2[i]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="4" maxlength="10" valign="center" readonly  onBlur="getQty(1);setCurrTax(); setCurr();calcAmount(#i#);  calcAmountAll(); calcTax(); GetAmountGrand(); predecimalin(document.frmNew.txtTotAmount); predecimalin(document.frmNew.txtGrandTotal); predecimalin(document.frmNew.txtTotTaxConv); predecimalin(document.frmNew.txtTotDeductConv);" onKeyUp="decimalinForMoney(this);" onKeyPress="event.returnValue=isIntOnly();">
                                  </td>
                                                    --->
                                  <cfif not isdefined("qSalesDetail.Qty2")>
                                        <cfquery name="qDua" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
                                            SELECT Scale FROM TPPICUnitConverter
                                            WHERE Status = 1
                                              <cfif #qsalesDetail.Unit_Type[i]# NEQ "" and #qsalesDetail.Unit_Type[i]# NEQ 0>
                                                AND Unit_Type_ID1=#qsalesDetail.Unit_Type[i]#
                                              <cfelse>
                                                AND Unit_Type_ID1=#qGetUT.Unit_Type_Id#
                                              </cfif>
                                              <cfif #qsalesDetail.Unit_Type2[i]# NEQ "" and #qsalesDetail.Unit_Type2[i]# NEQ 0>
                                                AND Unit_Type_ID2=#qsalesDetail.Unit_Type2[i]#
                                              <cfelse>
                                                AND Unit_Type_ID2=#qGetUT.Unit_Type_Id#
                                              </cfif>
                                         </cfquery>
                                         <cfif qDua.recordcount>
                                            <cfset Qty2=qSalesDetail.Qty[i]*val(qDua.Scale)>
                                         <cfelse>
                                            <cfset Qty2=qSalesDetail.Qty[i]>
                                         </cfif>
                                <cfelse>
                                    <cfset Qty2=qSalesDetail.Qty2[i]>
                                  </cfif>
                                  <td align="center" class="formtext" style="vertical-align:top">
                                      <input type="text"  style="text-align:right"  name="txtQty2_#i#" readonly class="inpdim"  value="#numberformat(val(Qty2),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="4"  maxlength="10"  valign="center"  onBlur="setCurrTax(); setCurr();calcAmount(#i#);  calcAmountAll(); calcTax(); GetAmountGrand(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);decimalinForMoney(this)" onKeyPress="return isIntOnlyNew(event);">                        </td>
                                  <td align="center" class="formtext" style="vertical-align:top">
								  	  <input type="text" name="txtUnitType2#i#" size="10" <cfif #qsalesDetail.Unit_Type2[i]# NEQ "" and #qsalesDetail.Unit_Type2[i]# NEQ 0>value="#qSalesDetail.Unit_Desc2[i]#"<cfelse>value="#qGetUT.Unit_Name#"</cfif> readonly class="inpdim">                        </td>
								  
								 <!--- SN Qty --->							  
							  
							  	 <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
                                  <input type="text" style="text-align:right" id="txtSNQty_#i#" name="txtSNQty_#i#" class="inpdim" readonly value="#NumberFormat(SNQty,".#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="4" maxlength="10">
                                  </td>
                                  <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
								  <input type="text" name="txtUnitType#i#" size="10" <cfif #qsalesDetail.Unit_Type[i]# NEQ "" and #qsalesDetail.Unit_Type[i]# NEQ 0>value="#qSalesDetail.Unit_Desc[i]#"<cfelse>value="#qGetUT.Unit_Name#"</cfif> readonly class="inpdim">                        </td>
                              
                                  <!---<cfif not isdefined("SNQty2")>--->
                                        <cfquery name="qDua" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
                                            SELECT Scale FROM TPPICUnitConverter
                                            WHERE Status = 1
                                              <cfif #qsalesDetail.Unit_Type[i]# NEQ "" and #qsalesDetail.Unit_Type[i]# NEQ 0>
                                                AND Unit_Type_ID1=#qsalesDetail.Unit_Type[i]#
                                              <cfelse>
                                                AND Unit_Type_ID1=#qGetUT.Unit_Type_Id#
                                              </cfif>
                                              <cfif #qsalesDetail.Unit_Type2[i]# NEQ "" and #qsalesDetail.Unit_Type2[i]# NEQ 0>
                                                AND Unit_Type_ID2=#qsalesDetail.Unit_Type2[i]#
                                              <cfelse>
                                                AND Unit_Type_ID2=#qGetUT.Unit_Type_Id#
                                              </cfif>
                                         </cfquery>
                                         <cfif qDua.recordcount>
                                            <cfset SNQty2=SNQty*val(qDua.Scale)>
                                         <cfelse>
                                            <cfset SNQty2=SNQty>
                                         </cfif>
                                <!---
								   <cfelse>
                                    <cfset SNQty2=SNQty2>
                                  </cfif> --->
                                  <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
                                      <input type="text"  style="text-align:right"  name="txtSNQty2_#i#" readonly class="inpdim"  
									  value="#numberformat(val(SNQty2),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" 
									  size="4"  maxlength="10"  valign="center"  
									  onBlur="setCurrTax(); setCurr();calcAmount(#i#);  calcAmountAll(); calcTax(); GetAmountGrand(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);decimalinForMoney(this)" onKeyPress="return isIntOnlyNew(event);">                        </td>
                                  <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
								  <input type="text" name="txtUnitType2#i#" size="10" <cfif #qsalesDetail.Unit_Type2[i]# NEQ "" and #qsalesDetail.Unit_Type2[i]# NEQ 0>value="#qSalesDetail.Unit_Desc2[i]#"<cfelse>value="#qGetUT.Unit_Name#"</cfif> readonly class="inpdim">                        </td>
								     
							  <!--- end SN Qty --->
								  
								  
                                  <cfif val(rbTypeDoc) eq 0>
                                    <cfif isdefined ("selQuotation") and selQuotation neq "">
                                      <cfif qQuotation.currency_id neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                      <cfelse>
                                      <cfif qSales.currency_id neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                    </cfif>
                                    <cfelseif val(rbTypeDoc) eq 1>
                                    <cfif isdefined ("selPro") and (selPro neq 0 OR Len(Trim(selProject)) NEQ 0)>
                                      <cfif qPro.currency_id neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                      <cfelse>
                                      <cfif qSales.currency_id neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                    </cfif>
                                    <cfelseif val(rbTypeDoc) eq 2>
                                    <cfif isdefined ("selProforma") and selProforma neq "">
                                      <cfif qProformaInvoice.currency_id neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                      <cfelse>
                                      <cfif qSales.currency_id neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                    </cfif>
                                    <cfelseif val(rbTypeDoc) eq 3>
                                    <cfif isdefined ("ddlSalesContract") and ddlSalesContract neq "">
                                      <cfif qSelectSalesContract.Currency_ID neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                      <cfelse>
                                      <cfif qSales.currency_id neq "#cookie.currencyid#">
                                        <cfset flag="0">
                                        <cfelse>
                                        <cfset flag="1">
                                      </cfif>
                                    </cfif>
                                  </cfif>
                                  <td align="center" class="formtext" style="vertical-align:top"><!--- aaaa  #val(qSalesDetail.generate_flag[i])# --->
                                      <!--- <input type="text"  style="text-align:right" name="txtConvertedUnitPrice_#i#"  
                                          <cfif flag eq "0">
                                              value="#numberformat(val(qsalesdetail.unitprice[i]),",.#repeatstring("_",application.stapp.decimal_range[vst_idx])#")#" 
                                              <cfset normal_price = val(qsalesdetail.unitprice[i])>
                                          <cfelseif flag eq "1">
                                              value="#numberformat(val(qsalesdetail.base_unitprice[i]),",.#repeatstring("_",application.stapp.decimal_range[vst_idx])#")#"
                                              <cfset normal_price = val(qsalesdetail.base_unitprice[i])>
                                          </cfif>size="12" maxlength="15" valign="center" <cfif val(qSalesDetail.config_level[i]) eq 0>onBlur="setCurrTax(); setCurr();calcAmount(#i#);  recalcTotal(); decimalin(this);" onKeyPress="return isIntOnlyNew(event);"<cfelse>readonly class="inplabel"</cfif>> --->
                                      <input type="text"  style="text-align:right" name="txtConvertedUnitPrice_#i#" id="txtConvertedUnitPrice_#i#"  
                                          <cfif flag eq "0">
                                              value="#numberformat(val(qsalesdetail.unitprice[i]),",.#repeatstring("_",application.stapp.decimal_range[vst_idx])#")#" 
                                              <cfset normal_price = val(qsalesdetail.unitprice[i])>
                                          <cfelseif flag eq "1">
                                              value="#numberformat(val(qsalesdetail.unitprice[i]),",.#repeatstring("_",application.stapp.decimal_range[vst_idx])#")#"
                                              <cfset normal_price = val(qsalesdetail.unitprice[i])>
                                          </cfif>size="12" maxlength="15" valign="center" 
                                          <cfif val(qSalesDetail.generate_flag[i]) neq 3>onBlur="setCurrTax(); setCurr();calcAmount(#i#);  recalcTotal();getDiscountTotal();getFreeItemTotal(); decimalin(this);calculateTermOfPayment();" onChange="changeBGcolor(this);" onKeyPress="return isIntOnlyNew(event);"<cfelse>readonly class="inplabel"</cfif>>
                                      <input type="hidden" name="HidBase_ConvertedUnitPrice_#i#" value="">                        </td>
                                  <!--- #NumberFormat(val(qsalesDetail.Disc_Percentage[i]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")# --->
                                  <!--- <td align="center" class="formtext" style="vertical-align:top">
                                      <cfset disc = "">
                                      <cfset discountv	= "">
                                      <cfset precious = normal_price * ItemQty>
                                      
                                      <!--- <cfif #qsalesDetail.Disc_Percentage[i]# neq "">
                                          <cfset discvalue = qsalesDetail.Disc_Percentage[i]>
                                          <cfset disctype = qsalesDetail.disc_type[i]>
                                          
                                          <cfset counter = 0>
                                          <cfloop list="#discvalue#" index="discv" delimiters="~">
                                              <cfset counter = counter + 1>
                                              <!--- <cfset disct = ListGetAt(disctype,i,"~")> --->
                                              <cfset disct = ListGetAt(disctype,counter,"~")> <!--- IND, ubah "i" menjadi "counter" karena menyebabkan error jika looping dari mulai item ke 2.. Apakah ini benar?--->
                                              <cfif disct eq 2>
                                                  <cfset disc = "#discv#%">
                                                  <cfset precious = precious - (precious * discv/100)>
                                              <cfelseif disct eq 1>
                                                  <cfset disc = "(-#DecimalFormat(discv)#)">
                                                  <cfset precious = precious - discv>
                                              <cfelseif disct eq 3>
                                                  <cfset disc = "">
                                                  <cfset discountv = "">
                                                  <cfset harga_item = discv>
                                                  <cfset precious = discv * itemqty>
                                                  <!--- <cfset discount_value_curr = "">
                                                  <cfset discount_type_curr = ""> --->
                                              </cfif>
                                                          
                                              <cfif len(discountv)>
                                                  <cfset discountv = discountv & "+" &  disc>
                                              <cfelse>
                                                  <cfset discountv = disc>
                                              </cfif>
                                                      
                                              <cfif discountv eq ""><cfset discountv = "-"></cfif>
                                              <!--- <cfset discount_value_curr = ListAppend(discount_value_curr,discv,"~")>
                                              <cfset discount_type_curr = ListAppend(discount_type_curr,disct,"~")> ---> 
                                          </cfloop>
                                          <cfset discount_percent = discountv>
                                      </cfif> --->
                                       
                                      <!--- <input type="text"  style="text-align:right" onChange="changeBGcolor(this);" name="txtDisc_#i#" value="#discountv#" size="10" valign="center">  --->
                                      <input type="hidden" name="txtDiscv_#i#" value="#qsalesDetail.Disc_Percentage[i]#">
                                      <input type="hidden" name="txtDiscType_#i#" value="#qsalesDetail.disc_type[i]#">
                                  </td> --->
                                  <cfset precious = normal_price * itemqty>
                                  <td align="center" class="formtext" style="vertical-align:top">
                                      <!--- randytia 26-07-2010 ---><input type="text" style="text-align:right" onChange="changeBGcolor(this);" name="txtDisc_#i#" id="txtDisc_#i#" value="#qSalesDetail.Disc_Value[i]#"  size="10" maxlength="10" valign="center" onBlur="calcAmount(#i#); recalcTotal();calcAmountAll();decimalinForMoney(this);calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);"><!--- class="inpdim" ---><!--- end --->

                                      <input type="hidden" name="txtDiscv_#i#" value="#qSalesDetail.Disc_Percentage[i]#">
                                      <input type="hidden" name="txtDiscType_#i#" value="#qSalesDetail.disc_type[i]#">

                                      <input type="hidden" style="text-align:left" name="txtUnitId_#i#" value="#val(qSalesDetail.Unit_Type[i])#" readonly>
                                      <input type="hidden" style="text-align:left" name="txtUnitId2_#i#" value="#val(qSalesDetail.Unit_Type2[i])#" readonly>                        </td>
                                 <!---add by NP Agts 2010-- sales trade agreement--->
                                 <td style="vertical-align:top">
        							<input type="text" onChange="changeBGcolor(this);checkDiscAll(this);" name="txtDiscount1#i#" id="txtDiscount1#i#" value="#qSalesDetail.Disc_Percentage[i]#" size="10" style="text-align:right" onBlur="calcAmount(#i#); recalcTotal();calculateTermOfPayment();">
                                    <input type="hidden" name="txtDiscount2#i#" value="">
        						</td>
                                <!---end--->
                                  <!--- <td align="center" class="formtext">
                                      <input type="text" readonly  style="text-align:right" name="txtExtra#i#" value="#NumberFormat(val(qsalesDetail.ExtraPrice[i]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="10" maxlength="15" valign="center"  onblur="setCurrTax(); setCurr();calcAmount(#i#);  calcAmountAll(); calcTax(); GetAmountGrand(); predecimalin(document.frmNew.txtTotAmount); predecimalin(document.frmNew.txtGrandTotal); predecimalin(document.frmNew.txtTotTaxConv); predecimalin(document.frmNew.txtTotDeductConv);" onKeyUp="decimalinForMoney(this);" onKeyPress="return isIntOnlyNew(event);"> 
                                  </td> --->
                                  <!--- <input type="hidden" readonly  style="text-align:right" name="txtExtra_#i#" value="#NumberFormat(val(qsalesDetail.ExtraPrice[i]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="10" maxlength="15" valign="center"  onblur="setCurrTax(); setCurr();calcAmount(#i#);  recalcTotal();decimalinForMoney(this);" onKeyPress="return isIntOnlyNew(event);"> --->
                                                        
                                  <td align="center" class="formtext" style="vertical-align:top"><input type="text"  style="text-align:right" name="txtConvertedAmount_#i#" value="#NumberFormat(val(precious),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="12" maxlength="15" valign="center" readonly class="inplabel">
                                      <input type="hidden" name="HidBase_ConvertedAmount_#i#" value="">            
                                      
                                       <input type="hidden" style="text-align:right" name="txtExtra_#i#" value="#NumberFormat(qsalesDetail.ExtraPrice[i],",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="10" maxlength="15" valign="center"  onBlur="setCurrTax(); setCurr();calcAmount(#i#);  recalcTotal();decimalinForMoney(this);calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);">
                                                  </td>

                                  <td align="center" class="formtext" style="vertical-align:top"><cfif val(qsalesDetail.Tax_Percentage1[i]) neq 0>
                                      <cfset "selTax1_#i#"="#qsalesDetail.Tax_Code1[i]#|#numberformat(qsalesDetail.Tax_Percentage1[i],",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#qsalesDetail.Tax_Operator1[i]#">
                                      <cfelse>
                                      <cfset "selTax1_#i#"="0|0|+">
                                    </cfif>
                                      <select name="selTax1_#i#" id="selTax1_#i#" onChange="calcAmount(#i#); calcTax(); GetAmountGrand(); setCurrTax(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);calculateTermOfPayment();">
                                        <option value="0|0|+" <cfif ListFindNOcase(EVALUATE("selTax1_#i#"),0,"|") eq 1>SELECTED</cfif>>#DO_VAR["None"]#
                                          <cfloop query="qTaxType">
                                                            <cfset temp="#Tax_Code#|#Numberformat(Tax_Rate,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#Tax_operator#">
                                                            <option value="#temp#" <cfif CompareNoCase(EVALUATE("selTax1_#i#"),temp) eq 0>SELECTED</cfif>>
                                            #Tax_Name#
                                          </cfloop>
                                      </select>
                                      <cfif qSales.tax_amount gt 0>
                                        <cfset taxrate = qSales.base_tax_amount  / qSales.tax_amount>
                                        <cfelse>
                                        <cfset taxrate =0>
                                      </cfif>
                                      <cfset TaxBase1 = qsalesDetail.Tax_Amount1 * taxrate>
                                      <cfset TaxBase2 = qsalesDetail.Tax_Amount2 * taxrate>
                                      <input type="hidden" name="txtTaxAmount1_#i#" value="#Numberformat(qsalesDetail.Tax_Amount1[i],",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#">
                                      <input type="hidden" name="hidBase_TaxAmount1_#i#" value="#Numberformat(TaxBase1,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#">                        </td>




                                  <td align="center" class="formtext" style="vertical-align:top"><cfif val(qsalesDetail.Tax_Percentage2[i]) neq 0>
                                      <cfset "selTax2_#i#"="#qsalesDetail.Tax_Code2[i]#|#Numberformat(qsalesDetail.Tax_Percentage2[i],",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#qsalesDetail.Tax_Operator2[i]#">

                                      <cfelse>
                                      <cfset "selTax2_#i#"="0|0|+">
                                    </cfif>
                                      <select name="selTax2_#i#" id="selTax2_#i#" onChange="calcAmount(#i#); calcTax(); GetAmountGrand(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);calculateTermOfPayment();">
                                        <option value="0|0|+" <cfif ListFindNOcase(EVALUATE("selTax2_#i#"),0,"|") eq 1>SELECTED</cfif>>#DO_VAR["None"]#
                                          <cfloop query="qTaxType">
                                                            <cfset temp="#Tax_Code#|#Numberformat(Tax_Rate,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#Tax_operator#">
                                                            <option value="#temp#" <cfif CompareNoCase(EVALUATE("selTax2_#i#"),temp) eq 0>SELECTED</cfif>>
                                            #Tax_Name#
                                          </cfloop>
                                      </select>
                                      <input type="hidden" name="txtTaxAmount2_#i#" value="#Numberformat(qsalesDetail.Tax_Amount2[i],",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#">
                                      <input type="hidden" name="hidBase_TaxAmount2_#i#" value="#Numberformat(TaxBase2,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#">                        </td>
                                  <!--- 
                                  <td align="center" class="formtext">
                                      <input type="Text" name="txtOthers#i#" size="20" maxlength="50" value="#qsalesDetail.others[i]#"> 
                                  </td> --->
                                  <input type="hidden" name="txtOthers_#i#" size="20" maxlength="50" value="#qsalesDetail.others[i]#">

                                  <td align="center" class="formtext" style="vertical-align:top" nowrap><cfset Local.ETAText = ""/>
                                      <cfset Local.ETAItem = ""/>
                                      <cfset Local.ETAValue = ""/>
                                      <cfif val(qSalesDetail.config_level[i]) eq 0>
                                        <!---<input type="Text" name="txtEstimateDate#i#" value="#dateformat(qSalesDetail.EstimateDate[i],"mm/dd/yyyy")#">--->
                                        <cfif isDate(qSalesDetail.EstimateDate[i]) AND year(qSalesDetail.EstimateDate[i]) gt 1900>
                                          <cfset dtmValue = #DateFormat(qSalesDetail.EstimateDate[i],"mm/dd/yyyy")#>
                                          <cfelse>
                                          <cfset dtmValue = "">
                                        </cfif>
                                        <script type="text/javascript">SunFishERP_DateTimePicker('txtEstimateDate_#i#','#dtmValue#');ndxdate=dtp_Identity;</script>
                                        <cfset dcf_Identity=dcf_Identity+1>
                                        <cfquery name="qGetETA" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                              <!---  select distinct TAccSO_ETA.*  from TAccSO_ETA
                                              where SO_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SONum#"/>
                                              and Item_Code=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qsalesDetail.Item_Code[i]#"/> --->
                                              
                                                 select distinct TAccSO_ETA.*  from TAccSO_ETA
                                                                                              
                                                where TAccSO_ETA.SO_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SONum#"/>
                                                and TAccSO_ETA.Item_Code= <cfqueryparam cfsqltype="cf_sql_varchar" value="#qsalesDetail.Item_Code[i]#"/>
                                                and dimension_id = #qsalesDetail.dimension_id[i]#
                                          </cfquery>
                                        <cfif qGetETA.recordCount>
                                          <cfset Local.ETAText = ""/>
                                        </cfif>
                                        <cfloop query="qGetETA">
                                          <cfset Local.ETAItem = DateFormat(qGetETA.EstimateDate,"mm/dd/yyyy") & "|" & qGetETA.Qty />
                                          <cfset Local.ETAValue = ListAppend(Local.ETAValue,Local.ETAItem) />
                                          <cfset Local.ETAText = Local.ETAText & "<span style='display:block;font-size:8pt'>" & DateFormat(qGetETA.EstimateDate,"dd/mm/yyyy") & " : " & qGetETA.Qty &  "</span>"/>
                                        </cfloop>
                                      		 
                                      </cfif>

                                      <input type="Hidden" name="txtEstimateDateSplit_#i#" id="txtEstimateDateSplit_#i#" value="#Local.ETAValue#" />
                                      <span id="lnkEstimateDateSplit#i#">#Local.ETAText#</span> </td>
                                  <td class="formtext" style="vertical-align:top"><cfif val(qSalesDetail.config_level[i]) eq 0>
                                    <a name="lnkEstimateDateSplit#i#" style="display:block" href="javascript:void(0)" onClick="splitETA(#i#,#dcf_Identity#)"><IMG src="#Application.stApp.Web_Path[1]#/eaccounting/images/list.gif" alt="Multiple" align="absmiddle" border="0"></a>
                                    <!--- #Local.ETAText# --->
                                    <cfelse>
                                    &nbsp;
                                  </cfif></td>
                                  <td align="center" class="formtext" style="vertical-align:top"><select name="selComponent_#i#">
                                      <option value="0">..::[#DO_VAR['eHRMNone']#]::..</option>

                                      <cfloop query="qGetComponent">
                                        <option value="#qGetComponent.Comp_ID#" <cfif qsalesDetail.Comp_ID[i] eq qGetComponent.Comp_ID>selected</cfif>>#Comp_Name#</option>
                                      </cfloop>
                                    </select>                        </td>
                                  <td align="center" class="formtext" style="vertical-align:top">
								  <!--- Hidden by Elsa : 	BUG50612-60133 --->
								  <!--- <cfif val(qSalesDetail.config_level[i]) eq 0>
                                      <input type="Checkbox" name="chkinstall_#i#" value='#qsalesDetail.is_install[i]#' 
                                          <cfif #qsalesDetail.is_install[i]# eq 1> checked </cfif>
                                      >
                                  </cfif>
								  --->
                                      <input type="hidden" name="txtCurrencyID_#i#" value="#qsales.currency_id#">
                                      <input type="hidden" name="txtPriceType_#i#" value="#qsalesdetail.pricetype[i]#">
                                      <input type="hidden" name="txtOriginPrice_#i#" value="#qsalesdetail.UnitPrice[i]#">
                                      <input type="hidden" name="HidBase_ConvertedUnitPrice_#i#" value="#val(qsalesDetail.unitPrice[i])#">
                                      <input type="hidden" name="HidBase_ConvertedUnitPrice2_#i#" value="#val(qsalesDetail.unitPrice[i])#">
                                      <input type="Hidden" name="txtCS_#i#" value="">
                                      <input type="Hidden" name="hid_generate_flag_#i#" value="#val(qSalesDetail.generate_flag[i])#">
                                      <input type="Hidden" name="hdnColorItem_#i#" value="0">                        </td>
                                </tr>
                                <cfset jumrowloop = jumrowloop + 1>
                                <cfif qsalesDetail.tax_operator1[i] eq "-">
                                  <cfset tax_minus = tax_minus + val(qsalesDetail.tax_amount1[i])>
                                  <cfelse>
                                  <cfset tax_plus= tax_plus + val(qsalesDetail.tax_amount1[i])>
                                </cfif>
                                <cfif qsalesDetail.tax_operator2[i]  eq "-">
                                  <cfset tax_minus = tax_minus + val(qsalesDetail.tax_amount2[i])>
                                  <cfelse>
                                  <cfset tax_plus= tax_plus + val(qsalesDetail.tax_amount2[i])>
                                </cfif>
                              </cfloop>

                      
                      </cfif>
                      
                    </cfif>
                  <cfelse>
					<cfif task is "edit">
                      <cfparam name="hdnLstItemID" default="#valueList(qSalesDetail.ref_id, ",")#">

                      <cfset local.tmpSCNumber = qSales.SC_Number>
                    <cfelse>
                      <cfparam name="hdnLstItemID" default="">
                    </cfif>
					
					<!--- SALES CONTRACT ITEM DETAIL --->
                    <cfquery name="qTmpDetail" datasource="#REQUEST.DSN#">
                      SELECT 
                        scd.Detail_ID, 
                        scd.Item_Code, 
                        scd.Disc_value,
                        itm.Item_Name, 
                        scd.Item_Desc, 
                        scd.Unit_Type, 
                        (
                          SELECT Unit_Name FROM TACCUNITTYPE utp1 WHERE utp1.Unit_Type_ID = scd.Unit_Type
                        ) AS Unit_Desc, 
                        CASE ISNULL(sod.Qty, 0) 
                          WHEN 0 THEN 
                            scd.Qty

                          ELSE
                            sod.Qty
                        END AS Qty, 
                        scd.Unit_Type2, 
                        (
                          SELECT Unit_Name FROM TACCUNITTYPE utp2 WHERE utp2.Unit_Type_ID = scd.Unit_Type2
                        ) AS Unit_Desc2, 
                        CASE ISNULL(sod.Qty, 0) 
                          WHEN 0 THEN 
                            scd.Qty2
                          ELSE
                            sod.Qty2
                        END AS Qty, 
                        scd.UnitPrice, 
                        scd.Base_UnitPrice, 
                        scd.Disc_Percentage, 
                        scd.Tax_Code1, 
                        scd.Tax_Percentage1, 
                        scd.Tax_Operator1, 
                        scd.Tax_Amount1, 
                        scd.Tax_Code2, 
                        scd.Tax_Percentage2, 
                        scd.Tax_Operator2, 
                        scd.Tax_Amount2, 
                        scd.TotalPrice, 
                        scd.Base_TotalPrice, 
                        scd.Parent_Item, 
                        scd.Parent_Path, 
                        scd.Generate_Flag, 
                        scd.Config_Level, 
                        scd.Config_Order, 
                        scd.Config_Ratio, 
                        itm.Currency_ID, 
                        itm.PriceType, 
                        0 AS Disc_Type, 
                        sod.EstimateDate, 
                        scd.Dimension_ID, 
                        ISNULL(itd.Dimension_Name, '') AS Dimension_Name 
                      FROM 
                        TACCSALESCONTRACT_DETAIL scd 
                        INNER JOIN TITEM itm 
                        ON itm.Item_Code = scd.Item_Code 
                        LEFT JOIN TACCSO_DETAIL sod 
                        ON scd.Item_Code = sod.Item_Code 
                        AND sod.ref_id = scd.Detail_ID 
                        AND sod.SO_Number = '#txtSONum#' 
                        LEFT JOIN TITEMDIMENSION itd 
                        ON itd.Dimension_ID = scd.Dimension_ID 
                      WHERE 
                        scd.SC_Number = '#local.tmpSCNumber#' 
                        <cfif local.tmpSCItemSetting IS 1>
                          <cfif hdnLstItemID IS "">
                            AND scd.Detail_ID = 0
                          <cfelse>
                            AND scd.Detail_ID IN (#listQualify(hdnLstItemID, "'", ",")#) 
                          </cfif>
                        </cfif>
                    </cfquery>
                    
                    <cfloop index="i" from="1" to="#qTmpDetail.RecordCount#">

								<cfquery name="qGetSNQty" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
									SELECT TACCSN_ITEM.ITEM_CODE,
										   SUM(TACCSN_ITEM.QTY) AS SN_QTY 
								    from TAccSN_Item
									INNER JOIN TACCSN_HEADER 
										ON TACCSN_HEADER.SN_NUMBER=TACCSN_ITEM.SN_NUMBER
									WHERE TACCSN_ITEM.SO_NUMBER='#SONum#'
									AND TACCSN_ITEM.ITEM_CODE='#qTmpDetail.Item_Code[i]#'
									AND TACCSN_ITEM.DIMENSION_ID='#qTmpDetail.Dimension_ID[i]#'
									AND ISNULL(TACCSN_HEADER.ISVOID,0)=0
									AND TACCSN_HEADER.APPROVAL_STATUS <> 4
									<cfif #lstSNDoc# neq "">
									AND TACCSN_HEADER.SN_NUMBER NOT IN (#listqualify(lstSNDoc,"'")#)
									</cfif>
									GROUP BY TACCSN_ITEM.ITEM_CODE
								</cfquery>
							  
							  	<cfquery name="qGetShipInstQty" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">									
									select SUM(TAccShippingInst_Detail.Qty) AS SI_Qty 
									from 
									TAccShippingInst_Detail
									inner join TAccShippingInst_Header 
										ON TAccShippingInst_Detail.ShipInst_Number=TAccShippingInst_Header.ShipInst_Number
									where TAccShippingInst_Header.doc_status <> 2
									AND TAccShippingInst_Header.doc_status <> 3
									AND TAccShippingInst_Detail.Item_Code='#qTmpDetail.Item_Code[i]#'
									AND TAccShippingInst_Detail.Dimension_ID='#qTmpDetail.Dimension_ID[i]#'	
									AND TAccShippingInst_Detail.SO_Number='#SONum#'
									AND isnull(TAccShippingInst_Header.isClose,0)=0
									GROUP BY TAccShippingInst_Detail.Item_Code								
							  	</cfquery>
								
								<cfset SNQty = val(qGetSNQty.SN_Qty) + val(qGetShipInstQty.SI_Qty)>
									
                      <tr id="tr#i#">
                        <td align="center" class="formtext" style="vertical-align:top"><cfif val(qTmpDetail.config_level[i]) eq 0><input type="checkbox"
                         name="chk" id="chk" onClick="tickItem(this,#i#)" value="#i#"/> <!---<cfif val(SNQty) gt 0>disabled</cfif>---> <cfset dorder=dorder+1></cfif>
						 <cfset prt=Iif(val(qTmpDetail.config_level[i]),"qTmpDetail.parent_item[i]",0)>
						 <cfset ppath=Iif(val(qTmpDetail.config_level[i]),"qTmpDetail.parent_path[i]",0)>
                         <input type="hidden" name="parent_item_#i#" value="#prt#" />
                         <input type="hidden" name="parent_path_#i#" id="parent_path_#i#" value="#ppath#" /></td>
                        <td align="left" class="formtext" style="vertical-align:top" nowrap><cfif val(qTmpDetail.config_level[i])><input type="checkbox"
                         name="chk" id="chk" onClick="tickItem(this,#i#)" value="#i#" disabled 
                         />#repeatstring("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", qTmpDetail.config_level[i]-1)#&nbsp;&nbsp;<IMG 
                         src="#Application.stApp.Upload_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/lastnode.gif" 
                         border="0" />&nbsp;</cfif>
                         <input type="text" name="txtPartNo_#i#" id="txtPartNo_#i#" value="#qTmpDetail.Item_Code[i]#" class="inplabel" width="10" size="15" readonly>
                         <input type="hidden" name="hdnLevel_#i#" value="#qTmpDetail.config_level[i]#">
                         <input type="hidden" name="hdnRatio_#i#" value="#qTmpDetail.config_ratio[i]#">
                         <cfquery name="qConvertUnit1to2" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                            SELECT * FROM TPPICUnitConverter
                            WHERE Status = 1
                            AND Unit_Type_ID1='#qTmpDetail.Unit_Type[i]#'
                            AND Unit_Type_ID2='#qTmpDetail.Unit_Type2[i]#'
                         </cfquery>
                         <cfquery name="qConvertUnit2to1" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                            SELECT * FROM TPPICUnitConverter
                            WHERE Status = 1
                            AND Unit_Type_ID1='#qTmpDetail.Unit_Type2[i]#'
                            AND Unit_Type_ID2='#qTmpDetail.Unit_Type[i]#'
                         </cfquery>
                         <input type="Hidden" name="txtUnitConv1to2#i#" size="10" value="#qConvertUnit1to2.Scale#">
                         <input type="Hidden" name="txtUnitConv2to1#i#" size="10" value="#qConvertUnit2to1.Scale#">
                         <input type="hidden" name="hdnMatrixItem_#i#">
                         <input type="hidden" name="hdnEventQty_#i#">
                         <input type="hidden" name="hdnEventPrice_#i#">
                         <input type="hidden" name="hdnEventDiscAmount_#i#">
                         <input type="hidden" name="hdnEventDiscPercent_#i#">
                         <input type="Hidden" name="hidQtyFree_#i#"></td>
                        <td align="left" class="formtext" nowrap style="vertical-align:top">#htmleditformat(qTmpDetail.Item_Name[i])#
                            <input type="hidden" name="txtDesc_#i#" value="#htmleditformat(qTmpDetail.Item_Name[i])#" size="20" maxlength="30" #local.tmpFormInputAttribute#>
                            <br>
                              <cfset colorlist ="">
                              <input type="Hidden" id="hdncolor_#i#" name="hdncolor_#i#" value="">
                              <input type="Hidden" name="hdnColorItem_#i#" value="0">
                              <input type="hidden" name="hdndorder_#i#" value="#dorder#">                          </td>
                        
					    <td align="left" class="formtext" nowrap style="vertical-align:top">
							  	 	<input type="text" name="txtNotes_#i#" value="#htmleditformat(qsalesDetail.Notes[i])#">
						</td>
                        <td align="left" class="formtext" nowrap style="vertical-align:top;#displayStyle#"><input type="text"
                         name="txtDimensionName_#i#" id="txtDimensionName_#i#" 
                         value="#HTMLEDITFORMAT(qTmpDetail.Dimension_Name[i])#" 
                         class="inplabel" readonly /><input type="hidden" 
                         name="txtDimensionID_#i#" id="txtDimensionID_#i#" 
                         value="#qTmpDetail.Dimension_ID[i]#" /></td>
                        
				 		<!--- Custom Samick --->
						<td align="left" valign="top" class="formtext">
							<span id="txtColorItem_#i#">
							<cfif len(qTmpDetail.item_color[i]) AND structkeyexists(strctColor,qTmpDetail.item_color[i])>
								#HTMLEDITFORMAT(strctColor[qTmpDetail.item_color[i]])#
							</cfif>
							</span>
							<input type="hidden" name="txtColorItem_#i#" id="txtColorItem_#i#" 
							<cfif len(qTmpDetail.item_color[i]) AND structkeyexists(strctColor,qTmpDetail.item_color[i])>
								value="#HTMLEDITFORMAT(strctColor[qTmpDetail.item_color[i]])#"
							<cfelse>
								value=""	
							</cfif>
							size="20" width="30" readonly />
						</td>
						<td align="left" valign="top" class="formtext">
						<span id="txtBrandItem_#i#">#HTMLEDITFORMAT(qTmpDetail.Item_size[i])#</span>
						<input type="hidden" name="txtBrandItem_#i#" id="txtBrandItem_#i#" value="#HTMLEDITFORMAT(qTmpDetail.Item_size[i])#" size="20" width="30" readonly />
						</td>
						<td align="left" valign="top" class="formtext">
						<span id="txtTypeItem_#i#">#HTMLEDITFORMAT(qTmpDetail.Item_description[i])#</span>
						<input type="hidden" name="txtTypeItem_#i#" id="txtTypeItem_#i#" value="#HTMLEDITFORMAT(qTmpDetail.Item_description[i])#" size="20" width="30" readonly />
						</td>
					  <!--- end Custom Samick --->
							  
                          <td align="center" class="formtext" style="vertical-align:top">
                              <input type="text" style="text-align:right" id="txtQty_#i#" name="txtQty_#i#" 
                                    <cfif val(qTmpDetail.config_level[i])> class="inpdim" readonly <cfelse> onBlur="setCurrTax(); setCurr(); calcAmount(#i#); recalcTotal(); decimalinForMoney(this);" onKeyPress="return isIntOnlyNew(event);" onChange="qty_ratio('#i#', this);"</cfif>
                                    value="#val(qTmpDetail.Qty[i])#" size="4"  maxlength="10" valign="center" />                          </td>
                          <td align="center" class="formtext" style="vertical-align:top"><input type="text" name="txtUnitType#i#" size="10" value="#qTmpDetail.Unit_Desc[i]#" #local.tmpFormInputAttribute# class="inpdim">                          </td>
                          <cfif not isdefined("qTmpDetail.Qty2")>
                            <cfquery name="qDua" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
                                      SELECT Scale FROM TPPICUnitConverter
                                      WHERE Status = 1
                                      AND Unit_Type_ID1='#qTmpDetail.Unit_Type[i]#'
                                      And Unit_Type_ID2='#qTmpDetail.Unit_Type2[i]#'
                               </cfquery>
                            <cfif qDua.recordcount>
                              <cfset Qty2=qTmpDetail.Qty[i]*val(qDua.Scale)>
                              <cfelse>
                              <cfset Qty2=qTmpDetail.Qty[i]>
                            </cfif>
                            <cfelse>
                            <cfset Qty2=qTmpDetail.Qty2[i]>
                          </cfif>
                          <td align="center" class="formtext" style="vertical-align:top">
                              <input type="text" style="text-align:right"  name="txtQty2_#i#" #local.tmpFormInputAttribute# class="inpdim"  value="#numberformat(val(Qty2),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="4" maxlength="10"  valign="center"></td>
                          <td align="center" class="formtext" style="vertical-align:top"><input type="text" name="txtUnitType2#i#" size="10" value="#qTmpDetail.Unit_Desc2[i]#" readonly class="inpdim">                          </td>
                          <cfset ItemQty = val(qTmpDetail.Qty[i])>
                          
						  
						   <!--- SN Qty --->							  
							  	
							  	 <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
	                              <input type="text" style="text-align:right" id="txtSNQty_#i#" name="txtSNQty_#i#" class="inpdim" readonly value="#val(SNQty)#" size="4"  maxlength="10" valign="center" />                          </td>
		                          <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
								  <input type="text" name="txtSNUnitType#i#" size="10" value="#qTmpDetail.Unit_Desc[i]#" #local.tmpFormInputAttribute# class="inpdim">                          </td>
		                          <!---<cfif not isdefined("SNQty2")>--->
		                            <cfquery name="qDua" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
		                                      SELECT Scale FROM TPPICUnitConverter
		                                      WHERE Status = 1
		                                      AND Unit_Type_ID1='#qTmpDetail.Unit_Type[i]#'
		                                      And Unit_Type_ID2='#qTmpDetail.Unit_Type2[i]#'
		                               </cfquery>
		                            <cfif qDua.recordcount>
		                              <cfset SNQty2=SNQty*val(qDua.Scale)>
		                              <cfelse>
		                              <cfset SNQty2=SNQty>
		                            </cfif>
									
								<!---	
		                          <cfelse>
		                            <cfset SNQty2=SNQty2>
		                          </cfif>
		                          --->
								  <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
		                              <input type="text" style="text-align:right"  name="txtSNQty2_#i#" #local.tmpFormInputAttribute# 
									  class="inpdim"  value="#numberformat(val(SNQty2),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" 
									  size="4" maxlength="10"  valign="center"></td>
		                          <td align="center" class="formtext" <cfif task eq "save">style="vertical-align:top;display:none"<cfelse>style="vertical-align:top"</cfif>>
								  	<input type="text" name="txtUnitType2#i#" size="10" value="#qTmpDetail.Unit_Desc2[i]#" readonly class="inpdim">                          </td>
		                         
							  <!--- end SN Qty --->
						  
						  
						  
						  <td align="center" class="formtext" style="vertical-align:top"><input type="text" style="text-align:right" 
                                    name="txtConvertedUnitPrice_#i#" id="txtConvertedUnitPrice_#i#" 
                                    value="#Numberformat(val(qTmpDetail.UnitPrice[i]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" 
                                    size="12" maxlength="15" valign="center" 
                                    onblur="setCurrTax(); setCurr(); calcAmount(#i#); recalcTotal(); decimalinForMoney(this);calculateTermOfPayment();" 
                                    onKeyPress="return isIntOnlyNew(event);"
                                    onChange="changeBGcolor(this);"

                                    #local.tmpFormInputAttribute# class="inplabel" />
                             
                              <input type="hidden" name="HidBase_ConvertedUnitPrice_#i#" value=""></td>
                          <cfset normal_price = val(qTmpDetail.UnitPrice[i])>
                          <cfset disc = "">
                          <cfset discountv	= "">
                          <cfset precious = normal_price * ItemQty>
                          
                          <td align="center" class="formtext" style="vertical-align:top">
                               <!--- randytia 26-07-2010 ---><input type="text" style="text-align:right" onChange="changeBGcolor(this); " name="txtDisc_#i#" id="txtDisc_#i#" value="#qTmpDetail.Disc_Value[i]#<!---#qTmpDetail.Disc_Percentage[i]#--->"  size="10" maxlength="10" valign="center" onBlur="calcAmount(#i#); recalcTotal();calcAmountAll();calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);" #local.tmpFormInputAttribute# class="inplabel" /><!--- class="inpdim" ---><!--- end --->
                              <input type="hidden" name="txtDiscv_#i#" value="#qTmpDetail.Disc_Percentage[i]#">
                              <input type="hidden" name="txtDiscType_#i#" value="#qTmpDetail.disc_type[i]#">
                              <input type="hidden" style="text-align:left" name="txtUnitId_#i#" value="#val(qTmpDetail.Unit_Type[i])#" readonly>
                              <input type="hidden" style="text-align:left" name="txtUnitId2_#i#" value="#val(qTmpDetail.Unit_Type2[i])#" readonly>
                              </td>
                          <td align="center" class="formtext" style="vertical-align:top">
						  <!--- randytia 27-09-2010 ---><input type="text" style="text-align:right" onChange="changeBGcolor(this);checkDiscAll(this);" name="txtDiscount1#i#" id="txtDiscount1#i#" value="#qTmpDetail.Disc_Percentage[i]#" size="10" maxlength="10" valign="center" onBlur="calcAmount(#i#); recalcTotal();calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);" #local.tmpFormInputAttribute# class="inplabel" />
                          </td>
                
                             
                          
                          <td align="center" class="formtext" style="vertical-align:top"><input type="text" style="text-align:right" name="txtConvertedAmount_#i#" value="#NumberFormat(val(qTmpDetail.TotalPrice[i]),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="12" maxlength="15" valign="center" readonly class="inplabel" />
                              <input type="hidden" name="HidBase_ConvertedAmount_#i#" value="" #local.tmpFormInputAttribute# />
                               <input type="hidden" style="text-align:right" name="txtExtra_#i#" value="#NumberFormat(0,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" size="10" maxlength="15" valign="center"  onBlur="setCurrTax(); setCurr();calcAmount(#i#);  recalcTotal();decimalinForMoney(this);calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);" #local.tmpFormInputAttribute# class="inplabel" />
                              </td>
                          <td align="center" class="formtext" style="vertical-align:top">
							  <cfif local.tmpDocType IS 0>
                                #DO_VAR['IncludedPPN']#
                              <cfelse>
                                <cfif qTmpDetail.Tax_Code1[i] IS 0>
                                  -
                                <cfelse>
                                  #qTmpDetail.Tax_Code1[i]#
                                </cfif>
                              </cfif>
                              <cfset tax1=qTmpDetail.Tax_Code1[i]>
                              <select style="display: none;" name="selTax1_#i#" id="selTax1_#i#" onChange="calcAmount(#i#); calcTax(); GetAmountGrand(); setCurrTax(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);">
                                <option value="#qTmpDetail.Tax_Code1[i]#|#qTmpDetail.Tax_Percentage1[i]#|#qTmpDetail.Tax_Operator1[i]#" selected="selected">#qTmpDetail.Tax_Code1[i]#</option>
                              </select>
                              <input type="hidden" name="txtTaxAmount1_#i#" value="#qTmpDetail.Tax_Amount1[i]#">
                              <input type="hidden" name="hidBase_TaxAmount1_#i#" value="#qTmpDetail.Tax_Amount1[i]#"></td>
                          <td align="center" class="formtext" style="vertical-align:top"><cfset tax2=qTmpDetail.Tax_Code2[i]>
                              <cfif qTmpDetail.Tax_Code2[i] IS 0>
                                -
                              <cfelse>
                                #qTmpDetail.Tax_Code2[i]#
                              </cfif>
                              
                              <select style="display: none;" name="selTax2_#i#" id="selTax2_#i#" onChange="calcAmount(#i#); calcTax(); GetAmountGrand(); setCurrTax(); decimalinForMoney(document.frmNew.txtTotAmount); decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge);">
                                <option value="#qTmpDetail.Tax_Code2[i]#|#qTmpDetail.Tax_Percentage2[i]#|#qTmpDetail.Tax_Operator2[i]#" selected="selected">#qTmpDetail.Tax_Code2[i]#</option>
                              </select>
                              <input type="hidden" name="txtTaxAmount2_#i#" value="#qTmpDetail.Tax_Amount2[i]#">
                              <input type="hidden" name="hidBase_TaxAmount2_#i#" value="#qTmpDetail.Tax_Amount2[i]#"></td>
                          
                          <input type="hidden" name="txtOthers_#i#" size="20" maxlength="50">
                          <td align="center" class="formtext" style="vertical-align:top" nowrap>
                              <cfset Local.ETAText = "">
							  <cfset Local.ETAItem = "">
							  <cfset Local.ETAValue = "">
                              <!--- <cfif isDefined("TXTESTIMATEDATESPLIT_#i#") and val(evaluate("HDNLEVEL_#i#")) eq 0> --->
                              <cfif isDefined("qTmpDetail") and val(qTmpDetail.config_level[i]) eq 0>
							  	<!--- <cfif evaluate('TXTESTIMATEDATESPLIT_#i#') eq "">
									<cfset datesplit = Evaluate("txtEstimateDate_#i#")>
								<cfelse>
	                                <cfset datesplit = ListGetAt(ListLast(evaluate('TXTESTIMATEDATESPLIT_#i#'),","),1,"|")>
								</cfif> --->
                                <cfif isDate(qTmpDetail.EstimateDate[i]) AND year(qTmpDetail.EstimateDate[i]) gt 1900>
								  <cfset dtmValue = #DateFormat(qTmpDetail.EstimateDate[i],"mm/dd/yyyy")#>
                                  <cfelse>
                                  <cfset dtmValue = "">
                                </cfif>
                                <script type="text/javascript">SunFishERP_DateTimePicker('txtEstimateDate_#i#','#dtmValue#');</script>
                                <cfset dcf_Identity=dcf_Identity+1>
                                <cfquery name="qGetETA" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                          <!---  select distinct TAccSO_ETA.*  from TAccSO_ETA
                                          where SO_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SONum#"/>

                                          and Item_Code=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qTmpDetail.Item_Code[i]#"/> --->
                                          
                                             select distinct TAccSO_ETA.*  from TAccSO_ETA
                                                                                          
                                            where TAccSO_ETA.SO_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SONum#"/>
                                            and TAccSO_ETA.Item_Code= <cfqueryparam cfsqltype="cf_sql_varchar" value="#qTmpDetail.Item_Code[i]#"/>
                                            and dimension_id = #qTmpDetail.dimension_id[i]#
                                      </cfquery>
                                <!--- <cfif len(trim(evaluate('TXTESTIMATEDATESPLIT_#i#')))>
                                  <cfset Local.ETAText = ""/>
                                </cfif> --->
                                <cfif qGetETA.recordCount>
								  <cfset Local.ETAText = ""/>
                                </cfif>
                                <!--- <cfloop list="#evaluate('TXTESTIMATEDATESPLIT_#i#')#" index="ioo"> --->
                                <cfloop query="qGetETA">
                                  <!--- <cfset Local.ETAItem = ioo>
                                  <cfset Local.ETAValue = ListAppend(Local.ETAValue,Local.ETAItem) />
                                  <cfset Local.ETAText = Local.ETAText & "<span style='display:block;font-size:8pt'>" & DateFormat(listfirst(ioo),"dd/mm/yyyy") & " : " & listlast(ioo) &  "</span>"/> --->
                                   <cfset Local.ETAItem = DateFormat(qGetETA.EstimateDate,"mm/dd/yyyy") & "|" & qGetETA.Qty />
								  <cfset Local.ETAValue = ListAppend(Local.ETAValue,Local.ETAItem) />
                                  <cfset Local.ETAText = Local.ETAText & "<span style='display:block;font-size:8pt'>" & DateFormat(qGetETA.EstimateDate,"dd/mm/yyyy") & " : " & qGetETA.Qty &  "</span>"/>
                                </cfloop>
                              </cfif>
                              <input type="hidden" name="txtEstimateDateSplit_#i#" id="txtEstimateDateSplit_#i#" value="#Local.ETAValue#" />
                              <span id="lnkEstimateDateSplit#i#">#Local.ETAText#</span> </td>
                          <td class="formtext" style="vertical-align:top"><cfif val(qTmpDetail.config_level[i]) eq 0>
                            <a name="lnkEstimateDateSplit#i#" style="display:block" href="javascript:void(0)" onClick="splitETA(#i#,#dcf_Identity#)"><IMG src="#Application.stApp.Web_Path[1]#/eaccounting/images/list.gif" alt="Multiple" align="absmiddle" border="0"></a>
                            <cfelse>
                            &nbsp;
                          </cfif></td>
                          <td align="center" class="formtext" style="vertical-align:top"><select name="selComponent_#i#">
                              <option value="0">..::[#DO_VAR['eHRMNone']#]::..</option>
                              <cfloop query="qGetComponent">
                                <option value="#qGetComponent.Comp_ID#">#Comp_Name#</option>
                              </cfloop>
                            </select></td>
                        </tr>
                        <input type="hidden" name="txtCurrencyID_#i#" value="#qTmpDetail.currency_id[i]#">
                        <input type="hidden" name="txtPriceType_#i#" value="#qTmpDetail.pricetype[i]#">
                        <input type="hidden" name="txtOriginPrice_#i#" value="#qTmpDetail.UnitPrice[i]#">
                        <input type="hidden" name="HidBase_ConvertedUnitPrice_#i#" value="#val(qTmpDetail.unitprice[i])#">
                        <input type="hidden" name="HidBase_ConvertedUnitPrice2_#i#" value="#val(qTmpDetail.unitPrice[i])#">
                        <input type="hidden" name="txtCS_#i#" value="">
                        <input type="hidden" name="hid_generate_flag_#i#" value="#val(qTmpDetail.generate_flag[i])#">
                        <input type="hidden" name="hdnSCDetailID_#i#" value="#val(qTmpDetail.Detail_ID[i])#">
                        
                        <cfset jumrowloop = jumrowloop + 1>
                      </cfloop>
                  </cfif>
                </table>
			    </DIV>
			  </DIV></td>
		</tr>
		
		<!--- add by NP, 03 Mei 2011 -- for free item --->
                
		<tr>
		<td>
		<DIV id="divFreeItem" style="width:100%; height:100%; overflow:auto">
		<cfif task eq "edit" and qGetFreeItem.recordcount>
			<input type="hidden" name="hdnCount" value="#qGetFreeItem.recordcount#">
			<table width="100%" id="tbl_FreeItem" class="formtext" cellpadding="2" cellspacing="1" border="0">
				<tr>
					<td class="formtitle" colspan="5">#DO_VAR["FreeItem"]#</td>
				</tr>
				<tr>
					<td class="formtitle">#DO_VAR["ItemCode"]#</td>
					<td class="formtitle">#DO_VAR["ItemName"]#</td>
					<td class="formtitle">#DO_VAR["Dimension"]#</td>
					<td class="formtitle">#DO_VAR["Qty"]#</td>
                    <td class="formtitle">#DO_VAR["CostCenter"]#</td>
				</tr>
				<cfloop query="qGetFreeItem">
				<tr>
					<td>#Item_Code#<input type="hidden" name="hdnFreeItemCode#currentrow#" value="#Item_Code#"></td>
					<td>#Item_Name#<input type="hidden" name="hdnFreeItemName#currentrow#" value="#Item_Name#"></td>
					<td>#Dimension_Name#<input type="hidden" name="hdnFreeDimension#currentrow#" value="#Dimension_Name#"><input type="hidden" name="hdnFreeDimensionID#currentrow#" value="#Dimension_ID#"></td>
					<td align="right">#NumberFormat(qGetFreeItem.Qty,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#<input type="hidden" name="hdnFreeQty#currentrow#" value="#Qty#"></td>
					<input type="hidden" name="hdnFreeUnitType#currentrow#" value="#Unit_Type#"></td>
                    <td nowrap align="center">
                        <cfparam name="FreeSelCostcenter#currentrow#" default="#qGetFreeItem.comp_id#" >
                        <select name="FreeSelCostcenter#currentrow#" >
                             <option value="0">#DO_VAR["None"]#</option>
                             <cfif qCostCenter.recordcount>
                                <cfloop query="qCostCenter">
                                    <cfif qCostCenter.flag eq 2>
                                        <optgroup label="#CostCenter_Code# - #CostCenter_Name#"></optgroup>
                                    <cfelse>    
                                        <option value="#costcenter_id#" <cfif costcenter_id eq evaluate("FreeSelCostcenter#qGetFreeItem.currentrow#")>selected</cfif> >#costcenter_code# - #costcenter_name#</option>  
                                    </cfif>
                                </cfloop>
                            </cfif> 
                        </select>
                    </td> 
				</tr>
				</cfloop>
				
			</table>
		</cfif>
			<!--- <table width="100%" id="tbl_FreeItem" class="formtext" cellpadding="2" cellspacing="1" border="0">
				<tr>
					<td class="formtitle" colspan="4">#DO_VAR["FreeItem"]#</td>
				</tr>
				<tr>
					<td class="formtitle">#DO_VAR["ItemCode"]#</td>
					<td class="formtitle">#DO_VAR["ItemName"]#</td>

					<td class="formtitle">#DO_VAR["Dimension"]#</td>
					<td class="formtitle">#DO_VAR["Qty"]#</td>
				</tr>
				
			</table> --->
		</div>
		</td>
		</tr>
		
		<!--- end --->
		<!--- End Detail - Start Total Amount --->
                <!--- Add Miscellaneous Charge --->
		
		<tr>
			<td colspan="3">
							<cfquery name="qAllocationType" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
								SELECT  AllocationType_ID, AllocationType_Code, AllocationType_Name
								FROM 	TAllocationType



								ORDER BY AllocationType_ID

							</cfquery> 
							<cfset vartemplate = "index.cfm">
							<cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785414">
							<a href="javascript://" onClick="arrNewPop[arrNewPop.length]=PopWindow('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&menu=sales&source=DSSO&task=save&ListMisc='+document.frmNew.ListMisc.value, 'Preview','500','500','scrollbars=yes,status=yes,resizable=yes');" style="text-decoration:none;">
								[+] #DO_VAR["Add"]# #DO_VAR["MiscellaneousCharge"]#						</a>
							<a href="javascript:delRowMisc('tbl_Misc',1)" title="Delete Row" onMouseOver="window.status='Delete Row'; return true;" onMouseOut="window.status=''; return true;">[-] #DO_VAR["Remove"]# #DO_VAR["MiscellaneousCharge"]#</a>						</td>
					</tr>
					<tr>
						<td colspan="3" style="border:3px double black;">
            	<cfif task eq 'edit'>
								<cfparam name="hidTransferMisc" default="#qGetMisc.recordcount#">
                <cfparam name="hidCountMisc" default="#qGetMisc.recordcount#">
              <cfelse>
              	<cfparam name="hidTransferMisc" default="0">
                <cfparam name="hidCountMisc" default="0">
              </cfif>
							<input type="Hidden" name="hidTransferMisc" value="#hidTransferMisc#">
              <input type="Hidden" name="hidCountMisc" value="#hidCountMisc#">
              <input type="hidden" name="ListMisc" value="#ListMisc#">
							<table width="100%" id="tbl_Misc" class="formtext" cellpadding="2" cellspacing="1" border="1">
							<tr>
								<td align="center" class="formtitle">
								<input type="Checkbox" onClick="IsSelectAllMisc(this)" name="chkAllMisc"></td> 
								<td align="center" class="formtitle">#DO_VAR["Name"]#</td>
								<td align="center" class="formtitle">#DO_VAR["Amount"]#</td>
                                <td align="center" class="formtitle">#DO_VAR["Tax"]#</td>
								<td align="center" class="formtitle">#DO_VAR["Notes"]#</td>
								<td align="center" class="formtitle">#DO_VAR['AllocationType']#</td>
							</tr>
              <cfset cnt = 1>
							<cfif isDefined("hidTransferMisc") AND hidTransferMisc neq 0 and task eq 'edit'>
								 <cfloop query="qGetMisc">
									<tr>
										<td align="center" class="formtext">
											<input type="checkbox" value="#cnt#" name="chkMisc"  onClick="pickThisMisc(this)">
										</td> 
										
										<td align="center" class="formtext">
											<input type="hidden" style="text-align:left" name="txtMiscChargeID#cnt#" value="#qGetMisc.MiscCharge_ID#">
											<input type="text" name="txtMiscChargeName#cnt#" value="#qGetMisc.MiscCharge_Name#" width="30" size="30" readonly class="inplabel">
										</td>
										
										<td align="center" class="formtext">
											<input type="text" name="txtConvertedAmountMisc_#cnt#" id="txtConvertedAmountMisc_#cnt#" 
									  		style="text-align:right"  value="#evaluate('qGetMisc.Amount')#" size="12" maxlength="15" onBlur= "calcAmountAll();calcTax(); GetAmountGrand();decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge); decimalinForMoney(document.frmNew.txtGrandTotalPayment);calculateTermOfPayment();decimalinForMoney(this)" 
											onKeyPress="return isIntOnlyNew(event);" onChange="changeBGcolor(this);">
                                      		<input type="hidden" name="HidBase_ConvertedAmountMisc_#cnt#" value="">

									  	</td>
                      <cfquery name="qGetTax" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                      		select * from TAccTax
                          where Tax_Code='#qGetMisc.Tax_Code#'
                      </cfquery>
									
																			
										<cfif val(qGetTax.Tax_Rate) neq 0>
                                      		<cfset "selTaxMisc_#cnt#"="#qGetMisc.Tax_Code#|#numberformat(qGetTax.Tax_Rate,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#qGetTax.Tax_Operator#">
                                  		<cfelse>
                                      		<cfset "selTaxMisc_#cnt#"="0|0|+">	
                                  		</cfif>
                                  		<td valign="top" align="center" class="formtext">
								  	 		<select name="selTaxMisc_#cnt#" onChange="calcAmountAll(); calcTax(); GetAmountGrand(); setCurrTax();decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv);calculateTermOfPayment();" > 
                                          		<option value="0|0|+" <cfif ListFindNOcase(EVALUATE("selTaxMisc_#cnt#"),0,"|") eq 1>SELECTED</cfif>>#DO_VAR["None"]#</option>
                                          		<cfloop query="qTaxType">
                                          			<cfset temp="#Tax_Code#|#Numberformat(Tax_Rate,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#Tax_operator#">
                                          			<option value="#temp#" <cfif Tax_Code eq qGetMisc.Tax_Code>SELECTED</cfif>>#Tax_Name#</option>
                                          		</cfloop>
                                      		</select>

                     					</td>
										
										<td align="center" class="formtext"><input type="text" name="txtNotes#cnt#" id="txtNotes#cnt#" style="text-align:left" value="#evaluate('qGetMisc.Notes')#" size="30" maxlength="30" ></td>
										
                                  		<td valign="top" align="center" class="formtext">
											<select name="selAllocationType#cnt#" onChange="calcAmountAll();calcTax(); GetAmountGrand();decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge); decimalinForMoney(document.frmNew.txtGrandTotalPayment);"> 
                                          		<option value="0" SELECTED>#DO_VAR["None"]#</option>
                                          		<cfloop query="qAllocationType">
                                          			<option value="#AllocationType_ID#" <cfif AllocationType_ID eq qGetMisc.Allocation_Type>SELECTED</cfif>>#AllocationType_Name#</option>
                                          		</cfloop>
                                      		</select>
                                      	</td>
									</tr>
                  <cfset cnt = cnt+1>
								</cfloop> 
              <cfelseif task eq 'save' and isDefined('rowcountMisc')>
								 <cfloop from="1" to="#rowCountMisc#" index="cnt">
                 	<cfif isDefined('txtMiscChargeID#cnt#')>
									<tr>
										<td align="center" class="formtext">
											<input type="checkbox" value="#cnt#" name="chkMisc"  onClick="pickThisMisc(this)">
										</td> 
										
										<td align="center" class="formtext">
											<input type="hidden" style="text-align:left" name="txtMiscChargeID#cnt#" value="#evaluate('txtMiscChargeID#cnt#')#">
											<input type="text" name="txtMiscChargeName#cnt#" value="#evaluate('txtMiscChargeName#cnt#')#" width="30" size="30" readonly class="inplabel">
										</td>
										
										<td align="center" class="formtext">
											<input type="text" name="txtConvertedAmountMisc_#cnt#" id="txtConvertedAmountMisc_#cnt#" 
									  		style="text-align:right"  value="#evaluate('txtConvertedAmountMisc_#cnt#')#" size="12" maxlength="15" onBlur= "calcAmountAll();calcTax(); GetAmountGrand();decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge); decimalinForMoney(document.frmNew.txtGrandTotalPayment);decimalinForMoney(this)"
											onKeyPress="return isIntOnlyNew(event);" onChange="changeBGcolor(this);">
                                      		<input type="hidden" name="HidBase_ConvertedAmountMisc_#cnt#" value="">
									  	</td>
			
                                      		<cfset "selTaxMisc_#cnt#"="#evaluate('selTaxMisc_#cnt#')#">

                                  		<td valign="top" align="center" class="formtext">
								  	 		<select name="selTaxMisc_#cnt#" onChange="calcAmountAll(); calcTax(); GetAmountGrand(); setCurrTax();decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotTaxConv); decimalinForMoney(document.frmNew.txtTotDeductConv);calculateTermOfPayment();" > 
                                          		<option value="0|0|+" <cfif ListFindNOcase(EVALUATE("selTaxMisc_#cnt#"),0,"|") eq 1>SELECTED</cfif>>#DO_VAR["None"]#</option>
                                          		<cfloop query="qTaxType">
                                          			<cfset temp="#Tax_Code#|#Numberformat(Tax_Rate,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#|#Tax_operator#">
                                          			<option value="#temp#">#Tax_Name#</option>
                                          		</cfloop>
                                      		</select>

                     					</td>
										
										<td align="center" class="formtext"><input type="text" name="txtNotes#cnt#" id="txtNotes#cnt#" style="text-align:left" value="#evaluate('txtNotes#cnt#')#" size="30" maxlength="30" ></td>
										
                                  		<td valign="top" align="center" class="formtext">
											<select name="selAllocationType#cnt#" onChange="calcAmountAll();calcTax(); GetAmountGrand();decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge); decimalinForMoney(document.frmNew.txtGrandTotalPayment);"> 
                                          		<option value="0" SELECTED>#DO_VAR["None"]#</option>
                                          		<cfloop query="qAllocationType">
                                          			<option value="#AllocationType_ID#">#AllocationType_Name#</option>
                                          		</cfloop>
                                      		</select>
                                      	</td>
									</tr>
                  </cfif>
								</cfloop> 
							</cfif>
              
							</table>						
						</td>
					</tr>

		<!--- End Miscellaneous Charge --->
					<tr>
          	<input type="hidden" name="hidQtyAll" id="hidQtyAll" value="0">
						<td colspan="3" id='Allocation' <cfif  hidCountMisc eq 0>style="display:none"</cfif>>
						<fieldset style="margin:6px;padding:10px;">
						<legend class="formtext">#DO_VAR["MiscChargeAllocation"]#</legend>
							
							<table width="100%" id="tbl_MiscAllo"  class="formtext" cellpadding="2" cellspacing="1" border="1">
							<tr>
								<td align="center" class="formtitle">
								<input type="checkbox" value="" name="chkAllAllo" id="chk" disabled onClick=""></td> 
								<td align="center" class="formtitle">#DO_VAR["ItemCode"]#</td>
								<td align="center" class="formtitle">#DO_VAR["Description"]#</td>
                				<cfif selcattype neq "AST">
                                <td align="center" class="formtitle" style="#displayStyle#">#DO_VAR["Dimension"]#</td>
								<td align="center" class="formtitle">#DO_VAR["Color"]#</td>
								<td align="center" class="formtitle">#DO_VAR["ItemBrand"]#</td>
								<td align="center" class="formtitle">#DO_VAR["eHRMType"]#</td>
                                </cfif>
								<td align="center" class="formtitle">#DO_VAR["Amount"]#</td>
							</tr>
        			<cfif task eq 'edit'>
              	<cfset rcd = qsalesdetail.recordcount>
              <cfelse>
              	<cfset rcd = 0>
              </cfif>
							
              <cfset i=1>
              <cfif task eq 'edit'>
									<cfif SELCATTYPE neq "AST">
                      <cfquery name="qGetMiscDet" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                      <!---
                        SELECT TAccSO_MiscChargeAllocation.item_code,
                                TItem.Item_name,
                                TAccSO_MiscChargeAllocation.dimension_id,
                                TItemDimension.dimension_name,
                                SUM(ISNULL(TAccSO_MiscChargeAllocation.Amount,0)) Amount
                        FROM TAccSO_MiscChargeAllocation
                        LEFT JOIN Titem ON TItem.Item_Code = TAccSO_MiscChargeAllocation.Item_Code
                        LEFT  JOIN 	TItemDimension ON TItemDimension.Dimension_ID =TAccSO_MiscChargeAllocation.Dimension_ID 
                        WHERE TAccSO_MiscChargeAllocation.SO_Number ='#SONum#'
                        GROUP BY TAccSO_MiscChargeAllocation.item_code,
                                TItem.Item_name,
                                TAccSO_MiscChargeAllocation.dimension_id,
                                TItemDimension.dimension_name
                      --->
                        SELECT TAccSO_Detail.item_code,
                                TItem.Item_name,
                                TAccSO_Detail.dimension_id,
                                 TItemDimension.dimension_name,
                                SUM(ISNULL(TAccSO_MiscChargeAllocation.Amount,0)) Amount,
								TItem.customfield1 AS item_description,
								TItem.Item_Color,
								TItem.Item_Size		
                        FROM TAccSO_Detail
                        LEFT JOIN TAccSO_MiscChargeAllocation ON TAccSO_Detail.SO_Number = TAccSO_MiscChargeAllocation.SO_Number
                        AND TAccSO_Detail.Item_Code = TAccSO_MiscChargeAllocation.Item_Code
                        AND TAccSO_Detail.Dimension_Id = TAccSO_MiscChargeAllocation.Dimension_Id
                        LEFT JOIN Titem ON TItem.Item_Code = TAccSO_Detail.Item_Code
                        LEFT  JOIN 	TItemDimension ON TItemDimension.Dimension_ID =TAccSO_Detail.Dimension_ID
                        WHERE TAccSO_Detail.SO_Number ='#SONum#'
                        GROUP BY TAccSO_Detail.item_code,
                                 TItem.Item_name,
                                 TAccSO_Detail.dimension_id,
                                 TItemDimension.dimension_name,
								 TItem.customfield1,
								TItem.Item_Color,
								TItem.Item_Size		 
                      </cfquery>
                  <cfelse>
                      <cfquery name="qGetMiscDet" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                      <!---
                        SELECT TAccSO_MiscChargeAllocation.item_code,
                                TAccAssetTemp.Asset_Desc,

                                TAccSO_MiscChargeAllocation.dimension_id,
                                '' as dimension_name,
                                SUM(ISNULL(TAccSO_MiscChargeAllocation.Amount,0)) Amount
                        FROM TAccSO_MiscChargeAllocation
                        LEFT  JOIN  TAccAssetTemp ON TAccAssetTemp.asset_code = TAccSO_MiscChargeAllocation.item_code
                        WHERE TAccSO_MiscChargeAllocation.SO_Number ='#SONum#'
                        GROUP BY TAccSO_MiscChargeAllocation.item_code,
                                 TAccAssetTemp.Asset_Desc,
                                TAccSO_MiscChargeAllocation.dimension_id
                        --->
                        SELECT TAccSO_Detail.item_code,
                                TAccAssetTemp.Asset_Desc item_name,
                                TAccSO_Detail.dimension_id,
                                '' as dimension_name,
                                SUM(ISNULL(TAccSO_MiscChargeAllocation.Amount,0)) Amount,
								'' AS item_description,
								'' AS Item_Color,
								'' AS Item_Size		
                        FROM TAccSO_Detail
                        LEFT JOIN TAccSO_MiscChargeAllocation ON TAccSO_Detail.SO_Number = TAccSO_MiscChargeAllocation.SO_Number
                        AND TAccSO_Detail.Item_Code = TAccSO_MiscChargeAllocation.Item_Code
                        AND TAccSO_Detail.Dimension_Id = TAccSO_MiscChargeAllocation.Dimension_Id
                        LEFT  JOIN  TAccAssetTemp ON TAccAssetTemp.asset_code = TAccSO_Detail.item_code
                        WHERE TAccSO_Detail.SO_Number ='#SONum#'
                        GROUP BY TAccSO_Detail.item_code,
                                 TAccAssetTemp.Asset_Desc,
                                 TAccSO_Detail.dimension_id
                      </cfquery>
                  </cfif>
                <cfelse>
                	<cfif rbTypeDoc neq 3>
                		<cfquery name="qGetMiscDet" dbtype="query">
                    		Select Item_Code,Item_Desc AS Item_Name,Dimension_Id, Dimension_Name, 0 Amount,
							item_description,Item_Color,Item_Size		
                        from qDetail
                        where 1=1
                    </cfquery>
                  <cfelse>
                		<cfquery name="qGetMiscDet" dbtype="query">
                    		Select Item_Code,Item_Desc AS Item_Name,Dimension_Id, Dimension_Name, 0 Amount,
							item_description,Item_Color,Item_Size	
                        from qTmpDetail
                        where 1=1
                    </cfquery>
                  </cfif>
                </cfif>
								
          			<cfif qGetMiscDet.recordcount gt 0>
								 <cfloop query="qGetMiscDet">
									<tr>
										<td align="center" class="formtext">
											<input type="checkbox" value="#i#" name="chkAllo" id="chk" disabled onClick="">

										</td> 
                                  
                                  <td valign="top" align="left" class="formtext" nowrap>
                                    <input type="text" name="txtPartNoMisc#i#" id="txtPartNoMisc#i#" value="#qGetMiscDet.item_code#" class="inplabel" width="10" size="15" readonly>
                                  </td>
                                  
                                  <td valign="top" align="left" nowrap><span id="txtDesc#i#">#HTMLEDITFORMAT(qGetMiscDet.Item_name)#</span><input type="hidden" name="txtDescMisc#i#" id="txtDescMisc#i#" value="#HTMLEDITFORMAT(qGetMiscDet.Item_name)#" size="20" width="30" readonly /></td>
                                  
                                  <cfif selcattype neq "AST">

                                  <td valign="top" align="left" nowrap style="#displayStyle#"><a
                                   href="javascript:void(0);"
                                   onClick="showLookup(#i#);" 
                                   style="text-decoration: none;"><img 
                                   id="imbPickDimension_#i#" border="0" style="display: ;" 
                                   src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/dimension_picker.gif" 
                                   onmouseover="return overlib('#DO_VAR['CHANGEITEMDIMENSION']#');" 
                                   onMouseOut="return nd();" width="15" height="13" /></a>&nbsp;<input type="text"
                                   name="txtDimensionNameMisc#i#" id="txtDimensionNameMisc#i#" 
                                   value="#HTMLEDITFORMAT(qGetMiscDet.Dimension_Name)#" 
                                   class="inplabel" readonly />
                                   </td>
								   <!--- Custom Samick --->
									<td align="left" valign="top" class="formtext">
										<span id="txtColorItemMisc_#i#">
										<cfif len(qGetMiscDet.item_color) AND structkeyexists(strctColor,qGetMiscDet.item_color)>
											#HTMLEDITFORMAT(strctColor[qGetMiscDet.item_color])#
										</cfif>
										</span>
										<input type="hidden" name="txtColorItemMisc_#i#" id="txtColorItemMisc_#i#" 
										<cfif len(qGetMiscDet.item_color) AND structkeyexists(strctColor,qGetMiscDet.item_color)>
											value="#HTMLEDITFORMAT(strctColor[qGetMiscDet.item_color])#"
										<cfelse>
											value=""	
										</cfif>
										size="20" width="30" readonly />
									</td>
									<td align="left" valign="top" class="formtext">
									<span id="txtBrandItemMisc_#i#">#HTMLEDITFORMAT(qGetMiscDet.Item_size)#</span>
									<input type="hidden" name="txtBrandItemMisc_#i#" id="txtBrandItemMisc_#i#" value="#HTMLEDITFORMAT(qGetMiscDet.Item_size)#" size="20" width="30" readonly />
									</td>
									<td align="left" valign="top" class="formtext">
									<span id="txtTypeItemMisc_#i#">#HTMLEDITFORMAT(qGetMiscDet.Item_description)#</span>
									<input type="hidden" name="txtTypeItemMisc_#i#" id="txtTypeItemMisc_#i#" value="#HTMLEDITFORMAT(qGetMiscDet.Item_description)#" size="20" width="30" readonly />
									</td>
								  <!--- end Custom Samick --->
                                   </cfif>
                                   <input type="hidden" 
                                   name="txtDimensionIDMisc#i#" id="txtDimensionIDMisc#i#" 
                                   value="#qGetMiscDet.Dimension_ID[i]#" />
                                  
								   <input type="hidden" name="hdnMatrixItem#i#">
								   <input type="hidden" name="hdnEventQty#i#">								   
								   <input type="hidden" name="hdnEventPrice#i#">
								   <input type="hidden" name="hdnEventDiscAmount#i#">
								   <input type="hidden" name="hdnEventDiscPercent#i#">
								   <input type="hidden" name="hidQtyFree#i#">
								   <input type="hidden" name="flagwarna#i#" id="flagwarna#i#" value="0" />
								   <input type="hidden" name="chkwarna#i#" id="chkwarna#i#" value="0" size="20" width="30" style="border: none" readonly /> 
								  
								 <td align="center" class="formtext">
                 		 <input type="hidden" name="hidTotalMiscNonUD_#i#" id="hidTotalMiscNonUD_#i#" value="0">
											<input type="text" name="txtConvertedAmountMisc2_#i#" id="txtConvertedAmountMisc2_#i#" 
									  		style="text-align:right" width="30" size="20" onBlur="calcAmountAll(); GetAmountGrand();decimalinForMoney(this)"
											<cfif task eq "save">

													value="0"<!--- "#val(qMiscCharge.Amount[cnt])#" --->

											<cfelse>
												value="#NumberFormat(val(qGetMiscDet.Amount),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#"
											</cfif>
											<cfif isdefined("generate_flag") and generate_flag eq 2>readonly</cfif> onKeyPress="return isIntOnlyNew(event);" onChange="">
                                      		<input type="hidden" name="HidBase_ConvertedAmountMisc2_#i#" value="">
									  	</td>
							</tr>
              	<cfset i=i+1>
								</cfloop>
                <cfelseif task eq 'save' and isDefined('rowcountMiscAllo')>
                
    								<cfloop from="1" to="#rowCountMiscAllo#" index="i">
                      <tr>
                        <td align="center" class="formtext">
                          <input type="checkbox" value="#i#" name="chkAllo" id="chk" disabled onClick="">
    
                        </td> 
                                      
                                      <td valign="top" align="left" class="formtext" nowrap>
                                        <input type="text" name="txtPartNoMisc#i#" id="txtPartNoMisc#i#" value="#evaluate('txtPartNoMisc#i#')#" class="inplabel" width="10" size="15" readonly>
                                      </td>
                                      
                                      <td valign="top" align="left" nowrap><span id="txtDesc#i#">#HTMLEDITFORMAT(evaluate('txtDescMisc#i#'))#</span><input type="hidden" name="txtDescMisc#i#" id="txtDescMisc#i#" value="#HTMLEDITFORMAT(evaluate('txtDescMisc#i#'))#" size="20" width="30" readonly /></td>
                                      
                                      <cfif selcattype neq "AST">
                                      <td valign="top" align="left" nowrap style="#displayStyle#"><a
                                       href="javascript:void(0);"
                                       onClick="showLookup(#i#);" 
                                       style="text-decoration: none;"><img 
                                       id="imbPickDimension_#i#" border="0" style="display: ;" 
                                       src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/dimension_picker.gif" 
                                       onmouseover="return overlib('#DO_VAR['CHANGEITEMDIMENSION']#');" 
                                       onMouseOut="return nd();" width="15" height="13" /></a>&nbsp;<input type="text"
                                       name="txtDimensionNameMisc#i#" id="txtDimensionNameMisc#i#" 
                                       value="#HTMLEDITFORMAT(evaluate('txtDimensionNameMisc#i#'))#" 
                                       class="inplabel" readonly />
                                       </td>
									      <!--- Custom Samick --->
										<td align="left" valign="top" class="formtext">
											<span id="txtColorItemMisc_#i#">
											<cfif len("txtColorItemMisc_#i#") AND structkeyexists(strctColor,"txtColorItemMisc_#i#")>
												#HTMLEDITFORMAT(strctColor["txtColorItemMisc_#i#"])#
											</cfif>
											</span>
											<input type="hidden" name="txtColorItemMisc_#i#" id="txtColorItemMisc_#i#" 
											<cfif len("txtColorItemMisc_#i#") AND structkeyexists(strctColor,"txtColorItemMisc_#i#")>
												value="#HTMLEDITFORMAT(strctColor['txtColorItemMisc_#i#'])#"
											<cfelse>
												value=""	
											</cfif>
											size="20" width="30" readonly />
										</td>
										<td align="left" valign="top" class="formtext">
										<span id="txtBrandItem_#i#">#HTMLEDITFORMAT("txtBrandItemMisc_#i#")#</span>
										<input type="hidden" name="txtBrandItemMisc_#i#" id="txtBrandItemMisc_#i#" value="#HTMLEDITFORMAT('txtBrandItemMisc_#i#')#" size="20" width="30" readonly />
										</td>
										<td align="left" valign="top" class="formtext">
										<span id="txtTypeItem_#i#">#HTMLEDITFORMAT("txtTypeItemMisc_#i#")#</span>
										<input type="hidden" name="txtTypeItemMisc_#i#" id="txtTypeItemMisc_#i#" value="#HTMLEDITFORMAT('txtTypeItemMisc_#i#')#" size="20" width="30" readonly />
										</td>
									  <!--- end Custom Samick --->
                                       </cfif>
                                       <input type="hidden" 
                                       name="txtDimensionIDMisc#i#" id="txtDimensionIDMisc#i#" 
                                       value="#evaluate('txtDimensionIDMisc#i#')#" />
                                      
                      
                     <td align="center" class="formtext">
                         <input type="hidden" name="hidTotalMiscNonUD_#i#" id="hidTotalMiscNonUD_#i#" value="#evaluate('hidTotalMiscNonUD_#i#')#">
                          <input type="text" name="txtConvertedAmountMisc2_#i#" id="txtConvertedAmountMisc2_#i#" 
                            style="text-align:right" width="30" size="20" onBlur="calcAmountAll(); GetAmountGrand();decimalinForMoney(this)"
                          <cfif task eq "save">
    
                              value="0"<!--- "#val(qMiscCharge.Amount[cnt])#" --->
    
                          <cfelse>
                            value="#NumberFormat(val(evaluate('txtConvertedAmountMisc2_#i#')),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#"
                          </cfif>
                          <cfif isdefined("generate_flag") and generate_flag eq 2>readonly</cfif> onKeyPress="return isIntOnlyNew(event);" onChange="">
                                              <input type="hidden" name="HidBase_ConvertedAmountMisc2_#i#" value="">
                          </td>
                  </tr>

                    </cfloop>
                
                </cfif>
					
							</table>
						  </fieldset>						
						</td>
					</tr>
      <cfparam name="hidTransfer" default="0">   
      <cfparam name="hidCountTransfer" default="0">
      
			<cfif task eq 'edit'><input type="Hidden" name="hidTransfer" value="#qsalesdetail.recordcount#"><cfelse>
					<cfif qDetail.recordcount gt 0>
            <cfif rbTypeDoc neq 3>
              <input type="Hidden" name="hidTransfer" value="#qDetail.recordcount#">
            <cfelse>
              <input type="Hidden" name="hidTransfer" value="#qTmpDetail.recordcount#">
            </cfif>
          <cfelse>
          <input type="Hidden" name="hidTransfer" value="#hidTransfer#">
          </cfif>
			</cfif>
 			<cfif task eq 'edit'><input type="Hidden" name="hidCountTransfer" value="#qsalesdetail.recordcount#"><cfelse>
					<cfif qDetail.recordcount gt 0>
            <cfif rbTypeDoc neq 3>
                <input type="Hidden" name="hidCountTransfer" value="#qDetail.recordcount#">
            <cfelse>
                <input type="Hidden" name="hidCountTransfer" value="#qTmpDetail.recordcount#">
            </cfif>
          <cfelse>
          <input type="Hidden" name="hidCountTransfer" value="#hidCountTransfer#">
          </cfif>
			</cfif>
		<tr>
    
			<!--- ### START NEW PAYMENT TERM --->
			<cfif rbTypeDoc eq "2">
			  <cfif task eq "Save">
			    <cfset dtmValue = #DateFormat(now(),"mm/dd/yyyy")#>
			  <cfelse>
			    <cfset dtmValue = #DateFormat(txtInvDueDate,"mm/dd/yyyy")#>
			  </cfif>
			<cfelse>
			  <cfif task eq "Save">
                            <cfif isdefined("qdetail.Due_Date") and qdetail.Due_Date neq "">
			              <cfset dtmValue = #DateFormat(qdetail.Due_Date,"mm/dd/yyyy")#>
			       <cfelse>
                                  <cfset duedate = dateadd("d",40,now())>
                                   <cfset dtmValue = #DateFormat(duedate,"mm/dd/yyyy")#>
                            </cfif>
                       <cfelse>
			    <cfset dtmValue = #DateFormat(txtInvDueDate,"mm/dd/yyyy")#>
			  </cfif>
			</cfif>
			
			<cfquery name="qPaymentDetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			  <!--- SELECT 
			    DUEDATE, AMOUNT 
			  FROM 
			    TACCDUEDATE 
			  WHERE 
			    TACCDUEDATE.TRXID = '#SONUM#' 
				AND TACCDUEDATE.TYPE = 'SO' 
				AND TACCDUEDATE.COMPANYID = '#COOKIE.COMPANYID#' --->
				select invoice_date INVOICEDATE, due_date DUEDATE, AMOUNT  from TACCCUSTOMERPAYMENT
					where TRX_NUMBER = '#SONUM#' 
					and DOC_TYPE = 'SO'
					and COMPANY_ID = #COOKIE.COMPANYID#
			</cfquery>
			
			<td valign="top" align="left">
			
			<table width="45%" id="tblIDX" class="formtext" cellpadding="2" cellspacing="1" border="0">			  	
			<!---  <tr>
			  <td><a
			   href="javascript://" title="Add Payment Terms" onClick="addRowTerm('tblPayment');" 
			   onmouseover="window.status='Add Payment Terms'; return true;" onMouseOut="window.status=''; return true;">[+] 
			   <em>Add Payment Term</em></a>&nbsp;<a 
			   href="javascript:delRowTerm('tblPayment')" title="Delete Row" onMouseOver="window.status='Delete Row'; return true;" 
			   onmouseout="window.status=''; return true;">[-] 

			   <em>Remove Payment Term</em></a></td>
			</tr>
			
			<tr>
			  <td style="border:3px double black;">
		  
		  <table width="100%" id="tblPayment" class="formtext" cellpadding="2" cellspacing="1" border="0">
			<tr>
			  <td align="center" class="formtitle" width="3%"><input type="Checkbox" onClick="IsSelectAllTerm(this,'')" name="chkAllTerm"></td>
			  <td align="center" class="formtitle" width="47%" nowrap>#DO_VAR['DueDate']#<br
			   /><font style="font-size: 9px; font-weight: normal;">(mm/dd/yyyy)</font></td>
			  <td align="center" class="formtitle" width="50%" nowrap>#DO_VAR['Amount']#</td>
			</tr>
			
			<cfloop query="qPaymentDetail">
			  <tr>
				<td align="center"><input type="checkbox" value="#currentrow#" name="chkTerm" onClick="pickTerm(this)">
				<td align="center"><input type="text" value="#DATEFORMAT(qPaymentDetail.DueDate, "mm/dd/yyyy")#" name="txtInvDueDate#currentrow#">
				<td align="center"><input type="text" value="#NumberFormat(qPaymentDetail.Amount,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" name="txtInvAmount#currentrow#"
				 onKeyPress="return isIntOnlyNew(event);" onBlur="decimalin(this);" size="22" style="text-align:right;"></td>
			  </tr>
			</cfloop>
		  </table>
		  
			  </td>

			</tr> --->
			<tr>
			<td colspan="2">#DO_VAR["paymentdetail"]#</td>
		</tr>
		<tr>
			<td>

				<table align="left" border="0" cellpadding="2" cellspacing="1" class="formtext" id="tblPayment"> 
					<tr><td class="formtitle">#DO_VAR["No"]#</td>
						<td class="formtitle">#DO_VAR["InvoiceDate"]#</td>
						<td class="formtitle">#DO_VAR["DueDate"]#</td>
						<td class="formtitle">#DO_VAR["Amount"]#</td>
					</tr>

					<cfif task eq "Edit" AND cboTerms eq qSales.Terms>
					<!--- grace remark, 29 dec 09, kalo cicilan, percentagenya ga 100, angkanya jadi salah --->
						<!--- <cfquery name="qTerms2" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
							SELECT TACCCUSTOMERPAYMENT.Payment_Period, TACCCUSTOMERPAYMENT.Due_Date, TACCCUSTOMERPAYMENT.Amount , 100 AS percentage
							FROM TACCCUSTOMERPAYMENT
							WHERE TACCCUSTOMERPAYMENT.TRX_Number = '#qSales.SO_Number#'
							AND TACCCUSTOMERPAYMENT.DOC_TYPE = 'SO'
							AND COMPANY_ID = #COOKIE.COMPANYID#
							ORDER BY PAYMENT_PERIOD
						</cfquery> --->
						<cfquery name="qTerms2" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">

							Select TAccCustomerPayment.Payment_Period,TAccCustomerPayment.Due_Date,TAccCustomerPayment.Amount,
								TAccTermOfPayment_Detail.Percentage,TAccCustomerPayment.Invoice_Date
							From TAccCustomerPayment, TAccTermOfPayment_Detail
							Where TAccCustomerPayment.TOP_Code=TAccTermOfPayment_Detail.TOP_Code
							And TAccTermOfPayment_Detail.Term_Id=TAccCustomerPayment.Payment_Period
							And TAccCustomerPayment.Doc_Type='SO'
							And TAccCustomerPayment.Company_Id=#Cookie.CompanyId#
							And TAccCustomerPayment.Trx_Number='#qSales.SO_Number#'
							Order By TAccCustomerPayment.Payment_Period
						</cfquery>
					<!--- grace end --->
					<cfelse>
                    	
						<cfquery name="qTerms2" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
							Select 	TAccTermOfPayment_Header.TOP_COde, 
                            		TAccTermOfPayment_Header.TOP_Type, 
                                    TAccTermOfPayment_Header.Term, 
                                    TAccTermOfPayment_Detail.Percentage, 
                                    TAccTermOfPayment_Detail.Term_ID 
							from TAccTermOfPayment_Header, TAccTermOfPayment_Detail
							WHERE TAccTermOfPayment_Header.TOP_CODE = TAccTermOfPayment_Detail.TOP_Code
							AND TAccTermOfPayment_Detail.TOP_Code = '#local.cboTerms#'
							ORDER BY TAccTermOfPayment_Detail.TERM_ID
						</cfquery>
					</cfif>
					<cfparam name="hdnTerm" default="#qTerms2.recordcount#">
					<cfif task eq "Edit" AND cboTerms eq qSales.Terms and qTerms2.recordcount>
						<cfif qTerms2.recordcount>
                        	<!--- qTerms2 <cfdump var="#qTerms2#"> --->
							<cfloop query="qTerms2">
								<tr><td align="center">#qTerms2.Payment_Period#</td>
									<td align="center">
										<script type="text/javascript">
											SunFishERP_DateTimePicker('txtInvoiceDate#qTerms2.currentrow#','#DateFormat(qTerms2.Invoice_Date,"mm/dd/yyyy")#');
											</script>
									</td>
									<td align="center">
										<!--- andiJ. 17Mar'10, use SunFishERP_DateTimePickerbnv
										<input type="text" value="#DateFormat(qTerms2.Due_Date,'mm/dd/yyyy')#" name="txtDueDate#qTerms2.currentrow#"> --->
										<script type="text/javascript">
											SunFishERP_DateTimePicker('txtDueDate#qTerms2.currentrow#','#DateFormat(qTerms2.Due_Date,"mm/dd/yyyy")#');
										</script>
									</td>
									<td align="center"><!---#qTerms2.Amount#---><input type="text" style="text-align:right" 
									value="#NumberFormat(qTerms2.Amount,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" 
									name="txtAmount#qTerms2.currentrow#" id="txtAmount#qTerms2.currentrow#" onKeyPress="return isIntOnlyNew(event);" onBlur="decimalinForMoney(this);" size="22"></td>
									<input type="hidden" name="hidPercentage#qTerms2.currentrow#" id="hidPercentage#qTerms2.currentrow#" value="#qTerms2.Percentage#">
	                              </tr>                                                                                                                                       
						   </cfloop>
						</cfif>
						<input type="Hidden" name="hdnTerm" value="#qTerms2.recordcount#">
					<cfelse>
						<cfquery name="qGetTerms" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
							SELECT * FROM TAccPaymentTerm WHERE paymentterm_code = '#cbotermsnew#'
						</cfquery>
						<cfif qGetTerms.recordcount eq 0>
							<cfset term_type = "m">
							<cfset term_duration = 1>
						<cfelse>
							<cfset term_type = qGetTerms.paymentterm_type>
							<cfif term_type eq "w"><cfset term_type = "ww"></cfif>
							<cfif term_type eq "y"><cfset term_type = "yyyy"></cfif>
							<cfset term_duration = qGetTerms.paymentterm_duration>
						</cfif>
						<cfquery name="qGetTerms1" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
							SELECT Term_Type FROM TAccTermOfPayment_Header WHERE TOP_Code = '#local.cboTerms#'
						</cfquery>
						<cfif qGetTerms1.recordcount eq 0>
							<cfset term_type1 = "d">
						<cfelse>
							<cfset term_type1 = Left(qGetTerms1.Term_Type,1)>
							<cfif term_type1 eq "w"><cfset term_type1 = "ww"></cfif>
							<cfif term_type1 eq "y"><cfset term_type1 = "yyyy"></cfif>
						</cfif>
						<!--- remark by wx :: 9 Nov 2010 :: harus mengikuti tgl invoice / due date pada header bukan tanggal SO 
															dan due date harus sesuai payment termnya
						<cfif txtSODate neq "">
							<cfset currdate = txtSODate>
						<cfelse>
							<cfset currdate = now()>
						</cfif>
						<cfif txtInvDueDate neq "">
							<cfset currdate2 = txtInvDueDate>
						<cfelse>
							<cfset currdate2 = DateAdd(term_type,term_duration,currdate)>
						</cfif> --->
						<cfif txtInvDueDate neq "">
							<cfset currdate = txtInvDueDate>
						<cfelse>
							<cfset currdate = now()>
						</cfif> 
						<cfset currdate2 = DateAdd(term_type,term_duration,currdate)>
						<input type="hidden" name="hdntermtype" value="#term_type#">
						<input type="hidden" name="hdntermduration" value="#term_duration#">
						<input type="hidden" name="hdntermtype1" value="#term_type1#">
						<cfset totalamount = val(replacenocase(txtGrandTotal,",","","All"))>
						<cfif qTerms2.recordcount and qTerms2.TOP_Type neq "CASH">
                        <cfset idx = 1>
                        <cfset amountTemp = 0>
		
							<cfloop query="qTerms2">
															<cfset amount = val(qTerms2.percentage) * totalamount / 100>
						
								<tr><td align="center">#qTerms2.currentrow#</td>
									<td align="center">
                                        <script type="text/javascript">
											SunFishERP_DateTimePicker('txtInvoiceDate#qTerms2.currentrow#','#DateFormat(currdate,"mm/dd/yyyy")#');
										</script></td>
									<td align="center">
										<!--- andiJ. 17Mar'10, use SunFishERP_DateTimePicker
											<input type="text" value="#DateFormat(currdate,'mm/dd/yyyy')#" name="txtDueDate#qTerms2.currentrow#"> --->

										<!--- IvanP. 19 July 2010 wrong Current row for datetime picker ! <script type="text/javascript">
											SunFishERP_DateTimePicker('txtDueDate#qTerms.currentrow#','#DateFormat(currdate,"mm/dd/yyyy")#');
										</script>--->
                                        <script type="text/javascript">
											SunFishERP_DateTimePicker('txtDueDate#qTerms2.currentrow#','#DateFormat(currdate2,"mm/dd/yyyy")#');
										</script></td>
                                    <cfif idx neq qTerms2.recordCount>
									<td align="center"><input type="text" style="text-align:right" 
									value="#NumberFormat(val(amount),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" 
									name="txtAmount#qTerms2.currentrow#" id="txtAmount#qTerms2.currentrow#" onKeyPress="return isIntOnlyNew(event);" onBlur="decimalinForMoney(this);" size="22">
									
									
<!---									<div id="warn" style="background:##FF6633; border:##CC0000 solid"> *******************************************************
									 amount = val(qTerms2.percentage) * totalamount / 100<br />*************this code only to show some variables value, no calculation
									 #amount# = #qTerms2.percentage# * #totalamount# / 100 ***************	affected.
									</div>**********************************************************************************************************************
--->									

									</td>
                                    <cfelse>                 
                                    <!---randytia	04Juni2010	--->                   

                                    <cfset amountTemp = totalamount - amountTemp>
										
                                    <td align="center">
									
									<input type="text" style="text-align:right" 
									value="#NumberFormat(val(amountTemp),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" 
									name="txtAmount#qTerms2.currentrow#" id="txtAmount#qTerms2.currentrow#" onKeyPress="return isIntOnlyNew(event);" onBlur="decimalinForMoney(this);" size="22">
									
									
									
									</td>

                                    </cfif>
								    <input type="hidden" name="hidPercentage#qTerms2.currentrow#" id="hidPercentage#qTerms2.currentrow#" value="#qTerms2.Percentage#">
                                </tr>
								<cfset currdate = DateAdd(term_type1,1,currdate)>
								<!--- remark by wx :: 9 Nov 2010 :: harus mengikuti payment termnya tidak boleh dihardcode = next invoice date 
								<cfset currdate2 = DateAdd(term_type1,1,currdate2)> --->
								<cfset currdate2 = DateAdd(term_type,term_duration,currdate)>
                                <cfset amountTemp += amount>
                                <cfset idx += 1>
							</cfloop>	
										
							<input type="Hidden" name="hdnTerm" value="#qTerms2.recordcount#">
						<cfelse>
                            <cfset totalamount = qPaymentDetail.AMOUNT>
							<cfparam name="txtAmount1"		default="0">
							<cfparam name="txtInvoiceDate1"	default="#currdate#">
							<cfparam name="txtDueDate1"		default="#currdate2#">

							<tr><td align="center">1</td>								
								<td align="center">
									<script type="text/javascript">
										SunFishERP_DateTimePicker('txtInvoiceDate1','#DateFormat(currdate,"mm/dd/yyyy")#');
									</script>
								</td>
								<td align="center">
									<!--- andiJ. 17Mar'10, use SunFishERP_DateTimePicker
										<input type="text" value="#DateFormat(currdate,'mm/dd/yyyy')#" name="txtDueDate1"> --->
									<script type="text/javascript">
										SunFishERP_DateTimePicker('txtDueDate1','#DateFormat(currdate2,"mm/dd/yyyy")#');
									</script>
								</td>
								<td align="center">
									<input type="text" style="text-align:right" 
									value="#NumberFormat(totalamount,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" name="txtAmount1" 
									id="txtAmount1" onKeyPress="return isIntOnlyNew(event);" onBlur="decimalinForMoney(this);" size="22">

									<input type="hidden" name="hidPercentage1" id="hidPercentage1" value="100">
								</td>
							</tr>
							<input type="Hidden" name="hdnTerm" value="1">
						</cfif>
					</cfif>

				</table>			
				</td>
			</tr>
			</table>
			<script>
				function changepaymentdate(){<!--- wx :: 9 Nov 2010 :: perubahan tgl payment detail ketika SO date atau Due date diubah --->
					//var dtp_Identity = 5;
					dtp_Identity =4;
					for(i=1;i<=parseInt(document.forms[0].hdnTerm.value);i++){
						if(i==1){
							//invoice date
							var sodate = document.forms[0].txtInvDueDate.value.split("/");
							
							var nextmth = parseInt(sodate[0])-1;
							
							var nextyear = parseInt(sodate[2]);
							var currdate = new Date(nextyear,nextmth,parseInt(sodate[1]));
							//alert(currdate)
							eval("Picker"+dtp_Identity+".setSelectedDate(currdate)");
							eval("Picker"+dtp_Identity+".setVisibleDate(currdate)");
							
							//due date
							dtp_Identity = dtp_Identity + 1;
							nextduedate = parseInt(sodate[1]);
							nextduemth = parseInt(nextmth);
							nextdueyear = nextyear;
							
							if(document.forms[0].hdntermtype.value == "m")
								nextduemth = parseInt(nextduemth) + parseInt(document.forms[0].hdntermduration.value);
							else if(document.forms[0].hdntermtype.value == "d")
								nextduedate = parseInt(nextduedate) + parseInt(document.forms[0].hdntermduration.value);
							else if(document.forms[0].hdntermtype.value == "ww")
								nextduedate = parseInt(nextduedate) + (parseInt(document.forms[0].hdntermduration.value)*7);

							else if(document.forms[0].hdntermtype.value == "yyyy")
								nextdueyear = parseInt(nextdueyear) + parseInt(document.forms[0].hdntermduration.value);
								
							var currduedate = new Date(nextdueyear,nextduemth,nextduedate);
							eval("Picker"+dtp_Identity+".setSelectedDate(currduedate)");
							eval("Picker"+dtp_Identity+".setVisibleDate(currduedate)");
							
						}else{
							var vardate = currdate.getDate();
							//invoice date
							if(document.forms[0].hdntermtype1.value == "m")
								nextmth = parseInt(nextmth) + 1;
							else if(document.forms[0].hdntermtype1.value == "d")
								vardate = parseInt(vardate) + 1;
							else if(document.forms[0].hdntermtype1.value == "ww")
								vardate = parseInt(vardate) + 7;
							else if(document.forms[0].hdntermtype1.value == "yyyy")

								nextyear = parseInt(nextyear) + 1;
								
							/*if(nextmth > 12){ nextmth = 1; nextyear = nextyear + 1; }
							if(nextmth == 2){
								if(nextyear % 4 == 0 && vardate > 29)
									vardate = 29;
								else if(vardate > 28)
									vardate = 28;
							}else if(nextmth == 4 || nextmth == 6 || nextmth == 9 || nextmth == 11 ){
								if(vardate > 30)
									vardate = 30;
							}*/
							var nextdate = new Date(nextyear, nextmth, vardate);
							dtp_Identity = dtp_Identity + 1;
							eval("Picker"+dtp_Identity+".setSelectedDate(nextdate)");
							eval("Picker"+dtp_Identity+".setVisibleDate(nextdate)");
							
							//due date
							varduedate = nextdate.getDate();
							nextduemth = parseInt(nextmth);
							nextdueyear = nextyear;
							if(document.forms[0].hdntermtype.value == "m")
								nextduemth = parseInt(nextduemth) + parseInt(document.forms[0].hdntermduration.value);
							else if(document.forms[0].hdntermtype.value == "d")
								varduedate = parseInt(varduedate) + parseInt(document.forms[0].hdntermduration.value);
							else if(document.forms[0].hdntermtype.value == "ww")
								varduedate = parseInt(varduedate) + (parseInt(document.forms[0].hdntermduration.value) * 7);
							else if(document.forms[0].hdntermtype.value == "yyyy")
								nextdueyear = parseInt(nextdueyear) + parseInt(document.forms[0].hdntermduration.value);
							
							/*if(nextduemth > 12){ nextduemth = 1; nextdueyear = nextdueyear + 1; }
							if(nextduemth == 2){
								if(nextdueyear % 4 == 0 && varduedate > 29)
									varduedate = 29;
								else if(varduedate > 28)
									varduedate = 28;
							}else if(nextduemth == 4 || nextduemth == 6 || nextduemth == 9 || nextduemth == 11 ){
								if(varduedate > 30)
									varduedate = 30;
							}*/
							var nextduedate = new Date(nextdueyear, nextduemth, varduedate);
							dtp_Identity = dtp_Identity + 1;
							eval("Picker"+dtp_Identity+".setSelectedDate(nextduedate)");
							eval("Picker"+dtp_Identity+".setVisibleDate(nextduedate)");
							
						}
					}
				}
			</script>
			</td>
			<!--- ### END OF NEW PAYMENT TERM --->
			<td align="right" valign="baseline">
				<table class="formtext" border="0" >
                <tr>
					<td colspan="2" align="right">
						<div id="contentprice"></div>
            <div id="contentdiscount">
			<input type="hidden" name="hdnDiscount" id="hdnDiscount" value="0">
<input type="hidden" name="hdnDiscountv" id="hdnDiscountv" value="0">
			</div>
						<div id="contentdiscounttotal"></div>
					</td>
				</tr>  
				<tr>
					<td><span id="idTotalQty">Total Qty</span></td>
					<td>: <input type="Text"  style="text-align:right" name="txtTotQty" size="15" maxlength="20" readonly class="inplabel" value="<cfif isdefined('qdetail.qty')>#NumberFormat(val(qDetail.qty),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#<cfelse>#NumberFormat(val(txtTotQty),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#</cfif>">
						  <input type="hidden" name="hidBaseTotQty" value="">
				    </td>
				</tr>
				<tr>
					<td><span id="idTotalAmount">#DO_VAR['TotalAmount']# (Converted)</span></td>
					<td>: <input type="Text"  style="text-align:right" name="txtTotAmount" size="15" maxlength="20" readonly class="inplabel" value="<cfif isdefined('qdetail.totalprice')>#NumberFormat(val(qDetail.totalprice),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#<cfelse>#NumberFormat(Val(txtTotAmount),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#</cfif>" onChange="decimalinForMoney(this);">
						  <input type="hidden" name="hidBaseTotAmount" value="">					</td>
				</tr>
				
				<tr>
					<td>
                    <!--- randytia 26-07-2010 --->
                    	<script>
							function checkDiscAll(obj){
								if(obj.value>100){
									obj.value=100;
								}
							}
						</script>
                    <!--- end --->    
						<span id="idDisctotal">
							#DO_VAR['Disc']#.   &nbsp;&nbsp;
							<!--- randytia 26-07-2010 ---><input type="Text" id="idDiscall" name="txtDisctotal" maxlength="5" style="width:40px;" value="#txtDisctotal#" onChange="checkDiscAll(this);calculateTermOfPayment();"  onBlur="recalcTotal();calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);">
                            &nbsp;%<!--- onKeyPress="return ((event.keyCode == 46) || (event.keyCode >= 48) && (event.keyCode <= 57))" ---><!--- end --->
						</span>					</td>
                    <!--randytia	15-04-2010-->
					<td>: 
						  <input type="text" id="idTotalDiscall" style="text-align:right"  name="txtTotDisc" size="15"  maxlength="20" onBlur="getPercent(this); recalcTotal();calculateTermOfPayment();decimalinForMoney(this);"  readonly="true" value="#NumberFormat(Val(txtTotDisc),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" onKeyPress="return isIntOnlyNew(event);">
						  <input type="hidden" id="idBaseTotalDiscall" name="hidBaseTotDisc" value="">					</td>

				</tr>
				
				<tr id="idTaxHide" style="display:''">
					<td><span id="idTotalTax">#DO_VAR["TotalTax"]# (Converted)</span></td>
					<td>: <input type="Text"  style="text-align:right" name="txtTotTaxConv" size="15" maxlength="20"  readonly class="inplabel" value="#NumberFormat(tax_plus,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" onChange="decimalinForMoney(this);">
						 <input type="hidden" id="hdnTotTaxConvBase" name="hdnTotTaxConvBase" value="">	
                         <!---  tax freight sekarang ini tidak diperhitungkan --->					</td>
				</tr>
				<tr>
					<td><span id="idTotalDeduction">#DO_VAR["TotalDeduction"]# (Converted)</span></td>
					<td>: <input type="Text"  style="text-align:right" name="txtTotDeductConv" size="15" maxlength="20" readonly class="inplabel" value="#NumberFormat(tax_minus,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#"></td>
					<input type="hidden" id="hdnTotDeductConvBase" name="hdnTotDeductConvBase" value="">	
                </tr>
				<tr>
					<td><span id="idTotalDeduction">#DO_VAR["TotalMiscellaneousCharge"]# (Converted)</span></td>
					<td>: <input type="Text"  style="text-align:right" name="txtTotMiscCharge" size="15" maxlength="20" readonly class="inplabel" value="0"></td>
                </tr>
				 
				<tr><td colspan="2"><hr></td></tr>
				<tr id="idTaxHide2">
					<td><span id="idGrandTotal">#DO_VAR["GrandTotal"]# (Converted)</span></td>
					<td>: <input type="Text" id="txtGrandTotal" name="txtGrandTotal" style="text-align:right"  size="15" maxlength="20" readonly class="inplabel" 
						  value="#numberformat(val(txtGrandTotal),",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#" onChange="decimalinForMoney(this);">					
					</td>
				</tr>

			<!--- b:CRF50912-07376 : add "claim deduction" field --->
			<!--- untuk lebih memudahkan currency id nya == currency id so --->
				<tr>
					<td>
						#do_var['claimdeduction']# 
						<span id="cd_curr">
							(<cfif isDefined('form.selCurrency')>#form.selCurrency#<cfelse>#selCurrency#</cfif>)
						</span>
					</td>
					<td>: 
						<input type="text" id="txt_cd_amount" name="txt_cd_amount" onKeyPress="return isIntOnlyNew(event);"
						value="<cfif task eq "edit">#qSales.claim_deduction_amount#<cfelse>#claim_deduction_amount#</cfif>" 
						onChange="recalcTotal();recalcDeduction();decimalinForMoney(this);">
					</td>
				</tr>
				<tr>
					<td valign="top">#do_var['Description']#</td>
					<td valign="top">: 
						<textarea name="txt_cd_desc"><cfif task eq "edit">#trim(qsales.claim_deduction_desc)#</cfif></textarea>
					</td>
				</tr>
			<!--- e:CRF50912-07376 : add "claim deduction" field --->

				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2" style="border-top:1px solid black; height:25px;" valign="middle" align="left">
				<cfif not isDefined('isPopUp')>
					<!--- kalau EDIT --->
					<cfif task eq "save" OR (task eq "edit" and SO_Status lt 2)><!--- New --->
						<cfset varStatusAccess = REQUEST.SFSecAccess.SecStatusAccess(FILEACCESSCODE="ERSTD0785411", 
												 USERID="#evaluate("cookie.#Application.stApp.Cookie_Name[1]#")#")>
	
						<cfif task eq "edit">
							<cfset btnValue="#DO_VAR['Update']#">
						<cfelse>
							<cfset btnValue="#DO_VAR['Save']#">
						</cfif>

						<cfif varStatusAccess>
							<input type="Button" name="btnSubmit" value="#btnValue#" onClick="passingVars();" style="width:100px">
							<input type="Button" name="btnConfirm" value="#DO_VAR['eHRMconfirm']#" onClick="passingVars('YES');" style="width:100px">
						</cfif>
					</cfif>
					<cfif task eq "Edit" and SO_Status eq 3 and qSetting.EnableSORevision eq 1>
							<input type="Hidden" name="hidRevision" value="#(qSales.Revision_Number+1)#">
							<cfset varStatusAccess = REQUEST.SFSecAccess.SecStatusAccess(FILEACCESSCODE="ERSTD0785412", 
													 USERID="#evaluate("cookie.#Application.stApp.Cookie_Name[1]#")#")>
		
							<cfif varStatusAccess eq "Yes">
								<input type="Button" name="btnRevise" value="#DO_VAR['Revise']#" onClick="cekRevisi();" style="width:100px">
							</cfif>
						<!---</cfif>--->
					</cfif>
					<!--- Erica: END ENC50311-02068 - for SO edit features --->
  
					<input type="button" name="btnCancel" value="#DO_VAR['Cancel']#" onClick="self.location='#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/index.cfm?HelpCategory_id=eAccSales&Help_Id=SalesOrder&FID=ERSTD07854&FUID=ERSTD0785401&menu=1;'" style="width:100px">			
         		<cfelse>
         			<input type="button" name="btnCancel" value="#DO_VAR['Cancel']#" onClick="window.close();" />
         		</cfif>       
        	</td>
		</tr>
		<cfif task eq "edit">
			<tr><td colspan="2">
				<table cellpadding="2" cellspacing="2" class="formtext">
					<tr>
						<td align="right">#DO_VAR['CreatedBy']#</td>
						<td align="center">:</td>
						<td>#qSales.Created_By_Name#</td>
					</tr>
					<tr>
						<td align="right">#DO_VAR['creationdate']#</td>
						<td align="center">:</td>
						<td>#qSales.Creation_DateTime_Display#</td>
					</tr>

					<tr>
						<td align="right">#DO_VAR['update']# #DO_VAR['by']#</td>
						<td align="center">:</td>
						<td>#qSales.Update_By_Name#</td>
					</tr>
					<tr>
						<td align="right">#DO_VAR['eHRMLastUpdate']#</td>
						<td align="center">:</td>
						<td>#qSales.Last_Update_Display#</td>
					</tr>
				</table>
			</td></tr>
		</cfif>
		</table>	
	</td>
</tr>
</table>
<!--- Javascript array to HTML --->
<!--- // *********************************************************** // --->
<!--- // Sales Person Selection 								 	 // --->
<!--- // *********************************************************** // --->	
<cfif val(qSetting.salesPerson) eq "1">
<DIV id="divSales" style="display:none; position:absolute; border:2px solid black; background-color:white;">
	<table border="0" class="formtext" cellpadding="2" cellspacing="1" id="tblSales">
		<tr>
			<td colspan="2">
				<input type="Text" name="txtSalesSearch" size="20" maxlength="50">
				<input type="button" value="#DO_VAR['Search']#" onClick="populateSales();">
				<input type="button" value="#DO_VAR['ShowAll']#" onClick="populateSales('all');">
			</td>
		</tr>
		<tr>
			<td>
				<table border="0" cellpadding="2" cellspacing="1">
					<tr>
						<td class="formtitle" style="width:137px">#DO_VAR["Employee_ID"]#</td>
						<td class="formtitle" style="width:152px">#DO_VAR["eHRMEmployeeName"]#</td>
					</tr>
				</table>				
			</td>
		</tr>
		<tr>
			<td>
				<DIV style="overflow:auto; width:300px; height:200px;" id="div">
				<table border="0" id="tblDataSales" cellpadding="2" cellspacing="1">
					<cfloop index="x" from="1" to="#qEmpList.RecordCount#">
					<tr id ="#qEmpList.emp_id[x]#" onMouseOver="hoover(this)" onMouseOut="unHoover(this)" onClick="selectSales(this)">
						<td class="formtext" style="width:137px">
							<cfif len(qEmpList.emp_id[x]) gt 15>
								#left(qEmpList.emp_id[x], 15)# ...
							<cfelse>
								#qEmpList.emp_id[x]#
							</cfif>
						</td>
						<td class="formtext" style="width:137px">
							<cfif len(qEmpList.name[x]) gt 15>
								#left(qEmpList.name[x], 15)# ...
							<cfelse>
								#qEmpList.name[x]#
							</cfif>
						</td>
					</tr> 
					</cfloop>
				</table>
				</DIV>
			</td>
		</tr>
		<tr>
			<td align="right" style="border-top:1px solid black;"><input type="Button" value="#DO_VAR['Close']#" onClick="popSales('no');"></td>
		</tr>
	</table>
</DIV>
</cfif>
<cfif task eq 'edit'>
	<cfset jumrowloopMisc = qGetMisc.recordcount>
</cfif>
<input type="Hidden" name="hidCurrRow" value="">
<input type="hidden" name="txtconfirm" value="">
<input type="Hidden" name="selCBType"  value="#selCatType#">
<input type="Hidden" name="rowCount" value="#jumrowloop#">
<input type="Hidden" name="rowCountMisc" value="#jumrowloopMisc#">
<input type="Hidden" name="rowCountMiscAllo" value="#jumrowloop#">
<input type="Hidden" name="rowCountTerm" value="<cfif qPaymentDetail.recordCount eq 0>0<cfelse>#qPaymentDetail.recordCount#</cfif>">
<input type="hidden" name="listalready" value="">
<input type="hidden" name="isExport" value="#isExport#"  />


<cfif rbTypeDoc IS 3>
<input type="hidden" name="hdnLstItemID" id="hdnLstItemID" value="#hdnLstItemID#" />
</cfif>
</form>
</body>
</html>
<cfinclude template="#Application.stApp.CFWeb_Path[1]##Application.stApp.SPT[VST_IDX]##Application.stApp.Home_Url[vst_idx]##Application.stApp.SPT[VST_IDX]#include#Application.stApp.SPT[VST_IDX]#validatedatefromto.cfm">
<!--- JS untuk hitung2 --->
<script>

function addRowMisc(thetype){
	if(document.forms[0].chkAll.length > 1)
		document.forms[0].chkAll[0].checked = false;
	else
		document.forms[0].chkAll.checked = false;
	
	document.forms[0].rowCountMisc.value = parseInt(document.forms[0].rowCountMisc.value) + 1
	cnt =  document.forms[0].rowCountMisc.value 
	 
	objTblMisc = document.getElementById('tbl_Misc')
	newTR = objTblMisc.insertRow(objTblMisc.rows.length)
	newTR.id = "tr"+cnt
	
	newTD = newTR.insertCell(0)
	newTD.width = "20";
	newTD.Align = "center";
	<!--- newTD.innerHTML = '<input type="checkbox" value="'+cnt+'" name="chk"  onClick="pickThis(this)">' --->
	newTD.innerHTML = '<input type="checkbox" value="'+cnt+'" name="chkMisc"  onClick="pickThisMisc(this)"><input type="Hidden" name="parent_item'+cnt+'" value=""><input type="Hidden" name="parent_path'+cnt+'" value="">';
	
	newTD = newTR.insertCell(1)
	newTD.align = "center";
	newTD.innerHTML = '<input type="hidden" style="text-align:left" name="txtMiscChargeID'+cnt+'" value=""><input type="text" name="txtMiscChargeName'+cnt+'" value="" size="30" width="30" readonly class="inplabel">';
	 
	newTD = newTR.insertCell(2)
	newTD.align = "center";

	newTD.innerHTML = '<input type="text" style="text-align:right" onChange="changeBGcolor(this);" name="txtConvertedAmountMisc_'+cnt+'" id="txtConvertedAmountMisc_'+cnt+'" value=0 size="12" maxlength="15" onblur="calcAmountAll(); calcTax(); GetAmountGrand();decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge); decimalinForMoney(document.frmNew.txtGrandTotalPayment);calculateTermOfPayment();" onKeyPress="return isIntOnlyNew(event);" onkeyup="decimalinForMoney(this);">'; <!--- updated --->	
	
	newTD = newTR.insertCell(3)
	newTD.align = "center";
	newTD.innerHTML = '<select name="selTaxMisc_'+cnt+'" onchange="calcAmountAll();calcTax(); GetAmountGrand();decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge); decimalinForMoney(document.frmNew.txtGrandTotalPayment);calculateTermOfPayment();"><option value="0|0|0">None</option><cfloop query="qTaxType"><option value="#Tax_Code#|#Tax_rate#|#Tax_Operator#">#Tax_Name#</option></cfloop></select>';


	newTD = newTR.insertCell(4)
	newTD.align = "center";
	newTD.innerHTML = '<input type="text" style="text-align:left" onChange="changeBGcolor(this);" name="txtNotes'+cnt+'" id="txtNotes'+cnt+'" value="" size="30" maxlength="30" >'; <!--- updated --->	
	

	newTD = newTR.insertCell(5)
	newTD.align = "center";
	newTD.innerHTML = '<select name="selAllocationType'+cnt+'" onchange="calcAmountAll();calcTax(); GetAmountGrand();decimalinForMoney(document.frmNew.txtGrandTotal); decimalinForMoney(document.frmNew.txtTotDeductConv); decimalinForMoney(document.frmNew.txtTotMiscCharge); decimalinForMoney(document.frmNew.txtGrandTotalPayment);"><option value="0">None</option><cfloop query="qAllocationType"><option value="#AllocationType_ID#">#AllocationType_Name#</option></cfloop></select>';
		
	//untuk keperluan delete - kelvin - 29 Aug 08
	document.frmNew.hidTransferMisc.value = parseInt(document.frmNew.hidTransferMisc.value) + 1;
	document.frmNew.hidCountMisc.value = parseInt(document.frmNew.hidCountMisc.value) + 1;
	
	showAllocation(1);

}

function delRowMisc(tblMisc,type){
	objTbl = document.getElementById(tblMisc);
	objChk = document.getElementsByName('chkMisc'); 
	


	if(objTbl==null || objChk==null)
		return;
	if(objChk.length==null){ //one row only
		if(objChk.checked || type==2){
			var otr=objChk.parentNode.parentNode;
			otr.parentNode.removeChild(otr);
			document.frmNew.hidCountMisc.value = parseInt(document.frmNew.hidCountMisc.value) - 1;
		}
	}else{
		var j=0;
		do {
			if(objChk[j].checked || type==2){
				var elinv1 = eval("document.frmNew.txtConvertedAmountMisc_"+objChk[j].value);
				if(elinv1!=null)
					elinv1.value="0";
					
				var elinv2 = eval("document.frmNew.HidBase_ConvertedUAmountMisc_"+objChk[j].value);
				if(elinv2!=null)
					elinv2.value="0";
					
				var elinv3 = eval("document.frmNew.txtNotes"+objChk[j].value);
				if(elinv3!=null)
					elinv3.value="0";
				
				var elinv4 = eval("document.frmNew.txtMiscChargeID"+objChk[j].value);	
				document.frmNew.ListMisc.value = document.frmNew.ListMisc.value.replace(","+elinv4.value,"");
				
				var elinv5 = eval("document.frmNew.selTaxMisc_"+objChk[j].value);
				if(elinv5!=null)
					elinv5.value="0";
					
				var elinv6 = eval("document.frmNew.selAllocationType"+objChk[j].value);
				if(elinv6!=null)
					elinv6.value="0";
					
				var elinv7 = eval("document.frmNew.hidTotalMiscNonUD_"+objChk[j].value);
				if(elinv7!=null)
					elinv7.value="0";
				
				var otr=objChk[j].parentNode.parentNode;
				otr.parentNode.removeChild(otr);
				
				document.frmNew.hidCountMisc.value = parseInt(document.frmNew.hidCountMisc.value) - 1;
			}else
				j++;
		}
		while (j<objChk.length)
	}
	document.frmNew.chkAllMisc.checked = false;
	calcAmountAll();
	calcTax();
	GetAmountGrand();
	
	var countMisc = document.frmNew.hidCountMisc.value;
	if(countMisc > 0){
			showAllocation(1);
	}else{
			showAllocation(0);
	} 
}
/*
//updated by kelvin 29 Aug 08
function delRowMisc_(tblMisc,type){
	objTbl = document.getElementById(tblMisc)
	<!--- objChk = document.getElementsByName('chk') --->
	objChk = document.forms[0].chk;
	var obj = objChk.length;
	
	if(type == 1){
		for (i=objChk.length-1; i>=0; i--){
			if(objChk[i].checked){
				<!---
				IVN : 30 November 2009
				Disabled and Change to table row, 
				hidTranser ga pernah di set isinya 0 mulu pasti boss ... !!!
				
				var len = parseInt (document.forms[0].hidTransferMisc.value) - 1;--->
				var len = parseInt(objTbl.rows.length) - 1;
				var delCount = 0;
				
				//mengambil semua nilai chk yg ada
				for (m=len; m>=0; m--){
					if(document.forms[0].chk[m]){
						if(document.forms[0].chk[m].value == objChk[i].value) //jika nilai chk sama dengan checkbox yg dipilih
						{
							var parent = document.forms[0].chk[m].value;
							
							//mengambil semua nilai chk yg ada
							for (k=len; k>=0; k--){
								var child = k + 1;
								if(eval("document.forms[0].txtPartNo" + parent)){

									if(eval("document.forms[0].hid_parent_item" + child)){
										<!---alert(eval("document.forms[0].hid_parent_item" + child).value);--->
										if(eval ("document.forms[0].hid_parent_item" + child).value == eval ("document.forms[0].txtPartNo" + parent).value)//jika parent item-nya sama dengan item
											delCount = delCount + 1;
									}
								}
		
							}
						}
					}
				}
				
				for (del = 0; del < delCount; del++){
					if(objTbl.rows[i + 2])
					objTbl.deleteRow(i + 2);
				}
		
				if(objTbl.rows[i + 1])
				objTbl.deleteRow(i+1);
			}
		}
	}else{
		for (i=objChk.length-1; i>=0; i--){ 
			objTbl.deleteRow(i+1) 
		}
	}
	frmNew.chkAll.checked = false;
	calcAmountAll();
	calcTax();
	GetAmountGrand();
}*/
// === Add by IVN Apr 01, 09 ===
    // Function Add Row Term

	function addRowTerm(){

	  var doc = document.frmNew;
	  document.frmNew.rowCountTerm.value = parseInt(document.frmNew.rowCountTerm.value) + 1;
	  counter = document.frmNew.rowCountTerm.value;
	  
	  objTbl = document.getElementById("tblPayment");
	  newTR = objTbl.insertRow(objTbl.rows.length);
	  newTR.id = "stage_"+counter;
	  
	  var tablename = counter;
	  
	  newTD = newTR.insertCell(0)
	  newTD.width = "20";
	  newTD.Align = "center";

	  newTD.style.verticalAlign="top";
	  newTD.innerHTML = '<input type="checkbox" value="'+counter+'" name="chkTerm" onClick="pickTerm(this)">';
	  
	  newTD = newTR.insertCell(1);
	  newTD.innerHTML = '<input type="text" value="#dtmValue#" name="txtInvDueDate'+counter+'">';
	  
	  newTD = newTR.insertCell(2);
	  newTD.innerHTML = '<input type="text" value="'+doc.txtGrandTotal.value+'" name="txtInvAmount'+counter+'" onKeyPress="return isIntOnlyNew(event);" onBlur="decimalinForMoney(this);" size="22" style="text-align:right;">';
	}
	
	// Function Pick This
	function pickTerm(thisobj){
	  var TblObj = document.getElementById('tblPayment');
	  var NumOfRows = TblObj.rows.length - 1 // minus 1 because it's the header
	  if(thisobj!= ''){
	    if(thisobj.checked) selectedRows++;
		else selectedRows--;
	  }
	  
	  if(selectedRows==NumOfRows){
	    document.frmNew.chkAllTerm.checked = true;
	  }else{
	    document.frmNew.chkAllTerm.checked = false;
	  }
	}
	
	// Function Is Select All
	function IsSelectAllTerm(thisobj,tablename){
	  if(tablename == ''){
	    var chkObjs = document.getElementsByName('chkTerm');
		table_name = 'tblPayment';
	  }else{
	    chkname= 'chk'+tablename;
		table_name = 'tablename';
	  }
	  
	  if(thisobj.checked){
	    for (var i=0; i<chkObjs.length; i++){
		  if( chkObjs[i].disabled ==false){
		    chkObjs[i].checked = true;
			selectedRows = document.getElementById('tblPayment').rows.length-1;
		  }
		}
	  }else{
	    for (var i=0; i<chkObjs.length; i++){
		  chkObjs[i].checked = false;
		  selectedRows = 0;
		}
	  }
	}
	
	// Function Get Parent

	function getParent(th,type){
	  var obj = th;

	  var objType = obj.nodeName;
	  var found = false;
	  type = type.toUpperCase();
	  
	  while ((objType!=type) && (objType!='##document')){
	    obj = obj.parentNode;
		objType = obj.nodeName;
		
		if(objType==type){
		  return obj;
		}
	  }
	}
	
	// Function Delete Row Stage
//modified version for delete rows by TW: 2009-12-07
function delRowTerm(){
	objTbl = document.getElementById("tblPayment");
	objChk = document.getElementsByName('chkTerm');
	if(objTbl==null || objChk==null)
		return;
	if(objChk.length==null){ //one row only
		objChk[0]=objChk;
/*		if(objChk.checked){
			var otr=objChk.parentNode.parentNode;
			otr.parentNode.removeChild(otr);
		}*/
	}
//	else{
		var j=0;
		do {
			if(objChk[j].checked){
				var elinv=eval("document.frmNew.txtInvAmount"+objChk[j].value);
				if(elinv!=null)
					elinv.value="0";
				var otr=objChk[j].parentNode.parentNode;
				otr.parentNode.removeChild(otr);
			}else
				j++;
		}
		while (j<objChk.length)

//	}
	document.frmNew.chkAllTerm.checked = false;
}
	function delRowTerm_(){
	  var objChk = document.getElementsByName('chkTerm');
	  objTbl = document.getElementById('tblPayment');
	  var obj = objChk.length;
	  var theBody;
	  
	  try
	  {
	    theBody = objTbl.tBodies(0);
	  }
	  catch(e){
	    theBody = objTbl.tBodies[0];
	  }
	  
	  var theRow = theBody.rows;
	  var rowToBeDeleted = new Array();
	  
	  for (var i=objChk.length-1; i>=0; i--){
	    if(objChk[i].checked){
		  //document.frmNew.ListExpenses.value = document.frmNew.ListExpenses.value.replace(objChk[i].value,"");
		  
		  var row = getParent(objChk[i],"tr");
		  var isSelected = false;
		  
		  for (var counter=0;counter<theRow.length;counter++){
		    if(theRow[counter]==row){
			  isSelected = true;
			  rowToBeDeleted[rowToBeDeleted.length] = theRow[counter];
			}
			if(isSelected && theRow[counter]!=row){
			  var inputs = theRow[counter].getElementsByTagName("input ");
			  var hasCheckbox = false;
			  
			  for (var x=0;x<inputs.length;x++){
			    if(inputs[x].name == 'chkTerm'){
				  hasCheckbox = true;
				}
			  }
			  if(!hasCheckbox){
			    rowToBeDeleted[rowToBeDeleted.length] = theRow[counter];
			  }else{
			    break;
			  }
			}
		  }
		}
	  }
	  if(rowToBeDeleted.length>0){
	    for (var counter=0;counter<rowToBeDeleted.length;counter++){
		  theBody.removeChild(rowToBeDeleted[counter]);
		}
	  }
	  
	  document.frmNew.chkAllTerm.checked = false;
	}
	
	// Function Validating Date
	function isValidDate(pdate){
	  var sp = pdate.split("/");
	  
	  if(sp.length != 3){
	    return false;
	  }
	  
	  var d = sp[1];
	  var m = sp[0];
	  var y = sp[2];
	  
	  try
	  {
	    var dt = new Date(y,m,d);
		
		if(dt=='NaN'){
		  return false;
		}else{
		  return true;
		}
	  }
	  catch(e){
	    return false;
	  }
	}
	
	// Function Check Payment Term
	function chkPaymentTerm(){
	  var TblObjTerm = document.getElementById('tblPayment');
	  var NumOfRowsTerm = TblObjTerm.rows.length-1; // minus 1 because it's the header
	  
	  var objTtlQty = 0;

	  var objSOCurrency = document.forms[0].selCurrency;
	  var objTaxCurrency = document.forms[0].selTaxCurrency;
		
	  if(objSOCurrency.value != objTaxCurrency.value){
		  objTtlQty = parseFloat(document.forms[0].txtTotAmount.value.split(",").join(""));
	  }else{
		  objTtlQty = parseFloat(document.forms[0].txtGrandTotal.value.split(",").join(""));
	  }


	  var tmpTtlQty = 0;
	  
	  /*for (i = 1; i <= document.frmNew.rowCountTerm.value; i++){
	    if(eval("document.frmNew.txtInvDueDate"+i)){
		  dt = eval("document.frmNew.txtInvDueDate"+i).value;
		  if(!isValidDate(dt)){
		    alert('#DO_VAR['InvalidDate']#!');
			eval("document.frmNew.txtInvDueDate"+i).focus();
			eval("document.frmNew.txtInvDueDate"+i).select();
			return false;
			break;
		  }else if(new Date(dt) < new Date(document.frmNew.txtSODate.value))//or used to be Customer PO Date???
		  {
		    alert('#DO_VAR['InvoiceMustGreater']#');
			eval("document.frmNew.txtInvDueDate"+i).focus();
			eval("document.frmNew.txtInvDueDate"+i).select();
			return false;
			break;
		  }
		}
		if(!document.frmNew.chkDonation.checked){
		  if(eval("document.frmNew.txtInvAmount"+i)){
			qty = eval("document.frmNew.txtInvAmount"+i).value.split(",").join("");
			if(qty == '' || parseFloat(qty) < 0)//=
			{
			  alert('#DO_VAR['InvalidAmount']#!');
			  eval("document.frmNew.txtInvAmount"+i).focus();
			  eval("document.frmNew.txtInvAmount"+i).select();
			  return false;
			  break;
			}
			
			tmpTtlQty = tmpTtlQty + parseFloat(qty);
		  }
		}
	  }*/
	  if(objSOCurrency.value == objTaxCurrency.value){
		  for(edf = 1;edf <= document.frmNew.hdnTerm.value;edf++){
			if(eval("document.frmNew.txtDueDate"+edf)){
			  dt = eval("document.frmNew.txtDueDate"+edf).value;
			  /*if(!isValidDate(dt)){
				alert('#DO_VAR['InvalidDate']#!');
				eval("document.frmNew.txtDueDate"+edf).focus();
				eval("document.frmNew.txtDueDate"+edf).select();
				return false;
				break;
			  }else*/ 
			  if(new Date(dt) < new Date(document.frmNew.txtSODate.value))//or used to be Customer PO Date???
			  {
				alert('#DO_VAR['InvoiceMustGreater']#');
				eval("document.frmNew.txtDueDate"+edf).select();
				return false;
				break;
			  }
			}
			tmpTtlQty = tmpTtlQty + parseFloat(eval("document.frmNew.txtAmount"+edf).value.split(",").join(""));
		  }

		if(parseFloat(decformat(tmpTtlQty).split(",").join("")) != parseFloat(decformat(objTtlQty).split(",").join(""))){
			alert('#DO_VAR['PaymentTermAmount']# '+decformat(parseFloat(tmpTtlQty))+' #DO_VAR['DifferentFromGrandTotal']# '+decformat(parseFloat(objTtlQty)));
			return false;
		}
		else{
			return true;
		}
	}else{
		return true;
	}
}
// === End of Add ===


// === Add by ZZ Nov 7, '08 ===
var curAllocateTo = 0;

function changeType(type){
	var rowCnt = parseInt(document.frmNew.rowCount.value);
	/*if(rowCnt!=0 && type.value != curAllocateTo){
		alert("#DO_VAR['AlreadyHaveItem']#, #DO_VAR['DeleteItem']# #DO_VAR['Before']# #DO_VAR['Continue']#");
		type.checked = false;
		if(type.value == 0){
			document.frmNew.rdoAllocate[1].checked = true;
		}else{
			document.frmNew.rdoAllocate[0].checked = true;
		}
	}else{*/
		if(type.value==""){
			document.getElementById("allocateTo").innerHTML = "#DO_VAR['ProjectComponent']#";
		}else if(type.value=="1"){
			document.getElementById("allocateTo").innerHTML = "#DO_VAR['CostCenter']#";


		}

		curAllocateTo = parseInt(type.value);
		document.frmNew.action = '';
		document.frmNew.submit();
	//}
}

var curSelType = 0;
function checkRow(type){
	var rowCnt = parseInt(document.frmNew.rowCount.value);
	/*if(rowCnt!=0 && type.selectedIndex != curSelType){
		type.selectedIndex = curSelType;
		alert("#DO_VAR['AlreadyHaveItem']#, #DO_VAR['DeleteItem']# #DO_VAR['Before']# #DO_VAR['Continue']#");
	}else{
		curSelType = parseInt(type.selectedIndex);
		changeType(document.frmNew.rdoAllocate);*/
		curAllocateTo = document.frmNew.rdoAllocate.value;
		document.frmNew.action = '';
		document.frmNew.submit();
	//}

}
// === End of Add ===

var currRow = document.getElementById('tbl_ID').rows.length-1;

//calc TOTAL per ROW
function calcAmount(RowPos){
    //alert("aaaa");
	//tax di hitung terpisah .. ini untuk menghitung total tanpa pajak
	var frm = document.frmNew;
	var TblObj = document.getElementById('tbl_ID'); 
	var NumOfRows = TblObj.rows.length-1 // minus 1 because it's the header

	unitPrice = 0

	baseUnitPrice = 0
	totalPrice = 0
	baseTotalPrice = 0
	totalprice		= 0
	baseCurrency = '#cookie.currencyID#'

	SOCurrency = document.frmNew.selCurrency.options[document.frmNew.selCurrency.selectedIndex].value
	SoDate = frmNew.txtSODate.value;
	if(RowPos == 'Currency'){
		for (idx=0; idx<=document.frmNew.rowCount.value; idx++){
			if(frmNew['txtPartNo_'+idx]!=null){ 
				RowPos = idx;
				break;
			} 
		}
	}
	

	var objQty = frmNew['txtQty_'+RowPos] 
	var objTotalPrice = frmNew['txtConvertedAmount_'+RowPos]		

	var objUnitPrice = frmNew['txtConvertedUnitPrice_'+RowPos]				// harga per unit yang sudah diconvert
	var objBaseUnitPrice = frmNew['HidBase_ConvertedUnitPrice_'+RowPos]		// harga per unit sesuai dengan base currency (currency perusahaan)
	var objPricingType = frmNew['txtPriceType_'+RowPos] // pricing type
	var objOriginCurr = frmNew['txtCurrencyID_'+RowPos] // original currency
	var objOriginPrice = frmNew['txtOriginPrice_'+RowPos] // original price
	
	//tipe=fixed, berarti musti diubah nilainya sesuai converter
	base_converter = eval("document.frmNew.txtCurr_"+baseCurrency).value.split(",").join("");
    if(eval("document.frmNew.txtCurr_"+SOCurrency) != null){
        document_converter = eval("document.frmNew.txtCurr_"+SOCurrency).value.split(",").join("");
    }else{
        document_converter = 0;
    }
    
	
	if(objPricingType.value == "1"){
        if(eval("document.frmNew.txtCurr_"+objOriginCurr.value)!=null)
		    converter = eval("document.frmNew.txtCurr_"+objOriginCurr.value).value.split(",").join("");
        else
            converter = eval("document.frmNew.txtCurr_#cookie.currencyid#").value.split(",").join("");
            
		ItemToBase =  objUnitPrice.value.split(",").join("") * converter; 
		if(document_converter > 0)
			ItemConvertToDoc = parseFloat(ItemToBase / document_converter);
		else 
			ItemConvertToDoc = parseFloat(0);
		  
		objUnitPrice.value = ItemConvertToDoc;
		objBaseUnitPrice.value = parseFloat(ItemToBase);
	}
	
	// total barang per item code (per-baris) yang sudah diconvert
	var objPricingType = frmNew['txtPriceType_'+RowPos] // pricing type
	var objBaseTotalPrice = frmNew['HidBase_ConvertedAmount_'+RowPos] // total barang per item code (per-baris) sesuai dengan base currency (currency perusahaan)	
    var objDisc = frmNew['txtDiscount1'+RowPos];
	
	var objDiscv = frmNew['txtDisc_'+RowPos];
	//alert(objDiscv.value);		
	//var objDisc = frmNew['txtDisc_'+RowPos];						 // diskon untuk masing-masing item 
	//var objDiscv = frmNew['txtDiscv_'+RowPos];	
	var objDiscType = frmNew['txtDiscType_'+RowPos];						 // diskon untuk masing-masing item 
	var objExtra = frmNew['txtExtra_'+RowPos];
    var objDisc2 = frmNew['txtDiscount2'+RowPos];
   //alert(objDiscv.value);
 	// set nilai default untuk diskon
	if(objExtra.value == '' || isNaN(objExtra.value.split(",").join("")) || objExtra.value == 0){
		objExtra.value = 0; 
	}
	if(objDisc.value == '' || isNaN(objDisc.value.split(",").join("")) || objDisc.value == 0){
		objDisc.value = 0; 
	}
	if(objDiscv.value == '' || isNaN(removecomma(objDiscv.value)) || objDiscv.value == 0){
		objDiscv.value = 0; 
	}
	
	/*totalprice = (parseFloat(objQty.value.split(",").join("")) * parseFloat(objUnitPrice.value.split(",").join("")))
	
	for (id=0;id<objDiscType.value.split('~').length;id++){
		
		if(objDiscType.value.split('~')[id] == 1){
			totalprice = totalprice - parseFloat(objDiscv.value.split('~')[id])
		}else if(objDiscType.value.split('~')[id] == 2){
			totalprice = totalprice * ((100- parseFloat(objDiscv.value.split('~')[id]))/100)
		}*/

		/*else if(objDiscType.value.split('~')[id] == 3){
			totalprice = totalprice * ((100- parseFloat(objDiscv.value.split('~')[id]))/100)
		}else{
		totalprice = totalprice * ((100- parseFloat(objDiscv.value.split('~')[id]))/100)
		}*/
	//}
	
	//totalprice = totalprice + parseFloat(objExtra.value.split(",").join(""));  
	//alert(objQty.value.split(",").join("") + ' \n ' + objUnitPrice.value.split(",").join("") + ' \n' + objDisc.value.split(",").join("") + ' \n ' + objExtra.value.split(",").join(""))
    totalprice = 	(parseFloat(removecomma(objUnitPrice.value)) - parseFloat(removecomma(objDiscv.value))) 
					* parseFloat(removecomma(objQty.value)) * ((100- parseFloat(removecomma(objDisc.value)))/100)+ parseFloat(objExtra.value.split(",").join(""));
                    
	//totalprice = (parseFloat(objQty.value.split(",").join("")) * parseFloat(objUnitPrice.value.split(",").join(""))) * ((100- parseFloat(objDisc.value.split(",").join("")))/100) + parseFloat(objExtra.value.split(",").join(""));  
	
	if(isNaN(totalprice) || totalprice < 0)
		totalprice=0;
	
	objTotalPrice.value = parseFloat(totalprice);
	//alert(objTotalPrice.value);
	decimalinForMoney(objTotalPrice)
	objBaseTotalPrice.value = base_converter * parseFloat(totalprice); 
	//alert("bbb")
}	 



function calcAmountMinusDisc(tot,basetot){
	var disc = document.getElementById("idDiscall").value;
	var totaldisc = parseFloat(tot) * disc/100 ;
	var basetotaldisc = parseFloat(basetot) * disc/100 ;
	
	document.getElementById("idTotalDiscall").value = totaldisc;
	document.getElementById("idBaseTotalDiscall").value = basetotaldisc;
	decimalinForMoney(document.getElementById("idTotalDiscall"))
	decimalinForMoney(document.getElementById("idBaseTotalDiscall"))
}

function loadPage(pageToRequest, idContent, cntidx){
	if(pageToRequest.readyState == 4){

		document.getElementById(idContent).innerHTML=pageToRequest.responseText;
		
		if(document.getElementById("hdninvalid_price") != null){
			
			//alert(document.getElementById("hdninvalid").value);
			if(document.getElementById("hdninvalid_price").value == 1){

				document.getElementById(idContent).innerHTML=document.getElementById("iderror_price").innerHTML + "<br>";                                
				
			}else{

				objChk = document.getElementsByName('chk');
				var obj = objChk.length;
				
				/*
				for(i=0;i< obj;i++){
					if(objChk[i].checked){
						var cnt = i + 1;
						var item = eval("document.forms[0].txtPartNo_"+cnt).value;
						if(document.getElementById("hdnPrice"+item) != null){
							eval("document.forms[0].txtConvertedUnitPrice_"+cnt).value = document.getElementById("hdnPrice"+item).value + '.00';
							eval("document.forms[0].HidBase_ConvertedUnitPrice_"+cnt).value = document.getElementById("hdnBasePrice"+item).value;
							eval("document.forms[0].HidBase_ConvertedUnitPrice2_"+cnt).value = document.getElementById("hdnPrice"+item).value;
																		

						}										
					}
				}*/
				
				
				var item = eval("document.forms[0].txtPartNo_"+cntidx).value;
				//alert(document.getElementById("hdnPrice"+item).value);
				if(document.getElementById("hdnPrice"+item) != null){
				  eval("document.forms[0].txtConvertedUnitPrice_"+cntidx).value = document.getElementById("hdnPrice"+item).value;
				  eval("document.forms[0].HidBase_ConvertedUnitPrice_"+cntidx).value = document.getElementById("hdnBasePrice"+item).value;
				  eval("document.forms[0].HidBase_ConvertedUnitPrice2_"+cntidx).value = document.getElementById("hdnPrice"+item).value;
				  eval("document.forms[0].txtOriginPrice_"+cntidx).value = document.getElementById("hdnPrice"+item).value;
				  
				  decimalinForMoney(eval("document.forms[0].txtConvertedUnitPrice_"+cntidx));
				}else{
				  eval("document.forms[0].txtConvertedUnitPrice_"+cntidx).value = 0;
				  eval("document.forms[0].HidBase_ConvertedUnitPrice_"+cntidx).value = 0;
				  eval("document.forms[0].HidBase_ConvertedUnitPrice2_"+cntidx).value = 0;
				  eval("document.forms[0].txtOriginPrice_"+cntidx).value = 0;
				  
				  decimalinForMoney(eval("document.forms[0].txtConvertedUnitPrice_"+cntidx));
				}
				
				document.getElementById('txtConvertedUnitPrice_' + cntidx).style.backgroundColor = '##FCC';
				
				calcAmountAll();
				setCurrTax();
				GetAmountGrand();
				decimalinForMoney(document.frmNew.txtGrandTotal);
				decimalinForMoney(document.frmNew.txtTotTaxConv);
				decimalinForMoney(document.frmNew.txtTotDeductConv);
				decimalinForMoney(document.frmNew.txtTotMiscCharge);
				if(eval("document.forms[0].btnSubmit"))
				document.forms[0].btnSubmit.disabled = false;
				if(eval("document.forms[0].btnConfirm"))
				document.forms[0].btnConfirm.disabled = false;
			}
		}
	}
	calculateTermOfPayment();
}

function getPrice(rowSel){
	objChk = document.getElementsByName('chk');
	var obj = objChk.length;
	var lstitem = "";
	
	/*
	for(i=0;i< obj;i++){
		if(objChk[i].checked){
			var cnt = i+1;
			if(lstitem=="")
				lstitem = eval("document.forms[0].txtPartNo_"+cnt).value + "|" + eval("document.forms[0].txtQty_"+cnt).value;
			else
				lstitem = lstitem + ";" + eval("document.forms[0].txtPartNo_"+cnt).value + "|" + eval("document.forms[0].txtQty_"+cnt).value;
		}
	}
	*/
	
	lstitem = eval("document.forms[0].txtPartNo_"+rowSel).value + "|" + eval("document.forms[0].txtQty_"+rowSel).value;
	
	//alert('cust:'+document.frmNew.txtCustCode.value);
	//alert('item:'+lstitem);
	//alert('curr:'+document.frmNew.selCurrency.value);
	//alert('term:'+document.frmNew.cboTerms.value);
	
	if(lstitem==""){
		alert("#DO_VAR['PlsSelectItem']#");
	}else if(document.frmNew.txtCustCode.value==""){
		alert("#DO_VAR['PlsSelectCustomer']#");
	}else{
		//jalankan ajax untuk mengisi harga item yg dipilih
		var URL = "#Application.stApp.Web_Path[VST_IDX]#/eaccounting/sales/quotation/form/updateprice.cfm?wh_id=#COOKIE.Location_ID#&lstitem="+lstitem+"&currencyid="+document.frmNew.selCurrency.value+"&customerid="+document.frmNew.txtCustCode.value+"&paymentterm="+document.frmNew.cboTerms.value+"&dimension="+eval("document.frmNew.txtDimensionID_" +rowSel).value+"&transdate="+document.frmNew.txtSODate.value;
		var idContent = "contentprice";
		// Start Ajax
		var pageToRequest = false;
		if(window.XMLHttpRequest) // if Mozilla, Safari etc
		   pageToRequest = new XMLHttpRequest();
		else if(window.ActiveXObject){ // if IE
		try {
			pageToRequest = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e){
			try{
				pageToRequest = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e){}

		}

		}else{
		   return false;
		}
		if(eval("document.forms[0].btnSubmit"))
		document.forms[0].btnSubmit.disabled = true;
		if(eval("document.forms[0].btnConfirm"))
		document.forms[0].btnConfirm.disabled = true;
		pageToRequest.onreadystatechange = function(){
		   loadPage(pageToRequest, idContent, rowSel);
		}
		pageToRequest.open('GET', URL, true);
		pageToRequest.send(null);
		// End Ajax
	}
	calculateTermOfPayment();
}

function loadPageD(pageToRequest, idContent, RowPos){
	if(pageToRequest.readyState == 4){

		document.getElementById(idContent).innerHTML=pageToRequest.responseText;
		
		if(document.getElementById("hdninvalid") != null){
			
			//alert(document.getElementById("hdninvalid").value);
			if(document.getElementById("hdninvalid").value == 1){

				document.getElementById(idContent).innerHTML=document.getElementById("iderror").innerHTML + "<br>";
			}else{

				objChk = document.getElementsByName('chk');
				var obj = objChk.length;
				//for(i=0;i<obj;i++){
					//if(objChk[i].checked){
						var cnt = i + 1;
						var item = eval("document.forms[0].txtPartNo_"+RowPos).value;
						//if(document.getElementById("hdnPrice"+item) != null){
						
							if(document.getElementById("hdnDiscount") != null)
							  eval("document.forms[0].txtDiscount1"+RowPos).value = document.getElementById("hdnDiscount").value;
							else
							  eval("document.forms[0].txtDiscount1"+RowPos).value = 0;
							
							if(document.getElementById("hdnDiscountv") != null)
							  eval("document.forms[0].txtDisc_"+RowPos).value = document.getElementById("hdnDiscountv").value;
							else
							  eval("document.forms[0].txtDisc_"+RowPos).value = 0;
				
							
							document.getElementById('txtDiscount1' + RowPos).style.backgroundColor = '##FCC';
							document.getElementById('txtDisc_' + RowPos).style.backgroundColor = '##FCC';
							//alert(eval("document.forms[0].txtDisc_"+RowPos).value);
							//eval("document.forms[0].HidBase_ConvertedUnitPrice_"+cnt).value = document.getElementById("hdnBasePrice"+item).value;
							//eval("document.forms[0].HidBase_ConvertedUnitPrice2_"+cnt).value = document.getElementById("hdnPrice"+item).value;
							
						//}
					//}
				//}
				calcAmountAll();
				setCurrTax(); 
				GetAmountGrand();
				decimalinForMoney(document.frmNew.txtGrandTotal); 
				decimalinForMoney(document.frmNew.txtTotTaxConv); 
				decimalinForMoney(document.frmNew.txtTotDeductConv);
				decimalinForMoney(document.frmNew.txtTotMiscCharge);
				if(eval("document.forms[0].btnSubmit"))
				document.forms[0].btnSubmit.disabled = false;
				if(eval("document.forms[0].btnConfirm"))
				document.forms[0].btnConfirm.disabled = false;
			}
		}
	}
	<!--- Add by Elsa ---> calculateTermOfPayment();
}

function getDiscount(RowPos){
	//alert(frmNew['txtQty_'+RowPos].value);
	objChk = document.getElementsByName('chk');
	var obj = objChk.length;
	var lstitem = "";
	/*for(i=0;i<obj;i++){
		//if(objChk[i].checked){
			var cnt = i+1;*/
			if(lstitem=="")
				lstitem = eval("document.forms[0].txtPartNo_"+RowPos).value;
			else
				lstitem = lstitem + ";" + eval("document.forms[0].txtPartNo_"+RowPos).value + "|" + eval("document.forms[0].txtQty_"+RowPos).value;
		//}
	//}	
	//jalankan ajax untuk mengisi harga item yg dipilih
	var URL = "#Application.stApp.Web_Path[VST_IDX]#/eaccounting/sales/so/forms/updatediscount.cfm?wh_id=#COOKIE.Location_ID#&lstitem="+lstitem+"&currencyid="+document.frmNew.selCurrency.value+"&customerid="+document.frmNew.txtCustCode.value+"&minqty="+frmNew['txtQty_'+RowPos].value+"&transdate="+document.frmNew.txtSODate.value+"&dimension="+eval("document.frmNew.txtDimensionID_" +RowPos).value;
	//var idContent = "contentprice";
	var idContent = "contentdiscount";
	
	// Start Ajax
	var pageToRequest = false;
	if(window.XMLHttpRequest) // if Mozilla, Safari etc
	   pageToRequest = new XMLHttpRequest();
	else if(window.ActiveXObject){ // if IE
	try {
		pageToRequest = new ActiveXObject("Msxml2.XMLHTTP");
	} catch (e){
		try{
			pageToRequest = new ActiveXObject("Microsoft.XMLHTTP");
		} catch (e){}
	}
	}else{
	   return false;
	}
	if(eval("document.forms[0].btnSubmit"))
	document.forms[0].btnSubmit.disabled = true;
	if(eval("document.forms[0].btnConfirm"))
	document.forms[0].btnConfirm.disabled = true;
	pageToRequest.onreadystatechange = function(){
	   loadPageD(pageToRequest, idContent, RowPos);
	}
	pageToRequest.open('GET', URL, true);
	pageToRequest.send(null);
	// End Ajax
		//calculateTermOfPayment();
}
// add by NP, 3 Mei 2011 -- for discount total and free item
function loadPageDT(pageToRequest, idContent){
	if(pageToRequest.readyState == 4){

		document.getElementById(idContent).innerHTML=pageToRequest.responseText;
		
		if(document.getElementById("hdninvalid") != null){
			
			//alert(document.getElementById("hdninvalid").value);
			if(document.getElementById("hdninvalid").value == 1){

				document.getElementById(idContent).innerHTML=document.getElementById("iderror").innerHTML + "<br>";
			}else{
				document.frmNew.txtDisctotal.value = document.getElementById("hdnDiscTotal").value
				calcAmountAll();
				setCurrTax(); 
				GetAmountGrand();
				<!--- Add by Elsa ---> calculateTermOfPayment();
				decimalinForMoney(document.frmNew.txtGrandTotal); 
				decimalinForMoney(document.frmNew.txtTotTaxConv); 
				decimalinForMoney(document.frmNew.txtTotDeductConv);
				decimalinForMoney(document.frmNew.txtTotMiscCharge);
				if(eval("document.forms[0].btnSubmit"))
				document.forms[0].btnSubmit.disabled = false;
				if(eval("document.forms[0].btnConfirm"))
				document.forms[0].btnConfirm.disabled = false;
			}

		}
	}

}

function getDiscountTotal(){
	//alert(frmNew['txtQty_'+RowPos].value);
	objChk = document.getElementsByName('chk');
	var obj = objChk.length;
	var lstitem = "";
	//calcAmountAll();
	var totalSO = document.frmNew.txtTotAmount.value.split(",").join("");
		
	//jalankan ajax untuk mengisi harga item yg dipilih
	var URL = "#Application.stApp.Web_Path[VST_IDX]#/eaccounting/sales/so/forms/discounttotal.cfm?wh_id=#COOKIE.Location_ID#&totalSO="+totalSO+"&currencyid="+document.frmNew.selCurrency.value+"&customerid="+document.frmNew.txtCustCode.value+"&transdate="+document.frmNew.txtSODate.value;
	//var idContent = "contentprice";
	var idContent = "contentdiscounttotal";
	
	// Start Ajax
	var pageToRequest = false;
	if(window.XMLHttpRequest) // if Mozilla, Safari etc
	   pageToRequest = new XMLHttpRequest();
	else if(window.ActiveXObject){ // if IE
	try {
		pageToRequest = new ActiveXObject("Msxml2.XMLHTTP");
	} catch (e){
		try{
			pageToRequest = new ActiveXObject("Microsoft.XMLHTTP");
		} catch (e){}
	}
	}else{
	   return false;
	}
	if(eval("document.forms[0].btnSubmit"))
	document.forms[0].btnSubmit.disabled = true;
	if(eval("document.forms[0].btnConfirm"))
	document.forms[0].btnConfirm.disabled = true;
	pageToRequest.onreadystatechange = function(){
		if(pageToRequest.readyState == 4){
	   		loadPageDT(pageToRequest, idContent);
		 }

	}
	pageToRequest.open('GET', URL, true);
	pageToRequest.send(null);
	// End Ajax
}

function loadPageFIT(pageToRequest, idContent){
	if(pageToRequest.readyState == 4){

		document.getElementById(idContent).innerHTML=pageToRequest.responseText;
		
		if(document.getElementById("hdninvalid") != null){
			
			//alert(document.getElementById("hdninvalid").value);
			if(document.getElementById("hdninvalid").value == 1){

				document.getElementById(idContent).innerHTML=document.getElementById("iderror").innerHTML + "<br>";
			}else{
				if(document.getElementById("hdnCount").value == 0){
					document.getElementById(idContent).style.display='none';
				}else{
					document.getElementById(idContent).style.display='';
				}
				
				calcAmountAll();
				setCurrTax(); 
				GetAmountGrand();
				decimalinForMoney(document.frmNew.txtGrandTotal); 
				decimalinForMoney(document.frmNew.txtTotTaxConv); 
				decimalinForMoney(document.frmNew.txtTotDeductConv);
				decimalinForMoney(document.frmNew.txtTotMiscCharge);
				if(eval("document.forms[0].btnSubmit"))
				document.forms[0].btnSubmit.disabled = false;
				if(eval("document.forms[0].btnConfirm"))
				document.forms[0].btnConfirm.disabled = false;
			}
		}
	}

}

function getFreeItemTotal(){
	//alert(frmNew['txtQty_'+RowPos].value);
	objChk = document.getElementsByName('chk');
	var obj = objChk.length;
	var lstitem = "";
	var totalSO = document.frmNew.txtTotAmount.value.split(",").join("");	
	for(i=1;i<=obj;i++){
		if(eval("document.forms[0].txtPartNo_"+i)){
			if(lstitem == ""){
				lstitem = eval("document.forms[0].txtPartNo_"+i).value + "," + eval("document.forms[0].txtQty_"+i).value+ "," + eval("document.forms[0].txtDimensionID_"+i).value;
			}else{
				lstitem = lstitem +"|"+eval("document.forms[0].txtPartNo_"+i).value + "," + eval("document.forms[0].txtQty_"+i).value+ "," + eval("document.forms[0].txtDimensionID_"+i).value;
			}
		}
	}
	
	//jalankan ajax untuk mengisi harga item yg dipilih
	var URL = "#Application.stApp.Web_Path[VST_IDX]#/eaccounting/sales/so/forms/totalSO.cfm?wh_id=#COOKIE.Location_ID#&totalSO="+totalSO+"&currencyid="+document.frmNew.selCurrency.value+"&customerid="+document.frmNew.txtCustCode.value+"&transdate="+document.frmNew.txtSODate.value+"&listitem="+lstitem;
	//var idContent = "contentprice";
	var idContent = "divFreeItem";
	
	// Start Ajax
	var pageToRequest = false;
	if(window.XMLHttpRequest) // if Mozilla, Safari etc
	   pageToRequest = new XMLHttpRequest();
	else if(window.ActiveXObject){ // if IE
	try {
		pageToRequest = new ActiveXObject("Msxml2.XMLHTTP");
	} catch (e){
		try{
			pageToRequest = new ActiveXObject("Microsoft.XMLHTTP");
		} catch (e){}
	}
	}else{
	   return false;
	}
	if(eval("document.forms[0].btnSubmit"))
	document.forms[0].btnSubmit.disabled = true;
	if(eval("document.forms[0].btnConfirm"))
	document.forms[0].btnConfirm.disabled = true;
	pageToRequest.onreadystatechange = function(){
	   loadPageFIT(pageToRequest, idContent);
	   <!--- Add by Elsa ---> //calculateTermOfPayment();
	}
	pageToRequest.open('GET', URL, true);
	pageToRequest.send(null);
	// End Ajax
	//calcAmountAll();
}
//end

function getPercent(obj){

     var discamount = obj.value.split(",").join("");
     var amount = document.frmNew.txtTotAmount.value.split(",").join("");
    
     var disc = discamount/amount * 100;
     document.frmNew.txtDisctotal.value = disc;
}

//cacl TOTAL AMOUNT (sebelum tax)
function calcAmountAll(){  

	SOCurrency = document.frmNew.selCurrency.options[document.frmNew.selCurrency.selectedIndex].value
	baseCurrency = '#cookie.currencyID#'
	var TotalSO = 0
	var BaseTotalSO = 0
	var brsbaru = document.frmNew.rowCount.value 
	var TotalQtySO = 0
	
    if( eval("document.frmNew.txtCurr_"+SOCurrency) != null){ 
	    RateSo = eval("document.frmNew.txtCurr_"+SOCurrency).value.split(",").join("");
	}else{

        RateSo = 0;
    }
    
    if(brsbaru > 0){
		for (idx=1; idx<=brsbaru; idx++){
			if(frmNew['txtPartNo_'+idx]!=null){		// artinya object tesebut ada .. 
				 
				calcAmount(idx)					
				
				var objTotalPrice = frmNew['txtConvertedAmount_'+idx]				// total barang per item code (per-baris) yang sudah diconvert		
				var objQty = frmNew['txtQty_'+idx]
				TotalSO = TotalSO + parseFloat(objTotalPrice.value.split(",").join(""));
				TotalQtySO = TotalQtySO + parseFloat(objQty.value.split(",").join(""));
				
				
			}
		}
	}else {
		TotalSO=0; 
		TotalQtySO=0;
	}
	
	// avoid error JS in arithmetic
	var tmpTotalSO = Math.round(parseFloat(TotalSO)*10000);
	var tmpRateSo = Math.round(parseFloat(RateSo)*10000);
	
	var subtotal = parseFloat(TotalSO);
	var basesubtotal =  tmpRateSo*parseFloat(tmpTotalSO)/100000000;
	frmNew.txtTotAmount.value  = parseFloat(TotalSO)
	frmNew.hidBaseTotAmount.value  = parseFloat(tmpRateSo * parseFloat(tmpTotalSO) / 100000000)
	frmNew.txtTotQty.value = parseFloat(TotalQtySO);
	
		<!--- set total MiscCharge --->
	var TotalMisc = 0
	if(frmNew.hidCountMisc.value > 0){
	 for(idx=1; idx<=frmNew.hidTransferMisc.value;  idx++){
	 		if(frmNew['txtConvertedAmountMisc_'+idx] <!---&& frmNew['selTaxMisc_'+idx]--->){
					var AmountMisc = frmNew['txtConvertedAmountMisc_'+idx]
					if(AmountMisc.value!= ''){
						TotalMisc = TotalMisc + parseFloat(AmountMisc.value.split(",").join(""));
						TaxOperator = eval("frmNew.selTaxMisc_"+idx).value.split("|")[2] ;
						if(TaxOperator == "-")
							TotalMisc = TotalMisc - (parseFloat(AmountMisc.value.split(",").join("")) * eval("frmNew.selTaxMisc_"+idx).value.split("|")[1] /100) ;
						else
							TotalMisc = TotalMisc + (parseFloat(AmountMisc.value.split(",").join("")) * eval("frmNew.selTaxMisc_"+idx).value.split("|")[1] /100) ;
						
						//frmNew.txtTotMiscCharge.value = TotalMisc;
					}else{
						break;
					}
			}
	  }
	}
	
	frmNew.txtTotMiscCharge.value = TotalMisc;
	
	<!--- set AllocationType to Amount --->
	var AmountMiscAllo = 0;
	var qtyAll = 0;
	var amountTemp = 0;
	
	var AmountMisc2_ = new Array();
	var TotalAmountMisc2_ = new Array();
	

	for(idx=1; idx<=frmNew.hidTransfer.value;  idx++){
			//AmountMisc2_[idx-1]= 0 ;
			//TotalAmountMisc2_[idx-1] = 0 ;
			AmountMisc2_[idx-1] = 0;
			TotalAmountMisc2_[idx-1] = 0;
	}
	var flagUD=0; 
	var idxUD = new Array();
	for(i=1; i<=frmNew.hidTransferMisc.value;  i++){

		if(frmNew.hidCountMisc.value > 0 && frmNew['selAllocationType'+i]){
			var AlloType = frmNew['selAllocationType'+i].value;
			if(AlloType == 4){
				idxUD[flagUD]= i;
				flagUD++;
			}
		}	
	}
	var qtyAll  =0;
	var qtyItem =0;

	for(idx=1; idx<=frmNew.hidTransfer.value;  idx++){
		if(frmNew['txtConvertedAmountMisc2_'+idx]!=null){
			var qtyItem = frmNew['txtQty_'+idx];
			qtyAll = qtyAll + parseFloat(qtyItem.value);
		}

					
	}
	frmNew['hidQtyAll'].value = qtyAll;
	
	for(i=1; i<=frmNew.hidTransferMisc.value;  i++){
		if(frmNew.hidCountMisc.value > 0 && frmNew['txtConvertedAmountMisc_'+i]){
			var AmountMisc_ = frmNew['txtConvertedAmountMisc_'+i].value.split(",").join("");
			TaxOperator = eval("frmNew.selTaxMisc_"+i).value.split("|")[2] ;
			var totMisc = parseFloat(AmountMisc_);
				if(TaxOperator == "-")
					totMisc = totMisc - (parseFloat(AmountMisc_) * eval("frmNew.selTaxMisc_"+i).value.split("|")[1] /100) ;
				else
					totMisc = totMisc + (parseFloat(AmountMisc_) * eval("frmNew.selTaxMisc_"+i).value.split("|")[1] /100) ;
	
			AmountMisc_ = parseFloat(totMisc);
		
				

			var AlloType = frmNew['selAllocationType'+i].value
			if(AlloType == 1){
			
	
					for(idx=1; idx<=frmNew.hidTransfer.value;  idx++){
							if(frmNew['txtConvertedAmountMisc2_'+idx]!=null){
									var Amount_ = frmNew['txtConvertedAmount_'+idx].value.split(",").join("");
									var TotMisc = frmNew.txtTotMiscCharge
									var TotAmount = frmNew.txtTotAmount
									if(flagUD == 0 )frmNew['txtConvertedAmountMisc2_'+idx].readOnly = true;

									/*frmNew['txtConvertedAmountMisc2_'+idx].value = (parseFloat(Amount_) * parseFloat(AmountMisc_)) 
																					/ parseFloat(TotAmount.value.split(",").join(""))*/
									AmountMisc2_[idx-1]= (parseFloat(Amount_) * parseFloat(AmountMisc_))/ parseFloat(TotAmount.value.split(",").join(""));
							}
	
					}
			}else if(AlloType == 2){
					qtyItem = 0;
	
	
	
	
					for(idx=1; idx<=frmNew.hidTransfer.value;  idx++){
						if(frmNew['txtConvertedAmountMisc2_'+idx]!=null){
								var qtyItem_ = frmNew['txtQty_'+idx];
								var TotMisc = frmNew.txtTotMiscCharge;
								if(flagUD == 0 )frmNew['txtConvertedAmountMisc2_'+idx].readOnly = true;
								/*
								frmNew['txtConvertedAmountMisc2_'+idx].value = ((qtyItem_.value) * parseFloat(TotMisc.value.split(",").join("")))
																				 / qtyAll
								*/
								AmountMisc2_[idx-1] = ((qtyItem_.value) * parseFloat(AmountMisc_))/ qtyAll;
						}
	
					}
			}else if(AlloType == 3){
	
					Amounttmp = AmountMisc_;

					idxitem = frmNew.hidCountTransfer.value;
					AmountMiscAllo = parseFloat(Amounttmp) / idxitem;
					for(idx=1; idx<=frmNew.hidTransfer.value;  idx++){
						if(frmNew['txtConvertedAmountMisc2_'+idx]!=null){
						//frmNew['txtConvertedAmountMisc2_'+idx].value = AmountMiscAllo;
						if(flagUD == 0 )frmNew['txtConvertedAmountMisc2_'+idx].readOnly = true;
						AmountMisc2_[idx-1] = AmountMiscAllo;
						}
					}
			}else if(AlloType == 4){
			
					for(idx=1; idx<=frmNew.hidTransfer.value;  idx++){
						if(frmNew['txtConvertedAmountMisc2_'+idx]!=null){
						frmNew['txtConvertedAmountMisc2_'+idx].readOnly = false;
						//frmNew['txtConvertedAmountMisc2_'+idx].value = 0;
						}
					}
			}else{
					
					for(idx=1; idx<=frmNew.hidTransfer.value;  idx++){
						if(frmNew['txtConvertedAmountMisc2_'+idx]!=null){
							if(flagUD == 0 )frmNew['txtConvertedAmountMisc2_'+idx].readOnly = true;
							AmountMisc2_[idx-1] = 0;
						}
	
					}
			}
				
			if(AlloType != 4){
	
					for(idx=1; idx<=frmNew.hidTransfer.value;  idx++){
						if(frmNew['txtConvertedAmountMisc2_'+idx]!=null){
							TotalAmountMisc2_[idx-1] = TotalAmountMisc2_[idx-1] + AmountMisc2_[idx-1];
						}
					}
			}
		}

	}
				
				for(idx=1; idx<=frmNew.hidTransfer.value;  idx++){
					if(frmNew['txtConvertedAmountMisc2_'+idx]!=null){
							if(flagUD == 0 ){		
									frmNew['txtConvertedAmountMisc2_'+idx].value = TotalAmountMisc2_[idx-1];
							}
							frmNew['hidTotalMiscNonUD_'+idx].value = TotalAmountMisc2_[idx-1];
					}
				}

	calcAmountMinusDisc(subtotal,basesubtotal); 
}

 
function calcTax(){ 

	PlusValues = 0
	MinusValues = 0;
	BasePlusValues = 0; // Dalam Base currency, konvert berdasarkan SO
	BaseMinusValues = 0; // Dalam Base currency, konvert berdasarkan SO currency
	baseCurrency = '#cookie.currencyid#'
	//selCurrDoc = document.frmNew.selCurrency.options[document.frmNew.selCurrency.selectedIndex].value
	//selCurrTax = document.frmNew.selTaxCurrency.options[document.frmNew.selTaxCurrency.selectedIndex].value;
	selCurrDoc = document.frmNew.selCurrency.value;


	selCurrTax = document.frmNew.selTaxCurrency.value;
	var TaxStatusIs =""; 
	var TaxAmount1 = 0;
	var TaxAmount2 = 0;
	if(!eval("document.frmNew.txtCurr_"+selCurrDoc))
	  return;
	if(!eval("document.frmNew.txtTax_"+selCurrTax))
	  return;
	RateSO = eval("document.frmNew.txtCurr_"+selCurrDoc).value.split(",").join("");
	if(selCurrDoc == selCurrTax)
		RateTax = 1;

	else
		RateTax =  eval("document.frmNew.txtTax_"+selCurrDoc).value.split(",").join("");
	
	
	
	RateTaxBase = eval("document.frmNew.txtTax_"+baseCurrency).value.split(",").join("");
	
	RateTaxSO = eval("document.frmNew.txtTax_"+selCurrDoc).value.split(",").join("");	
	var RateDiscTotal			= document.getElementById("idDiscall").value;
	

	for (idx=1; idx<=document.frmNew.rowCount.value; idx++){
		if(frmNew['txtConvertedUnitPrice_'+idx]){
			var objSelTax1 = frmNew['selTax1_'+idx]
			var objSelTax2 = frmNew['selTax2_'+idx]
			var objTotalPrice = frmNew['txtConvertedAmount_'+idx]				// total barang per item code (per-baris) sesuai dengan base currency (currency perusahaan)		
			var objBaseTotalPrice = frmNew['HidBase_ConvertedAmount_'+idx]
	
			var objTax1 = frmNew['txtTaxAmount1_'+idx]
			var objTax2 = frmNew['txtTaxAmount2_'+idx]
			
			var objQty = frmNew['txtQty_'+idx] 
			var objUnitPrice = frmNew['txtConvertedUnitPrice_'+idx]				// harga per unit yang sudah diconvert
			var objBaseUnitPrice = frmNew['HidBase_ConvertedUnitPrice_'+idx]		// harga per unit sesuai dengan base currency (currency perusahaan)
			var objTotalPrice = frmNew['txtConvertedAmount_'+idx]		
			
			var objPricingType = frmNew['txtPriceType_'+idx] // pricing type
			var objOriginCurr = frmNew['txtCurrencyID_'+idx] // original currency
			var objOriginPrice = frmNew['txtOriginPrice_'+idx] // original price
			var objDisc = frmNew['txtDisc_'+idx] // discount price

			var objDiscv = frmNew['txtDiscount1'+idx];	
			var objDiscType = frmNew['txtDiscType_'+idx];
			var objExtra = frmNew['txtExtra_'+idx] // extra price
			var check_Disc = objDisc.value.split(",").join("");
			
			if(check_Disc == '' || isNaN(check_Disc) || check_Disc == 0){
				objDisc.value = 0; 
			}
		

			if(objSelTax1 != null && objSelTax2 != null){
				taxCode1 		= objSelTax1.value.split('|')[0]
				taxRate1 		= objSelTax1.value.split('|')[1]
				taxOperator1 	= objSelTax1.value.split('|')[2]
				
				taxCode2 		= objSelTax2.value.split('|')[0]
				taxRate2 		= objSelTax2.value.split('|')[1]
				taxOperator2 	= objSelTax2.value.split('|')[2]	
				
				//tipe=fixed, berarti musti diubah nilainya sesuai converter

				if(objPricingType.value == "1"){ 
                    if(eval("document.frmNew.txtCurr_"+objOriginCurr.value)!=null)
            		    converter = eval("document.frmNew.txtTax_"+objOriginCurr.value).value.split(",").join("");
                    else
                        converter = eval("document.frmNew.txtTax_#cookie.currencyid#").value.split(",").join("");
                        
					ItemToBase =  objOriginPrice.value.split(",").join("") * converter; 
					
					if(RateSO > 0)
						ItemConvertToDoc = parseFloat(ItemToBase / RateSO);
					else 
						ItemConvertToDoc = parseFloat(0);
					
					unitprice= ItemConvertToDoc;
					unitprice_base = ItemConvertToDoc.split(",").join("") * RateTax; 
					
				}else{
					unitprice= objUnitPrice.value;
					unitprice_base =  objUnitPrice.value.split(",").join("") * RateTax; 
				}
				
				
				/*totalprice = (parseFloat(objQty.value.split(",").join("")) * parseFloat(objUnitPrice.value.split(",").join("")))
				for (id=0;id<objDiscType.value.split('~').length;id++){
					if(objDiscType.value.split('~')[id] == 1){
						totalprice = totalprice - parseFloat(objDiscv.value.split('~')[id])

					}else if(objDiscType.value.split('~')[id] == 2){
						totalprice = totalprice * ((100- parseFloat(objDiscv.value.split('~')[id]))/100)
					}

				}	
				totalprice = totalprice + parseFloat(objExtra.value.split(",").join(""));  */
				//totalprice = (parseFloat(objQty.value.split(",").join("")) * parseFloat(objUnitPrice.value.split(",").join(""))) * ((100- parseFloat(objDisc.value.split(",").join("")))/100)+ parseFloat(objExtra.value.split(",").join(""));  
				totalprice = (parseFloat(objQty.value.split(",").join("")) * (parseFloat(objUnitPrice.value.split(",").join("")) - parseFloat(objDisc.value.split(",").join(""))))* ((100- parseFloat(objDiscv.value.split(",").join("")))/100) +  parseFloat(objExtra.value.split(",").join(""));

				
				if(isNaN(totalprice) || totalprice < 0)
					totalprice=0;
				
				totalprice = parseFloat(totalprice) - ((parseFloat(totalprice) * parseFloat(RateDiscTotal)) / 100);		
				
				if(isNaN(totalprice)){ 
					totalprice =0;
				}
				totalprice_baseSO = totalprice * RateSO ;
							
				<!--- TaxAmount1_tmp = (taxRate1 /100) * totalprice_baseSO;
				TaxAmount2_tmp = (taxRate2 /100) * totalprice_baseSO;
				
				TaxAmount1 = TaxAmount1_tmp/RateTax;
				TaxAmount2 = TaxAmount2_tmp/RateTax --->
				
				<!--- randytia	Aug 04 2010	-> jika curr SO dan Tax sama maka tax dikali langsung dengan total price, tidak dilakukan perhitungan rate currency --->
				<!--- if(selCurrDoc!=selCurrTax){
					TaxAmount1_tmp = (taxRate1 /100) * totalprice_baseSO;
					TaxAmount2_tmp = (taxRate2 /100) * totalprice_baseSO;
					TaxAmount1 = TaxAmount1_tmp/RateTax;
					TaxAmount2 = TaxAmount2_tmp/RateTax;
				}else{
					TaxAmount1_tmp = (taxRate1 /100) * totalprice;
					TaxAmount2_tmp = (taxRate2 /100) * totalprice;
					TaxAmount1 = TaxAmount1_tmp;
					TaxAmount2 = TaxAmount2_tmp;
				} --->
				<!--- End ---> 
				
				<!--- 	Add By randytia Aug 23 2010
						Create by IVN : 09 April 2010 
				  CHANGE CALCULATION DUE VAT INCLUDE --->
				  
				  <!--- add by trias 03 24 2011 
				  		untuk sales order berdasarkan sales contract tidak
						dibutuhkan lagi perhitungan VAT karena sudah dihitung
						sewaktu pembuatan Quotation --->
				 <!--- add by trias 03 24 2011 
				  		untuk sales order berdasarkan sales contract tidak
						dibutuhkan lagi perhitungan VAT karena sudah dihitung
						sewaktu pembuatan Quotation --->
				 TaxAmount1_tmp = (taxRate1 / 100) * totalprice;
  				 TaxAmount1 = TaxAmount1_tmp;		
						
				  <cfif rbTypeDoc IS 3>

				  
				  	TaxAmount2_tmp = (taxRate2 / 100) * totalprice;
					TaxAmount2 = TaxAmount2_tmp;
					//TaxAmount2 = TaxAmount2_tmp/RateTax;
				  <cfelse>
				  
				  for (var xtc = 0; xtc < document.frmNew.txtSOtype.length; xtc++){
					if(document.frmNew.txtSOtype[xtc].checked){
					  if(document.frmNew.txtSOtype[xtc].value == 0) // IF DOCUMENT IS VAT INCLUDE
					  {
						tmpTaxInclude = document.getElementById('ddlTaxIncluded').value.split("|");
						tmpVATTaxRate = (parseFloat(tmpTaxInclude[1]) + 100) / 100;
						tmpVATTaxAmount = totalprice_baseSO - (totalprice / tmpVATTaxRate);
						
						TaxAmount2_tmp = (taxRate2 / 100) * (totalprice - tmpVATTaxAmount);
						TaxAmount2 = TaxAmount2_tmp;
					  }else{
					  	TaxAmount2_tmp = (taxRate2 / 100) * totalprice;
					    TaxAmount2 = TaxAmount2_tmp;
						
					  }
					}
				  }
				  <!--- END OF CHANGE --->
				  </cfif>
				  <!--- end of adding by trias --->
				
				TaxAmount1_Base = parseFloat(TaxAmount1 * RateTaxBase);
				TaxAmount2_Base = parseFloat(TaxAmount2 * RateTaxBase);
				 
				objTax1.value = parseFloat(TaxAmount1 * RateTax);
				objTax2.value = parseFloat(TaxAmount2 * RateTax);
				 
				// jika nilai plus, dikumpulkan menjadi 1 kelompok, demikian juga dengan nilai minus.
				 
				if(taxOperator1 == "+" ){
					PlusValues = PlusValues + (TaxAmount1 * RateTax)
					BasePlusValues = BasePlusValues + TaxAmount1_Base
				}else{
					MinusValues = MinusValues + (TaxAmount1 * RateTax)
					BaseMinusValues = BaseMinusValues + TaxAmount1_Base 
				}
				
				if(taxOperator2 == "+" ){ 
					PlusValues = PlusValues + (TaxAmount2 * RateTax)
					BasePlusValues = BasePlusValues + TaxAmount2_Base 
				}else{
					MinusValues = MinusValues + (TaxAmount2 * RateTax)
					BaseMinusValues = BaseMinusValues + TaxAmount2_Base 
				} 
			}

		}
	}
	

	<cfif rbTypeDoc IS 3>
	  TaxStatusIs = document.frmNew.txtSOtype.value;
	<cfelse>
	  for (var i=0;i<=document.frmNew.txtSOtype.length-1;i++){
		  if(document.frmNew.txtSOtype[i].checked) TaxStatusIs = document.frmNew.txtSOtype[i].value;
	  }

	</cfif>
	
	

	
	if(isNaN(MinusValues))
		MinusValues=0;
	frmNew.txtTotDeductConv.value = MinusValues;
	frmNew.hdnTotDeductConvBase.value = BaseMinusValues;
	
	

	if(TaxStatusIs == 0) document.frmNew.txtTotTaxConv.value = 0
	else{
	frmNew.txtTotTaxConv.value = PlusValues;
	frmNew.hdnTotTaxConvBase.value = BasePlusValues;
	}
	decimalinForMoney(frmNew.txtTotDeductConv)
	decimalinForMoney(frmNew.txtTotTaxConv)
	setCurrTax(); 
}

//GRAND TOTAL (dengan Tax)
function GetAmountGrand(){
	var a			= document.getElementById("idTaxHide2");
	var brsbaru		= document.frmNew.rowCount.value;
	var cd_amount	= document.forms[0].txt_cd_amount;

//	alert(cd_amount.value);

	selCurrPO	= document.frmNew.selCurrency.options[document.frmNew.selCurrency.selectedIndex].value;
 	selCurrTx	= document.frmNew.selTaxCurrency.options[document.frmNew.selTaxCurrency.selectedIndex].value;

	if(selCurrTx==selCurrPO){
		a.style.display	= ""; 
		var grandTotal	= parseFloat(document.frmNew.txtTotAmount.value.split(",").join("")) 
											- parseFloat(document.frmNew.txtTotDisc.value.split(",").join("")) 
											+ parseFloat(document.frmNew.txtTotTaxConv.value.split(",").join("")) 
											- parseFloat(document.frmNew.txtTotDeductConv.value.split(",").join(""))
											+ parseFloat(document.frmNew.txtTotMiscCharge.value.split(",").join(""));
	/*	sama, di keluarin aja dari if -_-'
		if(isNaN(grandTotal))
			grandTotal = 0;
		document.frmNew.txtGrandTotal.value = parseFloat(grandTotal);
	*/
	}else{
		a.style.display = "none"; 
		var grandTotal = parseFloat(document.frmNew.hidBaseTotAmount.value.split(",").join("")) 
											- parseFloat(document.frmNew.hidBaseTotDisc.value.split(",").join("")) 
											+ parseFloat(document.frmNew.hdnTotTaxConvBase.value.split(",").join("")) 
											- parseFloat(document.frmNew.hdnTotDeductConvBase.value.split(",").join(""));
	/*	sama, di keluarin aja dari if -_-'
		if(isNaN(grandTotal))
			grandTotal = 0;
		document.frmNew.txtGrandTotal.value = parseFloat(grandTotal);
	*/
	}

//	CRF50912-07376 : add new claim deduction field
	if(parseFloat(grandTotal) < parseFloat(cd_amount.value.split(',').join(''))){
		alert('Claim Deduction cannot be greater than Grand Total Amount');
		cd_amount.value = 0;
		cd_amount.focus();

		return false;
	}
	else{
	//	langsung di minus claim deduction, karena currency claim deduction == so currency
		grandTotal = parseFloat(grandTotal) - parseFloat(cd_amount.value.split(',').join(''));
	}

	if(isNaN(grandTotal)){ grandTotal = 0; }

	document.frmNew.txtGrandTotal.value = parseFloat(grandTotal);
	decimalinForMoney(document.frmNew.txtGrandTotal);
}

function calculateTermOfPayment(){
	var selCurrPO = document.frmNew.selCurrency.options[document.frmNew.selCurrency.selectedIndex].value; 	
	var selCurrTx = document.frmNew.selTaxCurrency.options[document.frmNew.selTaxCurrency.selectedIndex].value; 
	/*****************************************************************************
	' Created By........: IVAN
	' Created Date......: 19 July 2010
	------------------------------------------------------------------------------
	' Description.......: Calculate term of payment
	*****************************************************************************/
	if(eval("document.frmNew.txtCurr_"+selCurrPO))
		var RateCurr = eval("document.frmNew.txtCurr_"+selCurrPO).value.split(",").join("");
	else RateCurr = 0;

	if(eval("document.frmNew.txtTax_"+selCurrTx))
		var RateTax = eval("document.frmNew.txtTax_"+selCurrTx).value.split(",").join("");
	else RateTax = 0;

	if(document.frmNew.selCurrency.value != document.frmNew.selTaxCurrency.value){
		if(eval("document.frmNew.txtTax_"+selCurrPO) )
		var RateTaxToDoc = eval("document.frmNew.txtTax_"+selCurrPO).value.split(",").join("");
		else RateTaxToDoc = 1;
	}else{
		RateTaxToDoc = 1;
	}

	var totAmount	= eval("document.frmNew.txtTotAmount").value.split(",").join("");
	var totDisc		= eval("document.frmNew.txtTotDisc").value.split(",").join("");
	var totMisc		= eval("document.frmNew.txtTotMiscCharge").value.split(",").join("");
	var totTax		= eval("document.frmNew.txtTotTaxConv").value.split(",").join("");
	var totTaxD		= eval("document.frmNew.txtTotDeductConv").value.split(",").join("");
	var totalPO		= parseFloat(totAmount) - parseFloat(totDisc) + parseFloat(totMisc);
	var totalTax	= parseFloat(totTax) - parseFloat(totTaxD);
	var tempTotal	= 0;	
	var grandTotal	= parseFloat(totalPO + parseFloat(totalTax / RateTaxToDoc));

	for(xtc = 1; xtc <= document.frmNew.hdnTerm.value; xtc++){
		if(document.getElementById("txtAmount" + xtc)){		
			var objTotalAmount	= document.frmNew.txtGrandTotal;
			var objAmount		= document.getElementById("txtAmount" + xtc)
			var objPercentage	= document.getElementById("hidPercentage" + xtc);

			if(xtc == document.frmNew.hdnTerm.value){			
				objAmount.value = parseFloat(grandTotal) - parseFloat(tempTotal);
			}
			else{
				if(selCurrTx == selCurrPO){
					var intAmount	= parseFloat(objTotalAmount.value.split(",").join("")) * (parseFloat(objPercentage.value) / 100);
					objAmount.value = intAmount;
				}
				else{
					var intAmount	= parseFloat(grandTotal) * (parseFloat(objPercentage.value) / 100);
					objAmount.value	= intAmount;
				}
			}

			tempTotal = parseFloat(tempTotal) + parseFloat(objAmount.value.split(',').join(''));
		}	
	}

	decimalinForMoney(objAmount);
/**********************************************************************************************************************************************************/
}

function splitETA(idx,ndt){
	if(ndt==null)
		ndt=0;
	var objCurrentQty = eval("document.forms[0].txtQty_" + idx );
	var objCurrentHdnETA = eval("document.forms[0].txtEstimateDateSplit_" + idx);
	var objCurrentETA = document.forms[0].txtSODate ;
	var objItemCode = eval("document.forms[0].txtPartNo_" + idx);
    
    var dim = eval("document.forms[0].txtDimensionID_" +idx).value;
    
	var url = "#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/sales/so/forms/seleta.cfm";
	url = url + '?qty='+objCurrentQty.value+'&itemcode='+objItemCode.innerHTML+'&ETA='+objCurrentHdnETA.value+'&idx='+idx+'&ndt='+ndt+'&dim='+dim+'&SOdate='+objCurrentETA.value;
	var selItemWindow = window.open(url,'SelETA','scrollbars=yes,resizable=yes,location=no,status=yes')
	
}

  function flagwarna(cnt){
	// Ga Kepake, cuma biar ga error pas pick item doank, fungsinya bentrok!
  }
  
  function hover(Sender, ATargetImg){
	Sender.src = "#Application.stApp.Upload_Path[1]#/eaccounting/images/"+ATargetImg;
  }
  

  /*****************************************************************************
  ' Function Name.....: getColour() 
  ' Created By........: IVAN
  ' Created Date......: 12 October 2009
  ' Modified by			: TW
  ' Modified Date		: 2 Dec 2009
  ------------------------------------------------------------------------------
  ' Description.......: Get Item Colour
  *****************************************************************************/
  function getColour(objParamItemCode,tempcnt){
	var basedPath = "#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/color/";
	var elchk = document.frmNew.chk;
	var squota="";
	if(elchk.length!=null){
		for (var j=0; j<elchk.length; j++){
			if(elchk[j].value==tempcnt)
				break;
		}
//		alert(tempcnt+" = "+elchk.length);
		if(elchk[j].disabled){
			var elqty=eval("document.frmNew.txtQty_"+tempcnt);
			if(elqty.value==0){
				alert("#DO_VAR['PleaseSet']# #DO_VAR['Configure']# #DO_VAR['ItemQty']# #DO_VAR['First']#");
				return;
			}
			if(elqty!=null)
				squota="&quota="+elqty.value;

		}
	}
	var elcolor = eval("document.frmNew.hdncolor_"+tempcnt);//"+elitem.value+"_
	var scolor=(elcolor!=null?"&lstcolour="+elcolor.value:"")
	//arrNewPop[arrNewPop.length]=PopWindow(basedPath+"index_n.cfm?namaform="+objParamFormName+"&row="+objParamIDX+"&lstcolour="+objParamLstColour+"&itemcode="+objParamItemCode+"&qty="+qty,'wndPickColour','500','550','scrollbars=yes,resizable=yes,location=no,status=no');

	arrNewPop[arrNewPop.length]=PopWindow(basedPath+"index.cfm?itemcode="+objParamItemCode+"&tempcnt="+tempcnt+scolor+squota,'wndPickColour','500','550','scrollbars=yes,resizable=yes,location=no,status=no');
  }
  /*****************************************************************************
  =                                   END                                      =
  *****************************************************************************/
</script>

<cfinclude template="#Application.stApp.CFWeb_Path[1]#/include/lockperiod/checklock.cfm">



<script>
	var cntorder=#dorder#;
	var pageform = document.frmNew;
	if(opener!=null){
		window.resizeTo(980,700);
		window.moveTo((screen.width-980)/2,(screen.height-700)/2)
		window.focus();
	}
	
	function qty_ratio2(theparent,theinp){
		if(isNaN(theinp.value))
			theinp.value=0;
		var theqty = parseFloat(theinp.value);
		var theChk = theinp.form.chk;
		if(theChk != null){
			if(theChk.length != null){
				for (var j=0; j<theChk.length; j++){
					if(theChk[j].value==theparent)
						break;
				}
				thechild=theparent;
				for(i=j+1; i<theChk.length; i++){
					thechild++;
					if(theChk[i].disabled){
						var elmqtyparent=eval("theinp.form.txtQty2_"+(thechild-1));
						//theqty	 = elmqtyparent.value;	
						var elmqty=eval("theinp.form.txtQty2_"+thechild);
						var elmrto=eval("theinp.form.hdnRatio_"+thechild);
						if(elmqty!=null && elmrto!=null){
	//						alert(i+" = "+elmqty.value+" = "+parseFloat(elmrto.value)+"("+elmrto.value+") * "+theqty);
							var newvalue=parseFloat(elmrto.value) * theqty;

							
							if(newvalue!=elmqty.value){
								elmqty.value = parseFloat(elmrto.value) * theqty;

	//							setvalue("theinp.form.hdncolor_"+(i+1),"");
	//							setvalue("color_"+(i+1),"");
							}
						}
					}else
						break;
				}
			}
		}
	}

<!--- IVN : 28 April 2010 
CHANGE TAX1 FOR QUOTATION TYPE [Normal / VAT]
--->
var arrTaxType = new Array();
var arrSelTax = new Array();

arrTaxType[0] = new Array()
arrTaxType[0]['value'] = "0|0|0";
arrTaxType[0]['text'] = "None";

<cfloop index="i" from="1" to="#qTaxType.RecordCount#">

  arrTaxType[#i#] = new Array()
  arrTaxType[#i#]['value'] = "#JSStringFormat(qTaxType.Tax_Code[i])#|#JSStringFormat(qTaxType.Tax_rate[i])#|#JSStringFormat(qTaxType.Tax_Operator[i])#";
  arrTaxType[#i#]['text'] = "#JSStringFormat(TRIM(qTaxType.Tax_Name[i]))#";
</cfloop>

<cfif task IS "save">
  <cfif rbTypeDoc IS 3>
    <cfloop index="i" from="1" to="#qTmpDetail.recordcount#">
	  arrSelTax[#i - 1#] = new Array()
	  arrSelTax[#i - 1#]['selTaxCode1'] = "#JSStringFormat(qTmpDetail.tax_code1[i])#";
	  arrSelTax[#i - 1#]['selTaxCode2'] = "#JSStringFormat(qTmpDetail.tax_code2[i])#";
	</cfloop>
  <cfelse>
	<cfloop index="i" from="1" to="#qDetail.recordcount#">
	  arrSelTax[#i - 1#] = new Array()
	  arrSelTax[#i - 1#]['selTaxCode1'] = "#JSStringFormat(qDetail.tax_code1[i])#";
	  arrSelTax[#i - 1#]['selTaxCode2'] = "#JSStringFormat(qDetail.tax_code2[i])#";
	</cfloop>
  </cfif>
<cfelse>
	<cfloop index="i" from="1" to="#qSalesDetail.recordcount#">
		arrSelTax[#i - 1#] = new Array()
		arrSelTax[#i - 1#]['selTaxCode1'] = "#JSStringFormat(qSalesDetail.tax_code1[i])#";
		arrSelTax[#i - 1#]['selTaxCode2'] = "#JSStringFormat(qSalesDetail.tax_code2[i])#";
	</cfloop>
</cfif>

function SO_Switcher(thisobj){
  frmThis = document.frmNew;
  var HideTax = document.getElementById("idTaxHide");
  var HideTax2 = document.getElementById("idTaxHide2");
  var IncludedPPN = document.getElementById("trIncludedPPN");
  
  if(thisobj.value == 1){
	document.getElementById('SO_FOC_Pattern').innerHTML = "<b>#txtSONum#</b>";
	HideTax.style.display = "";
	HideTax2.style.display = "";
  }else if(thisobj.value == 0){
	document.getElementById('SO_FOC_Pattern').innerHTML = "<b>#txtSOnumnon#</b>";
	HideTax.style.display = "none";
	HideTax2.style.display = "";
  }
  
  if(thisobj.value == 1){
	HideTax.style.display = "";
	IncludedPPN.style.display = "none";
	
	for (idx=0;idx<=frmThis.rowCount.value;idx++){
	  if(eval("frmThis.selTax1_"+idx)){
		SelectListTax = eval("frmThis.selTax1_"+idx);
		SelectListTax.length = 0;
		
		for(var x = 0; x < arrTaxType.length; x++){
		  SelectListTax.options[SelectListTax.options.length] = new Option(arrTaxType[x]['text'], arrTaxType[x]['value'], false, false);
		}
		
		<!---for (idxx=0;idxx<=SelectListTax.length-1;idxx++){
		  if(SelectListTax[idxx].text == '#DO_VAR["IncludedPPN"]#'){
			SelectListTax[idxx].text = 'PPN';
		  }
		}--->
	  }
	  
	  if(eval("frmThis.selTax2_"+idx)){
		SelectListTax = eval("frmThis.selTax2_"+idx);
		SelectListTax.length = 0;
		
		for(var x = 0; x < arrTaxType.length; x++){
		  SelectListTax.options[SelectListTax.options.length] = new Option(arrTaxType[x]['text'], arrTaxType[x]['value'], false, false);
		}
	  }
	}
  }else if(thisobj.value == 0){
	HideTax.style.display = "none";
	IncludedPPN.style.display = "";
	
	for (idx=0;idx<=frmThis.rowCount.value;idx++){
	  if(eval("frmThis.selTax1_"+idx)){
		SelectListTax = eval("frmThis.selTax1_"+idx);
		SelectListTax.length = 0;
		
		SelectListTax.options[SelectListTax.options.length] = new Option('#DO_VAR["IncludedPPN"]#', '0|0|0', true, false);
		
		<!---for (idxx=0;idxx<=SelectListTax.length-1;idxx++){
		  if(SelectListTax[idxx].text == 'PPN'){
			SelectListTax[idxx].text = '#DO_VAR["IncludedPPN"]#';
			<cfif task neq "Edit">
				SelectListTax[idxx].selected = true;
			</cfif>
		  }
		}--->
	  }
	  
	  if(eval("frmThis.selTax2_"+idx)){
		SelectListTax = eval("frmThis.selTax2_"+idx);
		SelectListTax.length = 0;
		
		for(var x = 0; x < arrTaxType.length; x++){
		  var tmpTaxOperator = arrTaxType[x]['value'].split("|");
		  
		  if(tmpTaxOperator[2] == "0" || tmpTaxOperator[2] == "-"){
		    SelectListTax.options[SelectListTax.options.length] = new Option(arrTaxType[x]['text'], arrTaxType[x]['value'], false, false);
		  }
		}
	  }
	}
  }
  
  for (idx=0;idx<=frmThis.rowCount.value;idx++){
	if(eval("frmThis.selTax1_"+idx)){
	  calcAmount(idx); calcTax(); GetAmountGrand();
	}
  }
}

function buildSelTax(objParamID){
  var selTax1 = eval("frmThis.selTax1_" + objParamID);
  var selTax2 = eval("frmThis.selTax2_" + objParamID);
  
  selTax1.length = 0;
  selTax2.length = 0;
  
  <cfif rbTypeDoc IS 3>
    if(document.frmNew.txtSOtype.value == 0){
	  selTax1.options[selTax1.options.length] = new Option('#DO_VAR["IncludedPPN"]#', '0|0|0', true, false);
	  
	  for(var cxz = 0; cxz < arrTaxType.length; cxz++){
		var tmpTaxOperator = arrTaxType[cxz]['value'].split("|");
		
		if(tmpTaxOperator[2] == "0" || tmpTaxOperator[2] == "-"){
		  selTax2.options[selTax2.options.length] = new Option(arrTaxType[cxz]['text'], arrTaxType[cxz]['value'], false, false);
		}
	  }
	}else{
	  for(var cxz = 0; cxz < arrTaxType.length; cxz++){
		selTax1.options[selTax1.options.length] = new Option(arrTaxType[cxz]['text'], arrTaxType[cxz]['value'], false, false);
		selTax2.options[selTax2.options.length] = new Option(arrTaxType[cxz]['text'], arrTaxType[cxz]['value'], false, false);
	  }
	}
  <cfelse>
	for (zxc = 0; zxc < document.frmNew.txtSOtype.length; zxc++){

	  if(document.frmNew.txtSOtype[zxc].checked){
		if(document.frmNew.txtSOtype[zxc].value == 0){
		  selTax1.options[selTax1.options.length] = new Option('#DO_VAR["IncludedPPN"]#', '0|0|0', true, false);
		  
		  for(var cxz = 0; cxz < arrTaxType.length; cxz++){
			var tmpTaxOperator = arrTaxType[cxz]['value'].split("|");
			
			if(tmpTaxOperator[2] == "0" || tmpTaxOperator[2] == "-"){
			  selTax2.options[selTax2.options.length] = new Option(arrTaxType[cxz]['text'], arrTaxType[cxz]['value'], false, false);
			}
		  }
		}else{
		  for(var cxz = 0; cxz < arrTaxType.length; cxz++){
			selTax1.options[selTax1.options.length] = new Option(arrTaxType[cxz]['text'], arrTaxType[cxz]['value'], false, false);
			selTax2.options[selTax2.options.length] = new Option(arrTaxType[cxz]['text'], arrTaxType[cxz]['value'], false, false);
		  }
		}
	  }
	}
  </cfif>

}

function selTaxOnLoad(){
  frmThis = document.frmNew;

  for (var xtc = 0; xtc < arrSelTax.length; xtc++){
	var selTax1 = eval("frmThis.selTax1_" + (xtc + 1));
	var selTax2 = eval("frmThis.selTax2_" + (xtc + 1));
	
	for (var tmpRowCnt1 = 0; tmpRowCnt1 < selTax1.length; tmpRowCnt1++){
	  var tmpSelTax1 = selTax1[tmpRowCnt1].value.split("|");
	  
	  if(tmpSelTax1[0] == arrSelTax[xtc]['selTaxCode1']){
		selTax1[tmpRowCnt1].selected = true;
	  }
	}
	
	for (var tmpRowCnt2 = 0; tmpRowCnt2 < selTax2.length; tmpRowCnt2++){
	  var tmpSelTax2 = selTax2[tmpRowCnt2].value.split("|");
	  
	  if(tmpSelTax2[0] == arrSelTax[xtc]['selTaxCode2']){
		selTax2[tmpRowCnt2].selected = true;
	  }
	}
  }
}

<cfif rbTypeDoc IS 3>
  SO_Switcher(document.frmNew.txtSOtype);
<cfelse>
  for (i = 0; i < document.frmNew.txtSOtype.length; i++){
	if(document.frmNew.txtSOtype[i].checked){
	  SO_Switcher(document.frmNew.txtSOtype[i]);
	  break;
	}
  }
</cfif>

function cleardata(){
    document.frmNew.txtCustCode.value = "";
    document.frmNew.txtCustName.value = "";
    document.frmNew.txtCustAddress.value = "";
    document.frmNew.txtnpwp.value = "";
    document.frmNew.txtCPCode.value = "";
    document.frmNew.txtCPName.value = "";
    document.frmNew.txtCPAddress.value = "";
    document.frmNew.selQuotation.value = "";
    document.frmNew.selProforma.value = "";
    document.frmNew.ddlSalesContract.value = "";
       
    for (i=document.getElementById('tbl_ID').rows.length; i>0; i--){
    document.getElementById('tbl_ID').deleteRow(i-1);
    } 
      
    
}

var objLookupField = ''; // SET THIS FIELD SAME AS DIV FOR AJAX TARGET FIELD ID
var objTextField = ''; // SET THIS FIELD SAME AS TEXTBOX ID AND NAME FOR AJAX SEARCH TEXT
var objPageRequestURL = '#Application.stApp.Web_Path[1]#/#Application.stApp.Home_URL[VST_IDX]#/sales/so/forms/cntquicksearch.cfm';

function quickSearch(objSearchText, objPageRequestType, divName){
	var strURL = '#Application.stApp.Web_Path[1]#/#Application.stApp.Home_URL[VST_IDX]#/include/quicksearch.cfm?PageRequestID=' + Math.random()
			 + '&PageRequestType=' + objPageRequestType
			 + '&SearchText=' + objSearchText.value
			 + '&PageRequestURL=' + objPageRequestURL
			 + '&submenu=sales&selCatType=#selCatType#'
			 + '&divName=' + objLookupField
			 + '&ExtraQuery=1'
			 + '&selCurrency=#selCurrency#';
			 
	getAJAXContent(strURL, objLookupField, 1);

}

function onEvent(){
	// close search field
	popLookup('no');
	
	if(objValidation()){
		// do action
		if(objTextField=="selProject"){
			checkRow(this);
		}else{
			if(eval("document.forms[0].btnSubmit"))
			document.frmNew.selCurrency.disabled = true;
			document.frmNew.selTaxCurrency.disabled = true;
			document.frmNew.btnSubmit.disabled=true;
			reload_page();
			calcAmountAll();
		}
	}
}

function objValidation(){
	if(objTextField=="selProject"){
		var objNumberField = 'ProjectNumber';
	}else if(objTextField=="selQuotation"){
		var objNumberField = 'QuoNumber';
	}else if(objTextField=="selProforma"){
		var objNumberField = 'ProformaNumber';
	}else if(objTextField=="ddlSalesContract"){
		var objNumberField = 'SalesContractNumber';
	}
	if(document.getElementById(objTextField).value == ''){
		
		//else{
			alert('#DO_VAR['PlsChooseDocSource']#!');
		//}
		quickSearch(document.getElementById(objTextField), objNumberField,objTextField);
		document.getElementById(objTextField).focus();
		return false;
	}
	return true;
}

function setObjField(TextField, LookupField){
	//alert(TextField);
	if(objLookupField!="")popLookup('no');
	objTextField = TextField;
	objLookupField = LookupField;
}

function switched(doc,txtDoc){
	if(doc=='Project'){
		setObjField('selProject','divAjaxLookupProject'); 
		quickSearch(txtDoc, 'ProjectNumber','divAjaxLookupProject');
	}else if(doc=='Quo'){
		setObjField('selQuotation','divAjaxLookupQuo'); 
		quickSearch(txtDoc, 'QuoNumber','divAjaxLookupQuo');
	}else if(doc=='Proforma'){
		setObjField('selProforma','divAjaxLookupProforma');
		quickSearch(txtDoc, 'ProformaNumber','divAjaxLookupProforma');
	}else if(doc=='SalesContract'){
		setObjField('ddlSalesContract','divAjaxLookupSalesContract');
		quickSearch(txtDoc, 'SalesContractNumber','divAjaxLookupSalesContract');
	}

}

function changeBGcolor(objParam){
  objParam.style.backgroundColor = '';
}
//calcTax(); //GetAmountGrand(); setCurrTax();
selTaxOnLoad();
//recalcTotal();

//if(document.frmNew.selQuotation.value !='' || document.frmNew.selProforma.value !='' || document.frmNew.ddlSalesContract.value !='')
//{
		<cfif task eq "Save">
			<cfif isDefined ("form.selQuotation") or isDefined ("form.selProforma")>
				getDiscountTotal();
				getFreeItemTotal();
			</cfif>
		</cfif>
//}

<cfif task eq "Edit">
function converter_value(){
	<cfloop list="#lstcurrency#" index="idx" delimiters=";">
		<cfif listgetat(idx,1,"|") eq "Amount">
		<cfset converter = 0>
		
			<cfloop list="#qSales.CurrencyRateList#" index="curr" delimiters=";">
				<cfif listgetat(curr,1,"|") eq listgetat(idx,2,"|")>
						<cfset converter = listgetat(curr,2,"|") >
				</cfif>
			</cfloop>
			
			
		    <cfif converter neq 0>
				<cfparam name="txtCurr_#listgetat(idx,2,'|')#" default="#converter#" >
				if(eval("document.forms[0].txtCurr_#listgetat(idx,2,'|')#"))
				{
					eval("document.forms[0].txtCurr_#listgetat(idx,2,'|')#").value = "#Evaluate('txtCurr_#listgetat(idx,2,'|')#')#" ;
				}
			</cfif>
			
		<cfelse>
			<cfset converter = 0>
			
			<cfloop list="#qSales.Tax_CurrencyRateList#" index="curr" delimiters=";">
				<cfif listgetat(curr,1,"|") eq listgetat(idx,2,"|")>
						<cfset converter = listgetat(curr,2,"|") >
				</cfif>
			</cfloop>
			
			<cfif converter neq 0>
				<cfparam name="txtTax_#listgetat(idx,2,'|')#" default="#converter#" >
				if(eval("document.forms[0].txtTax_#listgetat(idx,2,'|')#"))
				{
					eval("document.forms[0].txtTax_#listgetat(idx,2,'|')#").value = "#Evaluate('txtTax_#listgetat(idx,2,'|')#')#" ;
				}
			</cfif>
		</cfif>
	</cfloop>

}
</cfif>

<!--- END OF CHANGE [28 April 2010] --->
<cfif rbTypeDoc EQ 1 AND (Len(Trim(selProject)) NEQ 0 OR selPro NEQ 0)>
	if(document.getElementById("chk")) delRow('tbl_ID',1,'pro');
</cfif>

	function recalcDeduction(){
		var cd_amount			= document.getElementById('txt_cd_amount');
		var paymentTerms_len	= document.getElementById('tblPayment').rows.length - 1;

		if(paymentTerms_len >= 1){
			var temp_result = 0;
			var paymentTerms_amt = eval('document.forms[0].txtAmount' + paymentTerms_len);

		//	alert(paymentTerms_amt.value);

			temp_result = parseFloat(paymentTerms_amt.value.split(',').join('')) - parseFloat(cd_amount.value.split(',').join(''));
			paymentTerms_amt.value = temp_result;

			decimalinForMoney(paymentTerms_amt);
		}
	}

</script>
</cfoutput>