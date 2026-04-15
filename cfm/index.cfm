<cfoutput> 
<cfset varSecAccess = REQUEST.SFSecAccess.SecAccessFile(FILEACCESSCODE="ERSTD0785401", BACKURL="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/index.cfm?selListItem=1&menu=0")>
<cfquery name="qStatus" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 		RequestSts,Request_type 
	FROM 		THRMRequestSts
</cfquery>
<CFSET LANGUAGELIST =  #ValueList(qStatus.Request_type)#>	
<CFSET LANGUAGELIST = LANGUAGELIST & ",Closed,Sales, SalesOrder, eAccSalesContract, History, SONumber, Customer, SODate, SOStatus, Approval,itemcategory, Page, Of, NoRecordFound, NewSO"
		& ",NewSOProject,Delete, SelectItemToDel, AreYouSure, eHRMClose, eHRMNew, eHRMOpen, dateFrom, dateTo, eHRMSearch, EdDateMustGTStDate, DateReq, EHRMALTDATE, createDocuments"
		& ", Invoiced, RawMaterial, FinishedGood, Supplies,Asset, commNumber, createDocuments, SelectOneDocumentOnly,AreYouSureWantedToDeleteThisDoc,CanNotReviseThisSO"
		& ",switchToTax, switchToNonTax,new,open,close,awaiting,eHRMApproved,rejected,revising,confirmEraseData,SoType,IsActive,All,Active,NotActive,SORevisionHistory,"
		& ",RawMaterial,FinishedGood,Asset,sparepart, ReviseSO, SODate ,PleaseSelectDocument, AreYouSureWanttoDelete, NoDocumentNumber,Currency, ChangeStatusSODoc,"
		& "AreYouSureWantedChangeThisDocStatus,SOTaxType,TaxIncludedInPrice,DocumentSummary,WIP,Local,Export,ApprovalFilterStatus,SOFilterStatus,DocumentFilterStatus,Normal,AttachmentFile,files,CustomerPONumber,PO_NUMCUSTOMER,ReviseRequestHistory,"
		& "DocumentStatus,Confirmed,Delivered">
<CF_DO_V25_MULTILANGUAGE MESSAGEIDLIST="#LanguageList#"> 

<cfparam name="filterStatus" default="">
<cfparam name="filterApprovalStatus" default="">
<cfparam name="filterDocStatus" default="">
<cfparam name="selCatType" default="FG">
<cfparam name="selSoType" default="Sal">
<cfparam name="selActive" default="-1">
<cfparam name="isExport" default="1">

<!--- ######################################################################################### --->
<!--- FOR STATUS DOCUMENT --->
<cfset functionid_var = 7854>
<!--- inisialisasi function image document --->
<cfset KEYID_VAR = "DOC">
<cfset liststatusiddoc = ""><!--- for the code --->
<cfset liststatusdoc = ""><!--- for the all data --->
<cfinclude template="#Application.stApp.CFWeb_Path[1]##Application.stApp.SPT[VST_IDX]##Application.stApp.SPT[VST_IDX]#include#Application.stApp.SPT[VST_IDX]#documentstatus/docstatus.cfm"> 
<!--- the output --->
<cfset liststatusiddoc = listresultid>
<cfset listStatusDoc = listresult>

<!--- inisialisasi function image document --->
<cfset KEYID_VAR = "APPROVAL">
<cfset liststatusapprovaliddoc = ""><!--- for the code --->
<cfset liststatusapprovaldoc = ""><!--- for the all data --->
<cfinclude template="#Application.stApp.CFWeb_Path[1]##Application.stApp.SPT[VST_IDX]##Application.stApp.SPT[VST_IDX]#include#Application.stApp.SPT[VST_IDX]#documentstatus/docstatus.cfm"> 
<!--- the output --->
<cfset liststatusapprovaliddoc = listresultid>
<cfset listStatusApprovalDoc = listresult>

<cfset functionid_var = 7854>
<!--- inisialisasi function image document --->
<cfset KEYID_VAR = "DOCSTATUS">
<cfset listdocstatus = ""><!--- for the code --->
<cfset listtitledocstatus = ""><!--- for the all data --->
<cfinclude template="#Application.stApp.CFWeb_Path[1]##Application.stApp.SPT[VST_IDX]##Application.stApp.SPT[VST_IDX]#include#Application.stApp.SPT[VST_IDX]#documentstatus/docstatus.cfm"> 
<!--- the output --->
<cfset listdocstatus = listresultid>
<cfset listtitledocstatus = listresult>
<!--- ######################################################################################### --->


<cfinclude template="#Application.stApp.CFWeb_Path[1]##Application.stApp.SPT[VST_IDX]##Application.stApp.SPT[VST_IDX]#include#Application.stApp.SPT[VST_IDX]#personalpreference/personalsetting.cfm"> 

<!--- Inisialisasi Fungsi Search (Begin) --->
<cfparam name="on_off" default=1>
<cfset DisplaySearch = 1>
<cfparam name="MaxSearchCriteria" default="5">	


<cfparam name="SortField" default="TAccSO_Header.SO_Number">	
<cfparam name="SortOrder" default="DESC">
<cfParam name="selPage"  default="1">	

<cfparam name="ExtraQuery" default="">	
<cfparam name="Condition" default="">	

<cfset LstSOStatus = "1,#DO_VAR['eHRMNew']#:2,#DO_VAR['eHRMopen']#:3,#DO_VAR['eHRMClose']#">

<cfset lstStatus = "">

<cfquery name="qSetting" datasource="#iif(isdefined('DSN'), 'DSN', 'Attributes.DSN')#">
	select * from TAccSetting
</cfquery>

<cfloop query="qStatus">
	<cfif qStatus.RequestSts neq 1>
		<cfset lstStatus = ListAppend(lstStatus,"#qStatus.RequestSts#,#DO_VAR['#qStatus.Request_type#']#",":")>
	</cfif>
</cfloop>
<cfquery name="qCurr" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
	Select Currency_ID from TCurrency
</cfquery>
<cfset LstCurr = "">
<cfloop query="qCurr">
	<cfset nilaibaris = "#Currency_id#,#Currency_id#">
	<cfset LstCurr = ListAppend(LstCurr,nilaibaris,":")>
</cfloop>

<cfset LstInvoiceStatus = "NI,No:FI,Yes">
<cfset LstDocStatus = "1,Open:2,Confirmed:3,Delivered:4,Invoiced:5,Closed">

