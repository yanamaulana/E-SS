<!------------------------------------------------------------------------------
APPLICATION......: SunFishERP 51
FID..............: -
FUID/SELACTIONID.: -
FILENAME.........: pickitem.cfm
================================================================================
CREATED BY.......: - ??
CREATED DATE.....: - ??
================================================================================
DESCRIPTION......:  ??
================================================================================
REVISION.........: /* Nov 29 '09 - TW */
.................: untuk multilevel configure
================================================================================
REVISION.........: /* May 29 '08 - RF */
.................: untuk event pricing
================================================================================
REVISION.........: /* April 2 '08 - ZZ */
.................: add filter item data which is master or transaction, change interface

REVISION.........: /* Frz */
.................:  FORM select Item Code
					dipakai di : Sales Order(SO)
								 Purchase Order(PO)
								
REVISION.........: /* 30 September 2010 - randytia */
.................: Change Credit limit, validation condition is not active

REVISION.........: /* 02 November 2010 - Ivan Pujianto */
.................: Change to new function get item price
------------------------------------------------------------------------------->

<cfset objInventory	= createObject("component", "#Application.ComponentPath#.sunfisherp.inventory.inventorycomponent")>
<cfset objDummy		= createObject("component", "#Application.ComponentPath#.sunfisherp.utility.cfdummy")>

<cfparam name="accountgroup" default="">
<cfparam name="IntroNo" default="">
<cfparam name="CBOCP" default="">
<cfparam name="local.strErrMsg" default="" type="string">

<cfif isDefined("url.DATE") AND ISDATE(URL['DATE'])>
  <cfset local.dtmDocumentDate = URL['DATE']>
<cfelse>
  <cfset local.strErrMsg = "Message : invalid parameter<br />Detail : URL parameter for date is undefined or not type of date!">
</cfif>

<cfif isDefined("url.SELCURRENCY") AND URL['SELCURRENCY'] NEQ "">
  <cfset local.strCurrencyID = URL['SELCURRENCY']>
<cfelse>
  <cfset local.strCurrencyID = COOKIE.CURRENCYID>
</cfif>

<cfif isDefined("selCatType") AND selCatType NEQ "">
  <cfif isDefined("form.selCatType")>
    <cfset local.strCatType = FORM['selCatType']>
  <cfelse>
    <cfset local.strCatType = URL['selCatType']>
  </cfif>
<cfelse>
  <cfset local.strErrMsg = "Message : invalid parameter<br />Detail : URL parameter for select category type is undefined!">
</cfif>

<cfif isDefined("cboCustomer")>
  <cfif isDefined("form.cboCustomer")>
    <cfset cboCustomer = objDummy.cfnumval(objParam: FORM['cboCustomer'])>
  <cfelse>
    <cfset cboCustomer = objDummy.cfnumval(URL['cboCustomer'])>
  </cfif>
<cfelse>
	<cfparam name="cboCustomer" default="0" type="numeric">				
</cfif>

<cfif isDefined("cboCustomer2")>
	<cfparam name="cboCustomer2" default="#cboCustomer2#">
<cfelse>
	<cfparam name="cboCustomer2" default="">
</cfif>

<cfif isDefined("url.MENU") AND URL['MENU'] NEQ "">
  <cfif TRIM(UCASE(URL['MENU'])) EQ "PURCHASE">
    <cfset local.strPricingType = TRIM(UCASE(URL['MENU']))>
    
    <cfif isDefined("url.SOURCE") AND URL['SOURCE'] NEQ "">
      <cfswitch expression="#TRIM(UCASE(URL['SOURCE']))#">
        <cfcase value="PO-RFQ">
          <cfset local.strDocumentType = "RequestForQuotation">
        </cfcase>
        
        <cfcase value="PO-QO">
          <cfset local.strDocumentType = "Quotation">
        </cfcase>
        
        <cfcase value="Direct_RR">
          <cfset local.strDocumentType = "DirectReceiptReport">
        </cfcase>
        
        <cfcase value="PO">
          <cfset local.strDocumentType = "PurchaseOrder">
        </cfcase>
        
        <cfdefaultcase>
          <cfset local.strErrMsg = "Message : invalid parameter<br />Detail : URL parameter for source is not valid!">
        </cfdefaultcase>
      </cfswitch>
    <cfelse>
      <cfset local.strErrMsg = "Message : invalid parameter<br />Detail : URL parameter for source is undefined!">
    </cfif>
  <cfelseif TRIM(UCASE(URL['MENU'])) EQ "SALES">
    <cfset local.strPricingType = TRIM(UCASE(URL['MENU']))>
    
    <cfif isDefined("url.SOURCE") AND URL['SOURCE'] NEQ "">
      <cfswitch expression="#TRIM(UCASE(URL['SOURCE']))#">
        <cfcase value="SORFQ">
          <cfset local.strDocumentType = "RequestForQuotation">
        </cfcase>
        
        <cfcase value="SO-QO">
          <cfset local.strDocumentType = "Quotation">
        </cfcase>
        
        <cfcase value="Direct_SN">
          <cfset local.strDocumentType = "DirectShipmentNote">
        </cfcase>
        
        <cfcase value="SO">
          <cfset local.strDocumentType = "SalesOrder">
        </cfcase>
        
        <cfdefaultcase>
          <cfset local.strErrMsg = "Message : invalid parameter<br />Detail : URL parameter for source is not valid!">
        </cfdefaultcase>
      </cfswitch>
    <cfelse>
      <cfset local.strErrMsg = "Message : invalid parameter<br />Detail : URL parameter for source is undefined!">
    </cfif>
  <cfelse>
    <cfset local.strErrMsg = "Message : invalid parameter<br />Detail : URL parameter for menu is not valid value, please use PURCHASE / SALES!">
  </cfif>
<cfelse>
  <cfset local.strErrMsg = "Message : invalid parameter<br />Detail : URL parameter for menu is undefined!">
</cfif>

