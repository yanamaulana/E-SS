<!------------------------------------------------------------------------------
APPLICATION......: SunFishERP 51
FID..............: ERSTD07854
FUID/SELACTIONID.: ERSTD0785411 / ERSTD0785412
FILENAME.........: qupdate.cfm
================================================================================
CREATED BY.......: - ??
CREATED DATE.....: - ??
================================================================================
DESCRIPTION......: add / edit sales order document
================================================================================
REVISION.........: /* 21 July 2010 - Ivan Pujianto */ *** ENC50710-01303
.................: Add function to record item dimension
================================================================================
REVISION.........: /* 27 September 2010 - Randytia */
.................: Menambahkan check selected Number
================================================================================
REVISION.........: /* Oct 19, 2010 - Randytia */
.................: Added Closing module

REVISION.........: /* 04 Mei 2011 - NP */
.................: Free Item and Discount Total
------------------------------------------------------------------------------->

<cfoutput>

<cfif task eq "edit">
	<cfset varSecAccess = REQUEST.SFSecAccess.SecAccessFile(FILEACCESSCODE="ERSTD0785412", 
						  BACKURL="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/index.cfm?selListItem=1&menu=0")>
<cfelse>
	<cfset varSecAccess = REQUEST.SFSecAccess.SecAccessFile(FILEACCESSCODE="ERSTD0785411", 
						  BACKURL="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/index.cfm?selListItem=1&menu=0")>
</cfif>

<CFSET LANGUAGELIST = "careerHistory, set, StepNotAvailable, SOAlreadyexistsforCustPONUm, CurrencyConverter, " 
					& "TaxConverter, DPAmount, eHRMGreaterThan, eHRMAlreadyExists, IsNotDefined">
					
<CF_DO_V25_MULTILANGUAGE MESSAGEIDLIST="#LanguageList#">

<cfset strModuleName	= "SalesOrder">
<cfset DocumentDate		= #txtSODate#>

<cfparam name="rdoAllocate"		default="0">
<cfparam name="cboPriceType"	default="">

<!---
<cfif isdefined("HIDREVISION") and HIDREVISION neq 0>
<cfelse>
	<cfinclude template="#Application.stApp.Web_Path[VST_IDX]#/include/lockperiod/locktransaction.cfm">
</cfif>
--->

<!--- <cfinclude template="#Application.stApp.CFWeb_Path[1]#/include/lockperiod/checklockmodule.cfm"> --->
<!--- <cfinclude template="#Application.stApp.Web_Path[vst_idx]#/eaccounting/qBudget.cfm"> --->

<cfinclude template="#Application.stApp.Web_Path[vst_idx]#/eaccounting/generateerror.cfm">
</cfoutput>

<title>eaccounting</title>

<cftransaction>

<cfset SelFreightCurrency = cookie.currencyid>

<cfif task neq "Edit">
	<cfif not isDefined("txtSOType") or txtSOtype eq 1>
		<cfset DOkType ="salesJournal">
	<cfelseif txtSOtype eq 0>
		<cfset DOkType ="salesJournalnontax">
	</cfif>

	<CF_DO_V30_ACCDOCUMENTNO TableName="TAccPattern" DocumentType="#DOkType#" DocumentNo="SONum" Type="value" 
	CompanyID="#Cookie.CompanyID#" LocationID="#COOKIE.LOCATION_ID#" TrxNo="Trans">
</cfif>

<cfif Not IsDefined("cboTerms")>
	<cfset cboTerms = "">
</cfif>

<cfinclude template="qcheckdoc.cfm">

<cfoutput>

<cfset InvoiceAmount = #val(replace(txtTotAmount,",","","ALL"))#>
<cfset BaseInvoiceAmount = #val(replace(hidBaseTotAmount,",","","ALL"))#>

<cfif task eq "edit">
<cfquery name="qGetCurr" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
select * from taccso_header
where so_number='#SONum#'
</cfquery>

<cfparam name="selCurrency" default="#qGetCurr.Currency_ID#">
<cfparam name="selTaxCurrency" default="#qGetCurr.Tax_Currency_ID#">
</cfif>

<!--- Erica: START ENC50311-02068 - for SO edit features --->
<cfif isdefined("HIDREVISION") and HIDREVISION neq 0>
    <cfquery name="qSetting" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
        Select * from TAccSetting
    </cfquery>

    <cfif qSetting.EnableSORevisionApproval eq 1>
        <cfset txtconfirm = "Yes">
    </cfif>

    <cfquery name="qCekIsDP" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
        select sum(Base_Amount) as Base_Amount from TAccCashBookDetail
        Where Invoice_No = '#SONum#' 
    </cfquery>

    <cfif qCekIsDP.recordcount neq 0>
        <cfif qCekIsDP.Base_Amount gt BaseInvoiceAmount>
            <script>
                alert("#DO_VAR['DPAmount']# #DO_VAR['eHRMGreaterThan']# #TXTGRANDTOTAL# #DO_VAR['eHRMAlreadyExists']#");
                history.back();
            </script>
            <cfabort>
        </cfif>
    </cfif>
</cfif>
<!--- Erica: END ENC50311-02068 - for SO edit features --->

<cfif txtconfirm eq 'YES'>
	<cfset local.TotalAmount	= 0/>
	<cfset local.TotalQty		= 0/>
	<cfset local.TotalAmount	= val(ReplaceNoCase(Form.txtGrandTotal,',','','ALL'))<!--- - val(ReplaceNoCase(Form.txtTotTaxConv,',','','ALL'))--->>
	<cfset j					= ROWCOUNT>

	<cfloop index = "LoopCount" from = "1" to = #j#>
		<cfif isdefined("txtqty#LoopCount#")>
			<cfset local.TotalQty = local.TotalQty + replace(form["txtqty#loopCount#"],",","","all")>
		</cfif>
	</cfloop>

	<!---<CF_DO_GFERP_REQUESTAPPROVAL_2009 COMPANY_ID="#COOKIE.COMPANYID#" dsn="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#" VST_IDX="#VST_IDX#" RequestApproval_Name="eACCSalesOrder" ReqApproval_ID="#SONum#" lastStatus="LASTSTATUS" amount="#local.TotalAmount#" qty="#local.TotalQty#" AutoApproval="autocreate_var" />--->
	
    <!--- Erica: START ENC50311-02068 - for SO edit features --->
    <cfif isdefined("HIDREVISION") and qSetting.EnableSORevisionApproval eq 1>
        <cfquery name="qUpdate" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			INSERT INTO [THRMApprovedByHistory](
				[ApprovedBy_ID],[ReqApproval_ID]
				,[Employee_ID],[Position_id]
				,[Approved_By],[Approve_Status]
				,[LastApprove_Status],[Approve_Date]
				,[Approved_EmpID],[Approve_Value]
				,[Approve_Leave],[RequestApproval_id]
				,[Must_Approved],[Approval_Note]
				,[LastRevisionNo]
			)
			select	[ApprovedBy_ID],[ReqApproval_ID]
					,[Employee_ID],[Position_id]
					,[Approved_By],[Approve_Status]
					,[LastApprove_Status],[Approve_Date]
					,[Approved_EmpID],[Approve_Value]
					,[Approve_Leave],[RequestApproval_id]
					,[Must_Approved],[Approval_Note]
					, #HIDREVISION#

			from THRMApprovedBy
			WHERE  ReqApproval_Id= '#SONum#'
        </cfquery>    
        
 
    </cfif>
    <!--- Erica: END ENC50311-02068 - for SO edit features --->
    
   	<CF_DO_V30_REQUESTAPPROVAL COMPANY_ID="#COOKIE.COMPANYID#" dsn="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#" VST_IDX="#VST_IDX#" 
	RequestApproval_Name="eACCSalesOrder" ReqApproval_ID="#SONum#" lastStatus="LASTSTATUS" amount="#local.TotalAmount#" qty="#local.TotalQty#" 
	AutoApproval="autocreate_var"/>
 