<cfset Field = StructNew()>
<cfset Field.field1 = "SONumber;	DoString; 	TAccSO_Header.SO_Number">
<cfset Field.field2 = "Customer;	DoCustom; 	TAccount.Account_Name">
<cfset Field.field3 = "SOStatus;	DoSelect;	TAccSO_Header.SO_Status;#LstSOStatus#">
<cfset Field.field4 = "Approval;	DoSelect;	TAccSO_Header.Approval_Status;#lstStatus#">
<cfset Field.field5 = "Invoiced;	DoSelect;	TAccSO_header.Invoice_Status;#LstInvoiceStatus#">
<cfset Field.field6 = "Currency;	DoSelect;	TAccSO_header.Currency_ID;#LstCurr#">
<cfset Field.field7 = "SODate;		DoDate;		TAccSO_Header.SO_Date">
<cfset Field.field8 = "CustomerPONumber;		DoString;		TAccSO_Header.PO_NumCustomer">
<cfset Field.field9 = "DocumentStatus;		DoSelect;		TAccSO_Header.Doc_Status;#LstDocStatus#">

<cfinclude template="#Application.stApp.CFWeb_Path[1]##Application.stApp.SPT[VST_IDX]##Application.stApp.Home_URL[VST_IDX]##Application.stApp.SPT[VST_IDX]#include#Application.stApp.SPT[VST_IDX]#search_inc_1.cfm">
<cfparam name="isTAX" default="Tax">

<script>
	var arrNewPop = new Array()
	var arrNewPop2 = new Array()
	/*function changeTax(isTaxAble) {
		if (isTaxAble == 'NonTax') document.forms[0].isTax.value = 'Tax'
		else document.forms[0].isTax.value = 'NonTax'
		refresh2();
	}*/		
	function refresh2() {	
		document.forms[0].action = '#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_Url[VST_IDX]#/index.cfm?HelpCategory_id=eAccSales&Help_Id=SalesOrder&FID=7854&FCNT=yes&refresh=#URLEncodedFormat(now())#'
		document.forms[0].method = 'post';
		document.forms[0].submit();
	}
    
    function openUploadForm(docno)
	{
		if(docno && docno != ''){
			var winuploadform = window.open('#Application.stApp.Web_Path[VST_IDX]#/eaccounting/tools/docupload/uploadform.cfm?SFDOCNO='+docno,'winUpload','location=no,toolbar=no,scrollbars=yes,status=yes');
		} else {
			alert('#DO_VAR["NoDocumentNumber"]#');
		}
	}
    
</script><!--- #isTax# --->