<cffunction name="getConfigItem">
	<cfargument name="prtcode" required="yes" type="string">
    <cfargument name="prtdimension" required="yes" type="string">
	<cfargument name="custid" required="yes" type="string">
 	<cfargument name="level" default="0">
	<cfargument name="listprt" default="">
	<cfargument name="ratio" default="1">
    <cfif listfindnocase(arguments.listprt,arguments.prtcode)>
		<cfexit>
	</cfif>
	<cfset variables.pratio=IIF(val(arguments.ratio),"#val(arguments.ratio)#",1)>
	<cfset variables.parentpath=listAppend(arguments.listprt,arguments.prtcode)>
	<cfquery name="VARIABLES.qryTmp" datasource="#REQUEST.DSN#">
		SELECT 
			TERPITEMRELATION.CHILD_ITEM_CODE AS ITEM_CODE,
			(TERPITEMRELATION.CHILD_RATIO * #ratio#) AS CHILD_RATIO,
			<cfif source neq "PO">
			ISNULL(TERPITEMPRICERELATION.PRICE,0) AS UNITPRICE,
			<cfelse>
			0 AS UNITPRICE,
			</cfif>
			TITEM.ITEM_NAME,
			TITEM.Item_Size, TITEM.Item_Material
			,TITEM.generate_flag
			,TItem.currency_id,TItem.pricetype
			,TAccUnitType.Unit_Name
			,TItem.Unit_Type_ID
            ,TERPITEMRELATION.Dimension_ID 
            ,TITEMDIMENSION.Dimension_Name
		FROM TERPITEMRELATION
		INNER JOIN TITEM ON TITEM.ITEM_CODE = TERPITEMRELATION.CHILD_ITEM_CODE 
        INNER JOIN TITEMDIMENSION ON TITEMDIMENSION.DIMENSION_ID = TERPITEMRELATION.DIMENSION_ID 
		<cfif source neq "PO">
		LEFT JOIN TERPITEMPRICERELATION ON TERPITEMPRICERELATION.CHILD_ITEM_CODE = TERPITEMRELATION.CHILD_ITEM_CODE 
		AND TERPITEMPRICERELATION.PARENT_ITEM_CODE = '#arguments.prtcode#'
                 AND TERPITEMPRICERELATION.TYPE_CODE = (SELECT SELLING_PRICE_TYPE FROM TACCOUNT WHERE ACCOUNT_ID = '#arguments.custid#' ) 
                 AND TERPITEMPRICERELATION.PARENT_DIMENSION_ID = '#prtdimension#'
		</cfif>
          	LEFT OUTER JOIN TAccUnitType ON TAccUnitType.Unit_Type_ID = TItem.Unit_Type_ID
		WHERE TERPITEMRELATION.PARENT_ITEM_CODE = '#arguments.prtcode#'
		order by  TERPITEMRELATION.child_item_code asc
	</cfquery>
	<cfloop query="VARIABLES.qryTmp">
		<cfif not listfindnocase(arguments.listprt,ITEM_CODE)>
			<cfset QueryAddRow(qCheckRelation,1)>
			<cfset QuerySetCell(qCheckRelation,"ITEM_CODE",ITEM_CODE)>
			<cfset QuerySetCell(qCheckRelation,"CHILD_RATIO",CHILD_RATIO)>
			<cfset QuerySetCell(qCheckRelation,"ITEM_NAME",ITEM_NAME)>
			<cfset QuerySetCell(qCheckRelation,"Item_Size",Item_Size)>
			<cfset QuerySetCell(qCheckRelation,"Item_Material",Item_Material)>
			<cfset QuerySetCell(qCheckRelation,"generate_flag",generate_flag)>
			<cfset QuerySetCell(qCheckRelation,"ilevel",arguments.level)>
            <cfset QuerySetCell(qCheckRelation,"prt",arguments.prtcode)>
            <cfset QuerySetCell(qCheckRelation,"ppath",listAppend(arguments.listprt,arguments.prtcode))>
			<cfset QuerySetCell(qCheckRelation,"Unit_Name",Unit_Name)>
			<cfset QuerySetCell(qCheckRelation,"Unit_Type_ID",Unit_Type_ID)>
			<cfset QuerySetCell(qCheckRelation,"Dimension_ID",Dimension_ID)>
            <cfset QuerySetCell(qCheckRelation,"Dimension_Name",Dimension_Name)>
            
            <cfset local.tmpItemPrice = objInventory.fntGetItemPrice(intCompanyID: COOKIE.COMPANYID,
																	 strItemCode: VARIABLES.qryTmp.Item_Code,
																	 intDimensionID: VARIABLES.qryTmp.Dimension_ID,
																	 strCurrencyID: local.strCurrencyID,
																	 intAccountID: arguments.custid,
																	 strPricingType: local.strPricingType,
																	 dtmDocumentDate: URL['txtDate'],
																	 strDocumentType: local.strDocumentType,
																	 fltQty: 0,
																	 strPaymentTerm: '')>
            
			<cfset QuerySetCell(qCheckRelation, "UNITPRICE", local.tmpItemPrice.ITEMPRICE)>
			
			<cfif generate_flag>
				<cfset getConfigItem(ITEM_CODE,Dimension_ID,arguments.custid,arguments.level+1,listAppend(arguments.listprt,arguments.prtcode),variables.pratio*CHILD_RATIO)>
			</cfif>
		</cfif>
	</cfloop>
</cffunction>
<cfoutput>
<script language="JavaScript" src="#Application.stApp.Web_Path[vst_idx]#/include/js/allscripts.js"></script>
<cfquery name="qStatus" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 		RequestSts,Request_type 
	FROM 		THRMRequestSts
</cfquery>

<cfset LANGUAGELIST = #ValueList(qStatus.Request_type)#>	
<cfset LANGUAGELIST = LANGUAGELIST & ", size, FlagColour, PriceList, Purchasing, N/A, CurrencyConverter, PurchaseOrder, Discount, ListofItem, " 
					& "PleaseSetCurrencyConverter, Yes, No, With, SisterCompanyTransaction, Outlet, ShowAll, Employee_ID, SalesPriceHistory, " 
					& "ItemCode, ItemName, ItemCategory, PONumber, Vendor, NoRecord, Filter, datefrom, Master, Transaction, ItemType, Search, " 
					& "page, of, SearchText, UnitPrice, POList, ContactPerson, Customer, SalesOrder, Close, SalesPerson, ALL, AssetCode, " 
					& "AssetName, PleaseSelect, PickItem, ItemSize, ItemMaterial, ItemColor, Price, PleaseSelectItem, Display, SalesPricing, " 
					& "PleaseSelectCustomer, Continue, Select, eHRMEmployeeName, , Reset, NoRecordFound, SelectCustomer, SelectSupplier, " 
					& "CostingSheetNo, Category, PriceType, ItemClass, show, note, Dimension, Description, eHRMType, Color, ItemBrand">

<CF_DO_V25_MULTILANGUAGE MESSAGEIDLIST="#LanguageList#"> 
<cfquery name="qSetting" datasource="#iif(isdefined('DSN'), 'DSN', 'Attributes.DSN')#">
	select	TAccSetting.salesPerson 
	from	TAccSetting
</cfquery>
<cfparam name="selcho2" default="C">
<cfparam name="ExtraQuery" default="">	
<cfparam name="alr" default="0">
<cfparam name="txtcustcode" default="">
<cfparam name="selcategory" default="-1">

<cfparam name="selPage" default="1">
<cfset idx = 1>
<cfparam name="on_off" default=1>

<cfparam name="date" default="#NOW()#">

<cfquery name="qCurrency" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
 	select	TCurrency.Currency_ID,
			TCurrency.Currency_Symbol
	from	TCurrency
	where currency_id <> '#cookie.currencyid#'
	AND ISNULL(STATUS,0) = 1
</cfquery>

 <cfquery name="qAllCurr" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
 	select	* 
	from 	TCurrency
	where  ISNULL(STATUS,0) = 1
</cfquery>

<cfloop query="qAllCurr">
	<cfquery name="qCurrencyConverter#currency_id#" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		select top 1 scale as kurs from tcurrencyconverter
		where currency_id_1 = '#local.strCurrencyID#'
		and currency_id_2 = '#currency_id#'
		and start_date < =#CreateODBcDate(date)#
		and company_id = #cookie.companyid#
		order by start_date desc, converter_id desc
	</cfquery>
</cfloop>

<!--- get credit Limit --->
<cfquery name="qGetCreditLimit" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 	Credit_Limit
	FROM 	TAccTermsDefault
	WHERE 	TAccTermsDefault.Company_ID = #cookie.companyID#
	AND		TAccTermsDefault.Account_ID = '#CBOCUSTOMER#'
</cfquery>

<!--- get NotPaidInvoice --->
<cfquery name="qGetNotPaidSalInvoice" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 	sum (base_invoice_amount+dbo.func_calculateByDelimiter(list_base_taxamount)) - sum(base_dp_amount+dbo.func_calculatebydelimiter(list_base_dp_taxamount)) as TotalInvoiceNotPaid 
	FROM	TAccSI_Header
	WHERE  	invoice_status != 'FP'
	AND 	isvoid = 0
	AND		account_id = '#CBOCUSTOMER#'
</cfquery>
<cfquery name="qGetNotPaidProInvoice" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 	sum (base_invoice_amount+dbo.func_calculateByDelimiter(list_base_taxamount)) - sum(base_dp_amount+dbo.func_calculatebydelimiter(list_base_dp_taxamount)) as TotalInvoiceNotPaid 
	FROM	TAccProjectInvoice_Header
	WHERE  	invoice_status != 'FP'
	AND 	isvoid = 0
	AND		account_id = '#CBOCUSTOMER#'
</cfquery>
<!--- get SOApproved --->
<cfquery name="qGetSOSalApproved" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 	sum(Base_Invoice_Amount+Base_Tax_Amount) as TotalSOApproved 
	FROM	TAccSO_Header
	WHERE 	approval_status  = 3
	AND isclose = 0 AND isnull(isnotactive,0) = 0
	and not exists(select 1 from TAccSI_Header where SO_Number = TAccSO_Header.SO_Number and TAccSI_Header.IsVoid=0)
	AND Account_ID =  '#CBOCUSTOMER#'
</cfquery>
<cfquery name="qGetSOProApproved" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 	sum(Stage_BaseAmount+Tax_Amount1*(Base_Tax_Amount/CASE Tax_Amount WHEN 0 THEN 1 ELSE Tax_Amount END)+Tax_Amount2*(Base_Tax_Amount/CASE Tax_Amount WHEN 0 THEN 1 ELSE Tax_Amount END)) 
			- (SELECT sum(Base_Invoice_Amount+dbo.func_calculateByDelimiter(list_base_taxamount)) FROM TAccProjectInvoice_Header WHERE SO_Number = TAccSOProject_Header.SO_Number AND (TAccProjectInvoice_Header.IsVoid = 0 OR TAccProjectInvoice_Header.IsVoid IS NULL))
			as qGetSOApproved 
	FROM	TAccSOProject_Header, TAccSOProject_Detail, TAccProjectStageHeader
	WHERE 	approval_status  = 3
       <!--- and not exists(select 1 from TAccProjectInvoice_Header where SO_Number = TAccSOProject_Header.SO_Number and TAccProjectInvoice_Header.IsVoid=0) --->
	AND Account_ID =  '#cboCustomer#' AND isnull(isnotactive,0) = 0
	AND TAccSOProject_Header.SO_Number = TAccSOProject_Detail.SO_Number
	AND TAccProjectStageHeader.StageCode = TAccSOProject_Detail.Stage_Code
	AND TAccProjectStageHeader.CompanyID = #Cookie.CompanyID#
	AND TAccProjectStageHeader.IsMilestone = 1
	GROUP BY TAccSOProject_Header.SO_Number
</cfquery>
<cfif TRIM(UCASE(URL['MENU'])) EQ "PURCHASE">
		<cfset defType ='purchase'>
<cfelse>
		<cfset defType ='sales'>
</cfif>
<cfquery name="qFindTermTax" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT	TAccTax.Tax_Code, TAccTax.Tax_Rate, Tax_Operator, Use_Tax_ID, TypeTerm_Id
	FROM	TAccTermsDefault
   Inner Join TAccTax on TAccTax.Tax_Id = TAccTermsDefault.Tax_Id
	WHERE	TAccTermsDefault.Company_ID = #Cookie.CompanyID#
	AND		TAccTermsDefault.Account_ID = '#CBOCUSTOMER#'
	AND		TAccTermsDefault.Default_Type = '#defType#'
</cfquery>

<cfset newSOProApproved = 0>
<cfloop query="qGetSOProApproved">
	<cfset newSOProApproved = val(newSOProApproved) + val(qGetSOApproved)>
</cfloop>
<cfset txtNotPaidInvoice = val(qGetNotPaidSalInvoice.TotalInvoiceNotPaid) + val(qGetNotPaidProInvoice.TotalInvoiceNotPaid)>
<cfset txtSOApproved = val(qGetSOSalApproved.TotalSOApproved) + val(newSOProApproved)>

<!--- Sales Person --->
<cfif val(qSetting.salesPerson) eq "1">
	<cfquery name="qEmpList" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT 	THRMEmpPersonalData.Emp_ID, 
				isNull(First_Name,'') + ' ' + isNull(Middle_Name,'') + ' ' + isNull(Last_Name,'') AS name,
				THRMEmpPersonalData.Effective_Date
		FROM 	THRMEmpPersonalData , THRMOrgConn, THRMCompany
		WHERE	THRMEmpPersonalData.OrgConn_ID = THRMOrgConn.OrgConn_ID
		AND		THRMOrgConn.Company_ID = THRMCompany.Company_ID 
		AND 	THRMCompany.Company_ID = #Cookie.COMPANYID# 
		AND	(Terminate_Date >= #now()# OR  Terminate_Date IS  NULL)
		AND 	THRMEmpPersonalData.isSalesPerson = 1
		Order By THRMEmpPersonalData.First_Name ASC
	</cfquery>
<cfelse>
	<cfquery name="qEmpList" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
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
	and TSalesCustomer.accountid = '#cboCustomer#'
	ORDER BY thrmemppersonaldata.Emp_ID ASC

	</cfquery>
</cfif>

<cfset emp_list="0|None">
<cfloop query="qEmpList">		
	<cfset emp_list=listappend(emp_list,"#emp_id#|#name#",",")>
</cfloop>

<!--- cari category barang yang sudah ada di TItem --->
<cfquery name="qCategory" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 	Itemcategory_id, ItemCategory_Name
	FROM 	TItemCategory
	WHERE 	Parent_ID = 0
	AND ItemCategoryType = '#local.strCatType#'
	AND ISNULL(COMPANY_ID,0)=#COOKIE.COMPANYID#
	ORDER BY 	ItemCategory_NAME ASC		
</cfquery>

<!--- customer / vendor --->
<!--- Untuk vendor(dari menu purchase) --->
<cfif local.strPricingType eq "Purchase">
	<cfquery name="qCustomer" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT 		Distinct TAccount.Account_ID,TAccount.Account_Code,AccountTitle_Code, Account_Name, account_address1, PaymentTerms,isnull(PAYMENTTERM,0) PAYMENTTERM, Account_Code, isnull(groupid_vendor,0) as groupid_vendor
		FROM 		TAccount
		<!--- <cfif local.strCatType eq "AST">
			inner join TAccAssetTemp on TAccAssetTemp.account_id = Taccount.account_id 
		</cfif> --->
		WHERE 		Status = '1' AND #cookie.companyID# in (TAccount.company_id)
		<!--- <cfif local.strCatType eq "AST">
			and TAccAssetTemp.po_number is null
		</cfif> --->
		<cfif local.strCatType eq "RM">
			 AND	TAccount.Ven_RM = 1
		<cfelseif local.strCatType eq "FG">
			 AND	TAccount.Ven_FG = 1
		<cfelseif local.strCatType eq "AST">
			 AND	TAccount.Ven_AST = 1 
		<cfelseif local.strCatType eq "SP">
			 AND	TAccount.Ven_SP = 1
		<cfelseif local.strCatType eq "SF">
			 AND	TAccount.Ven_SF = 1 			 
        <cfelse>
             AND	TAccount.Ven_WIP = 1 
		</cfif>
			<cfif IsDefined("REQUEST.vauthaccountfilter") AND REQUEST.vauthaccountfilter neq "">
				AND	TAccount.Category_ID IN (#preservesinglequotes(REQUEST.vauthaccountfilter)#)
			</cfif>
        <!--- And (Cust_Status <> 'RJC' or Cust_Status IS NULL) --->
		AND isnull(TAccount.Flag,0) = 0
		ORDER BY 	Account_Name ASC
	</cfquery>
	<cfset lstItemCatID = "#valuelist(qCategory.ItemCategory_ID,",")#">
	<cfset lstItemCatID = lstItemCatID & ",-1">
	<cfquery name="qCustDetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		Select Account_id
			,Account_Name = (CASE TAccount.accounttitle_code WHEN '' THEN TAccount.accounttitle_code +' '+ TAccount.Account_Name ELSE TAccount.accounttitle_code +'. '+ TAccount.Account_Name END)
			,Account_CurrencyID,Account_Address1 as Addr, PaymentTerms,isnull(PAYMENTTERM,0) PAYMENTTERM,isnull(kawasanberikat,0) as kawasanberikat,isnull(isSisterCompany,0) as isSisterCompany
			,isnull(SisterCompany,0) as SisterCompany, TaxFileNumber
		From TAccount
		Where Account_ID = '#cboCustomer#'
	</cfquery>

	<cfif not isdate(date)>
		<cfset date = now() />
	</cfif>

	<cfquery name="qCP" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		Select TContact.Contact_id, Contact_FirstName, Contact_MiddleName, Contact_LastName, Contact_HomeAddress as Addr
		From TContact
		Inner Join TAccountContact On TContact.Contact_ID = TAccountContact.Contact_ID
		Where Account_id = '#cboCustomer#'
	</cfquery>
	<cfquery name="qDiscount" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		select top 1 persen,disc_id
		from tdiscount
		where account_id ='#cboCustomer#'
		and effective_date <= #createodbcdate(dateadd("d",1,date))#
		and type='Buy'
		order by effective_date desc
	</cfquery>

<!--- Untuk customer(dari menu sales) --->
<cfelse>
	<cfquery name="qCustomer" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT 		Account_ID,AccountTitle_Code,Account_Code, TAccount.Account_Name, account_address1, Selling_Price_Type ,PaymentTerms,isnull(PAYMENTTERM,0) PAYMENTTERM,isnull(GroupID,0) as GroupID
					,isnull(isOutlet,0) as isOutlet,isnull(outlet_wh,0) as outlet_wh
		FROM 		TAccount
		WHERE 		#cookie.companyID# in (TAccount.company_id)
		<cfif local.strCatType eq "RM">
			 AND	TAccount.Cust_RM = 1
		<cfelseif local.strCatType eq "FG">
			 AND	TAccount.Cust_FG = 1
		<cfelseif local.strCatType eq "AST">
			 AND	TAccount.Cust_AST = 1 
		<cfelseif local.strCatType eq "SP">
			 AND	TAccount.Cust_SP = 1
		<cfelseif local.strCatType eq "SF">
			 AND	TAccount.Cust_SF = 1 
        <cfelse>
             AND    TAccount.Cust_WIP = 1     
		</cfif>
		<cfif IsDefined("REQUEST.vauthaccountfilter") AND REQUEST.vauthaccountfilter neq "">
			AND	TAccount.Category_ID IN (#preservesinglequotes(REQUEST.vauthaccountfilter)#)
		</cfif>
		AND 		Status = '1'
        <!--- randytia	Mei26-2010 -> tidak menampilkan customer yg sudah di reject --->
        <!--- And Cust_Status <> 'RJC' --->
		AND isnull(TAccount.Flag,0) = 0
		ORDER BY 	TAccount.Account_Name ASC
	</cfquery>
	<cfparam name="isOutlet" default="#qCustomer.isOutlet#">
	<cfparam name="outlet_wh" default="#qCustomer.outlet_wh#">
	
	<cfquery name="qDiscount" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		select top 1 persen,disc_id
		from tdiscount
		where account_id ='#cboCustomer#'
		and effective_date < #createodbcdatetime(dateadd("d",1,date))#
		and type='Sales'
		order by effective_date desc
		<!--- and isActive ='1' --->
	</cfquery>
	
	<cfset lstItemCatID = "#valuelist(qCategory.ItemCategory_ID,",")#">
	<cfset lstItemCatID = lstItemCatID & ",-1">
	
	<!--- cari Detail Cust yang dipilih --->
	<cfquery name="qCustDetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		Select Account_id
			,TAccount.Account_Name			
			,Account_CurrencyID, Account_Address1 as Addr, PaymentTerms,isnull(PAYMENTTERM,0) PAYMENTTERM,Selling_Price_Type,isnull(kawasanberikat,0) as kawasanberikat,isnull(isSisterCompany,0) as isSisterCompany
			,isnull(SisterCompany,0) as SisterCompany,cust_salesperson as salescode
			,isNull(THRMEMPPERSONALDATA.First_Name,'') + ' ' + isNull(THRMEMPPERSONALDATA.Middle_Name,'') + ' ' + isNull(THRMEMPPERSONALDATA.Last_Name,'') AS salesname
            ,TaxFileNumber
		From TAccount
			LEFT JOIN THRMEMPPERSONALDATA ON TAccount.Cust_SalesPerson = THRMEMPPERSONALDATA.EMP_ID
		Where Account_ID = '#cboCustomer#'
	</cfquery>
	
	<!--- untuk cari Contact Person dari Account ybs --->
	<cfquery name="qCP" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		Select TContact.Contact_id, Contact_FirstName ,Contact_MiddleName, Contact_LastName, Contact_HomeAddress as Addr
		From TContact
		Inner Join TAccountContact On TContact.Contact_ID = TAccountContact.Contact_ID
		Where Account_id = '#cboCustomer#'
	</cfquery>
	<cfquery name="qSalesOrder" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		Select so_number
		From TAccSo_Header
		Where Account_id = '#cboCustomer#'
		and so_status = 3
		and approval_status = 3
		and itemcategorytype = '#local.strCatType#'
		and company_id = #cookie.COMPANYID#
	</cfquery>
</cfif>

<cfquery name="qSalesNih" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT Emp_ID, (First_Name + ' ' + Last_Name) as SalesName
	FROM THrmEmppersonalData
	<cfif (isDefined("Source") and Source eq "Direct_SN") or (isDefined("Source") and Source eq "SO") or (local.strPricingType eq "Sales" and isDefined("Source") and Source eq "SO-QO")>
		WHERE isSalesPerson = 1
	</cfif>
	ORDER BY First_name
</cfquery>

<CF_DO_V25_ACCCATEGORY_TREE ITEMCATEGORY_ID = "#selcategory#">
<cfset lstCat= ValueList(qFunctionTree.ItemCategory_ID)>

<cfset DisplaySearch = 1>
<cfparam name="MaxSearchCriteria" default="5">	
<cfparam name="selType" default="ItemCode">

<cfquery name="qGetDisplayRow" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 	TAccSetting.Display_Rows 
	FROM 	TAccSetting
</cfquery>
<cfset varMaxRows = qGetDisplayRow.Display_Rows>

<cfquery name="qcolor" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
	Select color_code,color_name from TgsColor
</cfquery>

<cfset strctColor = StructNew()>
<cfloop query="qColor">
	<cfset strctColor[qColor.color_code] = qColor.color_name>
</cfloop>

<!--- JIka menu=purchase--->
<cfif (local.strPricingType eq "Purchase")>
	<cfif local.strCatType neq "AST">
		<cfquery name="qItemCat" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">	
			Select 	itemCategory_ID 
			From 	TItemcategory 
			Where 	itemCategoryType = '#local.strCatType#'
			AND #cookie.companyID# in (TItemcategory.Company_ID) 
		</cfquery>
		 
		<cfif val(qcustdetail.issistercompany) eq 1>
			<cfquery name="qItem" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
				select	distinct titem.item_code,
						titem.item_name, 
						titem.pricetype as pricetype,
						defaultdiscount as discount,
						titem.currency_id,
						titem.generate_flag,
						isnull(titem.labelout,0) as labelout,
						(select unit_name from taccunittype where unit_type_id = titem.unit_type_id) as unit_name,
						titemcompany.tax1,
						titemcompany.tax2,
						titem.unit_type_id,
						titemcompany.dimension_id,
						titemdimension.dimension_name,
						isnull((select moq from taccvendoritem a where a.vendor_id = '#cbocustomer#' and a.item_code =taccvendoritem.item_code),0) moq,
						titem.customfield1 as item_description,

						titem.item_color,
						tgscolor.color_name,
						titem.item_size,

						titem.item_length,
						titem.item_width,
						titem.item_height

				from titem
					inner join titemcompany on titem.item_code = titemcompany.item_code
	                inner join titemlocation on titemcompany.item_code = titemlocation.item_code and titemcompany.dimension_id = titemlocation.dimension_id 
    	            inner join titemdimension on titemdimension.dimension_id = titemcompany.dimension_id 
					inner join titemcategory on titemcategory.itemcategory_id = titemcompany.itemcategory_id
					left join taccvendoritem on taccvendoritem.item_code = titem.item_code
					left join tgscolor on tgscolor.color_code = titem.item_color

				where titemlocation.wh_id =#cookie.location_id# 
                	and titem.item_code in(
						select item_code from titemlocation where wh_id in 
						(select wh_id from taccwhlocation where company_id =  #qcustdetail.sistercompany#)
					)
					and titem.originalfrom <> 'production'
					and titemcompany.company_id = #cookie.companyid#

				<cfif extraquery neq "">
					<cfif #seltype# eq "itemcode">
						and titem.item_code like '%#extraquery#%'
					<cfelseif #seltype# eq "itemname">
						and titem.item_name like '%#extraquery#%'	
					<cfelseif #seltype# eq "type">
						and titem.customfield1 like '%#extraquery#%'	
					<cfelseif #seltype# eq "size">
						and cast(isnull(titem.item_length,0) as varchar) + ' x ' + cast(isnull(titem.item_width,0) as varchar) + ' x ' + cast(isnull(titem.item_height,0) as varchar) + ' mm' like '%#extraquery#%'	
					</cfif>
					<!--- and (titem.item_code like '%#extraquery#%' or titem.item_name like '%#extraquery#%' or titem.customfield1 like '%#extraquery#%') --->
				</cfif>
				<cfif selcategory neq "-1">
					<cfif listlen(lstcat) neq 0>
						and titemcompany.itemcategory_id in (#lstcat#)
					</cfif>
				</cfif>
				<cfif isdefined("rdomaster") and rdomaster eq 1>
					and titem.ismaster = 1
				<cfelseif isdefined("rdomaster") and rdomaster eq 0>
					and titem.ismaster = 0
				</cfif>
				<cfif isdefined("request.vauthitemfilter") and request.vauthitemfilter neq "">
					and	titem.item_code in (#preservesinglequotes(request.vauthitemfilter)#)
				</cfif>

					and (titem.inactive is null or titem.inactive = 0)
					and itemcategorytype = '#local.strcattype#' 
			</cfquery>
		<cfelse>
			<cfquery name="qItem" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
				select	distinct taccvendoritem.item_code,
						titem.item_name, 
						titem.pricetype as pricetype,
						defaultdiscount as discount,
						titem.currency_id,
						titem.itemclass,
						titem.item_size,
						titem.item_material,
						titem.generate_flag,
						isnull(titem.labelout, 0) as labelout,
						(select unit_name from taccunittype where unit_type_id = titem.unit_type_id) as unit_name,
						titemcompany.tax1,
						titemcompany.tax2,
						titem.unit_type_id,
						titemcompany.dimension_id,
						titemdimension.dimension_name,
						isnull(taccvendoritem.moq, 0) as moq,
						titem.customfield1 as item_description,
						titem.item_color,

						tgscolor.color_name,
						titem.item_size,
						titem.item_length,
						titem.item_width,
						titem.item_height

				from taccvendoritem
					inner join titem on taccvendoritem.item_code = titem.item_code
					inner join titemcompany on titem.item_code = titemcompany.item_code 
					inner join titemcategory on titemcategory.itemcategory_id = titemcompany.itemcategory_id				
					inner join titemdimension on titemdimension.dimension_id = titemcompany.dimension_id 
					left join tgscolor on tgscolor.color_code = titem.item_color

				where (titem.inactive is null or titem.inactive = 0)
					and titem.originalfrom <> 'production'
					<cfif isdefined("cbocustomer") and cbocustomer neq "">
					  and	taccvendoritem.vendor_id='#cbocustomer#'
					</cfif>

					<!---12-01-2023 update---->
					<cfif local.strcattype neq "FG">
						AND itemclass = 1
					</cfif>
					<!--- ----->
					<!---- and itemclass = 1 --->
					and isnull(titemcompany.company_id,0) = #cookie.companyid#
					and itemcategorytype = '#local.strcattype#'
					<cfif extraquery neq "">
						<cfif #seltype# eq "itemcode">
							and titem.item_code like '%#extraquery#%'
						<cfelseif #seltype# eq "itemname">
							and titem.item_name like '%#extraquery#%'	
						<cfelseif #seltype# eq "type">
							and titem.customfield1 like '%#extraquery#%'	
						<cfelseif #seltype# eq "size">
							and cast(isnull(titem.item_length,0) as varchar) + ' x ' + cast(isnull(titem.item_width,0) as varchar) + ' x ' + cast(isnull(titem.item_height,0) as varchar) + ' mm' like '%#extraquery#%'		
						</cfif>
					
						<!---and (titem.item_code like '%#extraquery#%' or item_name like '%#extraquery#%' or titem.customfield1 like '%#extraquery#%')--->
					</cfif>
					<cfif selcategory neq "-1">
						<cfif listlen(lstcat) neq 0>
							and titemcompany.itemcategory_id in (#lstcat#)
						</cfif>
					</cfif>
					<cfif isdefined("request.vauthitemfilter") and request.vauthitemfilter neq "">
						and	titem.item_code in (#preservesinglequotes(request.vauthitemfilter)#)
					</cfif>


					<cfif isdefined("rdomaster") and rdomaster eq 1>
						and titem.ismaster = 1
					<cfelseif isdefined("rdomaster") and rdomaster eq 0>
						and titem.ismaster = 0
					</cfif>
				<cfif (isdefined("cbocustomer") and trim(cbocustomer) neq "" and cbocustomer neq 0) >
					union (select titem.item_code, item_name, pricetype, defaultdiscount as discount, currency_id, itemclass, titem.item_size, titem.item_material, 
						titem.generate_flag ,isnull(titem.labelout,0) as labelout,
						(select unit_name from taccunittype where unit_type_id = titem.unit_type_id) as unit_name,titemcompany.tax1,titemcompany.tax2
					,titem.unit_type_id, titemcompany.dimension_id, titemdimension.dimension_name
          , isnull((select moq from taccvendoritem a where a.vendor_id = '#cbocustomer#' and a.item_code =taccvendoritem.item_code),0) moq
		  			,titem.customfield1 as item_description
					,titem.item_color
					,tgscolor.color_name
					,titem.item_size	
					,titem.item_length
					,titem.item_width
					,titem.item_height		
					from titem 
                    inner join titemcompany  on titemcompany.item_code = titem.item_code 
                    inner join titemcategory on titemcategory.itemcategory_id = titemcompany.itemcategory_id					
                    inner join titemdimension on titemdimension.dimension_id = titemcompany.dimension_id
					inner join titemlocation on titemcompany.item_code = titemlocation.item_code and titemcompany.dimension_id = titemlocation.dimension_id 
					left join taccvendoritem on taccvendoritem.item_code = titem.item_code
					left join tgscolor on tgscolor.color_code = titem.item_color
					where itemclass = 0 
					and titemlocation.wh_id = #cookie.location_id#
					and titemcategory.itemcategorytype = '#local.strcattype#'
					and #cookie.companyid# in (titemcompany.company_id) 
					<cfif extraquery neq "">
						<cfif #seltype# eq "itemcode">
							and titem.item_code like '%#extraquery#%'
						<cfelseif #seltype# eq "itemname">
							and titem.item_name like '%#extraquery#%'	
						<cfelseif #seltype# eq "type">
							and titem.customfield1 like '%#extraquery#%'	
						<cfelseif #seltype# eq "size">
							and cast(isnull(titem.item_length,0) as varchar) + ' x ' + cast(isnull(titem.item_width,0) as varchar) + ' x ' + cast(isnull(titem.item_height,0) as varchar) + ' mm' like '%#extraquery#%'	
						</cfif>
					
						<!---and (titem.item_code like '%#extraquery#%' or item_name like '%#extraquery#%' )--->
					</cfif>
					<cfif isdefined("rdomaster") and rdomaster eq 1>
						and titem.ismaster = 1
					<cfelseif isdefined("rdomaster") and rdomaster eq 0>
						and titem.ismaster = 0
					</cfif>
					<cfif isdefined("request.vauthitemfilter") and request.vauthitemfilter neq "">
						and	titem.item_code in (#preservesinglequotes(request.vauthitemfilter)#)
					</cfif>
					<cfif selcategory neq "-1">
						<cfif listlen(lstcat) neq 0>
							and titemcompany.itemcategory_id in (#lstcat#)
						</cfif>
					</cfif>
					and (titem.inactive is null or titem.inactive = 0)
					)
				</cfif>
			</cfquery> 
		</cfif>
	<cfelse>
		<cfquery name="qItem" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			Select 	Asset_code as item_code, 
					Asset_Desc as item_name,
					Asset_Cost as selling_Price,
					0 as Discount,
					2 as pricetype,
					currency_id,
					asset_cost,
					base_cost,
					0 as Generate_Flag, 
					0 as labelout,  
                    'N\A' as Unit_Name
					,asset_qty
                    ,1 AS Dimension_ID
                    ,'' AS Dimension_Name
					, ISNULL(TAccVendorItem.MOQ,0) MOQ
					, '' AS item_description
					,'' AS Item_Color
					,'' AS Color_Name
					,'' AS Item_Size	
					,0 AS Item_Length
					,0 AS Item_Width
					,0 AS Item_Height		
			From 	TAccAssetTemp
			LEFT JOIN TAccVendorItem ON TAccVendorItem.Item_code = TAccAssetTemp.asset_code
			Where 	TAccAssetTemp.company_id = #cookie.companyID#
			<!--- and account_id = '#CBOCUSTOMER#' --->
				and po_number is null
				
              <!--- 3AS BUG50412-55561  --->
                and TAccAssetTemp.Asset_Code not in (
                                     select Item_Code 
                                        from 
                                            TAccPO_Detail 
                                        inner join TaccPO_Header 
                                                on TaccPO_Detail.PO_Number = TaccPO_Header.PO_Number
                                        where
                                            TaccPO_Header.ItemCategoryType = 'AST'
                                        	and TaccPO_Header.Approval_Status <> 4
											and isNull(TAccPO_HEader.isClose,0) = 0
											and TAccPO_Header.isNotActive = 0
                                     Union
                                        select Item_Code 
                                        from TPPICPReq_Detail 
                                        inner join TPPICPReq_Header
                                                on TPPICPReq_Detail.Preq_id = TPPICPReq_Header.Preq_id
                                        where
                                            TPPICPReq_Header.ItemCategoryType = 'AST'
                                        and TPPICPReq_Header.ApprovalStatus <> 4
                                     Union
                                        select Item_Code 
                                        from TAccRFQ_Detail
                                        inner join TAccRFQ_Header
                                                on TAccRFQ_Detail.RFQ_Code = TAccRFQ_Header.RFQ_Code
                                        where
                                            TAccRFQ_Header.RFq_Category = 'AST'
                                        and isNULL(TAccRFQ_Header.Approval_Status,0) <> 4
                                        and TAccRFQ_Header.Rfq_type = 'Purchase'
                                     Union
                                        select Item_Code
                                        from TAccQuotation_detail
                                        inner join  TAccQuotation_Header
                                                on TAccQuotation_Header.Quotation_Number = TAccQuotation_detail.Quotation_Number
                                        where
                                            TAccQuotation_Header.Quotation_Type = 'Purchase'
                                        and TAccQuotation_Header.Quotation_Category = 'AST'
									Union
										select item_code
										from taccrr_header a
											inner join taccrr_item b on a.rr_number = b.rr_number
										where 
										<!--- yang sudah diapprove tapi blm void --->
											(
												isNull(a.isVoid,0) = 0 and a.approval_status = 3
											)
										<!--- yang belum direject dan belum diapprove --->
											OR (a.approval_status <> 4  AND a.approval_status <> 3)
                                       )
                
                <!---- END --->   
                
			<!--- b:added by angga 03/05/2012 : untuk BUG50412-56201 --->
				AND TACCAssetTemp.isProject <> 1 <!--- by request, asset yang di assign untuk project baru boleh muncul saat pembuatan new project --->
			<!--- e:added by angga 03/05/2012 : untuk BUG50412-56201 --->

			<cfif isdefined("cboCustomer") and (trim(cboCustomer) eq "" or cboCustomer eq 0) >
            	AND Account_id is NULL
            <cfelse>
            	AND IsNULL(Account_ID,#cboCustomer#) = #cboCustomer#
            </cfif>
			
			AND #cookie.companyID# in (TAccAssetTemp.Company_ID) 
			<cfif ExtraQuery neq "">
					<cfif #selType# eq "ItemCode">
						AND TAccAssetTemp.Asset_code LIKE '%#ExtraQuery#%'
					<cfelseif #selType# eq "ItemName">
						AND TAccAssetTemp.Asset_Desc LIKE '%#ExtraQuery#%'		
					<cfelseif #selType# eq "Type">
						AND Item_Description LIKE '%#ExtraQuery#%'	
					<cfelseif #selType# eq "Size">
						AND Cast(isnull(Item_Length,0) AS VARCHAR) + ' x ' + Cast(isnull(Item_Width,0) AS VARCHAR) + ' x ' + Cast(isnull(Item_Height,0) AS VARCHAR) + ' mm' LIKE '%#ExtraQuery#%'											
					</cfif>
					
				<!--- AND (TAccAssetTemp.Asset_code LIKE '%#ExtraQuery#%' OR TAccAssetTemp.Asset_Desc LIKE '%#ExtraQuery#%') --->
			</cfif>
			ORDER BY Asset_code
		</cfquery>
	</cfif>

<!--- Jika menu =sales --->

<cfelse>
	<cfif local.strCatType neq "AST">
		<cfquery name="qItemCat" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">	
			Select 	itemCategory_ID 
			From 	TItemcategory 
			Where 	itemCategoryType = '#local.strCatType#'
			AND #cookie.companyID# in (TItemcategory.Company_ID) 
		</cfquery>		
		
		<cfset lstitemCatID = valuelist(qItemCat.itemCategory_ID)>
	  	
		<cfquery name="qItem" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			SELECT <!--- TAccCustomerItem.item_code --->
					TITEM.item_code
					,TITEM.Item_name
					,TItem.pricetype as pricetype
					, DefaultDiscount as Discount
					,TITEM.currency_id
					,TITEM.ItemClass
					,Titem.DisplayHistory
					,Titem.RecordHistory, TITEM.Item_Size, TITEM.Item_Material
					,TITEM.generate_flag
					,isnull(Titem.labelout,0) as labelout
    	            ,(SELECT Unit_Name FROM TAccUnitType WHERE Unit_Type_ID = TItem.Unit_Type_ID) AS Unit_Name
					,TItem.unit_type_id
                    ,TItemCompany.Dimension_ID 
                    ,TitemDimension.Dimension_Name
					,0  MOQ
					,TItem.customfield1 AS item_description
					,TItem.Item_Color
					,tgscolor.Color_Name
					,TItem.Item_Size
					,TItem.Item_Length
					,TItem.Item_Width
					,TItem.Item_Height			
				FROM <!--- TAccCustomerItem --->TITEM
				<!--- INNER JOIN TITEM ON TAccCustomerItem.ITEM_CODE = TITEM.ITEM_CODE --->
                INNER JOIN TItemCompany  ON TItemCompany.item_code = TItem.item_code 
				INNER JOIN TitemCategory ON TitemCategory.ItemCategory_ID = TItemCompany.ItemCategory_ID
				--LEFT JOIN TAccVendorItem ON TAccVendorItem.Item_code = Titem.item_code
                INNER JOIN TItemDimension ON TItemDimension.Dimension_ID = TItemCompany.Dimension_ID 
				left JOIN tgscolor ON tgscolor.color_code = titem.item_color
			where (TItem.InActive is NULL Or TItem.InActive = 0) 
			AND TItemCompany.Company_ID = #cookie.companyID#
			<!--- AND	TAccCustomerItem.customer_ID='#cboCustomer#' --->
			<!---  AND	TITEM.item_code = '11320'  --->
			AND ItemCategoryType = '#local.strCatType#'
			and itemclass = 0
			<cfif ExtraQuery neq "">
				<cfif #selType# eq "ItemCode">
					AND TItem.Item_Code LIKE '%#ExtraQuery#%'
				<cfelseif #selType# eq "ItemName">
					AND TItem.Item_Name LIKE '%#ExtraQuery#%'	
				<cfelseif #selType# eq "Type">
					AND TItem.CustomField1 LIKE '%#ExtraQuery#%'	
				<cfelseif #selType# eq "Size">
					AND Cast(isnull(TItem.Item_Length,0) AS VARCHAR) + ' x ' + Cast(isnull(TItem.Item_Width,0) AS VARCHAR) + ' x ' + Cast(isnull(TItem.Item_Height,0) AS VARCHAR) + ' mm' LIKE '%#ExtraQuery#%'		
				</cfif>
				<!---AND (TItem.Item_Code LIKE '%#ExtraQuery#%' OR Item_name LIKE '%#ExtraQuery#%' )--->
			</cfif>
			<cfif IsDefined("REQUEST.vauthitemfilter") AND REQUEST.vauthitemfilter neq "">
						AND	Titem.item_code IN (#preservesinglequotes(REQUEST.vauthitemfilter)#)
					</cfif>
			<cfif selcategory neq "-1">
				<cfif ListLen(lstCat) neq 0>
					AND TItemCompany.ItemCategory_Id IN (#lstCat#)
				</cfif>
			</cfif>
			<cfif isDefined("rdoMaster") and rdoMaster eq 1>
				and tItem.isMaster = 1
			<cfelseif isDefined("rdoMaster") and rdoMaster eq 0>
				and tItem.isMaster = 0
			</cfif>
			<cfif (isdefined("cboCustomer") and trim(cboCustomer) neq "" and cboCustomer neq 0)>
				union ( select TITEM.item_code, item_name, pricetype, defaultdiscount as discount, currency_id, 
					Itemclass,DisplayHistory,RecordHistory, TITEM.Item_Size, TITEM.Item_Material, TITEM.generate_flag,isnull(Titem.labelout,0) as labelout
					,(SELECT Unit_Description FROM TAccUnitType WHERE Unit_Type_ID = TItem.Unit_Type_ID) AS Unit_Name
                    
					,TItem.unit_type_id,TItemCompany.Dimension_ID,TitemDimension.Dimension_Name, 0 MOQ
					,TItem.customfield1 AS item_description
					,TItem.Item_Color
					,tgscolor.Color_Name
					,TItem.Item_Size	
					,TItem.Item_Length
					,TItem.Item_Width
					,TItem.Item_Height		
				from titem 
                    INNER JOIN TItemCompany  ON TItemCompany.item_code = TItem.item_code 
                    INNER JOIN TitemCategory ON TitemCategory.ItemCategory_ID = TItemCompany.ItemCategory_ID					
                    INNER JOIN TItemDimension ON TItemDimension.Dimension_ID = TItemCompany.Dimension_ID 
					INNER JOIN TItemLocation ON TItem.item_code = TItemLocation.item_code AND TItemCompany.Dimension_ID = TItemLocation.Dimension_ID 
					INNER JOIN tacccustomeritem on titem.item_code = tacccustomeritem.item_code
					--LEFT JOIN TAccVendorItem ON TAccVendorItem.Item_code = Titem.item_code
					left JOIN tgscolor ON tgscolor.color_code = titem.item_color
				where TItemLocation.wh_id = #COOKIE.LOCATION_ID#
				AND tacccustomeritem.customer_id = #trim(cboCustomer)#
				AND TitemCategory.ItemCategoryType = '#local.strCatType#'
				AND #cookie.companyID# in (TItemCompany.Company_ID)
				 and (TItem.InActive is NULL Or TItem.InActive = 0)  
				<cfif ExtraQuery neq "">
					<cfif #selType# eq "ItemCode">
						AND TItem.Item_Code LIKE '%#ExtraQuery#%'
					<cfelseif #selType# eq "ItemName">
						AND TItem.Item_Name LIKE '%#ExtraQuery#%'	
					<cfelseif #selType# eq "Type">
						AND TItem.CustomField1 LIKE '%#ExtraQuery#%'	
					<cfelseif #selType# eq "Size">
						AND Cast(isnull(TItem.Item_Length,0) AS VARCHAR) + ' x ' + Cast(isnull(TItem.Item_Width,0) AS VARCHAR) + ' x ' + Cast(isnull(TItem.Item_Height,0) AS VARCHAR) + ' mm' LIKE '%#ExtraQuery#%'	
					</cfif>
						
					<!--- AND (TItem.Item_Code LIKE '%#ExtraQuery#%' OR Item_name LIKE '%#ExtraQuery#%' ) --->
				</cfif>
				<cfif IsDefined("REQUEST.vauthitemfilter") AND REQUEST.vauthitemfilter neq "">
						AND	Titem.item_code IN (#preservesinglequotes(REQUEST.vauthitemfilter)#)
					</cfif>
				<cfif isDefined("rdoMaster") and rdoMaster eq 1>
					and tItem.isMaster = 1
				<cfelseif isDefined("rdoMaster") and rdoMaster eq 0>
					and tItem.isMaster = 0
				</cfif>
				<cfif selcategory neq "-1">
					<cfif ListLen(lstCat) neq 0>
						AND TItemCompany.ItemCategory_Id IN (#lstCat#)
					</cfif>
				</cfif>
				)						
			</cfif>	
		</cfquery>
	<cfelse>
		<cfif isDefined ("form.cboCustomer")>
			<cfquery name="qItem" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
				Select 	Asset_code as item_code, 
						Asset_Desc as item_name,
						Asset_Cost as pricetype,
						asset_cost,
						0 as Discount,
						currency_id,
                        'N/A' as Unit_Name,
						0 AS generate_flag,
						0 as labelout, 
                        1 AS Dimension_ID, 
                        '' AS Dimension_Name
						,0  MOQ
						, '' AS item_description
						,'' AS Item_Color
						,'' AS Color_Name
						,'' AS Item_Size
						,0 AS Item_Length
						,0 AS Item_Width
						,0 AS Item_Height		
				From 	TAccAssetInventory
				--LEFT JOIN TAccVendorItem ON TAccVendorItem.Item_code = TAccAssetInventory.asset_code
				Where 	#cookie.companyID# in (TAccAssetInventory.company_id)
				And 	Asset_Status = 'active'
               
				<cfif ExtraQuery neq "">
					<cfif #selType# eq "ItemCode">
						AND Item_Code LIKE '%#ExtraQuery#%'
					<cfelseif #selType# eq "ItemName">
						AND Item_Name LIKE '%#ExtraQuery#%'	
					<cfelseif #selType# eq "Type">
						AND Item_Description LIKE '%#ExtraQuery#%'	
					<cfelseif #selType# eq "Size">
						AND Cast(isnull(Item_Length,0) AS VARCHAR) + ' x ' + Cast(isnull(Item_Width,0) AS VARCHAR) + ' x ' + Cast(isnull(Item_Height,0) AS VARCHAR) + ' mm' LIKE '%#ExtraQuery#%'									
					</cfif>
					<!---AND (Item_Code LIKE '%#ExtraQuery#%' OR Item_name LIKE '%#ExtraQuery#%' )--->
				</cfif>
				ORDER BY item_name
			</cfquery>
		<cfelse>
			<cfquery name="qItem" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
				Select 	Asset_code as item_code, 
						Asset_Desc as item_name,
						Asset_Cost as pricetype,
						asset_cost,
						0 as Discount,
						currency_id,
                        'N/A' as Unit_Name,
						0 AS generate_flag, 
                        1 AS Dimension_ID, 
                        '' AS Dimension_Name
						,0  MOQ
						, '' AS item_description
						,'' AS item_color
						,'' AS Color_Name
						,'' AS Item_Size
						,0 AS Item_Length
						,0 AS Item_Width
						,0 AS Item_Height		
				From 	TAccAssetInventory
				--LEFT JOIN TAccVendorItem ON TAccVendorItem.Item_code = TAccAssetInventory.asset_code
				Where 	#cookie.companyID# in (TAccAssetInventory.company_id)
				And 	Asset_Status = 'sss'
				<cfif ExtraQuery neq "">
					<cfif #selType# eq "ItemCode">
						AND Item_Code LIKE '%#ExtraQuery#%'
					<cfelseif #selType# eq "ItemName">
						AND Item_Name LIKE '%#ExtraQuery#%'	
					<cfelseif #selType# eq "Type">
						AND Item_Description LIKE '%#ExtraQuery#%'	
					<cfelseif #selType# eq "Size">
						AND Cast(isnull(Item_Length,0) AS VARCHAR) + ' x ' + Cast(isnull(Item_Width,0) AS VARCHAR) + ' x ' + Cast(isnull(Item_Height,0) AS VARCHAR) + ' mm' LIKE '%#ExtraQuery#%'			
					</cfif>
					<!---AND (Item_Code LIKE '%#ExtraQuery#%' OR Item_name LIKE '%#ExtraQuery#%' )--->
				</cfif>
				ORDER BY item_name
			</cfquery>
		</cfif>
	</cfif>
</cfif>

<cfset TotalPage = Ceiling(qItem.recordCount / varMaxRows)>
<cfif selPage gt 1> 

	<cfset StartRow = ((selPage-1)*varMaxRows) + 1>
<cfelse>
	<cfset StartRow = 1	>
</cfif>
<!---<cfif isdefined("EXTRAQUERY") and EXTRAQUERY neq "">
    <cfset StartRow = 1	>
</cfif>--->
<cfset EndRow = StartRow+varMaxRows-1>
<cfif EndRow gt qItem.RecordCount>
	<cfset EndRow = qItem.RecordCount>
</cfif>
<script>
var arrNewPop = new Array();
var arrNewPop2 = new Array();
var arrNewPop3 = new Array();
</script>
 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>#DO_VAR['ListofItem']#</title>
</head>

	<style>
		a { text-decoration:none; color:000066 }

		a:hover { text-decoration: underline; color: CC0000 }
	</style>
<script>
function SetAll(chkList, chkAll){ 
	if(chkList != null){
		if(chkList.length!=null) for(i=0; i<chkList.length; i++) chkList[i].checked = chkAll.checked
		else chkList.checked=chkAll.checked
	}
}

function tickItem(thisChk,allChk,idt){
	var theChk = thisChk.form.chkItem;
	var len = theChk.length;
	var x = 0;
	var refsub=null;
	if(theChk != null){
		if(len != null){
			var ceksub=null;
			for(i=0; i<len; i++){
				if (i > idt && ceksub==null) {
					ceksub=true;
					refsub=i-1;
				}
				if (ceksub) {
					if (theChk[i].disabled)
						theChk[i].checked=theChk[refsub].checked;
					else {
						ceksub=false;
					}
				}
				if(theChk[i].checked) x++;
			}
			allChk.checked = (x >= len);
		}
		else allChk.checked = theChk.checked;
	}
}

function pick(ItCd, ItName, ItUntPrice) {
	if (opener != null){
		opfrm = opener.document.frmNew;
		eval("opfrm.txtPartNo#idx#").value				= ItCd;
		eval("opfrm.txtDesc#idx#").value				= ItName;
		eval("opfrm.txtPartNoMisc"+idx).value			= eval("document.frmSearch.txtPartNoMisc"+i).value;
		eval("opfrm.txtDescMisc"+idx).value				= eval("document.frmSearch.txtDescMisc"+i).value;
		eval("opfrm.txtDimensionNameMisc"+idx).value	= eval("document.frmSearch.txtDimensionNameMisc"+i).value;
		eval("opfrm.txtDimensionIDMisc"+idx).value		= eval("document.frmSearch.txtDimensionIDMisc"+i).value;
	}

	self.close();
}

function deletecommaperiod(str,type) {
	var A = new Array();
	if ((type=="both") || (type=="comma"))
	{	
		A = str.split(",");
		str = A.join("");
	}
	if ((type=="both") || (type=="period"))
	{
		A = str.split(".");	
		str = A.join("");
	}
	return str;
}
		
function decimalin(ini){
	bil2 = deletecommaperiod(ini.value,'both')
	bil3 = "" 
	j = 0
	for (i=bil2.length-1;i>=0;i--)
	{
		j = j + 1;
		//if (j == 3)
		if (j == '#(Application.stApp.decimaL_range[VST_IDX]+1)#')
		{
			bil3 = "." + bil3
		}
		//else if ((j >= 9) && ((j % 3) == 0))
		else if( (j>='#4+Application.stApp.decimaL_range[VST_IDX]#') && ( ((j-('#Application.stApp.decimaL_range[VST_IDX]#'-2))%3) == 0) )
		{
			if (i!=0 || bil2.charAt(i) != '-')
			{		
				bil3 = "," + bil3
			}	
		}
		bil3 = bil2.charAt(i) + "" + bil3 ;
	}
	ini.value = bil3 ;
}
	
function predecimalin(ini){
	if(ini != null){
		if (ini.value.indexOf('.') >= 0) { // bukan bilangan bulat
			if (ini.value.length - ini.value.indexOf('.') == '#Application.stApp.decimaL_range[VST_IDX]#') { // berarti ada satu angka di belakang titik desimal
				ini.value = ini.value + "0"
				decimalin(ini)
			}	
			else {
				decimalin(ini)
			}	
		}
		else { // bilangan bulat
			ini.value = ini.value + "#repeatString('0',Application.stApp.decimaL_range[VST_IDX])#";
			decimalin(ini)
		}
	}
}
function getppath(prt,idx) {
	var vpath=prt;
	for (var i=idx;idx>0;idx--) {
		var elm=eval("opener.document.frmNew.txtPartNo"+i);
		if (elm!=null && elm.value==prt) {
			elm=eval("opener.document.frmNew.parent_path"+i);
			if (elm!=null)
				vpath=elm.value+","+prt;
			break;
		}
	}
	return vpath;
}
</script>


<body onLoad="self.focus();" onUnload="doCloseChild(arrNewPop3);">
<form method="post" name="frmSearch" action="">
<!--- andiJ. 05apr'10, vendor grouping --->
<cfif local.strPricingType eq "Purchase">
	<cfquery name="qGrpAll" datasource="#IIF(isDefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
		SELECT account_id, accounttitle_code, account_name, groupid_vendor
		FROM TAccount
		ORDER BY groupid_vendor
	</cfquery>
	
	<cfloop query="qCustomer">
<!--- 		<cfquery datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#" name="qGrp">
			SELECT Account_ID, Account_Name
			FROM TAccount
			WHERE GroupID_Vendor = #qCustomer.GroupID_Vendor#
		</cfquery> --->
		<cfquery name="qGrp" dbtype="query" cachedwithin="#CreateTimeSpan(0,0,0,10)#">
			SELECT Account_ID, Account_Name, accounttitle_code
			FROM qGrpAll
			WHERE GroupID_Vendor = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#qCustomer.GroupID_Vendor#">
		</cfquery>
				
		<cfset LstVenGrp = "">
		<cfif qCustomer.GroupID_Vendor neq 0>
			<cfloop query="qGrp">
				<cfif Len(Trim(qGrp.accounttitle_code)) gt 0>
					<cfset LstVenGrp = ListAppend(LstVenGrp, "#qGrp.Account_ID#|#qGrp.accounttitle_code#. #qGrp.Account_Name#", ",")>
				<cfelse>
					<cfset LstVenGrp = ListAppend(LstVenGrp, "#qGrp.Account_ID#|#qGrp.accounttitle_code# #qGrp.Account_Name#", ",")>	
				</cfif>	
			</cfloop>
        <cfelse>
			<cfif Len(Trim(qGrp.accounttitle_code)) gt 0>
				<cfset LstVenGrp = ListAppend(LstVenGrp, "#qCustomer.Account_ID#|#qGrp.accounttitle_code#.  #qCustomer.Account_Name#", ",")>
			<cfelse>
				<cfset LstVenGrp = ListAppend(LstVenGrp, "#qCustomer.Account_ID#|#qGrp.accounttitle_code#  #qCustomer.Account_Name#", ",")>
			</cfif>	           
		</cfif>
		<input type="hidden" name="txtVenGrp_#qCustomer.Account_ID#" value="#LstVenGrp#">
	</cfloop>
</cfif>
<!--- end --->
<table width="100%" class="formtitle" border="0" cellspacing="1" cellpadding="1">
<!--- randytia 08-02-2010 set discount customer --->
<cfif qDiscount.recordCount>
	<input type="Hidden" name="disc_acc" value="#qDiscount.persen#">
</cfif>
<!--- End --->
<input type="Hidden" name="txtTerms" value="#HTMLEditFormat(qCustDetail.PaymentTerms)#">
<input type="Hidden" name="txtTermsdate" value="#HTMLEditFormat(qCustDetail.PaymentTerm)#">
<input type="Hidden" name="hdnBZ" value="#qCustDetail.kawasanberikat#">
<input type="Hidden" name="hdnDiscountId" value="#qDiscount.disc_id#">
<input type="Hidden" name="hdnAccName" value="#HTMLEditFormat(qCustDetail.Account_Name)#">
<input type="Hidden" name="hdnAccCode" value="#HTMLEditFormat(qCustDetail.Account_ID)#">
<input type="Hidden" name="hdnAccAddr" value="#HTMLEditFormat(qCustDetail.Addr)#">
<input type="Hidden" name="hdnAccCurr" value="#HTMLEditFormat(qCustDetail.Account_CurrencyID)#">
<input type="hidden" name="hdnTermTax" value="#qFindTermTax.Tax_Code#|#qFindTermTax.Tax_Rate#|#qFindTermTax.Tax_Operator#">
<input type="hidden" name="hdnUseTax" value="#qFindTermTax.Use_Tax_ID#">
<input type="hidden" name="hdnTypePayment" value="#qFindTermTax.TypeTerm_Id#">
<cfif local.strPricingType eq "sales">
<input type="Hidden" name="hdnSalesName" value="#qCustDetail.salesname#">
<input type="Hidden" name="hdnSalesCode" value="#qCustDetail.salescode#">
<input type="hidden" name="selCatType" value="#local.strCatType#">

</cfif>
<tr>
  <td>&nbsp;#DO_VAR["ListofItem"]#</td>
</tr>
<cfif local.strErrMsg NEQ "">
<tr>
  <td>
    <table class="formbody" cellspacing="0" cellpadding="0" width="100%" border="0">
      <tr class="formtext">
        <td nowrap>#objDummy.cferror(ErrorText: local.strErrMsg, btnBack: false, btnClose: true, cfabort: false)#</td>
      </tr>
    </table>
  </td>
</tr>
<cfelse>
<tr>
    <td width="100%" >
		<table class="formbody" cellspacing="0" cellpadding="0" width="100%" border="0">
		<tr>
			  <td nowrap>
			  <table width="100%">
					<tr class="formText" style="height:25">
						<td width="20%" nowrap>
							<!---Modified by Rondi, 05 Dec 2007--->
							<cfif (local.strPricingType eq "purchase")>
								#DO_VAR['Vendor']# *
							<cfelse>
								#DO_VAR['Customer']# *
							</cfif> 
						</td>
						<cfif SOURCE eq "SO-QO">
                        	<cfparam name="dtmValue"  default="#DateFormat(now(),'mm/dd/yyyy')#">
                            <cfquery name="qFindTermCust" datasource="#REQUEST.DSN#">
                                SELECT	balance_due_Days, Term_type
                                FROM	TAccTermsDefault
                                Join TAccTermOfPayment_Header th On th.top_code = TAccTermsDefault.typeterm_id
                                WHERE	TAccTermsDefault.Company_ID = #cookie.companyid#
                                AND		TAccTermsDefault.Account_ID = '#cbocustomer#'
                                AND		TAccTermsDefault.Default_Type = 'sales'
                            </cfquery>
                            <cfif qFindTermCust.recordCount>
                                <cfif IsDefined("date")>
                                    <cfset dateValue = DateFormat(date,"mm/dd/yyyy")>
                                <cfelse>
                                    <cfset dateValue = #DateFormat(now(),"mm/dd/yyyy")#>
                                </cfif>
                                <cfif qFindTermCust.Term_type eq "monthly">
                                    <cfset dtmValue = DateFormat(DateAdd("m",1,dateValue),"mm/dd/yyyy")>
                                <cfelseif qFindTermCust.Term_type eq "daily">
                                    <cfset dtmValue = DateFormat(DateAdd("d",val(qFindTermCust.balance_due_Days),dateValue),"mm/dd/yyyy")>
                                </cfif>
                            </cfif>
                            <input type="hidden" name="hdnDueDate" value="#dtmValue#">
                        </cfif>
						<td width="2">&nbsp;:&nbsp;</td>
						<td>
						<cfif (local.strPricingType eq "purchase") and (isDefined("selRFQ") and (selRFQ NEQ 0 && selRFQ NEQ ""))>
							<cfquery name="qCustomer2" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
								select	TAccount.AccountTitle_Code,
										TAccount.account_name
								from 	TAccount
								where account_id ='#cboCustomer#'	
							</cfquery>
							<cfif Len(Trim(qCustomer2.AccountTitle_Code)) gt 0>#qCustomer2.accounttitle_code#.</cfif> #qCustomer2.account_name#
						 	<input type="hidden" name="cboCustomer" id="cboCustomer" value="#CBOCUSTOMER#">
                            
                        <!--- randytia	26-07-2010 --->
						<cfelseif (local.strPricingType eq "sales") and (selRFQ eq "SORFQ")>
                        	<cfif IntroNo neq "0" And IntroNo neq "">
                                <cfquery name="qCustomer2" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
									select	TAccount.AccountTitle_Code,
											TAccount.account_name
									from 	TAccount
                                    where account_id ='#cboCustomer#'	
                                </cfquery>
                                <cfif Len(Trim(qCustomer2.AccountTitle_Code)) gt 0>#qCustomer2.accounttitle_code#.</cfif> #qCustomer2.account_name#
                                <input type="hidden" name="cboCustomer" id="cboCustomer" value="#CBOCUSTOMER#">
                             <cfelse>
                                <!--- #txtCustCode# --->
								<select id="cboCustomer" name="cboCustomer" class="input" onChange="refresh();" <cfif URL.cboCustomer NEQ "">disabled</cfif>>
		                			<option value="" <cfif cboCustomer eq "">SELECTED</cfif>>
										<cfif (local.strPricingType eq "purchase")>
											-- #DO_VAR['SelectSupplier']# --
										<cfelse>
											-- #DO_VAR['SelectCustomer']# --
										</cfif>
									</option>
                                    <cfloop query="qCustomer">
                                        <option value="#account_id#" <cfif cboCustomer eq account_id>selected</cfif>><cfif Len(Trim(accounttitle_code)) gt 0>#accounttitle_code#.<cfelse>#accounttitle_code#</cfif> #account_name# [#trim(account_code)#] <cfif local.strPricingType eq "sales" and val(isOutlet) eq 1> - #DO_VAR["Outlet"]#</cfif>
                                    </cfloop>
								</select>
                             </cfif>
                        <!--- End --->
                        
                        <cfelseif (local.strPricingType eq "purchase") and isDefined("preq") and (preq neq 0 && preq neq "")>
							<cfquery name="qCustomer2" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
								select	TAccount.AccountTitle_Code,
										TAccount.account_name
								from 	TAccount
								where account_id ='#cboCustomer#'	
							</cfquery>
							<cfif Len(Trim(qCustomer2.accounttitle_code)) gt 0>#qCustomer2.accounttitle_code#.<cfelse>#qCustomer2.accounttitle_code#</cfif> #qCustomer2.account_name#
							<input type="hidden" name="cboCustomer" id="cboCustomer" value="#CBOCUSTOMER#">
						<cfelseif isDefined("Source") and Source eq "SO">
						#txtCustCode#
						<!--- <cfif isDefined("URL.cboCustomer") AND isValid("numeric",URL.cboCustomer)>disabled</cfif> ---><!--- IND, jika sudah di pilih sebelumnya, maka tidak boleh di pilih ulang - HPG --->
		                	<select id="cboCustomer" name="cboCustomer" class="input"  onchange="refresh();" <cfif URL.cboCustomer NEQ "">disabled</cfif>>
		                	<option value="" <cfif cboCustomer eq "">SELECTED</cfif>>
								<!---Modified by Rondi, 05 Dec 2007--->
								<cfif (local.strPricingType eq "purchase")>
								-- #DO_VAR['SelectSupplier']# --
								<cfelse>
								-- #DO_VAR['SelectCustomer']# --
								</cfif>
								</option>
						   <cfloop query="qCustomer">
								<option value="#account_id#" <cfif cboCustomer eq account_id>selected</cfif>><cfif Len(Trim(accounttitle_code)) gt 0>#accounttitle_code#.<cfelse>#accounttitle_code#</cfif> #account_name# [#trim(account_code)#] <cfif local.strPricingType eq "sales" and val(isOutlet) eq 1> - #DO_VAR["Outlet"]#</cfif>
						   </cfloop>
							</select>
						<cfelse>
							<!--- <cfif isDefined("URL.cboCustomer") AND isValid("numeric",URL.cboCustomer)>disabled</cfif> ---><!--- IND, jika sudah di pilih sebelumnya, maka tidak boleh di pilih ulang - HPG --->
		                	<select id="cboCustomer" name="cboCustomer" class="input"  onchange="refresh();" <cfif URL.cboCustomer NEQ "">disabled</cfif>>
		                	<option value="" <cfif cboCustomer eq "">SELECTED</cfif>>
								<!---Modified by Rondi, 05 Dec 2007--->
								<cfif (local.strPricingType eq "purchase")>
								-- #DO_VAR['SelectSupplier']# --
								<cfelse>
								-- #DO_VAR['SelectCustomer']# --
								</cfif>
								</option>
						   <cfloop query="qCustomer">
								<option value="#account_id#" <cfif cboCustomer eq account_id>selected</cfif>><cfif Len(Trim(accounttitle_code)) gt 0>#accounttitle_code#.<cfelse>#accounttitle_code#</cfif> #account_name# [#trim(account_code)#] <cfif local.strPricingType eq "sales" and val(isOutlet) eq 1> - #DO_VAR["Outlet"]#</cfif>
						   </cfloop>
							</select>
                        </cfif>
						
						<cfif isdefined("source") and source eq "so">
							<input type="hidden" name="isOutlet" value="#isOutlet#">
							<input type="hidden" name="outlet_wh" value="#outlet_wh#">
						</cfif> 
						
						<cfquery name="qselectedAccount" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
								select isnull(groupID,0) as groupID,
								isnull(GroupID_Vendor,0) as GroupID_Vendor
								,account_name
								from taccount
								where account_id ='#cboCustomer#'
							</cfquery>
								
							<cfif source eq "SO">
								<cfset accountgroup="">
								<cfif val(qselectedAccount.groupID) eq" 0">
									<cfset accountgroup="#cboCustomer#~#qselectedAccount.account_name#">
								<cfelse>
									<cfquery name="qAccount" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
										select account_ID,account_name
										from taccount
										where GroupID IN (
											select isnull(GroupID,0) as GroupID
											from taccount
											where account_id ='#cboCustomer#'	
										)
									</cfquery>
									<cfloop query="qAccount">
										<cfset accountgroup=listappend(accountgroup,"#qAccount.account_ID#~#qAccount.account_name#",";")>
									</cfloop>
								</cfif>
							<cfelseif source eq "PO">
							 	<cfset accountgroup="">
								<cfif val(qselectedAccount.GroupID_Vendor) eq "0">
									<cfset accountgroup="#cboCustomer#~#qselectedAccount.account_name#">
								<cfelse>
									<cfquery name="qAccount" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
										select account_ID,account_name
										from taccount
										where GroupID_Vendor IN (
											select isnull(GroupID_Vendor,0) as GroupID_Vendor
											from taccount
											where account_id ='#cboCustomer#'	
										)
									</cfquery>
									<cfloop query="qAccount">
										<cfset accountgroup=listappend(accountgroup,"#qAccount.account_ID#~#qAccount.account_name#",";")>
									</cfloop>
								</cfif>
							</cfif>
                            
                            <cfset lstSister="">
                            
							<cfif isDefined("Source") and Source eq "PO" and qcustdetail.isSisterCompany eq "1" and qcustdetail.SisterCompany neq 0> <font color="red"><i>[#DO_VAR["SisterCompanyTransaction"]#]</i> </font>
                              <cfquery name="qSister" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                SELECT 
                                  WH_ID
                                  , WH_Name 
                                FROM 
                                  TAccWHLocation
                                WHERE 

                                  Company_ID = '#qCustdetail.SisterCompany#'
                              </cfquery>
                              
                              <cfloop query="qSister">
                                <cfset lstsister=listappend(lstsister,"#wh_id#~#wh_name#",";")>
                              </cfloop>
                              
                              <input type="hidden" name="hdnIsSisterCompany" id="hdnIsSisterCompany" value="#qcustdetail.isSisterCompany#" />
                              <input type="hidden" name="hdnSisterCompany" id="hdnSisterCompany" value="#qcustdetail.SisterCompany#" />
                              <input type="hidden" name="hdnLstSisterCompany" id="hdnLstSisterCompany" value="#lstsister#" />
                            <cfelseif isDefined("Source") and Source eq "PO" and val(qcustdetail.isSisterCompany) IS 0>
                              <input type="hidden" name="hdnIsSisterCompany" id="hdnIsSisterCompany" value="" />
                              <input type="hidden" name="hdnSisterCompany" id="hdnSisterCompany" value="" />
                              <input type="hidden" name="hdnLstSisterCompany" id="hdnLstSisterCompany" value="#lstsister#" />
                            </cfif>
							
						<CF_DO_V30_AUTH_TOMBOL paramButtonName="btnNotes" granted="granted">
						<cfparam name="isTAX" default="normal">
						<cfparam name="menuparam" default="sales">
						<cfset menuparam = local.strPricingType />

						<input type="Hidden" name="hdnAccGroup" value="#accountgroup#">
						<input type="Hidden" name="hdnEmpList" value="<cfif val(qSetting.salesPerson) neq '1'>#emp_list#</cfif>">
							<!--- <a href="javascript:void(0)" onClick="showNotes('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate#/#varQueryString#&menu=#menuparam#&edit=1&isTax=#isTax#')">#Do_Var['show']# #Do_Var['note']#</a> --->
						</td>
					</tr>
					
					<!---  <cfif isDefined("form.cboCP") and source eq "Direct_SN">--->
					<cfif isDefined("Source") and source eq "Direct_SN">
						<tr class="formText">
							<td nowrap width="20%" >#DO_VAR['SalesOrder']# </td>
							<td width="2">&nbsp;:&nbsp;</td>
							<td>
								<select name="selSO" class="input">
								  <cfif qSalesOrder.recordCount gt 0>
								  				<option value="0">Without Sales Order</option>
									  <cfloop query="qSalesOrder">
									  		  <option value="#SO_Number#" <cfif selSo eq "#SO_Number#">selected</cfif>>#qSalesOrder.SO_Number#</option>
									  </cfloop>
									<cfelse>
										<option value="0">-#DO_VAR['NoRecord']#-</option>
								  </cfif>
								</select>
							</td>
						</tr>
					</cfif>
					<!--- modified by RF, 4 dec 2007 --->
					<!--- <cfif isDefined("Source") and Source neq "PO" and (isDefined("Source") and Source neq "PO-RFQ")> --->
					<cfif isDefined("form.cboCP") and source eq "PO-QO" or source eq "SO" or source eq "SO-QO" or source eq "Direct_SN" or source eq "RFQ">
						<tr class="formText">
							<td nowrap width="20%" >#DO_VAR['ContactPerson']#*</td>
							<td width="2">&nbsp;:&nbsp;</td>
							<td>
								<select name="cboCP" class="input" onChange="setThisValue(this.value, 1);">
								  <cfif qCP.recordCount>
									  <cfloop query="qCP">
                                        	<option value="#Contact_ID#|#Contact_FirstName# #Contact_MiddleName# #Contact_LastName#|#Addr#" <cfif (cboCP eq Contact_ID or cboCP eq "#Contact_ID#|#Contact_FirstName# #Contact_MiddleName# #Contact_LastName#|#Addr#") And IntroNo eq "">selected</cfif>>#Contact_FirstName# #Contact_MiddleName# #Contact_LastName#   
									  </cfloop>
									<cfelse>
										<option value="0|0">-#DO_VAR['NoRecord']#-
								  </cfif>
								</select>
								<!--- &nbsp;<input type="hidden" name="txtcustcode" class="input" size="10" onkeypress="caricust();" value="#txtcustcode#"> --->
							</td>
						</tr>
					</cfif>
                    
					<tr class="formText">
						<td nowrap width="20%">#DO_VAR['Category']# *</td>
						<td width="2">&nbsp;:&nbsp;</td>
						<td>
							<select name="selcategory" onChange="refresh();">
								<option value="-1">--------- #DO_VAR["ALL"]# ---------
				                <cfloop query="qCategory">
								<CF_DO_V25_ACCCATEGORY_TREE ITEMCATEGORY_ID="#qCategory.ItemCategory_ID#" QUERY_NAME="qQueryfolderB" ALLCHILD="1">
									<cfloop query="qQueryfolderB">
					                    <option value="#ItemCategory_ID#" <cfif selcategory eq ItemCategory_id>SELECTED</cfif>>#RepeatString("&nbsp;", (depth)*(3))##ItemCategory_Name#</option>
					                </cfloop>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr class="formText">
						<td nowrap width="20%">#DO_VAR['SearchText']# *</td>
						<td width="2">&nbsp;:&nbsp;</td>
						<td>
							<!--- Custom for Samick --->
							<select id="selType" name="selType">
								<option value="ItemCode" <cfif #selType# eq "ItemCode">selected</cfif>>#DO_VAR['ItemCode']#
								<option value="ItemName" <cfif #selType# eq "ItemName">selected</cfif>>#DO_VAR['ItemName']#
								<option value="Type" <cfif #selType# eq "Type">selected</cfif>>#DO_VAR['eHRMType']#
								<option value="Size" <cfif #selType# eq "Size">selected</cfif>>#DO_VAR['Size']#
							</select>
							<!--- end --->							
							<input type="Text" name="ExtraQuery" value="#ExtraQuery#">
							<input type="Button" value="#DO_VAR["Search"]#" onClick="document.forms[0].selPage.value = 1;refresh();">
							<cfif source eq "RFQ">					
							<a href="javascript://" onClick="arrNewPop[arrNewPop.length]=PopWindow('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/sales/so/forms/newitem.cfm?selCatType=#local.strCatType#&source=RFQ&menu=sales','Preview','800','600','scrollbars=yes,status=yes,resizable=yes');" style="text-decoration:none;">
								[<em>Add New Item Master</em>]
							</a>
							</cfif>
						</td>
					</tr>
					<tr class="formText">
						<td nowrap width="20%">#DO_VAR['Filter']# &nbsp; #DO_VAR['ItemType']#</td>
						<td width="2">&nbsp;:&nbsp;</td>
						<td>
							<input type="radio" name="rdoMaster" value="1" onClick="document.forms[0].selPage.value = 1;refresh();" <cfif isDefined("rdoMaster") and rdoMaster eq 1>checked</cfif>>#DO_VAR['Master']#
							<input type="radio" name="rdoMaster" value="0" onClick="document.forms[0].selPage.value = 1;refresh();" <cfif isDefined("rdoMaster") and rdoMaster eq 0>checked</cfif>>#DO_VAR['Transaction']#
							<input type="radio" name="rdoMaster" value="2" onClick="document.forms[0].selPage.value = 1;refresh();" <cfif isDefined("rdoMaster") and rdoMaster eq 2>checked</cfif>>#DO_VAR['All']#						
						</td>
					</tr>
					<tr><td>&nbsp;</td></tr>
					<tr>
						<td>&nbsp;</td>
					</tr>

				 <tr>
				  	<td>&nbsp;</td>
					<td colspan="2">
						<fieldset name="1" style="display:none"><legend>#DO_VAR["CurrencyConverter"]#</legend>
						 	<table width="50%" style="display: none;" cellpadding="4" cellspacing="1" class="formbody" border="0">
								<cfif qCurrency.recordcount>
									<cfloop query="qCurrency">
										<cfif qCurrency.currency_id neq cookie.currencyid>
											 
											<cfquery name="qCurrencyConverter" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
												select top 1 scale as kurs from tcurrencyconverter
												where currency_id_1 = '#qCurrency.currency_id#'
												and currency_id_2 = '#cookie.currencyid#'
												and start_date < =#CreateODBCDate(date)#
												and company_id = #cookie.companyid#
												order by start_date desc, converter_id desc
											</cfquery>
											<cfset rate=val(qCurrencyConverter.kurs)>
											 
											<tr>
												<td>1 #currency_symbol#</td>
												<td>:</td>
												<td>#numberformat(rate,".#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#</td>
											</tr>
									</cfif>
								</cfloop>
							</cfif>
						</table>
					</fieldset>
					</td>
				</tr>
		 
				</table>
				<table width="100%">
				<tr><td colspan="6" align="left">&nbsp;</td></tr>
				<tr>
					<td colspan="6" align="left">
					<cfparam name="selcho" default="C">
					<cfif qItem.recordcount>
						<input type="hidden" name="selcho" value="C">
						<input type="button" name="btnsel" class="btns" value="#DO_VAR['Select']#" onClick="selectalot(document.frmSearch.selcho.value);">
					</cfif>
						<input type="Button" name="btnClose" value=" #DO_VAR['Close']# " onClick="window.close();">
					</td>
					 	
					<cfif (local.strPricingType eq "Purchase")>
						<td  <cfif local.strCatType eq "AST">colspan="2"  <cfelseif isDefined("Source") and Source eq "PO-RFQ">colspan="3" <cfelse>colspan="8" </cfif> class="formtext" align="right">
						#DO_VAR['page']# :
						<select name="selPage" onChange="<!--- showSearch(); --->refresh();">
							<cfif qItem.RecordCount eq 0>
								<option value="0">0</option>
							<cfelse>
								<cfloop index="i" from="1" to="#TotalPage#">
									<option value="#i#" <cfif selPage eq i>Selected</cfif>>#i#</option>
								</cfloop>
							</cfif>
						</select>
						#DO_VAR["of"]# #TotalPage#
					</td>
					<cfelse>
						<td <cfif isdefined("source") and source eq "po-rfq">colspan="1" <cfelse>colspan="4" </cfif>class="formtext" align="right">
						#DO_VAR['page']# :
						<select name="selPage" onChange="<!--- showSearch(); --->refresh();">
							<cfif qItem.RecordCount eq 0>
								<option value="0">0
							<cfelse>
								<cfloop index="i" from="1" to="#TotalPage#">
									<option value="#i#" <cfif selPage eq i>Selected</cfif>>#i#
								</cfloop>
							</cfif>
						</select>
						#DO_VAR["of"]# #TotalPage#
					</td>
					</cfif>
				</tr>

			<cfif not isDefined("Source") or Source eq "SO" or source eq "Direct_SN">
				<script>
					function tampilkan(){

						if(document.frmSearch.chkDisc.checked == true){
							document.frmSearch.txtDiscAll.style.display = '';
							document.getElementById('satu').style.display = '';
						}
						if(document.frmSearch.chkExtra.checked == true){
							document.frmSearch.txtExtraAll.style.display = '';
							document.getElementById('dua').style.display = '';
						}
						if(document.frmSearch.chkDisc.checked == false){
							document.frmSearch.txtDiscAll.style.display = 'none';
							document.getElementById('satu').style.display = 'none';
						}
						if(document.frmSearch.chkExtra.checked == false){
							document.frmSearch.txtExtraAll.style.display = 'none';
							document.getElementById('dua').style.display = 'none';
						}
					}
				</script>
			</cfif>
				<!--- end --->
					<tr class="heading2" align="center">
						<td width="4%" align="center"><input type="Checkbox" name="chkAll" onClick="SetAll(this.form.chkItem,this);"></td>
						<td width="4%" align="center" class="formtext"><b>No.</b></td>
						<td nowrap class="formtext"><b><cfif local.strCatType EQ "AST">#DO_VAR["AssetCode"]#<cfelse>#DO_VAR["ItemCode"]#</cfif></b></td>
						<td nowrap class="formtext"><b><cfif local.strCatType EQ "AST">#DO_VAR["AssetName"]#<cfelse>#DO_VAR["ItemName"]#</cfif></b></td>
                        <cfif local.strCatType NEQ "AST"><td nowrap class="formtext" style="display:none;"><b>#DO_VAR["Dimension"]#</b></td></cfif>
						<!--- Samick Custom --->						
						<cfif local.strCatType NEQ "AST" and menu NEQ "PURCHASE"><td nowrap class="formtext"><b>#DO_VAR["Color"]#</b></td></cfif>
						<cfif local.strCatType NEQ "AST" and menu NEQ "PURCHASE"><td nowrap class="formtext"><b>#DO_VAR["ItemBrand"]#</b></td></cfif>
						<cfif local.strCatType NEQ "AST"><td nowrap class="formtext"><b>#DO_VAR["size"]#</b></td></cfif>
						<cfif local.strCatType NEQ "AST"><td nowrap class="formtext"><b>#DO_VAR["eHRMType"]#</b></td></cfif>
						<!--- end --->
						<cfif local.strPricingType EQ "PURCHASE" AND isDefined("Source")>
                          <td class="formtext"><b>#do_var['UnitPrice']# #local.strCurrencyID#</b></td>
						<cfelseif local.strPricingType EQ "SALES" AND local.strCatType NEQ "AST" AND source NEQ "RFQ">
							<td class="formtext"><b>#DO_VAR["SalesPricing"]#</b></td>
                            <td class="formtext"><b>#DO_VAR["SalesPriceHistory"]#</b></td>
						</cfif>
						<cfif isDefined("qItem.item_description")>
							<td class="formtext" style="display:none"><strong>#DO_VAR['Description']#</strong></td>
						</cfif>
					</tr>
					<cfif not qItem.recordcount>
						<tr class="tablebodyodd">
							<td align="center" <cfif isDefined("Source") and source neq "PO-RFQ">colspan="10"<CFELSE>COLSPAN="11"</CFIF>>
								<strong>..:: #DO_VAR['NoRecordFound']# ::..</strong>
							</td>
						</tr>
					<cfelse>
						<cfset on_off=1>
					<cfset ndx=-1>
					<cfloop query="qItem" startrow="#StartRow#" endrow="#EndRow#">
						<cfset qCheckRelation = QueryNew("ITEM_CODE,CHILD_RATIO,UNITPRICE,ITEM_NAME,Item_Size,Item_Material,generate_flag,ilevel,prt,ppath,Unit_Name,Unit_Type_ID,Dimension_ID,Dimension_Name")>
						<cfset ndx=ndx+1>
						<cfset supndx=ndx>
						<cfset on_off=not on_off>
						<cfset clattr=IIF(on_off,DE("class='TablebodyEven'"),DE("class='tablebodyodd'"))>
						<input type="hidden" name="txtflc_#ndx#" id="txtflc_#ndx#" value="0">

						<!-- disini -->
						<tr #clattr#>
							<td width="4%" align="center"><input type="Hidden" name="hidlabel_#ndx#" value="#qItem.labelout#">
								<cfif local.strCatType eq "AST">
									<input type="Checkbox" name="chkItem" onClick="tickItem(this,this.form.chkAll,#ndx#);" value="#HTMLEditFormat(item_Code)#">
									<!--- value="#ndx#" ---> 
								<cfelse>
									<input type="Checkbox" name="chkItem" onClick="tickItem(this,this.form.chkAll,#ndx#);
									<cfif qItem.generate_flag gt 0>showchild('#JSStringFormat(item_Code)#',this);</cfif>"
									value="#HTMLEditFormat(item_Code)#">
								</cfif>

								<cfif ListFindNoCase(alr,item_code)>*</cfif>
							</td>
							<td width="4%" align="center" class="formtext">#currentrow#</td>
							<td class="formtext">
								#HTMLEDITFORMAT(qItem.Item_Code)#

								<cfset tmpscale = 0>

								<!--- IVN : 04 Mei 2010 ITEM UNIT MEASUREMENT --->
								<cfscript>
								  // CREATE OBJECT
								  objSetupInventory = createObject("component", "#Application.ComponentPath#.sunfisherp.setup.inventory");
								  objDummy = createObject("component", "#Application.ComponentPath#.sunfisherp.utility.cfdummy");
								  
								  try
								  {
									objItemCode = qItem.Item_Code[currentrow];
									objCompanyID = COOKIE.COMPANYID;
									
									if(listfind("PO-RFQ,PO-QO,PO,Direct_RR",source))
									{
									  objDocType = "RR";
									}
									else if(listfind("SO,SO-QO,Direct_SN",source))
									{
									  objDocType = "SN";
									}
									else
									{
									  objDocType = "Production";
									}
									
									if(local.strCatType != "AST")
									{
									  // GET ITEM PRIMARY UNIT MEASUREMENT
									  dtsPrimaryUnit = objSetupInventory.getUMPrimary(objItemCode);
									  
									  tmpUnit = dtsPrimaryUnit.Unit_Name;
									  tmpUnitID = dtsPrimaryUnit.Unit_Type_ID;
									  
									  // GET ITEM SECONDARY UNIT MEASUREMENT
									  dtsSecondaryUnit = objSetupInventory.getUMSecondary(objCompanyID, objItemCode, objDocType);
									  
									  tmpUnit2 = dtsSecondaryUnit.Unit_Name;
									  tmpUnitID2 = dtsSecondaryUnit.Unit_Type_ID;
									  tmpMOQ = 0 ;
									  // GET UNIT CONVERTER
									  tmpScale = objSetupInventory.getUMConverter(tmpUnitID, tmpUnitID2);
									}
									else
									{
									  tmpScale = 1;
									  tmpUnit = "";
									  tmpUnitID = "";
									  tmpUnit2 = "";
									  tmpUnitID2 = "";
									  tmpMOQ = 0 ;
									}
								  }
								  catch(Any err)
								  {
									objDummy.cfdump(err.Message);
									
									WriteOutput('<br /><font style="color: ##c90;">Please define Primary and Secondary unit type for item!</font>');
								  }
								</cfscript>
                                <input type="hidden" name="txtQtyConv_#ndx#" id="txtQtyConv_#ndx#" value="#tmpScale#" />
                                <input type="hidden" name="txtUnitPI_#ndx#" id="txtUnitPI_#ndx#" value="#tmpUnit#" />
                                <input type="hidden" name="txtUnitIDPI_#ndx#" id="txtUnitIDPI_#ndx#" value="#tmpUnitID#" />
                                <input type="hidden" name="txtUnit2PI_#ndx#" id="txtUnit2PI_#ndx#" value="#tmpUnit2#" />
                                <input type="hidden" name="txtUnitID2PI_#ndx#" id="txtUnitID2PI_#ndx#" value="#tmpUnitID2#" />
								<!---<input type="hidden" name="txtMOQ_#ndx#" id="txtMOQ_#ndx#" value="#tmpMOQ#" />--->
                                <!--- IVN : 04 Mei 2010
								END OF UNIT MEASUREMENT --->
                                
								<!---BEGIN Cek apakah item ini ada Event Pricing atau tidak--->
								<cfset discvalue	= "">
								<cfset disctype		= "">
								<cfset disccurrId	= "">
								
								<cfquery name="qEventPricing" datasource="#REQUEST.DSN#">
									select * from TAccMatrixItem_Header 
									where status = 1 
									and (((select count(0) from TAccMatrixItem_Detail where (ITEM_SOURCE = 1) and Matrix_Code=TAccMatrixItem_Header.Matrix_Code) = 0) 
									or exists(select 1 from TAccMatrixItem_Detail where (Item_Code = '#qItem.Item_Code#') and (Item_Source = 1)
									and Matrix_Code=TAccMatrixItem_Header.Matrix_Code)) 
									and exists(select 1 from TaccEventPricing_Matrix where MATRIX_CODE=TAccMatrixItem_Header.MATRIX_CODE
									and exists(select 1 from TAccEventPricing where (((select count(0) from TAccEventPricing_WH 
									where EVENT_ID=TAccEventPricing.EVENT_ID) = 0) 
									or exists(select 1 from TAccEventPricing_WH where (WH_ID = #COOKIE.LOCATION_ID#) and EVENT_ID=TAccEventPricing.EVENT_ID)) 
									and ('#dateformat (createodbcdate(DATE), "yyyy/mm/dd")#' BETWEEN EVENT_START AND EVENT_END) 
									AND ((Customer_Type = 1) Or ((Customer_Type = 2) and exists(select 1 from TAccEventPricing_Customer 
									where account_ID = '#CBOCUSTOMER#' and EVENT_ID=TAccEventPricing.EVENT_ID))) 
									AND (STATUS = 1) and EVENT_ID=TaccEventPricing_Matrix.EVENT_ID))
								</cfquery>
								
                                <input type="hidden" name="hdnPriceType_#ndx#" value="#qItem.PriceType#">
                                
								<cfif qEventPricing.RecordCount gt 0>
									<input type="hidden" name="hdnEventQty_#ndx#" value="#qEventPricing.Qty#">
									<input type="Hidden" name="hidQtyFree_#ndx#" value="#qEventPricing.Qty_free#">
                                    <input type="hidden" name="hdnMatrixItem_#ndx#" value="#qEventPricing.Matrix_Code#">
									<cfif qEventPricing.ISDEFAULT_PRICE eq 0>
										<input type="hidden" name="hdnEventPrice_#ndx#" value="#qEventPricing.Price_Value#">
									<cfelse>
										<input type="hidden" name="hdnEventPrice_#ndx#" value="0">
									</cfif>
									<cfif qEventPricing.DISCOUNT_TYPE eq 0>
										<input type="hidden" name="hdnEventDiscAmount_#ndx#" value="0">
										<input type="hidden" name="hdnEventDiscPercent_#ndx#" value="0">
									<cfelseif qEventPricing.DISCOUNT_TYPE eq 1>
										<input type="hidden" name="hdnEventDiscAmount_#ndx#" value="#qEventPricing.DISCOUNT_VALUE#">
										<input type="hidden" name="hdnEventDiscPercent_#ndx#" value="0">
									<cfelse>
										<input type="hidden" name="hdnEventDiscAmount_#ndx#" value="0">
										<input type="hidden" name="hdnEventDiscPercent_#ndx#" value="#qEventPricing.DISCOUNT_VALUE#">
									</cfif>
									<!---  --->
								</cfif>
							</td>
							<td class="formtext">
								<cfquery name="qunit2" datasource="#request.dsn#">
									select * from (				
										SELECT 	Unit_Type_ID, Unit_Name, 
												(
												SELECT COUNT(0) FROM TItemQtyConvert WHERE Unit_Type_ID=TAccUnitType.Unit_Type_ID 
												AND Item_Code = '#Item_Code#' AND Company_Id = #Cookie.CompanyID# 
												AND Document_Type = 'RR') AS intCountRR,
												(
												SELECT COUNT(0) FROM TItemQtyConvert WHERE Unit_Type_ID=TAccUnitType.Unit_Type_ID 
												AND Item_Code = '#Item_Code#'	AND Company_Id = #Cookie.CompanyID# 	AND Document_Type = 'SN'
												) AS intCountSN, 
												(
												SELECT COUNT(0) FROM TItemQtyConvert WHERE Unit_Type_ID=TAccUnitType.Unit_Type_ID 
												AND Item_Code = '#Item_Code#'		AND Company_Id = #Cookie.CompanyID#	AND Document_Type = 'Production') AS intCountProduction
										FROM	TAccUnitType
										WHERE	ItemCategoryType  = '#local.strCatType#'
										)  tbl
										where 1=1
										and <cfif source eq "SO" or source eq "SO-QO" or source eq "Direct_SN">
										intCountSN > 0	
										<cfelse>
										intCountRR > 0	
										</cfif>
								</cfquery>
								<cfif local.strCatType neq "AST">
									<cfquery name="qConvertUnit1to2" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
										SELECT * FROM TPPICUnitConverter
										WHERE Status = 1
										AND Unit_Type_ID1='#Unit_Type_ID#'
										AND Unit_Type_ID2='#qunit2.Unit_Type_ID#'
									</cfquery>
									<input type="Hidden" name="txtUnitConv1to2#ndx#" size="10" value="#qConvertUnit1to2.Scale#">
								<cfelse>
									<input type="Hidden" name="txtUnitConv1to2#ndx#" size="10" value="1">
								</cfif>
								#qItem.Item_Name#
								<cfif isdefined("tax1")><input type="hidden" name="txtdeftax_#ndx#" value="#tax1#"></cfif>
								<cfif isdefined("tax2")><input type="hidden" name="txtdeftax2_#ndx#" value="#tax2#"></cfif>
              					<input type="hidden" name="txtMOQ_#ndx#" id="txtMOQ_#ndx#" value="#qItem.MOQ#"> 
								<cfif local.strCatType neq "AST">
									<input type="hidden" name="txtItemCode_#ndx#" value="#HTMLEDITFORMAT(Item_Code)#">
									<input type="hidden" name="txtItemName_#ndx#" value="#HTMLEDITFORMAT(Item_Name)#">
                  
                 					<input type="hidden" name="txtPartNoMisc#ndx#" value="#HTMLEDITFORMAT(Item_Code)#">
									<input type="hidden" name="txtDescMisc#ndx#" value="#HTMLEDITFORMAT(Item_Name)#">
					
                                    <input type="hidden" name="txtUnit_#ndx#" value="#HTMLEDITFORMAT(Unit_Name)#">
									<input type="hidden" name="txtUnitId#ndx#" value="#HTMLEDITFORMAT(Unit_Type_ID)#">
									<input type="hidden" name="txtUnit2_#ndx#" value="#HTMLEDITFORMAT(qunit2.Unit_Name)#">
									<input type="hidden" name="txtUnitId2X#ndx#" value="#HTMLEDITFORMAT(qunit2.Unit_Type_ID)#">				
								<cfelse>  
									<input type="hidden" name="txtItemCode_#ndx#" value="#Item_Code#"> 
									<input type="hidden" name="txtQty_#ndx#" value="#asset_qty#">
									<input type="hidden" name="txtItemName_#ndx#" value="#Item_Name#">
                 					<input type="hidden" name="txtPartNoMisc#ndx#" value="#Item_Code#">
									<input type="hidden" name="txtDescMisc#ndx#" value="#Item_Name#">
								</cfif>
								
							</td>
							
                            <cfif local.strCatType neq "AST">
	                            <td class="formtext" style="display:none;">
	                              #qItem.Dimension_Name#
	                              <input type="hidden" name="txtDimensionName_#ndx#" id="txtDimensionName_#ndx#" value="#JSSTRINGFORMAT(qItem.Dimension_Name)#" />
	                              <input type="hidden" name="txtDimensionID_#ndx#" id="txtDimensionID_#ndx#" value="#qItem.Dimension_ID#" />
	                            </td>		
							</cfif>	

							<cfif local.strCatType neq "AST" and menu NEQ "PURCHASE">							
								<td class="formtext">
									<!---
									<cfif len(qitem.item_color) AND structkeyexists(strctColor,qItem.item_color)>
										#strctColor[qItem.item_color]#
									</cfif>
									<input type="hidden" name="txtColorItem_#ndx#" id="txtColorItem_#ndx#" 
									<cfif len(qitem.item_color) AND structkeyexists(strctColor,qItem.item_color)> 
										value="#strctColor[qItem.item_color]#" 
									<cfelse>
										value="" 
									</cfif>/>
									--->
									#qitem.color_name#
									<input type="hidden" name="txtColorItem_#ndx#" value="#qitem.color_name#">
								</td>
								<td class="formtext">
									#qitem.item_size#
									<input type="hidden" name="txtBrandItem_#ndx#" id="txtBrandItem_#ndx#" value="#qItem.item_size#" />
								</td>
							<cfelseif local.strCatType neq "AST" and menu eq 'purchase'>
								<!--- BUG50313-82076 --->
								<input type="hidden" name="txtColorItem_#ndx#" id="txtColorItem_#ndx#" value="#qitem.color_name#">
								<input type="hidden" name="txtBrandItem_#ndx#" id="txtBrandItem_#ndx#" value="#qItem.item_size#" />
							</cfif>

							<cfif local.strCatType neq "AST"> 	
								<td class="formtext">
									#val(qitem.item_length)# x #val(qitem.item_width)# x #val(qitem.item_height)# mm
									<input type="hidden" name="txtSize_#ndx#" id="txtSize_#ndx#" 
									value="#val(qitem.item_length)# x #val(qitem.item_width)# x #val(qitem.item_height)# mm" />
								</td>
								<td class="formtext">
									#qitem.item_description#
									<input type="hidden" name="txtTypeItem_#ndx#" id="txtTypeItem_#ndx#" value="#qItem.item_description#" />
								</td>
                            </cfif>

							<cfparam name="harga_item" 	default="">
							<cfparam name="disc_type"	default="">
							<cfparam name="discount_percent" default="0">
							<cfif isDefined("Source")>
								<cfif local.strPricingType EQ "PURCHASE">
                                <td align="right">
									<cfif local.strCatType EQ "AST"> 
										<cfif qitem.currency_id eq local.strCurrencyID>
											<cfset harga_item = qitem.asset_cost> 
										<cfelse>
											<cfset harga_itemTemp = qitem.base_cost>
											<cfif local.strCurrencyID eq cookie.currencyid>
												<cfset rate=1>
											<cfelse>
												<cfset rate= val(evaluate("qCurrencyConverter#qItem.Currency_ID#.Kurs"))>
											</cfif> 
											<cfif rate gt 0> 
												<cfset harga_item = harga_itemTemp / rate>
											<cfelse>
												<cfset harga_item = harga_itemTemp>
											</cfif>
											<!--- <cfset harga_item = qitem.asset_cost> --->
										</cfif> 
                                        <cfset curr_id = local.strCurrencyID> 
                                    <cfelse> 
                                        <cfset local.tmpItemPrice = objInventory.fntGetItemPrice(intCompanyID		: COOKIE.COMPANYID,
                                                                                                 strItemCode		: qItem.Item_Code,
                                                                                                 intDimensionID		: qItem.Dimension_ID,
                                                                                                 strCurrencyID		: local.strCurrencyID,
                                                                                                 intAccountID		: cboCustomer,
                                                                                                 strPricingType		: local.strPricingType,
                                                                                                 dtmDocumentDate	: URL['date'],
                                                                                                 strDocumentType	: local.strDocumentType,
                                                                                                 fltQty				: 0,
                                                                                                 strPaymentTerm		: '')>
                                        
                                        <cfif local.tmpItemPrice.SUCCESS>
											<cfset harga_item = local.tmpItemPrice.ITEMCURRENCYPRICE>
                                            <cfset curr_id = local.tmpItemPrice.ITEMCURRENCYID>
                                            
                                            <cfif local.tmpItemPrice.ITEMCURRENCYPRICE NEQ 0>
                                              <cfset rate = local.tmpItemPrice.ITEMPRICE / local.tmpItemPrice.ITEMCURRENCYPRICE>
                                            <cfelse>
                                              <cfset rate = local.tmpItemPrice.ITEMPRICE>
                                            </cfif>
                                        <cfelse>
                                            <cfset harga_item = 0>
                                            <cfset curr_id = 0>
                                            <cfset rate = 0>
                                        </cfif>
                                    </cfif>

                                    <cfif local.strCatType eq "AST">
									
                                        <input type="hidden" name="txtPrice_#ndx#" value="#numberformat(harga_item,".#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#">
                                    <cfelse>
                                        <input type="hidden" name="txtPrice_#ndx#" value="#numberformat(local.tmpItemPrice.ITEMPRICE,".#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#">
                                        <cfquery name="qGetDiscount" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                                            SELECT DefaultDiscount FROM TItem WHERE item_code ='#qitem.item_code#'
                                        </cfquery>
                                        <cfset discount_percent = val(qGetDiscount.DefaultDiscount)>
                                    </cfif>
                                    <input type="hidden" name="txtOriginPrice_#ndx#" value="#harga_item#">
                                    <input type="hidden" name="txtCurrencyID_#ndx#" value="#curr_id#">
                                    <input type="hidden" name="txtDiscount_#ndx#" value="#discount_percent#">
                                    <input type="hidden" name="txtDiscountv_#ndx#" value="#discvalue#">
                                    <input type="hidden" name="txtDiscountType_#ndx#" value="#disctype#">

									<cfif local.strCatType eq "AST">
										#numberformat(harga_item,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#
									<cfelse>
										<cfif local.tmpItemPrice.SUCCESS>
											#numberformat(local.tmpItemPrice.ITEMPRICE,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#
										<cfelse>
											#objDummy.cferror(ErrorText: local.tmpItemPrice.MESSAGE, btnBack: false, btnClose: false, cfabort: false)#
										</cfif>
									</cfif>
                                </td>
                                </cfif>
							</cfif>
                            
							<cfif local.strPricingType eq "sales" and local.strCatType neq "AST" and source neq "RFQ">
                            
                                    <cfif local.strCatType EQ "AST"> 
                                        <cfset harga_item = qitem.asset_cost>
                                        <cfset curr_id = qItem.currency_ID> 
                                    <cfelse> 
                                        <cfset local.tmpItemPrice = objInventory.fntGetItemPrice(intCompanyID: COOKIE.COMPANYID,
                                                                                                 strItemCode: qItem.Item_Code,
                                                                                                 intDimensionID: qItem.Dimension_ID,
                                                                                                 strCurrencyID: local.strCurrencyID,
                                                                                                 intAccountID: cboCustomer,
                                                                                                 strPricingType: local.strPricingType,
                                                                                                 dtmDocumentDate: URL['date'],
                                                                                                 strDocumentType: local.strDocumentType,
                                                                                                 fltQty: 0,
                                                                                                 strPaymentTerm: '')>
                                        
                                        <cfif local.tmpItemPrice.SUCCESS>											
                                            <cfset curr_id = local.tmpItemPrice.ITEMCURRENCYID>
                                        <cfelse>
                                            <cfset curr_id = 0>
                                        </cfif>
                                    </cfif>
                                    
								<td class="formtext">
									<cfset vartemplate = "index.cfm">
									<cfset varQueryString = "?fid=ERSTD07148&fuid=ERSTD0714826&menu=1">
									<a href="javascript: void(0);" onClick="arrNewPop3[arrNewPop3.length]=PopWindow('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&ItemCode=#Item_Code#&AccountID=#cbocustomer#&selprice=#qCustDetail.Selling_Price_Type#&DimensionID=#qItem.Dimension_ID#&TransDate=#date#&CurrencyID=#local.strCurrencyID#','wndSalesPricing','600','200','scrollBars=yes,location=no,status=no,toolbar=no,resizable=yes');" style="text-decoration:none;">
                                    	#DO_VAR['Display']# #DO_VAR['SalesPricing']#
									</a>
								</td>
                                
                                <td class="formtext">
								<cfif DisplayHistory eq 1>
									<cfset vartemplate = "index.cfm">
									<cfset varQueryString = "?fid=ERSTD07148&fuid=ERSTD0714816&menu=1">
									<a href="javascript: void(0);" onClick="arrNewPop3[arrNewPop3.length]=PopWindow('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&ItemCode=#Item_Code#&cbocustomer=#cbocustomer#&selprice=#qCustDetail.Selling_Price_Type#&DimensionID=#qItem.Dimension_ID#','wndSalesPriceHistory','400','500','scrollBars=yes,location=no,status=no,toolbar=no,resizable=yes');" style="text-decoration:none;">
										#DO_VAR['Display']# #DO_VAR['SalesPriceHistory']# 
									</a>
								<cfelse>
									#DO_VAR["N/A"]#
								</cfif>
								</td>
							</cfif>
							
							<cfif isDefined("qItem.item_description")>
								<td class="formtext" style="display:none">#qitem.item_description#</td>
							</cfif>

							<cfif local.strCatType neq "AST">
								<input type="Hidden" name="hdnboard_#ndx#" id="hdnboard_#ndx#" value="0">
								<input type="hidden" name="hidGenerate_#ndx#" id="hidGenerate_#ndx#" value="#val(generate_flag)#">
								<input type="hidden" name="hidParent_#ndx#" id="hidParent_#ndx#" value="0">
								<input type="Hidden" name="hdnRatio_#ndx#" id="hdnRatio_#ndx#" value="1">
							</cfif>

							<input type="hidden" name="txtCurrencyID_#ndx#" id="txtCurrencyID_#ndx#" value="#curr_id#">
                            <input type="hidden" name="hidppath_#ndx#" id="hidppath_#ndx#" value="0">
							<input type="Hidden" name="hdnChildList_#ndx#" id="hdnChildList_#ndx#" value="">
						</tr>
						</cfloop>
					</cfif>
				</table>
			</td>
		</tr>
		</table>
	</td>
</tr>

</cfif>
</table>
<cfparam name="TSPCode" default="#qSalesNih.Emp_ID#">
<cfparam name="TSPName" default="#qSalesNih.SalesName#">
<cfset TCPCode=qCP.Contact_ID>

<cfset TCPName="#qCP.Contact_FirstName# #qCP.Contact_MiddleName# #qCP.Contact_LastName#">
<cfset TCPAddr=qCP.Addr>
<cfset TCPTaxFileNumber=qCustDetail.TaxFileNumber>

<cfif isdefined("selRFQ")>
	<input type="Hidden" name="selRFQ" value="#selRFQ#">
</cfif>
<cfif isDefined("date")>
	<input type="Hidden" name="date" value="#date#">
</cfif>
<cfif isDefined("preq")>
	<input type="Hidden" name="preq" value="#preq#">
</cfif>
<cfif isDefined("RowItem")>
	<input type="Hidden" name="RowItem" value="#RowItem#">
</cfif>
<input type="Hidden" name="selCurrency" value="#local.strCurrencyID#">
<input type="Hidden" name="TSPCode" value="#TSPCode#">
<input type="Hidden" name="TSPName" value="#TSPName#">
<input type="Hidden" name="TCPCode" value="#TCPCode#">
<input type="Hidden" name="TCPName" value="#TCPName#">
<input type="Hidden" name="TCPAddr" value="#qCP.Addr#">
<input type="Hidden" name="TCPTaxFileNumber" value="#qCustDetail.TaxFileNumber#">
<input type="Hidden" name="DisplaySearch" value="0">
<input type="Hidden" name="txtCustCode" value="#txtCustCode#">
<input type="Hidden" name="idx" value="#idx#">
<cfif isDefined("Source")><input type="Hidden" name="Source" value="#Source#"></cfif>
<input type="Hidden" name="Menu" value="#local.strPricingType#">
<!--- rn, Dec 2007 --->
<cfif isDefined("CBOCUSTOMER2")><input type="Hidden" name="CBOCUSTOMER2" value="#CBOCUSTOMER2#"></cfif>
<cfif isDefined("SUMBER")><input type="Hidden" name="SUMBER" value="#SUMBER#"></cfif>
 
<input type="Hidden" name="CreditLimit" value="#NumberFormat(qGetCreditLimit.Credit_Limit,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#">
<input type="Hidden" name="InvNotPaid" value="#NumberFormat(txtNotPaidInvoice,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#">
<input type="Hidden" name="SOApproved" value="#NumberFormat(txtSOApproved,",.#repeatstring("_",Application.stApp.decimaL_range[VST_IDX])#")#">

</form>
</body>
</html>
<script language="Javascript" type="text/javascript">
function refresh() {
	document.frmSearch.action = '';
	document.frmSearch.method = 'post';
	document.frmSearch.submit();
	}

function setThisValue(thisvalue, iddxx){
	if (iddxx == 1){
		var thisvaluesplit = thisvalue.split('|');
		document.frmSearch.TCPCode.value = thisvaluesplit[0];
		document.frmSearch.TCPName.value = thisvaluesplit[1];
		document.frmSearch.TCPAddr.value = thisvaluesplit[2];
        document.frmSearch.TCPTaxFileNumber.value = thisvaluesplit[3];
	}
	else if (iddxx == 2){
		var thisvaluesplit = thisvalue.split('|');
		document.frmSearch.TSPCode.value = thisvaluesplit[0];
		document.frmSearch.TSPName.value = thisvaluesplit[1];
	}
}
	
//	untuk select Item dari checkBox
	function selectalot(meth){
		if(document.frmSearch.cboCustomer.value == ""){
			<cfif (local.strPricingType eq "purchase")>
				alert('#DO_VAR['PleaseSelect']# #DO_VAR['Vendor']#');
			<cfelse>
				alert('#DO_VAR['PleaseSelect']# #DO_VAR['Customer']#');
			</cfif>
	
			document.frmSearch.cboCustomer.focus();
			return false;
		}
		else{
			doSave(meth);
		}
	}

	function doSave(meth){
		var theChk = document.frmSearch.chkItem;
		if(theChk != null){
			len = theChk.length;
			ok = 0;
			if(len != null){
				for(i=0; i<len; i++){
					if(theChk[i].checked  == true && ok == 0){
						ok = 1;
						break;
					}
				}
			}else{
				ok = 1;
				if(theChk.checked != true){
					alert("#DO_VAR['PickItem']#");
					ok = 0;
					return false;
				}
			}
		}
	
		if(ok == 0){
			alert("#DO_VAR['PickItem']#");				
			return false;
		}
	
		opener.getItem(meth);
	
		<cfif isDefined("Source") and Source eq "PO">
			opener.rrviaccount(eval("document.frmSearch.txtVenGrp_"+document.frmSearch.cboCustomer.value).value);
		</cfif>	
		top.close();
		return;
	}

<cfif source eq "PO-QO">
	function pickThis (thisobj) {

		var NumOfRows = document.getElementsByName('chkdelitem').length;
		
		if (thisobj!= '') {
			if (thisobj.checked) selectedRows++;
			//alert(thisobj.checked);
			else selectedRows--;	
		}
		if (selectedRows==NumOfRows) document.frmSearch.chkdelitemAll.checked = true;
			else document.frmSearch.chkdelitemAll.checked = false;
	}
</cfif>


<!--- add by RF : 08 april 2008 --->
function showchild(itemcode_js, parent){
	var doc = document.frmSearch;
	
	if(eval("document.frmSearch.hid_child_"+itemcode_js)){
		var child_var = eval("document.frmSearch.hid_child_"+itemcode_js);
		for(i=1; i<=child_var.value.split(',').length; i++){
			var thechkchild = eval("document.frmSearch.chk_"+itemcode_js+"_"+i);
			
			if(parent.checked == true){
				thechkchild.checked = true;
			}else{
				thechkchild.checked = false;
			}
		}
	}				
}

function selfcheck(obj){
	if(obj.checked == true){
		obj.checked = false;
	}else{
		obj.checked = true;
	}
}

function popDetailItem(item,DimensionID)
{
	var TempAction = document.forms[0].action
	var TempTarget = document.forms[0].target
	document.forms[0].action = '#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/purchase/po/forms/detailitem.cfm?menu=#local.strPricingType#&itemcode='+item+'&DimensionID='+DimensionID;
	window.open ('', "DetailItem", "scrollBars=yes,location=no,status=yes,toolbar=no,resizable=yes");
	document.forms[0].target = 'DetailItem';
	document.forms[0].submit();

	document.forms[0].action = TempAction
	document.forms[0].target = TempTarget
}

x = 800;
y = 500;
posX = (screen.width - x)/2;
posY = (screen.height - y)/2;
window.resizeTo(x, y);
window.moveTo(posX, posY);

function showNotes(url){
	var objAccount = document.getElementById("cboCustomer");
	if(objAccount.value==""){
		return false;

	}
	PopWindow(url+'&Account_id='+objAccount.value,'window_baru','800','600','scrollbars=yes,resizable=yes,location=no,status=yes')
}
</script>

</cfoutput>