</cfif>

<cfset discAmount		= #val(replace(TXTTOTDISC,",","","ALL"))#>
<cfset BasediscAmount	= #val(replace(HIDBASETOTDISC,",","","ALL"))#>
<cfset discrate			= TXTDISCTOTAL>

<cfset txtTotTaxConv		= #val(replace(txtTotTaxConv,",","","ALL"))#> 
<cfset txtTotTaxConv_Base	= txtTotTaxConv * #val(replace( evaluate("txtTax_#seltaxCurrency#") ,",","","ALL"))#> 

<cfset txtTotDeductConv			= #val(replace(txtTotDeductConv,",","","ALL"))#>
<cfset txtTotDeductConv_Base	= txtTotDeductConv * #val(replace( evaluate("txtTax_#seltaxCurrency#") ,",","","ALL"))#>

<cfset CurrencyRateList	= "#cookie.currencyid#|1">
<cfset TaxRateList		= "#cookie.currencyid#|1"> 
<cfset AmountCurrency	= "#cookie.currencyid#">
<cfset TaxCurrency		= "#cookie.currencyid#">

<cfloop list="#lstCurrency#" index="ListAwal" delimiters=";">
	<cfset TypeofTransaction=listgetat(ListAwal,1,"|")>
	<cfset Currency=listgetat(ListAwal,2,"|")>
	<cfif TypeofTransaction eq "Amount">
		<cfif listfindnocase(AmountCurrency,Currency) eq "0">
			<cfset converter = #val(replace(evaluate("txtCurr_#Currency#"),",","","ALL"))#> 
			<cfset CurrencyRateList=listappend(CurrencyRateList,"#Currency#|#converter#",";")> 
			<cfset AmountCurrency=listappend(AmountCurrency,Currency)>
			<cfif converter eq 0>
				<script>
					alert('#DO_VAR["CurrencyConverter"]# #Currency# #DO_VAR["IsNotDefined"]#');
					history.back();
				</script>
				<cfabort>
			</cfif>
		</cfif>
	</cfif>
	
	<cfif TypeofTransaction eq "Tax" AND (txtTotTaxConv GT 0 OR txtTotDeductConv GT 0)>
		<cfif listfindnocase(TaxCurrency,Currency) eq "0">
			<cfset converter = #val(replace(evaluate("txtTax_#Currency#"),",","","ALL"))#> 
			<cfset TaxRateList=listappend(TaxRateList,"#Currency#|#converter#",";")>
			<cfset TaxCurrency=listappend(TaxCurrency,Currency)>
			<cfif converter eq 0>
				<script>
					alert('#DO_VAR["TaxConverter"]# #Currency# #DO_VAR["IsNotDefined"]#');

					history.back();
				</script>
				<cfabort>
			</cfif>
		</cfif>
	</cfif> 
</cfloop>