<cfquery name="qResult" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
	SELECT 	TAccSO_Header.SO_Number,
			TAccSO_Header.SO_Date,
			TAccSO_Header.Approval_Status,
			TAccSO_Header.Invoice_Status,
			TAccSO_Header.SO_Status,
			TAccSO_Header.SN_Status,
			TAccSO_Header.isNotActive,
			TAccount.AccountTitle_Code,
			TAccount.Account_Name,
			isnull(TAccSO_Header.ReviseCounter,0) as ReviseCounter,
			TAccSO_Header.PO_NumCustomer,
            isClose, Doc_Status
	FROM 	TAccSO_Header, TAccount
	WHERE	TAccSO_Header.Account_ID = TAccount.Account_ID 
	AND 	TAccSO_Header.Company_ID = #Cookie.CompanyID#
	AND 	TAccSO_Header.WH_ID = #Cookie.Location_ID#
	And 	TAccSO_Header.SO_Date >= #CreateDateTime(year(txtDateFrom),month(txtDateFrom),day(txtDateFrom),00,00,00)#
	And 	TAccSO_Header.SO_Date <= #CreateDateTime(year(txtDateTo),month(txtDateTo),day(txtDateTo),23,59,59)#
	AND		TAccSO_Header.ItemCategoryType = '#selCatType#'
	<CFIF selSoType eq "ppn">
		And TAccSO_Header.SOType = 1
	<cfelseif selSoType eq "non">
		And TAccSO_Header.SOType = 0
	</CFIF>
	<cfif isDefined("selActive") and selActive neq -1>
		<cfif selActive eq "">
			AND (TAccSO_header.isNotActive is NULL or TAccSO_Header.IsNotActive <> 1)
		<cfelse>
			AND TAccSO_header.isNotActive = 1
		</cfif>
	</cfif>
	<cfif ExtraQuery neq "">AND ( #PreserveSingleQuotes(ExtraQuery)# )</cfif>
	<cfif filterStatus neq "">
		AND	TAccSO_header.SO_Status in (#filterStatus#)
	</cfif>
	<cfif filterApprovalStatus neq "">
		AND	TAccSO_header.Approval_Status in (#filterApprovalStatus#)
	</cfif>
    <cfif filterDocStatus neq "">
		AND	TAccSO_header.Doc_Status in (#filterDocStatus#)
	</cfif>
	<cfif IsDefined("REQUEST.vauthaccountfilter") AND REQUEST.vauthaccountfilter neq "">
		AND	TAccount.Category_ID IN (#preservesinglequotes(REQUEST.vauthaccountfilter)#)
	</cfif>	
     <cfif isDefined("isExport")>
    	AND isNULl(TaccSO_Header.isExport,0) = #isExport#
    </cfif>
	ORDER BY #SortField# #SortOrder#
</cfquery>
<cfquery name="qAllDoc" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	select count(*) as CountALL from TAccSO_Header where wh_id = #COOKIE.Location_ID#
</cfquery>
<cfquery name="qAllDocType" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
	select ItemCategoryType, count(SO_Number) as CountALL from TAccSO_Header where wh_id = #COOKIE.Location_ID# Group By ItemCategoryType 
</cfquery>
<cfset TotalPage = Ceiling(qResult.recordCount / varMaxRows)>
<cfif selPage gt 1>
	<cfset StartRow = ((selPage-1)*varMaxRows) + 1>
<cfelse>
	<cfset StartRow = 1	>
</cfif>
<cfset EndRow = StartRow+varMaxRows-1>
<cfif EndRow gt qResult.RecordCount>
	<!--- 	
		Jika data halaman terakhir lebih sedikit dari record yang ada, gunakan jumlah data terakhir saja 
		co: data halaman terakhir (hal 4) ada 13 data (tiap halaman 20 data), di settingan, tiap hal ditampilkan 20 data.
		Jadi, tampilkan data yang ke 61 s/d 73; bukan data ke 61 s/d 80 
	--->
	<cfset EndRow = qResult.RecordCount>
</cfif>

<form method="post" name="frmSearch">
<input type="hidden" name="txtDel" value="1">
<table width="100%" class="formtitle" border="0" cellspacing="1" cellpadding="1">
<tr>
	<!--- Judul --->
  	<td>
		<img src="#Application.stApp.Upload_Path[1]#/doadminsite/money2.gif" width="18" height="18" border="0" alt="">
		<!--- <input type="Hidden" name="isTax" value="#isTax#"> --->
		#DO_VAR["Sales"]# | #DO_VAR["SalesOrder"]# | #DO_VAR["SalesOrder"]# <!--- | #DO_VAR["History"]# --->
	</td>
</tr>
<tr>
  	<!--- Fasilitas Pencarian --->
  	<td >
		<table width="100%" class="formbody" cellpadding="1" cellspacing="1" border="0">
		<tr>
			<td bgcolor="##FFFFFF">
				<cfinclude template="#Application.stApp.CFWeb_Path[1]##Application.stApp.SPT[VST_IDX]##Application.stApp.Home_URL[VST_IDX]##Application.stApp.SPT[VST_IDX]#include#Application.stApp.SPT[VST_IDX]#search_inc_3.cfm">
			</td>
		</tr>
        <tr>
            <td align="center" colspan="2">		
                <table width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                    <td class="formbody">
                    <div class="left_panel">
                        <table  cellpadding="2" cellspacing="0" border="0" class="formtext">					
                            <tr>
                                <td align="left" nowrap>			
                                    #DO_VAR['SOTaxType']#
                                  <select name="selSoType" onChange="ganti();frmSearch.submit();"> 
                                        <option value="All" <cfif selSoType eq "All">selected</cfif>>[#DO_VAR["All"]#]
                                        <option value="ppn" <cfif selSoType eq "ppn">selected</cfif>>#DO_VAR["normal"]#
                                        <option value="non" <cfif selSoType eq "non">selected</cfif>>#DO_VAR["TaxIncludedInPrice"]#
                                  </select>
                                    #DO_VAR["itemcategory"]#&nbsp;&nbsp;<select name="selCatType" onChange="ganti();refresh();">
                                            <!--- <option value="AST" <cfif selCatType eq "AST">selected</cfif>>#DO_VAR["Asset"]# --->
                                            <option value="RM" <cfif selCatType eq "RM">selected</cfif>>#DO_VAR["RawMaterial"]# 
                                            <option value="FG" <cfif selCatType eq "FG">selected</cfif>>#DO_VAR["FinishedGood"]#
                                            <option value="SP" <cfif selCatType eq "SP">selected</cfif>>#DO_VAR["Supplies"]#
                                            <option value="WIP" <cfif selCatType eq "WIP">selected</cfif>>#DO_VAR["WIP"]# 
                                    </select>
                                    #RepeatString("&nbsp;",2)#
                                    #DO_VAR["IsActive"]#
                                  <select name="selActive" onChange="ganti();document.frmSearch.submit();">
                                        <option value="-1" <cfif selActive eq -1>selected</cfif>>#DO_VAR["ALL"]#
                                        <option value="" <cfif selActive eq "">selected</cfif>>#DO_VAR["Active"]#
                                        <option value="1" <cfif selActive eq 1>selected</cfif>>#DO_VAR["NotActive"]#
                                  </select>
                                  
                                  <input type="radio" name="isExport" value="0"  <cfif isExport eq 0> checked </cfif> onClick="ganti();refresh();"/> #DO_VAR["Local"]#
                                  <input type="radio" name="isExport" value="1"  <cfif isExport eq 1> checked </cfif> onClick="ganti();refresh();"/> #DO_VAR["Export"]#
                                </td>						
                                <td rowspan="2" valign="top" align="center" width="160px">
                                    #RepeatString("&nbsp;",2)#<a onClick="displaySummary();">-- #DO_VAR["DocumentSummary"]# --</a>
                                    <div id="summary" style="display:none">
                                        <strong>All Doc: #qAllDoc.CountALL#</strong><br>
                                        <cfloop query="qAllDocType">
                                            #ItemCategoryType# - #CountAll#<br>
                                        </cfloop>
                                    </div>
                                </td>
                                
                                <td rowspan="2" valign="top" align="center">
                                  <div class="right_panel" style="margin-left:10px;padding-left:10px;padding-right:10px;">
                                
                                <!--- randytia 08-02-2010 --->
                                <!--- <cfset listdocstatus = "58.gif,list.png,icon_truck_big.png,money.gif,boxin.gif">
                                <cfset listtitledocstatus = "Open,Confirmed,Delivered,Invoiced,Closed"> --->
                                <fieldset style="width:150px;" class="status_layer">
                                <legend>&nbsp;#DO_VAR["DocumentFilterStatus"]#&nbsp;</legend>
                                <cfloop list="#listdocstatus#" delimiters="," index="i"><!--- <cfloop From = "1" To = "#ListLen(listdocstatus)#" index="i"> --->
                                    <!--- <cfset picture = listGetAt(listdocstatus, i, ",")>
                                    <cfset picture_title = listGetAt(listtitledocstatus, i, ",")> --->
                                    <cfset picture = listGetAt(listGetAt(listtitledocstatus, listFind(listdocstatus, i, ","), "~"), 3, "|")>
                                    <cfset alt_picture = DO_VAR[listGetAt(listGetAt(listtitledocstatus, listFind(listdocstatus, i, ","), "~"), 2, "|")]>
                                    <!--- <a href="javascript:filter(#i#);"><img title="#picture_title#" src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/#picture#" border="0" style="opacity:0.3;filter:alpha(opacity=30)" width="20" height="20"></a>&nbsp; --->
                                    <a href="javascript:filterDocStatus(#i#);"><img src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/#picture#" width="20" height="20" border="0" alt="#alt_picture#" title="#alt_picture#" <cfif not listFind(filterDocstatus, i, ",")> style="opacity:0.3;filter:alpha(opacity=30)" </cfif>></a>&nbsp;
                                </cfloop>										
                                </fieldset>
                                <script>
                                    function filterDocStatus(x){
                                        var doc = document.frmSearch;							
                                        var thelist	= doc.filterDocStatus.value;
                                        var newlist = "";
                                        var flagnew	= 1;
                                        
                                        if(thelist == ""){
                                            newlist = x;
                                        }else{
                                            if(parseFloat(thelist.split(',').length) == 1){								
                                                if(thelist != x){
                                                    newlist = thelist + ',' + x;
                                                }
                                            }else{
                                                for(i=0; i<thelist.split(',').length; i++){
                                                    if(thelist.split(',')[i] != x){
                                                        if(newlist == ""){
                                                            newlist = thelist.split(',')[i];
                                                        }else{
                                                            newlist = newlist + ',' + thelist.split(',')[i];
                                                        }																
                                                    }else{
                                                        flagnew = 0;
                                                    }
                                                }									
                                                if(flagnew == 1){
                                                    newlist = newlist + ',' + x;
                                                }
                                            }
                                        }					
                                        document.frmSearch.filterDocStatus.value = newlist;
                                        document.frmSearch.selPage.value = 1;
                                        document.frmSearch.action ='';
                                        document.frmSearch.submit();
                                    }
                                </script>
                                <!--- End --->
                                
                                <fieldset style="width:150px;" class="status_layer">
                                <legend>&nbsp;#DO_VAR["SOFilterStatus"]#&nbsp;</legend>									
                                <cfloop list="#liststatusiddoc#" delimiters="," index="i">
                                    <cfset picture = listGetAt(listGetAt(listStatusDoc, listFind(liststatusiddoc, i, ","), "~"), 3, "|")>
                                    <cfset alt_picture = DO_VAR[listGetAt(listGetAt(listStatusDoc, listFind(liststatusiddoc, i, ","), "~"), 2, "|")]>
                                    <a href="javascript:filter(#i#);"><img src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/#picture#" border="0" alt="#alt_picture#" title="#alt_picture#" <cfif not listFind(filterstatus, i, ",")> style="opacity:0.3;filter:alpha(opacity=30)" </cfif>></a>&nbsp;
                                </cfloop>										
                                </fieldset>
                                <script>
                                    function filter(x){
                                        var doc = document.frmSearch;							
                                        var thelist	= doc.filterStatus.value;
                                        var newlist = "";
                                        var flagnew	= 1;
                                        
                                        if(thelist == ""){
                                            newlist = x;
                                        }else{
                                            if(parseFloat(thelist.split(',').length) == 1){								
                                                if(thelist != x){
                                                    newlist = thelist + ',' + x;
                                                }
                                            }else{
                                                for(i=0; i<thelist.split(',').length; i++){
                                                    if(thelist.split(',')[i] != x){
                                                        if(newlist == ""){
                                                            newlist = thelist.split(',')[i];
                                                        }else{
                                                            newlist = newlist + ',' + thelist.split(',')[i];
                                                        }																
                                                    }else{
                                                        flagnew = 0;
                                                    }
                                                }									
                                                if(flagnew == 1){
                                                    newlist = newlist + ',' + x;
                                                }
                                            }
                                        }					
                                        document.frmSearch.filterStatus.value = newlist;
                                        document.frmSearch.selPage.value = 1;
                                        document.frmSearch.action ='';
                                        document.frmSearch.submit();
                                    }
                                </script>
                                
                                <fieldset style="width:150px;" class="status_layer">
                                <legend>&nbsp;#DO_VAR["ApprovalFilterStatus"]#&nbsp;</legend>			
                                <cfloop list="#liststatusapprovaliddoc#" delimiters="," index="i">
                                    <cfset picture = listGetAt(listGetAt(listStatusApprovalDoc, listFind(liststatusapprovaliddoc, i, ","), "~"), 3, "|")>
                                    <cfset alt_picture = DO_VAR[listGetAt(listGetAt(listStatusApprovalDoc, listFind(liststatusapprovaliddoc, i, ","), "~"), 2, "|")]>
                                    <a href="javascript:filterApproval(#i#);"><img src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/#picture#" border="0" alt="#alt_picture#" title="#alt_picture#" <cfif not listFind(filterApprovalStatus, i, ",")> style="opacity:0.3;filter:alpha(opacity=30)" </cfif>></a>&nbsp;
                                </cfloop>
                                </fieldset>				
                                <script>
                                    function filterApproval(x){
                                        var doc = document.frmSearch;							
                                        var thelist	= doc.filterApprovalStatus.value;
                                        var newlist = "";
                                        var flagnew	= 1;
                                        
                                        if(thelist == ""){
                                            newlist = x;
                                        }else{
                                            if(parseFloat(thelist.split(',').length) == 1){								
                                                if(thelist != x){
                                                    newlist = thelist + ',' + x;
                                                }
                                            }else{
                                                for(i=0; i<thelist.split(',').length; i++){
                                                    if(thelist.split(',')[i] != x){
                                                        if(newlist == ""){
                                                            newlist = thelist.split(',')[i];
                                                        }else{
                                                            newlist = newlist + ',' + thelist.split(',')[i];
                                                        }																
                                                    }else{
                                                        flagnew = 0;
                                                    }
                                                }									
                                                if(flagnew == 1){
                                                    newlist = newlist + ',' + x;
                                                }
                                            }
                                        }						
                                        document.frmSearch.filterApprovalStatus.value = newlist;
                                        document.frmSearch.selPage.value = 1;
                                        document.frmSearch.action ='';
                                        document.frmSearch.submit();
                                    }
                                </script>
                            </div>
                                 </td>
                            </tr>
                            <tr>
                                <td>
                                    <cfinclude template="#Application.stApp.CFWeb_Path[1]##Application.stApp.SPT[VST_IDX]##Application.stApp.SPT[VST_IDX]#include#Application.stApp.SPT[VST_IDX]#personalpreference/dateanddisplay.cfm"> 
                                </td>
                            </tr>
                          </table>
                        </div>
                        
                        
                        
                        <div class="clear"></div>	
                        <table width="100%" id="tblIDX" border="0">
                        <tr class="formtext">
                            <td align="right" nowrap>
                                #DO_VAR["Page"]# :
                              <select name="selPage" onChange="refresh();">
                                    <cfif qResult.RecordCount eq 0>
                                        <option value="0">0
                                    <cfelse>
                                        <cfloop index="i" from="1" to="#TotalPage#">
                                            <option value="#i#" <cfif selPage eq i>Selected</cfif>>#i#
                                        </cfloop>
                                    </cfif>
                              </select>
                                #DO_VAR["Of"]# #TotalPage#
                            </td>					
                        </tr>					
                        </table>
                        
                        <table width="100%" id="tblIDX">
                        <tr class="heading2">
                            <td width="2%"><input type="Checkbox" name="chkAll" onClick="IsSelectAll(this)"></td>
                            <td width="4%" align="center">No.</td>
                            <td><b>#DO_VAR[trim(ListGetAt(Field.Field1,1,";"))]#</b><a href="javascript:Sort('#trim(ListGetAt(Field.Field1,3,";"))#','ASC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_up.gif" border="0" title="Asc"></a><a href="javascript:Sort('#trim(ListGetAt(Field.Field1,3,";"))#','DESC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_down.gif" border="0" title="Desc"></a></td>
                            <td><b>#DO_VAR[trim(ListGetAt(Field.Field2,1,";"))]#</b><a href="javascript:Sort('#trim(ListGetAt(Field.Field2,3,";"))#','ASC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_up.gif" border="0" title="Asc"></a><a href="javascript:Sort('#trim(ListGetAt(Field.Field2,3,";"))#','DESC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_down.gif" border="0" title="Desc"></a></td>
                            <td><b>#DO_VAR[trim(ListGetAt(Field.Field8,1,";"))]#</b><a href="javascript:Sort('#trim(ListGetAt(Field.Field8,3,";"))#','ASC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_up.gif" border="0" title="Asc"></a><a href="javascript:Sort('#trim(ListGetAt(Field.Field8,3,";"))#','DESC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_down.gif" border="0" title="Desc"></a></td>
                            <td><b>#DO_VAR['SODate']#</b><a href="javascript:Sort('#trim(ListGetAt(Field.Field7,3,";"))#','ASC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_up.gif" border="0" title="Asc"></a><a href="javascript:Sort('#trim(ListGetAt(Field.Field7,3,";"))#','DESC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_down.gif" border="0" title="Desc"></a></td>
                            <td align="center"><b>#DO_VAR[trim(ListGetAt(Field.field9,1,";"))]#</b><a href="javascript:Sort('#trim(ListGetAt(Field.field9,3,";"))#','ASC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_up.gif" border="0" title="Asc"></a><a href="javascript:Sort('#trim(ListGetAt(Field.field9,3,";"))#','DESC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_down.gif" border="0" title="Desc"></a></td>
                            <td><b>#DO_VAR[trim(ListGetAt(Field.Field3,1,";"))]#</b><a href="javascript:Sort('#trim(ListGetAt(Field.Field3,3,";"))#','ASC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_up.gif" border="0" title="Asc"></a><a href="javascript:Sort('#trim(ListGetAt(Field.Field3,3,";"))#','DESC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_down.gif" border="0" title="Desc"></a></td>
                            <td><b>#DO_VAR[trim(ListGetAt(Field.Field4,1,";"))]#</b><a href="javascript:Sort('#trim(ListGetAt(Field.Field4,3,";"))#','ASC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_up.gif" border="0" title="Asc"></a><a href="javascript:Sort('#trim(ListGetAt(Field.Field4,3,";"))#','DESC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_down.gif" border="0" title="Desc"></a></td>
                            <td nowrap><b>#DO_VAR[trim(ListGetAt(Field.Field5,1,";"))]#</b><a href="javascript:Sort('#trim(ListGetAt(Field.Field5,3,";"))#','ASC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_up.gif" border="0" title="Asc"></a><a href="javascript:Sort('#trim(ListGetAt(Field.Field5,3,";"))#','DESC');"><img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/arrow_down.gif" border="0" title="Desc"></a></td>
                            <td>#DO_VAR['isActive']#</td>
                            <td><b>#DO_VAR["AttachmentFile"]#</b></td>
							<td <cfif qSetting.EnableSORevision neq "1">style="display:none"</cfif>><b>#DO_VAR["SORevisionHistory"]#</b></td>
                        </tr>
                        <cfif not qResult.recordcount>
                            <tr class="tablebodyodd"><td align="center" colspan="12"><strong>..:: #DO_VAR["NoRecordFound"]# ::..</strong></td></tr>
                        <cfelse>
                            <cfset on_off=1>
                            <input type="Hidden" name="revise" value="0">
                            <cfloop query="qResult"  startrow="#StartRow#" endrow="#EndRow#">
                                <cfset on_off=not on_off>
                              <tr <cfif on_off>Class="TablebodyEven"<cfelse>Class="tablebodyodd"</cfif>>
                                <td width="2%"><input type="Checkbox" name="chk" value="#SO_Number#" onClick="pickThis(this)">
                                </td>
                                    <td width="4%" align="center">#currentrow#.</td>
                                    <td nowrap>
                                        <!--- cfquery name="qForm" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#" dbtype="ODBC">
                                            SELECT * FROM TDO_ACTION
                                            WHERE Action_ID = 2051
                                        </cfquery>
                                        <CF_DO_V25_PARAMPARSE QUERY_NAME="#qForm#"> --->
                                        <!--- <cfif SO_Status lt 2 > ---><!--- Open, tidak bisa di-edit lagi (1=New, 2=Open, 3=Closed)--->
                                        <!--- <a href="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/sales/so/forms/add.cfm?SONum=#so_number#">#SO_Number#</a> --->
                                        <cfset varStatusAccess = REQUEST.SFSecAccess.SecStatusAccess(FILEACCESSCODE="ERSTD0785403", USERID="#evaluate("cookie.#Application.stApp.Cookie_Name[1]#")#")>
                                      <cfif varStatusAccess eq "Yes">
                                            <cfset vartemplate = "index.cfm">
                                            <cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785403&menu=1">	
                                            <a href="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&SONum=#so_number#&isTax=#isTax#&task=Edit&selCatType=#selCatType#&isExport=#isExport#">#SO_Number#</a>
                                        <cfelse>
                                            #SO_Number#
                                </cfif>							</td>
                                    <td><cfif Len(trim(AccountTitle_Code)) gt 0>#AccountTitle_Code#. </cfif>#Account_Name#</td>
                                    <td>
                                    <cfif len(trim(PO_NumCustomer)) gt 0>
                                        #PO_NumCustomer#
                                    <cfelse>
                                        <em>-N/A-</em>
                                    </cfif>							</td>
                                    <td nowrap>
                                        <!--- <cfquery name="qUpdateSODate_POCustomer" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#" dbtype="ODBC">
                                               SELECT * FROM TDO_ACTION
                                               WHERE Action_ID=2792
                                           </cfquery>
                                           <CF_DO_V25_PARAMPARSE QUERY_NAME="#qUpdateSODate_POCustomer#"> --->
                                        <cfset varStatusAccess = REQUEST.SFSecAccess.SecStatusAccess(FILEACCESSCODE="ERSTD0785405", USERID="#evaluate("cookie.#Application.stApp.Cookie_Name[1]#")#")>
                                      <cfif varStatusAccess eq "Yes">
                                            <cfset vartemplate = "index.cfm">
                                            <cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785405&menu=1">	
                                        <a href="javascript://" onClick="arrNewPop2[arrNewPop2.length]=PopWindow('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&SO_Date=#SO_Date#&SO_Number=#SO_Number#&selCatType=#selCatType#','Preview','500','500','scrollbars=yes,status=yes,resizable=yes');" style="text-decoration:none;">
                                        #DateFormat(SO_Date,"dd mmm yyyy")#       	                            </a>
                                        <cfelse>
                                            #DateFormat(SO_Date,"dd mmm yyyy")#
                                      </cfif>                          </td>
                                  <td align="center" nowrap>
                                    <!--- randytia 08-02-2010 --->
                                    <cfif qResult.Doc_Status eq 1><img title="Open" src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/58.gif" border="0" alt="#alt_picture#" title="#alt_picture#" width="20" height="20">
                                    <cfelseif qResult.Doc_Status eq 2><img title="Confirm" src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/list.png" border="0" alt="#alt_picture#" title="#alt_picture#" width="20" height="20">
									<cfelseif qResult.Doc_Status eq 3 and qResult.SN_Status eq "ND"><img title="Confirm" src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/list.png" border="0" alt="#alt_picture#" title="#alt_picture#" width="20" height="20">
                                    <cfelseif qResult.Doc_Status eq 3 and qResult.SN_Status neq "ND"><img title="Delivered" src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/icon_truck_big.png" border="0" alt="#alt_picture#" title="#alt_picture#" width="20" height="20">
                                    <cfelseif qResult.Doc_Status eq 4><img title="Invoiced" src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/money.gif" border="0" alt="#alt_picture#" title="#alt_picture#" width="20" height="20">
                                    <cfelse><img title="Closed" src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/boxin.gif" border="0" alt="#alt_picture#" title="#alt_picture#" width="20" height="20">
                                    </cfif>
                                    <!--- End --->                        </td>
                                    <td align="center">
                                        <!---<cfif SO_Status eq 1>
                                            <cfset SOStatus = "#DO_VAR['New']#">
                                        <cfelseif SO_Status eq 2>
                                            <cfset SOStatus = "#DO_VAR["Open"]#">
                                        <cfelseif SO_Status eq 3>
                                            <cfset SOStatus = "#DO_VAR["Close"]#">
                                        </cfif>									
                                        #SOStatus#--->
                                        <cfset picture = listGetAt(listGetAt(listStatusDoc, listFind(liststatusiddoc, SO_Status, ","), "~"), 3, "|")>
                                        <cfset alt_picture = DO_VAR[listGetAt(listGetAt(listStatusDoc, listFind(liststatusiddoc, SO_Status, ","), "~"), 2, "|")]>
                                        <img src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/#picture#" border="0" alt="#alt_picture#" title="#alt_picture#">							</td>
                                    <td align="center">
                                        <!--- <cfquery name="Detail" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#" dbtype="ODBC">
                                            SELECT * FROM TDO_ACTION
                                            <!--- WHERE Action_ID=2169 --->
                                            WHERE Action_ID=2170
                                        </cfquery>
                                        <CF_DO_V25_PARAMPARSE QUERY_NAME="#Detail#"> --->
                                        <cfset varStatusAccess = REQUEST.SFSecAccess.SecStatusAccess(FILEACCESSCODE="ERSTD0785404", USERID="#evaluate("cookie.#Application.stApp.Cookie_Name[1]#")#")>
                                      <cfif varStatusAccess eq "Yes">
                                            <cfset vartemplate = "index.cfm">
                                            <cfset varquerystring = "?FID=ERSTD07802&FUID=ERSTD0780202&menu=1">	
                                            <a href="javascript:window.open('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&cboType=#selCatType#&SONum=#SO_Number#&isTax=#isTax#&task=Edit&isPopUp=yes','Detail','width=500, height=600, scrollbars=yes,status=yes,resizable=yes'); void(null);" >
                                        <!---<cfif Approval_Status eq 0>
                                            <cfset Approve = "#DO_VAR['New']#">
                                        <cfelseif Approval_Status eq 2>
                                            <cfset Approve = "#DO_VAR['Awaiting']#">
                                        <cfelseif Approval_Status eq 3>
                                            <cfset Approve  = "#DO_VAR['eHRMApproved']#">
                                        <cfelseif Approval_Status eq 4>
                                            <cfset Approve = "#DO_VAR['Rejected']#">
                                        <cfelseif Approval_Status eq 5>
                                            <cfset Approve = "#DO_VAR['Revising']#">
                                        </cfif>
                                        #Approve# --->
                                            <cfset picture = listGetAt(listGetAt(listStatusApprovalDoc, listFind(liststatusapprovaliddoc, Approval_Status, ","), "~"), 3, "|")>
                                            <cfset alt_picture = DO_VAR[listGetAt(listGetAt(listStatusApprovalDoc, listFind(liststatusapprovaliddoc, Approval_Status, ","), "~"), 2, "|")]>
                                            <img src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/#picture#" border="0" alt="#alt_picture#" title="#alt_picture#">								</a>
                                        <cfelse>
                                            <img src="#Application.stApp.Upload_Path[VST_IDX]#/eaccounting/images/docstatus/#picture#" border="0" alt="#alt_picture#" title="#alt_picture#">
                                      </cfif>
                                      <cfif ReviseCounter gt 0><font color="##808080">- Revise [#reviseCounter#]</font></cfif>							</td>
                                    <!--- 
                                        ini untuk menentukan apakah SO ybs bisa direvisi atau tidak
                                        syaratnya: 	1. approval statusnya harus approved atau rejected
                                                    2. masih ada barang yang bisa dikirim (SO - DO + SR)
                                     --->
                                    <cfquery name="qQtySO" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
                                        Select  sum(isnull(Qty,0)) as Qty
                                        From TAccSO_Detail
                                        where SO_Number = '#Trim(SO_Number)#'
                                    </cfquery>
                                    <cfquery name="qQtyDO" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
                                        Select  sum(isnull(Qty,0)) as Qty
                                        From taccSN_Item 
                                        inner join taccSN_Header On taccSN_Item.SN_number = taccSN_Header.SN_number
                                        where Ref_Number = '#Trim(SO_Number)#'
                                    </cfquery>
                                    <cfquery name="qQtySR" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
                                        Select  sum(isnull(Qty,0)) as Qty
                                        From TAccSR_Item 
                                        inner join TAccSR_Header On TAccSR_Item.SR_number = TAccSR_Header.SR_number
                                        where TAccSR_Header.SO_Number = '#Trim(SO_Number)#'
                                        <!--- And isnull(reserve_Status,0) <> 1 --->
                                    </cfquery>
                                    <cfset availPair = val(qQtySO.Qty) - val(qQtyDO.Qty) + val(qQtySR.Qty)>
                                    <cfset availAll = availPair>
                                    <!--- SO = #val(qQtySO.Qty)# - DO= #val(qQtyDO.Qty)# + SR= #val(qQtySR.Qty)#<br>
                                    P = #availPair#<br>  L = #AvailLeft#<br> R = #AvailRight#<br> --->
                                    <input type="Hidden" name="revise" <cfif (Approval_Status eq 3 or Approval_Status eq 4) and availAll gt 0>value="Yes"<cfelse>value="No"</cfif>>
                                    <!--- end --->
                                    <td align="center">
                                      <cfif Invoice_Status eq "NI">
                                            <img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/no.gif" border="0" title="No">
                                        <cfelse>
                                            <img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/yes.gif" border="0" title="Yes">
                                      </cfif>							</td>
                                    <td align="center">
                                      <cfif isNotActive eq 1>
                                            <img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/no.gif" border="0" title="No">
                                        <cfelse>
                                            <img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/yes.gif" border="0" title="Yes">
                                      </cfif>							
                                    <input type="hidden" name="hidden_isNotActive#currentrow#" value="#isNotActive#">
                                    </td>
                                    <cfquery name="qAttachment" datasource="#iif(isdefined('DSN'),'DSN','Attributes.DSN')#">
                                        select TAccDoc_Upload.* from TAccDoc_Relate
                                        INNER JOIN TAccDoc_Upload ON TAccDoc_Relate.DOCID = TAccDoc_Upload.docid
                                        WHERE SFDocNo = '#Trim(SO_Number)#'
                                    </cfquery>
                                <td style="text-align:center">
                                    <!--- <a target="_blank" href="#Application.stApp.Web_Path[VST_IDX]#/eaccounting/tools/docupload/uploadform.cfm?SFDOCNO=#SO_Number#">#DO_VAR["files"]#</a> --->	
                                    #qAttachment.recordcount#<a style="cursor:pointer;" onClick="openUploadForm('#SO_Number#')">#DO_VAR["files"]#</a></td>
								
								<td <cfif qSetting.EnableSORevision neq "1">style="display:none"</cfif>>
									<cfset vartemplate = "index.cfm">
									<cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785415&menu=1">
									<a href="javascript://" onClick="arrNewPop[arrNewPop.length]=PopWindow('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#vartemplate##varquerystring#&id=#so_number#&isTax=#isTax#&task=Edit&selCatType=#selCatType#&isExport=#isExport#','PORevisionHistory','500','300','scrollbars=yes,resizable=yes,location=no,status=no')" title="" OnMouseOver="window.status='';return true;" OnMouseOut="window.status='';">
									<img src="#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/images/list.gif" border="0" alt="#do_var['SORevisionHistory']#"> 
									</a>
									</td>	
                              </tr>
                            </cfloop>
                        </cfif>
                        </table>
                        <table align="left" border="0" width="100%">
                            <tr><td>&nbsp;</td></tr>
                            <tr>
                                <td>							
                                    <cfset varStatusAccess = REQUEST.SFSecAccess.SecStatusAccess(FILEACCESSCODE="ERSTD0785402", USERID="#evaluate("cookie.#Application.stApp.Cookie_Name[1]#")#")>
                                  <cfif varStatusAccess eq "Yes">
                                    <input type="button" name="BtnAdd" value="#DO_VAR['NewSO']#" onClick="addnew('newDoc')">
                                  </cfif>
                                    <!--- <input type="button" name="BtnAdd" value="#DO_VAR['ReviseSO']#" onclick="addnew('revise')" <cfif not qResult.recordcount>Disabled</cfif>>&nbsp; --->
                                    <cfset varStatusAccess = REQUEST.SFSecAccess.SecStatusAccess(FILEACCESSCODE="ERSTD0785406", USERID="#evaluate("cookie.#Application.stApp.Cookie_Name[1]#")#")>
                                  <cfif varStatusAccess eq "Yes">
                                    <input name="btnCreate" type="Button" id="btnCreate" onClick="createDocuments()" value="#DO_VAR['createDocuments']#" <cfif not qResult.recordcount>Disabled</cfif>>
                                  </cfif>
                                    <!--- <input type="button" value="#DO_VAR['eAccSalesContract']#" onclick="get_sales_contract()" /> --->
                                    <!--- <CF_DO_V30_AUTH_TOMBOL paramButtonName="btnSOStatus" granted="granted">
                                    <cfif granted> --->
                                    <cfset varStatusAccess = REQUEST.SFSecAccess.SecStatusAccess(FILEACCESSCODE="ERSTD0785408", USERID="#evaluate("cookie.#Application.stApp.Cookie_Name[1]#")#")>
                                  <cfif varStatusAccess eq "Yes">
                                    <input type="button" name="BtnChange" value="#DO_VAR['ChangeStatusSODoc']#" onClick="delIndex('inactive')" <cfif not qResult.recordcount>disabled</cfif>>
                                  </cfif>
                                    <!--- </cfif> --->
                                <!---</td>
                                <td align="right">--->
                                  <cfif qResult.recordcount>
                                        <cfset varStatusAccess = REQUEST.SFSecAccess.SecStatusAccess(FILEACCESSCODE="ERSTD0785407", USERID="#evaluate("cookie.#Application.stApp.Cookie_Name[1]#")#")>
                                    <cfif varStatusAccess eq "Yes">
                                      <input type="button" name="BtnDel" value="#DO_VAR['Delete']#" onClick="delIndex('delete')">
                                    </cfif>
                                  </cfif>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                </table>
            </td>
        </tr>
		</table>		
	</td>
</tr>


</table>
<cfinclude template="#Application.stApp.CFWeb_Path[1]##Application.stApp.SPT[VST_IDX]##Application.stApp.Home_URL[VST_IDX]##Application.stApp.SPT[VST_IDX]#include#Application.stApp.SPT[VST_IDX]#search_inc_2.cfm">  
<input type="Hidden" name="filterApprovalStatus" value="#filterApprovalStatus#">
<input type="Hidden" name="filterStatus" value="#filterStatus#">
<input type="Hidden" name="filterDocStatus" value="#filterDocStatus#">
<input type="Hidden" name="SortField" value="#SortField#">
<input type="Hidden" name="SortOrder" value="#SortOrder#">	
<input type="Hidden" name="JmlSearch" value="#JmlSearch#">
<input type="Hidden" name="DisplaySearch" value="0">
</form>
<script>
function delIndex(switchfunc) {
	//if(confirm('#DO_VAR['AreYouSureWanttoDelete']#')){
	chkObj = document.getElementsByName('chk');
	
	count = 0;
	selectedDoc = '';						
	
	for (i=0; i<chkObj.length; i++) {
		if (chkObj[i].checked==true) {
			count++;
			if(selectedDoc == "") {
				selectedDoc = chkObj[i].value;
			}else{
				selectedDoc = selectedDoc +','+chkObj[i].value;
			}
		}
	}
	if (count>0) {
		if (switchfunc == 'delete'){
			btnDisable()
			if(confirm("#DO_VAR['AreYouSureWantedToDeleteThisDoc']#")){
				<cfset vartemplate = "index.cfm">
				<cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785407&menu=1">	
				document.forms[0].action = '#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&selCatType=#selCatType#';
				document.forms[0].method = 'post';
				document.forms[0].submit();
			} else {
				btnEnable()
			}
		}
		else {
			if(confirm("#DO_VAR['AreYouSureWantedChangeThisDocStatus']#")){
				<cfset vartemplate = "index.cfm">
				<cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785408&menu=1">	
				window.open('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&sonum='+selectedDoc+'&selCatType=#selCatType#','winDocs','scrollbars=yes')
				//document.forms[0].action = '#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/sales/so/queries/qinactive.cfm';
				//document.forms[0].method = 'post';
				//document.forms[0].submit();
			}
		}
	}
	else {
		alert("#DO_VAR['PleaseSelectDocument']#!")
	}
}

function IsSelectAll(thisobj) {
	var chkObjs = document.getElementsByName('chk');
	if (thisobj.checked) {
		for (i=0; i<chkObjs.length; i++) {
			chkObjs[i].checked = true;

			selectedRows = document.getElementById('tblIDX').rows.length-1;
		}				
	}
	else {
		for (i=0; i<chkObjs.length; i++) {
			chkObjs[i].checked = false;
			selectedRows = 0
		}
	}
}

var selectedRows = 0

function pickThis (thisobj) {
	var TblObj = document.getElementById('tblIDX');
	var NumOfRows = TblObj.rows.length-1 // minus 1 because it's the header
	if (thisobj!= '') {
		if (thisobj.checked) selectedRows++;
		else selectedRows--;	
	}
	if (selectedRows==NumOfRows) document.forms[0].chkAll.checked = true;
		else document.forms[0].chkAll.checked = false;
}

function refresh () {
	<cfset vartemplate = "index.cfm">
	<cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785401&menu=1">	
	if (checkDateFromTo(document.forms[0].txtDateFrom, document.forms[0].txtDateTo)==true) {		
		document.forms[0].action = '#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&refresh=#urlencodedformat(now())#';
		document.forms[0].method = 'post';
		document.forms[0].submit();
	}
}
	
function changecbotype() {
	selCatType = document.forms[0].selCatType.value;
}
	
function addnew (type) {
	
	if (type == 'newDoc'){
		<!--- <cfquery name="Add" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#" dbtype="ODBC">SELECT * FROM TDO_ACTION  WHERE Action_ID=2051</cfquery><CF_DO_V25_PARAMPARSE QUERY_NAME="#Add#"> --->
		<cfset vartemplate = "index.cfm">
		<cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785402&menu=1">	
		document.forms[0].action = "#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&task=save&isTax=#isTax#";
		document.forms[0].method = 'post';
		document.forms[0].submit();
		}
	 
	else if(type == 'revise'){
		<cfquery name="revise" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#" dbtype="ODBC">
			SELECT * FROM TDO_ACTION
		    WHERE Action_ID=2325
		</cfquery>
		<CF_DO_V25_PARAMPARSE QUERY_NAME="#revise#">
	
		hit = 0
		validate = 0
		selectedDoc = ''
		objChk = document.getElementsByName('chk')
		for (i=0; i<objChk.length; i++) {
			if (objChk[i].checked) {	
				hit++
				selectedDoc = objChk[i].value
				if (document.frmSearch.revise[i+1].value == 'Yes') validate = 1 
			}
		}
		if (hit == 1) {
			if (validate == 1){
				document.forms[0].action = "#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&task=revise&isTax=#isTax#";
				document.forms[0].method = 'post';
				document.forms[0].submit();
			}
			else{
				alert("#DO_VAR['CanNotReviseThisSO']#")
			}
		}
	else if (hit == 0) alert("#DO_VAR['PleaseSelectDocument']#!")
	else alert("#DO_VAR['SelectOneDocumentOnly']#!");
	}
}

function createDocuments(type) {
	hit = 0
	selectedDoc = ''
	objChk = document.getElementsByName('chk')
	for (i=0; i<objChk.length; i++) {
		if (objChk[i].checked) {	
			hit++
			selectedDoc = objChk[i].value
		}
	}
	<!--- <cfquery name="Print" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#" dbtype="ODBC">SELECT * FROM TDO_ACTION	    WHERE Action_ID = 2206 	</cfquery>	<CF_DO_V25_PARAMPARSE QUERY_NAME="#Print#"> --->
	if (hit == 1) 
		<cfset vartemplate = "index.cfm">
		<cfset varquerystring = "?FID=ERSTD07854&FUID=ERSTD0785406&menu=1">	
		window.open('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/#varTemplate##varQueryString#&isTax=#isTax#&sonum='+selectedDoc,'winDocs','scrollbars=yes')
	else if (hit == 0) alert("#DO_VAR['PleaseSelectDocument']#!")
	else alert("#DO_VAR['SelectOneDocumentOnly']#!");
}

function get_sales_contract() {
	hit = 0;
	selectedDoc = '';
	objChk = document.getElementsByName('chk')
	for (i=0; i<objChk.length; i++) {
		if (objChk[i].checked) {	
			hit++;
			selectedDoc = objChk[i].value;
		}
	}
	if (hit == 1) {
		window.open('#Application.stApp.Web_Path[VST_IDX]#/#Application.stApp.Home_URL[VST_IDX]#/sales/so/forms/printcontract.cfm?sonum='+selectedDoc,'winSalesContract','scrollbars=yes');
	}
	else {
		if (hit == 0) {
			alert("#DO_VAR['PleaseSelectDocument']#!");
		}
		else {
			alert("#DO_VAR['SelectOneDocumentOnly']#!");
		}
	}
}

function displaySummary(){
	if(document.getElementById('summary').style.display == '') document.getElementById('summary').style.display = 'none'
	else document.getElementById('summary').style.display = ''
}

function btnDisable() {
	document.forms[0].BtnAdd.disabled=true;

	document.forms[0].btnCreate.disabled=true;
	document.forms[0].BtnChange.disabled=true;
	document.forms[0].BtnDel.disabled=true;
}

function btnEnable() {
	document.forms[0].BtnAdd.disabled=false;
	document.forms[0].btnCreate.disabled=false;
	document.forms[0].BtnChange.disabled=false;
	document.forms[0].BtnDel.disabled=false;
}

function ganti(){
	document.frmSearch.selPage.value = 1 ;
}

</script>
</cfoutput>