<CFIF task eq "Edit">
    <!--- Erica: START ENC50311-02068 - for SO edit features --->
    <cfif isdefined("HIDREVISION") and HIDREVISION neq 0>
        <cfquery name="qInsertHeaderHistory" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		<!--- CRF50912-07376 : added columns : 'claim_deduction_amount' and 'claim_deduction_desc' --->
            Insert into TAccSOHistory_Header
            (
                Revision_Number                 ,Base_Invoice_Amount        ,close_reason           ,outlet_wh
                ,SO_Number                      ,SN_Status                  ,project_code           ,TransactionDiscountRate
                ,TrxNo                          ,Emp_ID                     ,Proforma_Number        ,TransactionDiscountAmount
                ,SO_Date                        ,FreightTax_Code            ,KawasanBerikat         ,TransactionDiscountBaseAmount
                ,SO_Notes                       ,FreightTax_Percentage      ,INVOICE_PERCENTAGE     ,isDonation
                ,Account_ID                     ,Invoice_Status             ,REMARK_NOTACTIVE       ,directpo
                ,Contact_ID                     ,Due_date                   ,isDirect               ,isDP
                ,Payment_Type                   ,Approve_Date               ,SN_Account_ID          ,tax_code
                ,PO_NumCustomer                 ,FOC_number                 ,SI_Account_ID          ,SC_Number
                ,PO_DateCustomer                ,ETD                        ,Creation_DateTime      ,ExtCom_Status
                ,Project_ID                     ,ETA                        ,Created_By             ,IntCom_Status
                ,ExternalSales_Commision        ,quotation_number           ,Last_Update            ,isTaxAble
                ,Base_ExternalSales_Commision   ,ItemCategoryType           ,Update_By              ,isFOC
                ,InternalSales_Commision        ,DisplayNumber              ,CurrencyRateList       ,isDisplay
                ,Base_InternalSales_Commision   ,JO_Code                    ,Tax_CurrencyRateList   ,isNotActive
                ,Approval_Status                ,created_date               ,isSisterCompany        ,ReviseCounter
                ,SO_Status                      ,SOType                     ,SisterCompany          ,include_do
                ,Company_ID                     ,terms                      ,SisterCompanyDocument  ,invoicedirect
                ,Tax_Currency_ID                ,Deliveryterms              ,AllocateTo             ,Doc_Status
                ,Tax_Amount                     ,WH_ID                      ,BudgetPeriod_ID        ,paymentterm_code
                ,Base_Tax_Amount                ,disc_id                    ,SI_SisterCompany       ,TaxDocNumPPN
                ,Currency_ID                    ,automaticsn                ,TaxCodeInclude         ,TaxDocNumPPh
                ,Invoice_Amount                 ,isClose                    ,isOutlet               ,PPNNumberGenerated
				,PriceType						,claim_deduction_amount		,claim_deduction_desc   ,reason_revision
				,pi_number						,Production_month			,Production_year
            )
            select 
                Revision_Number                 ,Base_Invoice_Amount        ,close_reason           ,outlet_wh
                ,SO_Number                      ,SN_Status                  ,project_code           ,TransactionDiscountRate
                ,TrxNo                          ,Emp_ID                     ,Proforma_Number        ,TransactionDiscountAmount
                ,SO_Date                        ,FreightTax_Code            ,KawasanBerikat         ,TransactionDiscountBaseAmount
                ,SO_Notes                       ,FreightTax_Percentage      ,INVOICE_PERCENTAGE     ,isDonation
                ,Account_ID                     ,Invoice_Status             ,REMARK_NOTACTIVE       ,directpo
                ,Contact_ID                     ,Due_date                   ,isDirect               ,isDP
                ,Payment_Type                   ,Approve_Date               ,SN_Account_ID          ,tax_code
                ,PO_NumCustomer                 ,FOC_number                 ,SI_Account_ID          ,SC_Number
                ,PO_DateCustomer                ,ETD                        ,Creation_DateTime      ,ExtCom_Status
                ,Project_ID                     ,ETA                        ,Created_By             ,IntCom_Status
                ,ExternalSales_Commision        ,quotation_number           ,Last_Update            ,isTaxAble
                ,Base_ExternalSales_Commision   ,ItemCategoryType           ,Update_By              ,isFOC
                ,InternalSales_Commision        ,DisplayNumber              ,CurrencyRateList       ,isDisplay
                ,Base_InternalSales_Commision   ,JO_Code                    ,Tax_CurrencyRateList   ,isNotActive
                ,Approval_Status                ,created_date               ,isSisterCompany        ,ReviseCounter
                ,SO_Status                      ,SOType                     ,SisterCompany          ,include_do
                ,Company_ID                     ,terms                      ,SisterCompanyDocument  ,invoicedirect
                ,Tax_Currency_ID                ,Deliveryterms              ,AllocateTo             ,Doc_Status
                ,Tax_Amount                     ,WH_ID                      ,BudgetPeriod_ID        ,paymentterm_code
                ,Base_Tax_Amount                ,disc_id                    ,SI_SisterCompany       ,TaxDocNumPPN
                ,Currency_ID                    ,automaticsn                ,TaxCodeInclude         ,TaxDocNumPPh
                ,Invoice_Amount                 ,isClose                    ,isOutlet               ,PPNNumberGenerated
				,PriceType						,claim_deduction_amount		,claim_deduction_desc   ,reason_revision
				,pi_number						,Production_month			,Production_year
                from TAccSO_Header
                Where SO_Number = '#SONum#'
        </cfquery>
        
        <cfquery name="qGetRevisionNumber" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
            Select *,isnull(Revision_Number,0) revNumber from TAccSO_Header
            Where SO_Number = '#SONum#'
        </cfquery>
        
        <cfquery name="qInsertDetailHistory" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
            Insert into TAccSOHistory_Detail
            (
                SO_Number               ,Tax_Percentage1     ,Others          ,is_install
                ,Item_Code              ,Tax_Operator1       ,CS_Number       ,config_level
                ,Item_Description       ,Tax_Amount1         ,EstimateDate    ,config_ratio
                ,Qty                    ,Tax_Code2           ,parent_item     ,config_order
                ,Qty_DO	                ,Tax_Percentage2     ,parent_path     ,disc_type
                ,UnitPrice              ,Tax_Operator2       ,generate_flag   ,SODetail_ID
                ,Base_UnitPrice         ,Tax_Amount2         ,Comp_ID         ,ref_id
                ,Disc_percentage        ,TotalPrice          ,Qty2            ,Dimension_ID
                ,ExtraPrice             ,Base_TotalPrice     ,Unit_Type       ,Disc_Value
                ,Tax_Code1              ,Include_DO          ,Unit_Type2      ,isFreeItem
				,Notes
                ,Revision_Number        

            )
            Select 
                SO_Number               ,Tax_Percentage1     ,Others          ,is_install
                ,Item_Code              ,Tax_Operator1       ,CS_Number       ,config_level
                ,Item_Description       ,Tax_Amount1         ,EstimateDate    ,config_ratio
                ,Qty                    ,Tax_Code2           ,parent_item     ,config_order
                ,Qty_DO	                ,Tax_Percentage2     ,parent_path     ,disc_type
                ,UnitPrice              ,Tax_Operator2       ,generate_flag   ,SODetail_ID
                ,Base_UnitPrice         ,Tax_Amount2         ,Comp_ID         ,ref_id
                ,Disc_percentage        ,TotalPrice          ,Qty2            ,Dimension_ID
                ,ExtraPrice             ,Base_TotalPrice     ,Unit_Type       ,Disc_Value
                ,Tax_Code1              ,Include_DO          ,Unit_Type2      ,isFreeItem
				,Notes
                ,#qGetRevisionNumber.revNumber#
                
            from TAccSO_Detail
            Where SO_Number = '#SONum#' 
        </cfquery>
        
        <cfquery name="qInsertLog" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
            Insert into TAccDocumentRevision 
            (
                Doc_type
                ,Doc_No
                ,LastRevisionNo
                ,USER_ID
                ,Created_datetime
            )
            values
            (
                'SO'
                ,'#SONum#'
                ,#HIDREVISION#
                ,#cookie.CKSATRIADEVID#
                ,GETDATE()
            )
        </cfquery>       
        
    </cfif>
    <!--- Erica: END ENC50311-02068 - for SO edit features --->

	<cfquery name="qNewSO" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
    	delete TAccSO_ETA where SO_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SONum#"/>;
		UPDATE	TAccSO_Header
			SET <cfif isDefined("txtPONum") and Len(trim(txtPONum)) neq 0>PO_NumCustomer			= '#txtPONum#',</cfif>
				<cfif isDefined("txtPODate") and Len(trim(txtPODate)) neq 0>PO_DateCustomer			= #CreateODBCDate(txtPODate)#,</cfif>
				SO_Date 				= #CreateODBCDateTime(CreateDateTime(year(txtSODate),month(txtSODate),day(txtSODate),hour(now()),minute(now()),second(now())))#,
				SO_Notes 				= '#txtMemo#',
				Account_ID 				= '#txtCustCode#', <!--- '#selCustomer#', --->
				Company_ID 				= '#cookie.companyID#', 			
				Currency_ID 			='#SelCurrency#' ,
				Tax_Currency_ID 		= '#SelTaxCurrency#', 
				<!--- Freight_Currency_ID 	= '#SelFreightCurrency#', --->					
				 
				Invoice_Amount 			= #InvoiceAmount#,
				Base_Invoice_Amount 	= #BaseInvoiceAmount#,   
				Tax_Amount 				= #txtTotTaxConv#,
				Base_Tax_Amount 		= #txtTotTaxConv_Base#, 
				
				Due_Date				= <cfif isDefined("txtInvDueDate") and txtInvDueDate neq "">#CreateODBCDate(txtInvDueDate)#<cfelse>null</cfif>,
                
                <!--- Erica: START ENC50311-02068 - for SO edit features --->
                <cfif not isdefined("HIDREVISION")>
				SO_Status 				= <cfif txtconfirm eq 'YES'>2<cfelse>1</cfif>,	<!--- SO_Status  1 = new, 2 = open, 3 = close --->
				</cfif>
                <!--- Erica: END ENC50311-02068 - for SO edit features --->
                
                Emp_ID							= '#txtSPCode#',	<!--- Sales Person Code / Emp ID --->
				Contact_ID						= '#txtCPCode#',	<!--- Contact Person ID --->
				<!--- Terms 					= '#txtTerms#', --->
				terms							= '#cboTerms#',
				WH_ID 							= #COOKIE.Location_ID#,
				SOtype							= <cfif isDefined("txtSOtype")>#txtSOtype#<cfelse>'1'</cfif>,
				DeliveryTerms					= '#txtDeliveryTerms#',
				automaticsn						= <cfif isdefined("cbautosn")>1<cfelse>0</cfif>,
				KawasanBerikat					= <cfif isdefined("chkKawasan")>1<cfelse>0</cfif>,
				SN_Account_ID					= <cfif isdefined("selSNGroup")>#selSNGroup#<cfelse>0</cfif>,
				SI_Account_ID					= <cfif isdefined("selSIGroup")>#selSIGroup#<cfelse>0</cfif>,
				Update_By						= #cookie.CKSATRIADEVID#,
				Last_Update						= GETDATE(),
				CurrencyRateList				= '#CurrencyRateList#',
				Tax_CurrencyRateList			= '#TaxRateList#',
				Project_ID						= '#val(selProject)#',
				AllocateTo						= #rdoAllocate#,
                TransactionDiscountRate			= #discrate#,
				TransactionDiscountAmount		= #discAmount#,
				TransactionDiscountBaseAmount	= #BasediscAmount#
				
				<!--- ,
				isDP					= <cfif isDefined("chkDP")>1<cfelse>0</cfif>,
				isDonation				= <cfif isDefined("chkDonation")>1<cfelse>0</cfif>,
				DirectPO				= <cfif isDefined("chkDirectPO")>1<cfelse>0</cfif> --->

		<cfif isDefined("txtSOtype") AND txtSOtype EQ 0>
			, Tax_Code = '#listGetAt(ddlTaxIncluded, 1, "|")#' 
		<cfelse>
			, Tax_Code = null 
		</cfif>
			, paymentterm_code= '#cboTermsNew#'
		<cfif isdefined("HIDREVISION")>
			, Revision_Number = #HIDREVISION#
		</cfif>
		<cfif isDefined("cboPriceType")>
			, PriceType = '#cboPriceType#'
		</cfif>

		<!--- CRF50912-07376 : added columns : 'claim_deduction_amount' and 'claim_deduction_desc' --->
			, claim_deduction_amount	= '#form.txt_cd_amount#'
			, claim_deduction_desc		= '#txt_cd_desc#'
			, reason_revision           = '#txtRevisionReason#' 
			, pi_number					= '#txtPiNumber#'
			, Production_month			= '#txtProMonth#'
			, Production_year			= '#txtProYear#'
		WHERE SO_Number = '#SONum#'
	</cfquery>
	
	<cfquery name="qSODetail" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
		DELETE FROM TAccSO_Detail WHERE SO_Number = '#SONum#'
	</cfquery>
    
    <!--- Erica: START ENC50311-02068 - for SO edit features --->
    <cfif isdefined("HIDREVISION") and HIDREVISION neq 0>
         <cfif qSetting.EnableSORevisionApproval eq 1>                
            <cfquery name="qUpdateStatus"  datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                Update TAccSO_Header
                set SO_Status = 2, Approval_Status = 0
                where SO_Number = '#SONum#'
            </cfquery>   
         </cfif>
    </cfif>
    <!--- Erica: END ENC50311-02068 - for SO edit features --->
    
<CFELSE>

	<!--- add by RF. 20 08 2007, check if the Quotation from project ? --->
	
	<cfset project_source = "">
	
	<cfif isdefined("SELQUOTATION")>
		<cfif selQuotation neq "">
			<cfquery name="qCheckQuo" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
				select project_code from taccQuotation_header
				where quotation_number = '#selQuotation#'
			</cfquery>
			
			<cfif qCheckQuo.recordCount gt 0>
				<cfset project_source = qCheckQuo.project_code>
			</cfif>
		</cfif>
	</cfif>
	
	<cfif isdefined("rbTypeDoc")>
		<cfif rbTypeDoc eq 1>
			<cfset project_source = form.selPro>
		</cfif>
	</cfif>

	<cfquery name="qNewSO" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		INSERT INTO	TAccSO_Header(	
			SO_Number, 	
			PO_NumCustomer,
			PO_DateCustomer,			
			SO_Date,
			SO_Notes, 			
			Account_ID, 		
			Payment_Type, 					                                     
			Company_ID, 			
			Currency_ID,
			Tax_Currency_ID, 
			<!--- Freight_Currency_ID, --->
			Approval_Status, 	
			SO_Status, 	
			SN_Status,
			Invoice_Status,	 
			Invoice_Amount,
			Base_Invoice_Amount,
			Tax_Amount,
			Base_Tax_Amount,
			Due_Date,

			Emp_ID,
			Contact_ID,
			ItemCategoryType,
			Quotation_Number,
			Terms,
			SOType,
			WH_ID,
			DeliveryTerms,
			disc_id,
			automaticsn,
			isClose,	
			project_code,
			Proforma_Number,
		<cfif isdefined("rbTypeDoc") and rbTypeDoc eq "3">
			SC_Number, 
		</cfif>
			KawasanBerikat,
			SN_Account_ID,
			SI_Account_ID,
			Creation_DateTime,
			Created_By,
			Last_Update,
			Update_By,
			TrxNo,
			CurrencyRateList,
			Tax_CurrencyRateList,
			isSisterCompany,
			SisterCompany,
			Project_ID,
			AllocateTo,
        	TransactionDiscountRate,
			TransactionDiscountAmount,
			TransactionDiscountBaseAmount<!--- ,
			isDP,
			isDonation,
			DirectPO --->
            <cfif isDefined("txtSOtype") AND txtSOtype EQ 0>
              , Tax_Code
            </cfif>
            ,paymentterm_code
            ,isExport
			,PriceType,

		<!--- CRF50912-07376 : added columns : 'claim_deduction_amount' and 'claim_deduction_desc' --->
			claim_deduction_amount,
			claim_deduction_desc,
			Revision_Number,
			reason_revision,
			pi_number,
			Production_month,
			Production_year
		)
		VALUES(
			'#SONum#',		
			<cfif Len(trim(txtPONum)) neq 0>'#txtPONum#',<cfelse>null,</cfif>
			<cfif Len(trim(txtPODate)) neq 0>#CreateODBCDate(txtPODate)#,<cfelse>null,</cfif>
		    #CreateODBCDateTime(CreateDateTime(year(txtSODate),month(txtSODate),day(txtSODate),hour(now()),minute(now()),second(now())))#, 	
			'#txtMemo#', 
			'#txtCustCode#', <!--- '#selCustomer#',  --->
			'Credit',					
			'#cookie.companyID#',
			'#SelCurrency#',
			'#SelTaxCurrency#',
			<!--- '#SelFreightCurrency#', --->						
			'0',	<!--- Approval Status  0 = new,1 = checked ,2 = awaiting,3 = revised, 4 = rejected, 5 = approved--->
			<cfif txtconfirm eq 'YES'>2<cfelse>1</cfif>,	<!--- SO_Status  1 = new, 2 = open, 3 = close --->
			'ND',	<!--- SN_Status = ND , HD, FD --->
			'NI',	<!--- Invoice_Status = NI, HI, FI --->
			 
			#InvoiceAmount#,
			#BaseInvoiceAmount#, 
			#txtTotTaxConv#,
			#txtTotTaxConv_Base#, 
	 
		<cfif isDefined("txtInvDueDate") and txtInvDueDate neq "">#CreateODBCDate(txtInvDueDate)#<cfelse>null</cfif>,						
			'#txtSPCode#',	<!--- Sales Person Code / Emp ID --->
			'#Val(txtCPCode)#',	<!--- Contact Person ID --->
			'#SelCBType#', 
			'#SelQuotation#',
			'#cboTerms#',
		<cfif isDefined("txtSOtype")>#txtSOtype#<cfelse>'1'</cfif>,
			#COOKIE.Location_ID#,
			'#txtDeliveryTerms#',
			#val(txtDiscID)#,
		<cfif isdefined("cbautosn")>1<cfelse>0</cfif>,
			'0'
		<cfif project_source neq "">
			,'#project_source#'
		<cfelse>
			,'0'
		</cfif>
		
		<cfif isdefined("rbTypeDoc") and rbTypeDoc eq "2">
			,'#selProforma#'
		<cfelse>
			,'0'
		</cfif>

		<cfif isdefined("rbTypeDoc") and rbTypeDoc eq "3">
		  ,'#FORM['ddlSalesContract']#'
		</cfif>

			,<cfif isdefined("chkKawasanBerikat")>1<cfelse>0</cfif>
			,<cfif isdefined("selSNGroup") and selSNGroup neq "">#selSNGroup#<cfelse>0</cfif>
			,<cfif isdefined("selSIGroup") and selSIGroup neq "">#selSIGroup#<cfelse>0</cfif>
			,GETDATE()
			,#cookie.CKSATRIADEVID#
			,GETDATE()
			,#cookie.CKSATRIADEVID#,
			'#Trans#',
			'#CurrencyRateList#',
			'#TaxRateList#',
			0,
			0,
			'#val(selProject)#',
			#rdoAllocate#,
        	#discrate#,
			#discAmount#,
			#BasediscAmount#<!--- ,
			<cfif isDefined("chkDP")>1<cfelse>0</cfif>,
			<cfif isDefined("chkDonation")>1<cfelse>0</cfif>,
			<cfif isDefined("chkDirectPO")>1<cfelse>0</cfif> --->

		<cfif isDefined("txtSOtype") AND txtSOtype EQ 0>
			 ,'#listGetAt(ddlTaxIncluded, 1, "|")#' 
		</cfif>

            ,'#cboTermsNew#'
            ,#isExport#

		<cfif isDefined("cboPriceType")>
			,'#cboPriceType#'
		</cfif>

		<!--- CRF50912-07376 : added columns : 'claim_deduction_amount' and 'claim_deduction_desc' --->
			, '#form.txt_cd_amount#'
			, '#txt_cd_desc#'
			, 0
			, '#txtRevisionReason#'
			, '#txtPiNumber#'
			, '#txtProMonth#'
			, '#txtProYear#'

		)
	</cfquery>
</cfif>

<cfset lstIncludeDO="">
<cfset prevorder=0>
<cfset setorder=0>

<cfset lstIncludeDO="">
<cfloop index="idx" from="1" to="#ROWCOUNT#">
	<cfif isDefined("TXTPARTNO_"&idx)>
		<cfif evaluate("hdndorder_#idx#") neq prevorder>
			<cfset setorder=setorder+1>
			<cfset prevorder=evaluate("hdndorder_#idx#")>
		</cfif>
		<cfset TotalPrice = #replace(evaluate("txtConvertedAmount_"&idx),",","","ALL")#>
		<cfset TotalPriceBase = TotalPrice * #val(replace(evaluate("txtCurr_#selCurrency#"),",","","ALL"))#>
		
		<cfset Price = #replace(evaluate("txtConvertedUnitPrice_"&idx),",","","ALL")#> 
		<cfset PriceBase = price * #val(replace(evaluate("txtCurr_#selCurrency#"),",","","ALL"))#>
		 
		<cfquery name="qCheckItem" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
			SELECT habis FROM Titem WHERE item_code ='#evaluate("TXTPARTNO_"&idx)#'
		</cfquery>
		<cfset lstIncludeDO=ListAppend(lstIncludeDO,#qCheckItem.habis#)>
		 
		<CFIF txtSOtype eq "1">
			<cfset TaxAmount1 =  #val(replace(evaluate("txtTaxAmount1_#idx#"),",","","ALL"))#>
		<cfelse> 
			<cfset TaxAmount1 =0>
		</cfif>
		<cfset TaxAmount2 =  #val(replace(evaluate("txtTaxAmount2_#idx#"),",","","ALL"))#> 
		 <cfset local.ETADetail = "">
		 <cfif isdefined("txtEstimateDateSplit_#idx#")>
		 	<cfset local.ETADetail = evaluate("txtEstimateDateSplit_#idx#")>
		 </cfif>
		
        <cfif local.ETADetail neq "">
			<cfquery name="qPOETA" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
                <cfloop list="#local.ETADetail#" index="x">
                insert into TAccSO_ETA
                (SO_Number,Item_Code,Qty,EstimateDate,dimension_id)
                values(
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#SONum#"/>
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('TXTPARTNO_'&idx)#"/>
                ,#ListGetAt(x,2,'|')#
                ,#createodbcdate(ListGetAt(x,1,'|'))#
                ,#FORM['txtDimensionID_' & idx]#
                );
                </cfloop>
	        </cfquery>

        </cfif>
        
		<cfquery name="qSODetail" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
			INSERT INTO TAccSO_Detail (  
			   SO_Number,
			   Item_Code,
			   Item_description,
			   Qty,
			   <!--- add by meicy 20090910 --->
			   Qty2,
			   Unit_Type,
			   Unit_Type2,
			   <!--- end add by meicy --->
			   UnitPrice,
			   Base_UnitPrice,
			   Disc_Percentage,
			   Tax_Code1,Tax_Percentage1,Tax_Operator1,Tax_Amount1,
			   Tax_Code2,Tax_Percentage2,Tax_Operator2,Tax_Amount2,
			   TotalPrice,
			   Base_TotalPrice,
			   Include_DO,
			   Others,
			   CS_Number,
			   ExtraPrice,
			   EstimateDate,
			   generate_flag,
			   parent_item,
			   parent_path,
			   Comp_ID
			   ,config_level
               ,config_ratio,config_order
               <cfif rbTypeDoc IS 3>
                 , ref_id
               </cfif>
               ,Dimension_ID
               ,Disc_Value
			   ,isFreeItem
			   ,Notes
			)
			VALUES (  
			   '#SONum#',
			   '#evaluate("TXTPARTNO_#idx#")#',
			   '#evaluate("txtDesc_#idx#")#',
			   #val(replace(evaluate("txtQty_#idx#"),",","","ALL"))#,
			   <!--- add by meicy 20090910 --->
			   #val(replace(evaluate("txtQty2_#idx#"),",","","ALL"))#,
			   #evaluate("txtUnitID_#idx#")#,
<!---RIZAL, 03Feb10--->
<cfif #evaluate("txtUnitID2_#idx#")# neq ''>
#evaluate("txtUnitID2_#idx#")#
<cfelse>
0
</cfif>  
,
			   <!--- end add by meicy --->
			   #Price#,
			   #PriceBase#,
			   #val(replace(evaluate("TXTDISCOUNT1"&idx),",","","ALL"))#,
			   <cfif val(listgetat(evaluate("seltax1_#idx#"),2,"|")) neq 0 >
			   		'#listgetat(evaluate("seltax1_#idx#"),1,"|")#',#val(listgetat(evaluate("seltax1_#idx#"),2,"|"))#,'#listgetat(evaluate("seltax1_#idx#"),3,"|")#',#TaxAmount1#,
				<cfelse>
					0,0,0,0,
				</cfif>
				<cfif val(listgetat(evaluate("seltax2_"&idx),2,"|")) neq 0 >
					'#listgetat(evaluate("seltax2_#idx#"),1,"|")#',#val(listgetat(evaluate("seltax2_#idx#"),2,"|"))#,'#listgetat(evaluate("seltax2_#idx#"),3,"|")#',#TaxAmount2#,
				 <cfelse>
					0,0,0,0,
				</cfif>
				#TotalPrice#,
				#TotalPriceBase#,
				<cfif #qCheckItem.habis# eq 1>1<cfelse>0</cfif>,
				'#evaluate("txtOthers_#idx#")#',
				'#evaluate("txtCS_#idx#")#',
				#replace(evaluate("txtExtra_#idx#"),",","","ALL")#,
				<cfif not isdefined("txtEstimateDate_#idx#") or evaluate("txtEstimateDate_#idx#")  eq "">#createodbcdate(createdate(year(txtSOdate),month(txtSODate),day(txtSODate)))#<cfelse>#createodbcdate(evaluate("txtEstimateDate_#idx#"))#</cfif>
				,'#form["HID_generate_flag_#idx#"]#'
				,'<cfif evaluate("form.parent_item_#idx#") IS "undefined">0<cfelse>#form["parent_item_#idx#"]#</cfif>'
				,'<cfif evaluate("form.parent_path_#idx#") IS "undefined">0<cfelse>#form["parent_path_#idx#"]#</cfif>'
				,#Evaluate("selComponent_#idx#")#
				,<cfif isdefined("form.hdnLevel_#idx#")>#val(form["hdnLevel_#idx#"])#<cfelse>NULL</cfif>
				,<cfif isdefined("form.hdnRatio_#idx#")>#val(form["hdnRatio_#idx#"])#<cfelse>NULL</cfif>
				,#setorder#
                <cfif rbTypeDoc IS 3>
                 , #FORM['hdnSCDetailID_' & idx]#
               </cfif>
               ,#FORM['txtDimensionID_' & idx]#
               ,'#val(replace(evaluate("txtDisc_"&idx),",","","ALL"))#,'
			   ,'0'
			   ,'#FORM['txtNotes_' & idx]#'
			 );
			 SELECT @@IDENTITY AS 'Identity';
		</cfquery>
	</cfif>
</cfloop>

<!--- add by NP, 04 Mei 2011 --->
<!--- <cfif task eq "edit">
	<cfquery name="qDelFreeItem" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		DELETE FROM TACCSO_Detail
		WHERE SO_NUMBER = '#SONum#'
		AND IsFreeItem = 1
	</cfquery>
</cfif> --->
<cfif isdefined("hdnCount")>
<cfloop from="1" to="#hdnCount#" index="idxFree">
<cfif isDefined("hdnFreeItemCode#idxFree#")>
<cfquery name="qInsertFreeItem" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	<cfscript>
    // Ambil data dari form/evaluate agar tidak perlu ngetik evaluate berkali-kali
    vItemCode    = evaluate("TXTPARTNO_#idx#");
    vItemDesc    = evaluate("txtDesc_#idx#");
    vQty         = val(replace(evaluate("txtQty_#idx#"), ",", "", "ALL"));
    vQty2        = val(replace(evaluate("txtQty2_#idx#"), ",", "", "ALL"));
    vUnit1       = evaluate("txtUnitID_#idx#");
    
    // Logika UnitID2
    vUnit2Raw    = evaluate("txtUnitID2_#idx#");
    vUnit2       = (vUnit2Raw neq '') ? vUnit2Raw : 0;

    // Logika Pajak 1
    vTax1Raw     = evaluate("seltax1_#idx#");
    vTax1Pct     = val(listGetAt(vTax1Raw, 2, "|"));
    vTax1Code    = (vTax1Pct neq 0) ? listGetAt(vTax1Raw, 1, "|") : 0;
    vTax1Op      = (vTax1Pct neq 0) ? listGetAt(vTax1Raw, 3, "|") : 0;
    vTax1Amt     = (vTax1Pct neq 0) ? TaxAmount1 : 0;

    // Logika Pajak 2
    vTax2Raw     = evaluate("seltax2_#idx#");
    vTax2Pct     = val(listGetAt(vTax2Raw, 2, "|"));
    vTax2Code    = (vTax2Pct neq 0) ? listGetAt(vTax2Raw, 1, "|") : 0;
    vTax2Op      = (vTax2Pct neq 0) ? listGetAt(vTax2Raw, 3, "|") : 0;
    vTax2Amt     = (vTax2Pct neq 0) ? TaxAmount2 : 0;

    // Logika Tanggal Estimasi
    if (not isDefined("txtEstimateDate_#idx#") or evaluate("txtEstimateDate_#idx#") eq "") {
        vEstDate = createODBCDate(createDate(year(txtSOdate), month(txtSODate), day(txtSODate)));
    } else {
        vEstDate = createODBCDate(evaluate("txtEstimateDate_#idx#"));
    }

    // Logika Parent Item & Path
    vParentItem  = (evaluate("form.parent_item_#idx#") eq "undefined") ? 0 : form["parent_item_#idx#"];
    vParentPath  = (evaluate("form.parent_path_#idx#") eq "undefined") ? 0 : form["parent_path_#idx#"];
    
    // Logika Level & Ratio (NULL handling)
    vLevel       = isDefined("form.hdnLevel_#idx#") ? val(form["hdnLevel_#idx#"]) : "NULL";
    vRatio       = isDefined("form.hdnRatio_#idx#") ? val(form["hdnRatio_#idx#"]) : "NULL";

    vDiscValue   = val(replace(evaluate("txtDisc_#idx#"), ",", "", "ALL"));
</cfscript>
<cfquery name="qInsertDetail" datasource="#DSN#">
    INSERT INTO TAccSO_Detail SET
        SO_Number        = '#SONum#',
        Item_Code        = '#vItemCode#',
        Item_description = '#vItemDesc#',
        Qty              = #vQty#,
        Qty2             = #vQty2#,
        Unit_Type        = #evaluate("txtUnitID_#idx#")#,
        Unit_Type2       = #vUnit2#,
        UnitPrice        = #Price#,
        Base_UnitPrice   = #PriceBase#,
        Disc_Percentage  = #val(replace(evaluate("TXTDISCOUNT1"&idx),",","","ALL"))#,
        
        Tax_Code1        = '#vTax1Code#',
        Tax_Percentage1  = #vTax1Pct#,
        Tax_Operator1    = '#vTax1Op#',
        Tax_Amount1      = #vTax1Amt#,
        
        Tax_Code2        = '#vTax2Code#',
        Tax_Percentage2  = #vTax2Pct#,
        Tax_Operator2    = '#vTax2Op#',
        Tax_Amount2      = #vTax2Amt#,
        
        TotalPrice       = #TotalPrice#,
        Base_TotalPrice  = #TotalPriceBase#,
        Include_DO       = <cfif qCheckItem.habis eq 1>1<cfelse>0</cfif>,
        Others           = '#evaluate("txtOthers_#idx#")#',
        CS_Number        = '#evaluate("txtCS_#idx#")#',
        ExtraPrice       = #val(replace(evaluate("txtExtra_#idx#"),",","","ALL"))#,
        EstimateDate     = #vEstDate#,
        generate_flag    = '#form["HID_generate_flag_#idx#"]#',
        parent_item      = '<cfif evaluate("form.parent_item_#idx#") IS "undefined">0<cfelse>#form["parent_item_#idx#"]#</cfif>',
        parent_path      = '<cfif evaluate("form.parent_path_#idx#") IS "undefined">0<cfelse>#form["parent_path_#idx#"]#</cfif>',
        Comp_ID          = #evaluate("selComponent_#idx#")#,
        config_level     = #vLevel#,
        config_ratio     = #vRatio#,
        config_order     = #setorder#,
        Dimension_ID     = #form['txtDimensionID_' & idx]#,
        Disc_Value       = #val(replace(evaluate("txtDisc_"&idx),",","","ALL"))#,
        isFreeItem       = '0',
        Notes            = '#form['txtNotes_' & idx]#'

        <cfif rbTypeDoc IS 3>
            , ref_id = #form['hdnSCDetailID_' & idx]#
        </cfif>;

    SELECT @@IDENTITY AS 'Identity';
</cfquery>
</cfquery>
</cfif>
<!--- <cfquery name="qInsertHistory" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	INSERT INTO TFreeItemHistory
	(
	
	)
	VALUES
	(
	
	)
</cfquery> --->
</cfloop>
</cfif>

<!--- end --->

<cfquery name="qUpdateSO" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	UPDATE	TAccSO_Header
	SET		Include_DO = <cfif ListFindNOCase(lstIncludeDO,1)>1<cfelse>0</cfif>, Last_Update = GETDATE(), Update_By = #cookie.CKSATRIADEVID#
	WHERE 	SO_Number  = '#SONum#'
</cfquery>

<cfif isDefined("hdnTerm")><!--- add by wx, Sept 2009 --->
	<cfquery name="qDelCustDetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		DELETE FROM TACCCUSTOMERPAYMENT
		WHERE TRX_NUMBER = '#SONum#'
		AND DOC_TYPE = 'SO'
		AND COMPANY_ID = #COOKIE.COMPANYID#
	</cfquery>
	<cfif hdnTerm eq 0><cfset hdnTerm = 1></cfif>
	<cfloop index="id" from="1" to="#hdnTerm#">
		<cfquery name="qInsCustDetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			INSERT INTO TACCCUSTOMERPAYMENT 
			( 
				TRX_NUMBER, DOC_TYPE, 
				COMPANY_ID, PAYMENT_PERIOD, 
				INVOICE_DATE, DUE_DATE, AMOUNT, 
				UPDATED_BY, LAST_UPDATE, TOP_CODE )
			VALUES
			( 
			'#SONum#', 'SO', 
			#COOKIE.COMPANYID#, '#ID#', 
			#CreateODBCDate(evaluate("txtInvoiceDate#id#"))#, #CreateODBCDate(evaluate("txtDueDate#id#"))#,  #replacenocase(evaluate("txtAmount#id#"),",","","All")#, 
			'#COOKIE.CKSATRIADEVID#', #CreateODBCDateTime(now())#, '#cboTerms#'
			)
		</cfquery>
	</cfloop>
</cfif>

<!--- IVN : 10 May 2010 
ADD FUNCTION TO RESERVE DOCUMENT ITEM --->
<cfif (txtconfirm IS "YES" AND SELCATTYPE NEQ "AST") or  (isdefined("HIDREVISION") and HIDREVISION neq 0)>

  <cfscript>
    // CREATE OBJECT
	objInventory = createObject("component", "#Application.ComponentPath#.sunfisherp.inventory.inventorycomponent");
	objInventory.COMPANYID = COOKIE.COMPANYID;
	objInventory.LOCATION_ID = COOKIE.LOCATION_ID;
	
	objDummy = createObject("component", "#Application.ComponentPath#.sunfisherp.utility.cfdummy");
	
	// DECLARE GLOBAL VARIABLE
	local.objDocNumber = SONum;
	local.objDocType = "SO";
	local.strSQL = "";
	local.strMsg = "";
	
	try
	{
	  // DELETE RESERVED
	  objInventory.fntReservedDelete(local.objDocNumber);
	  
	  // COLLECT ITEM
	  local.strSQL = "SELECT"
				   & " soh.SO_Number AS DocNumber,"
				   & " soh.WH_ID,"

				   & " sod.Item_Code,"
				   & " sod.Dimension_ID,"
				   & " SUM(ISNULL(sod.Qty, 0)) AS RsvQty "
				   & "FROM"
				   & " TACCSO_HEADER soh"
				   & " INNER JOIN TACCSO_DETAIL sod"
				   & " ON sod.SO_Number = soh.SO_Number "
				   & "WHERE"
				   & " soh.SO_Number = '" & local.objDocNumber & "' "
				   & "GROUP BY"
				   & " soh.SO_Number, soh.WH_ID, sod.Item_Code, sod.Dimension_ID";
	  
	  dtsCollectItem = objDummy.cfreturnquery(local.strSQL);
	  
	  if(dtsCollectItem.recordcount)
	  {
		// INSERT RESERVED ITEM



		local.strMsg = objInventory.fntInsertReserved(local.objDocNumber, local.objDocType, dtsCollectItem);
	  }
	}
	catch(Any err)
	{
	  //objDummy.cfdump(err.Message);
	  local.strErrMsg = "Message&nbsp;:&nbsp;" & err.Message 
					  & "<br />"
					  & "Detail&nbsp;:&nbsp;An error has occured, please contact your system administrator!";
	  objDummy.cferror(ErrorText: local.strErrMsg, btnBack: true, btnClose: false, cfabort: true);
	}
  </cfscript>
</cfif>
<!--- END OF ADD --->
<cfquery name="qDelMisc" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	DELETE FROM TAccSO_MiscCharge
	WHERE SO_Number ='#SONum#'
	
	DELETE FROM TAccSO_MiscChargeAllocation
	WHERE SO_Number ='#SONum#'
</cfquery>

<cfset totalMisc = val(replace(evaluate("txtTotMiscCharge"),",","","ALL"))>
<cfset netAmountTotal = val(replace(evaluate("txtTotAmount"),",","","ALL"))>
<cfset taxMisc = 0>

<!--- START Add Misc --->
<cfloop from="1" to="#hidTransferMisc#" index="idx">
	<cfif isDefined ("txtMiscChargeID#idx#")>
				<cfset allotype = evaluate("selAllocationType#idx#")>
        <cfif val(listgetat(evaluate("selTaxMisc_#idx#"),2,"|")) neq 0 >
        		<cfset taxMisc = val(listgetat(evaluate("selTaxMisc_#idx#"),2,"|")) * val(replace(evaluate("txtConvertedAmountMisc_#idx#"),",","","ALL")) /100>
        </cfif>
        <cfset amountMisc = val(replace(evaluate("txtConvertedAmountMisc_#idx#"),",","","ALL"))>
        <cfif listgetat(evaluate("selTaxMisc_#idx#"),3,"|") eq '-'>
        	<cfset amountMisc = amountMisc - val(taxMisc)>
        <cfelse>
        	<cfset amountMisc = amountMisc + val(taxMisc)>
        </cfif>
        <cfset qtyAll = val(evaluate("hidQtyAll"))>
            <cfquery name="qInsSOMisc" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                INSERT INTO TAccSO_MiscCharge (SO_Number, MiscCharge_ID, Tax_Code,Amount,Notes,Allocation_Type)
                VALUES
                (
                    '#SONum#',
                    #evaluate('txtMiscChargeID#idx#')#,
                   <cfif val(listgetat(evaluate("selTaxMisc_#idx#"),2,"|")) neq 0 >
                      '#listgetat(evaluate("selTaxMisc_#idx#"),1,"|")#',
                  <cfelse>
                    0,
                  </cfif>
                  #val(replace(evaluate("txtConvertedAmountMisc_#idx#"),",","","ALL"))#,
                  '#evaluate('txtNotes#idx#')#',
                  #evaluate('selAllocationType#idx#')#
    
                )
             </cfquery>
    
        <cfloop from="1" to="#hidTransfer#" index="idx2">
            <cfif isDefined ("txtPartNoMisc#idx2#")>
                <cfif allotype eq 1>
                    <cfset netAmount = val(replace(evaluate("txtConvertedAmount_#idx2#"),",","","ALL"))>
                    <cfset amountAllo = netAmount*1000 / netAmountTotal * amountMisc/1000>
                <cfelseif allotype eq 2>
                    <cfset qtyItem = val(evaluate("txtQty_#idx2#"))>
                    <cfset amountAllo = qtyItem*1000 / qtyAll * amountMisc/1000>
                <cfelseif allotype eq 3>
                    <cfset amountAllo = amountMisc / hidCountTransfer>
                <cfelseif allotype eq 4>
                    <cfset amountNonUD = val(replace(evaluate("hidTotalMiscNonUD_#idx2#"),",","","ALL"))>
                    <cfset amountWithUD = val(replace(evaluate("txtConvertedAmountMisc2_#idx2#"),",","","ALL"))>
                    <cfset amountAllo = amountWithUD - amountNonUD>                
                </cfif>
            
                <cfquery name="qInsSOMiscDetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
                    INSERT INTO TAccSO_MiscChargeAllocation(SO_Number,Item_Code,Dimension_Id,Amount,MiscCharge_ID)
                    VALUES
                    (
                        '#SONum#',
                        '#evaluate("txtPartNoMisc#idx2#")#',
                         #evaluate('txtDimensionIDMisc#idx2#')#,
                          #val(amountAllo)#,
                          #evaluate('txtMiscChargeID#idx#')#
                    )
                </cfquery>
            </cfif>
        </cfloop>    
    </cfif>
</cfloop>

<!--- END Add Misc --->

<cfinclude template="qrycheckreference.cfm">
</cfoutput>

<!---<cfabort>--->

</cftransaction>

<!--- wx :: utk autoapproved --->
<cfif txtconfirm eq 'YES' and autocreate_var eq 1>
	<cfquery name="qEmpData" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		select 
			THRMEmpPersonalData.Emp_ID,
			ThrmEmpPosition.Position_ID
		from THRMEmpPersonalData
		inner join ThrmEmpPosition on ThrmEmpPosition.Emp_ID = THRMEmpPersonalData.Emp_ID
		inner join ThrmPosition on ThrmEmpPosition.position_id = ThrmPosition.position_id
			WHERE ThrmEmpPosition.company_id = #cookie.companyid#
           	and THRMEmpPersonalData.User_ID = '#COOKIE.CKSATRIADEVID#'
			AND	THRMPosition.Position_Flag = 3
    </cfquery>
	<cfset lstEmpPosition = valueList(qEmpData.Position_ID)>
		
	<cfquery name="qGetApprovalData" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
		SELECT THRMApprovedBy.ApprovedBy_ID, 
			isNull(CONVERT(VARCHAR,Approved_By),THRMApprovedBy.LstApprovedBy) Approved_By,	<!--- posisi Approver --->
			THRMApprovedBy.Is_Required,
			THRMApprovedBy.Flag_Turn
		FROM		THRMApprovedBy
		WHERE		ReqApproval_ID = '#SONum#'
		order by SettingApproval_StepData, ApprovedBy_Id asc
    </cfquery>

	<cfset form.hdnDO_2009_Approval = lstEmpPosition>
	<cfset form.hdnApprovedById = "">
	<cfloop query="qGetApprovalData">
		<cfset temporary.HasAccess = "false"/>
		<cfif qGetApprovalData.Flag_Turn eq 1>
			<cfloop list="#qGetApprovalData.Approved_By#" index="pos">	
				<cfif ListFind(lstEmpPosition,pos) gt 0>
	               	<cfset temporary.HasAccess = "true"/>
					<cfset form.hdnApproveBy = pos>
	            </cfif>
			</cfloop>
		</cfif>
		<cfif temporary.HasAccess eq "true">
			<cfset form.hdnApprovedById = ListAppend(form.hdnApprovedById,qGetApprovalData.ApprovedBy_id,",")>
			<cfset "FORM.cboStatus#qGetApprovalData.ApprovedBy_id#" = 3>
			<cfset "FORM.txtReason#qGetApprovalData.ApprovedBy_id#" = "Automatic Approved By System">
		</cfif>
	</cfloop>
	<cfif form.hdnApprovedById neq "">
		<cfset noreload = 1>
		<cfinclude template="#Application.stApp.CFWeb_Path[1]#/eaccounting/sales/so_inbox/queries/qupdate.cfm">
	</cfif>
</cfif>

	<!--- add by RF, to auto Approve and create SN (surat jalan) automatically 
	<cfif txtconfirm eq 'YES' and autocreate_var eq "true">
		<!--- init variabel --->
		<cfset Approveby = qSetting.requestby_posid>
		<cfset requester = qEmpData.emp_id>
		<cfset cbostatus = 3>
		<cfset txtReason = "Auto Approved by System">
		
		<cfset fromso = "YES">
		
		<!--- approved document --->
		<cfinclude template="#Application.stApp.CFWeb_Path[1]##Application.stApp.SPT[VST_IDX]##Application.stApp.Home_URL[VST_IDX]##Application.stApp.SPT[VST_IDX]#sales#Application.stApp.SPT[VST_IDX]#so_inbox#Application.stApp.SPT[VST_IDX]#queries/qupdate.cfm">									
		
		<cfif isdefined("cbautosn")>
				<!--- create DO --->
				<cfset txtconfirm = "NO"><!--- to avoid from auto approved in DO --->
				<cfset task = "save">
				<cfset istax = "no">
				<cfset SNTYPE = "SN_SAL">
				
				<!--- read so_header --->
				<cfquery name="qReadSo" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
					select
						account_id
					from
						taccso_header
					where
						so_number = '#SONum#'
				</cfquery>
				<!--- read so Detail --->
				<cfquery name="qReadSODetail" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
					select
						item_code, qty
					from
						taccso_detail
					where
						so_number = '#SONum#'
				</cfquery>
				<!--- for DO_header --->
				
				<cfset selreference = SONum>
				<cfset txtdodate = createODBCDATE(now())>
				<cfset txtmemo = "">
				<cfset dotype = "SN_SAL">
				<cfset selWH = #cookie.location_id#>
				<cfset accountid = #qReadSO.account_id#>
				<cfset txtship = "">
				<cfset txtVehicle = "">
				<cfset txtReference = "">

				
				<!--- for SO Detail --->
				<cfset BrsChk = qReadSODetail.recordCount>
				<cfset i = 1>
				<cfloop query="qReadSODetail">
					<cfset "chkItem#i#" = qReadSODetail.item_code>
					<cfset "TXTQTYDO#i#" = qReadSODetail.qty>
					<cfset "txtOthers_#i#" = "">
					<cfset i = i + 1>
				</cfloop>
				<cfinclude template="#Application.stApp.CFWeb_Path[1]##Application.stApp.SPT[VST_IDX]##Application.stApp.Home_URL[VST_IDX]##Application.stApp.SPT[VST_IDX]#inventory#Application.stApp.SPT[VST_IDX]#sn#Application.stApp.SPT[VST_IDX]#sn_history#Application.stApp.SPT[VST_IDX]#queries/qinsert.cfm">

		</cfif>
	</cfif>		--->

<cfoutput>	

<script type="text/javascript">
	alert("Sales Order No : #SONum#");
</script>

<cfif local.lstRefDoc IS "">
  <cfset vartemplate = "index.cfm">
  <cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785401&menu=1">
  
	<script>
	//	if (parent.top.frmMarquee != null){
	//		parent.top.frmMarquee.location.reload();
	//	}

		self.location = "#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&refresh=#URLEncodedFormat(now())#";
	</script>
<cfelse>
  <script>
    self.location = "#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/sales/so/forms/frmpickreference.cfm?DocNumber=#SONum#&RefDocument=#local.lstRefDoc#";
  </script>
</cfif>
</cfoutput>