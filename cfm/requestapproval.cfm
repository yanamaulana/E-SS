<CFSET LANGUAGELIST = "eHRMManagerDesignatedSupervisor,eHRMStatus,eHRMApproveDate,eHRMRequired,eHRMReason,eHRMNew,eHRMChecked,eHRMAwaiting,eHRMApproved,eHRMRejected,eHRMRevising,eHRMRemains,eHRMAppReason ">
<CF_DO_V25_MULTILANGUAGE MESSAGEIDLIST="#LanguageList#"> 

<cfset qActiveLanguage.Field_Table=Application.stLang.Field_Table[ListFindNoCase(Application.stLang.Language_ID,cookie.lang_id)]>

<cfparam name="Attributes.DSN" default="">
<cfparam name="Attributes.ReqApproval_ID" default="">
<cfparam name="Attributes.RequestApproval_Name" default="">
<cfparam name="Attributes.Employee_ID" default="">
<cfparam name="Attributes.Company_ID" default="">
<cfparam name="Attributes.Amount" default="">
<cfparam name="Attributes.Action" default="">
<cfparam name="Attributes.APP_ID" default="53">
<cfparam name="Attributes.cf_Approved_By" default="">
<cfparam name="Attributes.cf_ApprovedBy_ID" default="">
<cfparam name="Attributes.VST_IDX" default="">
<cfparam name="ATTRIBUTES.AutoApproval" default=""/><!---return : apakah request ini merupakan transaksi auto approve atau bukan--->
<cfparam name="ATTRIBUTES.IsUpdatable" default="false"/><!--- return : true / false , jika current user memiliki akses u/ proses approval --->

<cfparam name="ATTRIBUTES.LastStatus" default=""/><!---return : posisi terakhir dari proses approval : [3=Approved | 2=awaiting | 4 = rejected | 5 = revising]--->
<cfparam name="ATTRIBUTES.RecordAffected" default=""/><!---return : jumlah data yang di masukkan ke database--->

<cfparam name="req_approval2009.SendNotification" default="true"/>
<cfparam name="req_approval2009.IsCSSGenerated" default="false"/>
<cfparam name="req_approval2009.User_ID" default=""/>
<cfparam name="req_approval2009.Employee_ID" default=""/>
<cfparam name="req_approval2009.Position_ID" default=""/>
<cfparam name="req_approval2009.Position_Name" default=""/>
<cfparam name="req_approval2009.Company_ID" default=""/>
<cfparam name="req_approval2009.Action" default=""/>
<cfparam name="req_approval2009.AutoApproval" default="false"/>
<cfparam name="req_approval2009.LastStatus" default="0"/>
<cfparam name="req_approval2009.DiffType" default="1"/>
<cfparam name="req_approval2009.IsUpdatable" default="false"/>
<cfparam name="req_approval2009.RecordAffected" default="0"/>
<cfset req_approval2009.HasApprovalEx = false/>
<cfif thisTag.ExecutionMode eq "start">
	<cfset Attributes.Amount  = #replace(Attributes.Amount,",","","ALL")#>
    
	<!---start: validasi--->
    <cfif Attributes.DSN eq "">
	    <cfoutput>
    	#GenerateError("Attributes.DSN is required")#
        </cfoutput>
    </cfif>
    
    <cfif Attributes.ReqApproval_ID eq "">
	    <cfoutput>
    	#GenerateError("Attributes.ReqApproval_ID is required")#
        </cfoutput>
    </cfif>
    <cfif Attributes.RequestApproval_Name eq "">
	    <cfoutput>
    	#GenerateError("Attributes.RequestApproval_Name is required")#
        </cfoutput>
    </cfif>
    
    <cfif Attributes.Employee_ID eq "">
    	<cfif not isDefined("cookie.CKSATRIADEVID")>
			<cfoutput>
			#GenerateError("Attributes.Employee_ID is required")#
			</cfoutput>
		<cfelse>
            <cfset req_approval2009.User_ID = #cookie.CKSATRIADEVID#/>
        </cfif>
    <cfelse>
    	<cfset req_approval2009.Employee_ID = Attributes.Employee_ID/>
    </cfif>
    
    <cfif Attributes.Company_ID eq "">
    	<cfif not isDefined("cookie.CompanyID")>
			<cfoutput>
			#GenerateError("Attributes.Company_ID is required")#
			</cfoutput>
        <cfelse>
   	       	<cfset req_approval2009.Company_ID = #cookie.CompanyID#/>
        </cfif>
    <cfelse>
    	<cfset req_approval2009.Company_ID = #Attributes.Company_ID#/>
    </cfif>
	<!---end: validasi--->
        
    <!---start: collecting data--->
    <cfquery name="qGetCurrentUserData" datasource="#ATTRIBUTES.DSN#">
		select 
		THRMEmpPersonalData.Emp_ID,
		ThrmEmpPosition.Position_ID,
		THRMEmpPersonalData.User_ID,
		ThrmEmpPosition.Company_ID,
		THRMPosition.Position_Name#qActiveLanguage.Field_Table# as PositionName
		from THRMEmpPersonalData
		inner join ThrmEmpPosition on ThrmEmpPosition.Emp_ID = THRMEmpPersonalData.Emp_ID
		inner join ThrmPosition on ThrmEmpPosition.position_id = ThrmPosition.position_id
			WHERE		ThrmEmpPosition.company_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.Company_ID#"/>
            <cfif req_approval2009.Employee_ID neq "">
            	and THRMEmpPersonalData.Emp_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.Employee_ID#"/>
            <cfelse>
	            and THRMEmpPersonalData.User_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.User_ID#"/>
            </cfif>
    </cfquery>
    <cfif qGetCurrentUserData.RecordCount eq "0">
		<cfoutput>
			#GenerateError("Current User Data is not found on database")#
		</cfoutput>
	<cfelse>
    	<cfset req_approval2009.User_ID = qGetCurrentUserData.User_ID />
    	<cfset req_approval2009.Employee_ID = qGetCurrentUserData.Emp_ID />
    	<cfset req_approval2009.Company_ID = qGetCurrentUserData.Company_ID />
        <cfset req_approval2009.Position_ID = ""/>
        <cfset req_approval2009.Position_Name = ""/>
        <cfloop query="qGetCurrentUserData">
	    	<cfset req_approval2009.Position_ID = ListAppend(req_approval2009.Position_ID,qGetCurrentUserData.Position_ID) />
	    	<cfset req_approval2009.Position_Name = ListAppend(req_approval2009.Position_Name,qGetCurrentUserData.PositionName) />
        </cfloop>
    </cfif>
	
	<!--- start : position id ketika confirm ambil dari default ajah--->
	<cfif req_approval2009.Action eq "NewTransaction">
	    <cfquery name="qGetDefaultPosition" datasource="#ATTRIBUTES.DSN#">
			select
			ThrmPosition.Position_ID,ThrmPosition.Position_Name#qActiveLanguage.Field_Table# PositionName
			from thrmEmpCompany
			inner join ThrmPosition on ThrmPosition.Position_ID = thrmEmpCompany.Position_ID
			where Emp_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#req_approval2009.Employee_ID#"/>
			and thrmEmpCompany.Company_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#req_approval2009.Company_ID#"/>
		</cfquery>
		<cfif qGetDefaultPosition.recordCount>
		    <cfset req_approval2009.Position_ID = qGetDefaultPosition.Position_ID />
		    <cfset req_approval2009.Position_Name = qGetDefaultPosition.PositionName />
		</cfif>
	</cfif>

    <cfif Attributes.Action neq "">
    	<cfset req_approval2009.Action = Attributes.Action />
    <cfelse>
		<cfif isnumeric(Attributes.Amount)>
            <cfset req_approval2009.Action = "NewTransaction" />
        </cfif>
        <cfif isDefined("form.hdnDO_2009_Approval")>
            <cfset req_approval2009.Action = "Save" />
        </cfif>
        <cfif req_approval2009.Action eq "">
            <cfset req_approval2009.Action = "form" />
        </cfif>
    </cfif>
    <!---end: decide action--->

    <!--- JIKA MERUPAKAN TRANSAKSI BARU, MISAL KETIKA CREATE SO --->
    <!---start: New Transaction--->
    <cfif req_approval2009.Action eq "NewTransaction">
		
	    <cfquery name="qGetCurrentApprovalStep" datasource="#ATTRIBUTES.DSN#">
         	select 
				THRMRequestApproval.RequestApproval_ID,
				THRMSettingApproval.SettingApproval_ID,
				THRMSettingApprovalDetail.SettingApproval_Step,
		        THRMSettingApprovalDetail.ApprovedBy_PosID,
				THRMSettingApprovalDetail.is_required,
				THRMRequestApproval.AppOrder_Type,
				THRMRequestApproval.AutoSelf_Approver AutoApprove
				<!--- ,THRMSettingApproval.AutoApprove --->
	        from THRMSettingApprovalDetail
		        inner join THRMSettingApproval on THRMSettingApprovalDetail.SettingApproval_ID = THRMSettingApproval.SettingApproval_ID
		        inner join THRMRequestApproval on THRMRequestApproval.RequestApproval_ID = THRMSettingApproval.RequestApproval_ID
	        where RequestBy_PosID in(#ListQualify(req_approval2009.Position_ID,"'")#)
		        and THRMRequestApproval.RequestApproval_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Attributes.RequestApproval_Name#"/>
				<!--- <cfif req_approval2009.DiffType eq "2">
		        and THRMSettingApproval.RangeFrom <=<cfqueryparam cfsqltype="cf_sql_money" value="#Attributes.Qty#">
		        and THRMSettingApproval.RANGETO >=<cfqueryparam cfsqltype="cf_sql_money" value="#Attributes.Qty#">
				<cfelse> --->
		        and THRMSettingApprovalDetail.From_Amount <=<cfqueryparam cfsqltype="cf_sql_money" value="#Attributes.Amount#">
		        and THRMSettingApprovalDetail.To_Amount >=<cfqueryparam cfsqltype="cf_sql_money" value="#Attributes.Amount#">
				<!--- </cfif> --->
				and ltrim(rtrim(isnull(THRMSettingApprovalDetail.ApprovedBy_PosID,''))) <> ''
			group by THRMRequestApproval.RequestApproval_ID,
					THRMSettingApproval.SettingApproval_ID,
					THRMSettingApprovalDetail.SettingApproval_Step,
			        THRMSettingApprovalDetail.ApprovedBy_PosID,
					THRMSettingApprovalDetail.is_required,
					THRMRequestApproval.AppOrder_Type,
					THRMRequestApproval.AutoSelf_Approver
			order by THRMSettingApprovalDetail.SettingApproval_Step asc
	    </cfquery>
		
        <cfif qGetCurrentApprovalStep.recordCount eq 0>
			<cfoutput>
					<!--- <cfif req_approval2009.DiffType eq "2">
					#GenerateError("Transaction created by " & req_approval2009.Position_Name & " does not have request approval setting yet for qty " & Attributes.Qty & ".<br/>Please contact your Admin.")#
					<cfelse> --->
					#GenerateError("Transaction created by " & req_approval2009.Position_Name & " does not have request approval setting yet for amount " & Attributes.Amount & ".<br/>Please contact your Admin.")#
					<!--- </cfif> --->
			</cfoutput>
        </cfif>
        
		<cfset req_approval2009.ApprovalStep = ArrayNew(1)/>
        <cfset temporary.counter = 0/>
		<cfset firstreqapproval = 0>
		<cfoutput query="qGetCurrentApprovalStep" group="SettingApproval_Step">
        	<cfset temporary.counter = temporary.counter + 1 />
        	<cfset temporary.settingstep = ""/>
            <cfset req_approval2009.ApprovalStep[temporary.counter] = Structnew()/>
            <cfset req_approval2009.ApprovalStep[temporary.counter].AutoApproval = qGetCurrentApprovalStep.AutoApprove/> 
            <cfset req_approval2009.ApprovalStep[temporary.counter].ApprovedBy_PosID = qGetCurrentApprovalStep.ApprovedBy_PosID/>
            <cfset req_approval2009.ApprovalStep[temporary.counter].RequestApproval_ID = qGetCurrentApprovalStep.RequestApproval_ID/>
			<cfset req_approval2009.ApprovalStep[temporary.counter].is_required = qGetCurrentApprovalStep.is_required/>
        	<cfoutput>
            	<cfset temporary.settingstep = listappend(temporary.settingstep,qGetCurrentApprovalStep.SettingApproval_ID & "|" & qGetCurrentApprovalStep.SettingApproval_Step) />
            </cfoutput>
            <cfset req_approval2009.ApprovalStep[temporary.counter].SettingApproval_StepData = temporary.settingstep/>
			<!--- wx :: approval bertingkat --->
			<cfset req_approval2009.ApprovalStep[temporary.counter].appOrder_Type = val(qGetCurrentApprovalStep.AppOrder_Type)/>
			<cfif val(qGetCurrentApprovalStep.AppOrder_Type) eq 1>
				<cfif firstreqapproval eq 0 and qGetCurrentApprovalStep.is_required eq 1>
					<cfset firstreqapproval = temporary.counter>
					<cfset req_approval2009.ApprovalStep[temporary.counter].flag_turn = 1/>
				<cfelse>
					<cfset req_approval2009.ApprovalStep[temporary.counter].flag_turn = 0/>
				</cfif>
			<cfelse>
				<cfset req_approval2009.ApprovalStep[temporary.counter].flag_turn = 1/>
			</cfif>
			<!---  --->
        </cfoutput>
        
		<cfif req_approval2009.HasApprovalEx >
			<cfquery name="qGetCurrentApprovalStepEx" datasource="#ATTRIBUTES.DSN#">	
			declare @Lookup table(
				Item_Code varchar(50),
				ItemCategory_ID int
			)
			insert into @Lookup
			(Item_Code,ItemCategory_ID)
			<cfswitch expression="#Attributes.RequestApproval_Name#">
				<cfcase value="eAccSalesOrder">
				SELECT tItem.Item_Code,tItem.ItemCategory_ID FROM TAccSO_Detail
				inner join tItem on TAccSO_Detail.Item_Code = tItem.Item_Code
				inner join tItemCategory on tItem.ItemCategory_ID = tItemCategory.ItemCategory_ID
				where TAccSO_Detail.SO_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Attributes.ReqApproval_ID#"/>;
				</cfcase>

                <cfcase value="eAccPurchaseOrder">
				SELECT tItem.Item_Code,tItemCategory.ItemCategory_ID FROM TAccPO_Detail
				inner join tItem on TAccPO_Detail.Item_Code = tItem.Item_Code
				INNER JOIN TitemCompany ON TItemCompany.Item_Code = tItem.Item_Code
				inner join tItemCategory on TitemCompany.ItemCategory_ID = tItemCategory.ItemCategory_ID
				where TAccPO_Detail.PO_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Attributes.ReqApproval_ID#"/>;
				</cfcase>
			</cfswitch>

			<!--- select 
			THRMRequestApproval.RequestApproval_ID,
			THRMSettingApprovalEx.SettingApproval_ID,
			THRMSettingApprovalDetailEx.SettingApproval_Step,
			THRMSettingApprovalDetailEx.ApprovedBy_PosID
			from THRMSettingApprovalDetailEx
			inner join THRMSettingApprovalEx on THRMSettingApprovalDetailEx.SettingApproval_ID = THRMSettingApprovalEx.SettingApproval_ID
			inner join THRMRequestApproval on THRMRequestApproval.RequestApproval_ID = THRMSettingApprovalEx.RequestApproval_ID
			where RequestBy_PosID in(#ListQualify(req_approval2009.Position_ID,"'")#)
			and THRMRequestApproval.RequestApproval_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Attributes.RequestApproval_Name#"/> --->
			
			select 
				THRMRequestApproval.RequestApproval_ID,
				THRMSettingApproval.SettingApproval_ID,
				THRMSettingApprovalDetail.SettingApproval_Step,
				THRMSettingApprovalDetail.is_required,
				THRMSettingApprovalDetail.ApprovedBy_PosID
			from THRMSettingApprovalDetail
				inner join THRMSettingApproval on THRMSettingApprovalDetail.SettingApproval_ID = THRMSettingApproval.SettingApproval_ID
				inner join THRMRequestApproval on THRMRequestApproval.RequestApproval_ID = THRMSettingApproval.RequestApproval_ID
			where RequestBy_PosID in(#ListQualify(req_approval2009.Position_ID,"'")#)
				and THRMRequestApproval.RequestApproval_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Attributes.RequestApproval_Name#"/>
				<!--- <cfif req_approval2009.DiffType eq "2">
		        and THRMSettingApproval.RangeFrom <=<cfqueryparam cfsqltype="cf_sql_money" value="#Attributes.Qty#">
		        and THRMSettingApproval.RANGETO >=<cfqueryparam cfsqltype="cf_sql_money" value="#Attributes.Qty#">
				<cfelse> --->
		        and THRMSettingApprovalDetail.From_Amount <=<cfqueryparam cfsqltype="cf_sql_money" value="#Attributes.Amount#">
		        and THRMSettingApprovalDetail.To_Amount >=<cfqueryparam cfsqltype="cf_sql_money" value="#Attributes.Amount#">
				<!--- </cfif> --->
			</cfquery>
			
			<cfset req_approval2009.ApprovalStepEx = ArrayNew(1)/>
			<cfset temporary.counter = 0/>
			<cfoutput query="qGetCurrentApprovalStepEx" group="SettingApproval_Step">
				<cfset temporary.counter = temporary.counter + 1 />
				<cfset temporary.settingstep = ""/>
				<cfset req_approval2009.ApprovalStepEx[temporary.counter] = Structnew()/>
				<cfset req_approval2009.ApprovalStepEx[temporary.counter].AutoApproval = 0/> 
				<cfset req_approval2009.ApprovalStepEx[temporary.counter].ApprovedBy_PosID = qGetCurrentApprovalStepEx.ApprovedBy_PosID/>
				<cfset req_approval2009.ApprovalStepEx[temporary.counter].RequestApproval_ID = qGetCurrentApprovalStepEx.RequestApproval_ID/>
				<cfset req_approval2009.ApprovalStepEx[temporary.counter].is_required = qGetCurrentApprovalStepEx.is_required/>
				<cfoutput>
					<cfset temporary.settingstep = listappend(temporary.settingstep,qGetCurrentApprovalStepEx.SettingApproval_ID & "Ex|" & qGetCurrentApprovalStepEx.SettingApproval_Step) />
				</cfoutput>
				<cfset req_approval2009.ApprovalStepEx[temporary.counter].SettingApproval_StepData = temporary.settingstep/>
				<cfset req_approval2009.ApprovalStepEx[temporary.counter].IsAppended = 0/>
			</cfoutput>
			
			<!---combine approval--->
			<cfloop from="1" to="#ArrayLen(req_approval2009.ApprovalStep)#" index="x">
				<cfloop from="1" to="#ArrayLen(req_approval2009.ApprovalStepEx)#" index="y">
					<cfif ((req_approval2009.ApprovalStep[x].ApprovedBy_PosID eq req_approval2009.ApprovalStepEx[y].ApprovedBy_PosID )and (req_approval2009.ApprovalStepEx[y].IsAppended eq 0 ))>
						<cfset temporary.dummy = req_approval2009.ApprovalStepEx[y].SettingApproval_StepData />
						<!---
						<cfloop list="#temporary.dummy#" index="z">
							<cfoutput>
							#z#
							</cfoutput>
						</cfloop>
						--->
						<cfset req_approval2009.ApprovalStep[x].SettingApproval_StepData = listappend(req_approval2009.ApprovalStep[x].SettingApproval_StepData,temporary.dummy)/>
						<cfset req_approval2009.ApprovalStepEx[y].IsAppended = 1 />
					</cfif>
				</cfloop>
			</cfloop>
			
			<cfset temporary.counter = arrayLen(req_approval2009.ApprovalStep)/>
			<cfloop from="1" to="#ArrayLen(req_approval2009.ApprovalStepEx)#" index="y">
				<cfif req_approval2009.ApprovalStepEx[y].IsAppended eq "0">
					<cfset temporary.counter = temporary.counter + 1 />
					<cfset req_approval2009.ApprovalStep[temporary.counter] = Structnew()/>
					<cfset req_approval2009.ApprovalStep[temporary.counter].AutoApproval = req_approval2009.ApprovalStepEx[y].AutoApproval /> 
					<cfset req_approval2009.ApprovalStep[temporary.counter].ApprovedBy_PosID = req_approval2009.ApprovalStepEx[y].ApprovedBy_PosID/>
					<cfset req_approval2009.ApprovalStep[temporary.counter].RequestApproval_ID = req_approval2009.ApprovalStepEx[y].RequestApproval_ID/>
					<cfset req_approval2009.ApprovalStep[temporary.counter].SettingApproval_StepData = req_approval2009.ApprovalStepEx[y].SettingApproval_StepData/>
					<cfset req_approval2009.ApprovalStep[temporary.counter].is_required = req_approval2009.ApprovalStepEx[y].is_required/>
				</cfif>
			</cfloop>

		</cfif>
	    <cfquery name="qInsertTHRMApprovedBy" datasource="#ATTRIBUTES.DSN#">
			delete THRMApprovedBy where ReqApproval_ID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Attributes.ReqApproval_ID#"/>
			
	        <cfloop from="1" to="#ArrayLen(req_approval2009.ApprovalStep)#" index="x">
                insert into THRMApprovedBy	(
					ReqApproval_ID,Employee_ID,Position_ID,LstApprovedBy,Approve_Status,LastApprove_Status,RequestApproval_ID,SettingApproval_StepData,is_required
					<!--- wx :: approval bertingkat --->
					,Flag_Turn,appOrder_Type
				)
                values(
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#Attributes.ReqApproval_ID#"/>
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.Employee_ID#"/>
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#ListGetAt(req_approval2009.Position_ID,1)#"/>
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.ApprovalStep[x].ApprovedBy_PosID#"/>
                ,0,0
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.ApprovalStep[x].RequestApproval_ID#"/>
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.ApprovalStep[x].SettingApproval_StepData#"/>
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.ApprovalStep[x].is_required#"/>
				<!--- wx :: approval bertingkat --->
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.ApprovalStep[x].flag_turn#"/>
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.ApprovalStep[x].appOrder_Type#"/>
                );
    
            </cfloop>
        </cfquery>

		
		<cfset req_approval2009.RecordAffected = ArrayLen(req_approval2009.ApprovalStep) />

            <cfloop from="1" to="#ArrayLen(req_approval2009.ApprovalStep)#" index="x">
				<cfif req_approval2009.ApprovalStep[x].AutoApproval eq "1">
					<cfset req_approval2009.AutoApproval = "true"/>
				</cfif>
            </cfloop> 

		<cfif req_approval2009.SendNotification eq "true">
			<!--- lakukan procedure send mail --->
            <cftry>
				<cfset temporary.PositionID = ""/>
                <cfloop query="qGetCurrentApprovalStep">
                    <cfset temporary.PositionID = ListAppend(temporary.PositionID,qGetCurrentApprovalStep.ApprovedBy_PosID)/>
                </cfloop>
                <cfquery name="qGetSendMailTo" datasource="#ATTRIBUTES.DSN#">
					select Emp_ID from thrmEmpPosition
					where Company_ID=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#req_approval2009.Company_ID#"/>
					and Position_ID in(#ListQualify(temporary.PositionID,"'")#)
                </cfquery>
                
                <cfloop query="qGetSendMailTo">
                    <CF_DO_V30_APPROVALMAIL TEMPLATE_NAME="eHRMFirstApproval"  TYPE_OF_REQUEST="#Attributes.RequestApproval_Name#"  URL="http://#CGI.SERVER_NAME#/#Application.stApp.Web_Path[Attributes.VST_IDX]#/#Application.stApp.Home_URL[Attributes.VST_IDX]#/default.cfm" REQUESTER="#req_approval2009.Employee_ID#" REQUEST_FOR="NONE" TO_APPROVER="#qGetSendMailTo.Emp_ID#" APPROVER="#qGetSendMailTo.Emp_ID#" REQUEST_NUMBER="#Attributes.ReqApproval_ID#" MAIL_TO="#qGetSendMailTo.Emp_ID#" IS_LEADER="0" APP_ID="#Attributes.APP_ID#" >  
                </cfloop>
                
                <cfcatch>
                </cfcatch>
            </cftry>

        </cfif>
    
    </cfif>
    <!---end: New Transaction--->

    <!---start: Form--->
    <cfif req_approval2009.Action eq "Form">
    	<!---
            select 
            THRMSettingApprovalDetail.SettingApproval_Step,
            THRMApprovedBy.ApprovedBy_ID,
			THRMApprovedBy.ReqApproval_ID,
			THRMApprovedBy.Employee_ID,	<!--- Requester --->
			THRMApprovedBy.Position_ID,	<!--- posisi Requester --->
			THRMApprovedBy.Approved_By,	<!--- posisi Approver --->
			THRMApprovedBy.Approved_EmpID,	<!--- Approver --->
			THRMApprovedBy.Approve_Date,	<!--- Approve Date--->
			THRMApprovedBy.Approve_Status,
			THRMApprovedBy.Approval_Note
            from THRMApprovedBy
            inner join THRMRequestApproval on THRMApprovedBy.RequestApproval_ID = THRMRequestApproval.RequestApproval_ID
            inner join THRMSettingApproval on THRMSettingApproval.RequestApproval_ID = THRMRequestApproval.RequestApproval_ID
            and THRMSettingApproval.RequestBy_PosID = THRMApprovedBy.Position_ID
            inner join THRMSettingApprovalDetail on THRMSettingApprovalDetail.SettingApproval_ID = THRMSettingApproval.SettingApproval_ID
            and THRMSettingApprovalDetail.ApprovedBy_PosID = THRMApprovedBy.Approved_By
            where THRMRequestApproval.RequestApproval_Name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Attributes.RequestApproval_Name#"/>
            and THRMApprovedBy.ReqApproval_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Attributes.ReqApproval_ID#"/>
            order by THRMSettingApprovalDetail.SettingApproval_Step asc
		--->
        <cfset req_approval2009.color = ArrayNew(1) />
        <cfset req_approval2009.color[1] = "ff9999"/>
        <cfset req_approval2009.color[2] = "00cc33"/>
        <cfset req_approval2009.color[3] = "ccffcc"/>
        <cfset req_approval2009.color[4] = "ffcc33"/>
        <cfset req_approval2009.color[5] = "996699"/>
        <cfset req_approval2009.color[6] = "990000"/>
        
	    <cfquery name="qGetApprovalData" datasource="#ATTRIBUTES.DSN#">
			SELECT THRMApprovedBy.ApprovedBy_ID, THRMApprovedBy.ReqApproval_ID,
				THRMApprovedBy.Employee_ID,	<!--- Requester --->
				THRMApprovedBy.Position_ID,	<!--- posisi Requester --->
				isNull(CONVERT(VARCHAR,Approved_By),THRMApprovedBy.LstApprovedBy) Approved_By,	<!--- posisi Approver --->
				THRMApprovedBy.Approved_EmpID,	<!--- Approver --->
				THRMApprovedBy.Approve_Date,	<!--- Approve Date--->
				THRMApprovedBy.Approve_Status,
				THRMApprovedBy.Approval_Note,
				isnull(THRMApprovedBy.SettingApproval_StepData,'') SettingApproval_StepData,
				THRMApprovedBy.Is_Required,
				THRMApprovedBy.Flag_Turn
			FROM		THRMApprovedBy
			WHERE		ReqApproval_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Attributes.ReqApproval_ID#"/>
			order by SettingApproval_StepData, ApprovedBy_Id asc
        </cfquery>
        <cfquery name="qStatus" datasource="#iif(isDefined('DSN'),'DSN','Attributes.DSN')#">
			SELECT RequestSts, Request_type FROM THRMRequestSts
			ORDER BY RequestSts
		</cfquery>
        <cfif qGetApprovalData.RecordCount>
			<table width="100%"  cellpadding="2" cellspacing="0">
            	<thead>
				<cfoutput>
				<tr>
					<th class="formtitle" style="text-align:left"><b>#DO_VAR["eHRMManagerDesignatedSupervisor"]#</b></th>
					<th class="formtitle" style="text-align:left">&nbsp;</th>
					<th class="formtitle" style="text-align:left"><b>#DO_VAR["eHRMStatus"]#</b></th>
					<th class="formtitle" style="text-align:left"><b>#DO_VAR["eHRMApproveDate"]#</b></th>
					<th class="formtitle" style="text-align:left"><b>#DO_VAR['eHRMReason']#</b></th>
				</tr>
                </cfoutput>
                </thead>
                <tbody>
                
				<cfset Temporary.ColorIndex = ""/>
                <cfoutput query="qGetApprovalData">
                	<cfset temporary.HasAccess = "false"/>
                    <cfif qGetApprovalData.Flag_Turn eq 1>
						<cfloop list="#qGetApprovalData.Approved_By#" index="pos">
		                    <cfif ListFind(req_approval2009.Position_ID,pos) gt 0>
			                	<cfset temporary.HasAccess = "true"/>
		                    </cfif>
						</cfloop>
					</cfif>
					<cfquery name="qDetEmpApp" datasource="#iif(isdefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
						SELECT 	THRMPosition.Position_Name#qActiveLanguage.Field_Table# AS Position_Name
						FROM 	THRMPOsition 
						WHERE 	THRMPosition.Position_Id IN (#ListQualify(qGetApprovalData.Approved_By,"'",",")#)
						AND		Company_ID = #cookie.companyid#
					</cfquery>
					<cfset PositionName="#valueList(qDetEmpApp.Position_Name,' | ')#">
					<tr>
						<td class="formtext" valign="top">#CurrentRow#.
							<font color="##0076EC"><b>
							<cfif qGetApprovalData.Approved_EmpID neq "">
							    <cfquery name="qGetEmpName" datasource="#ATTRIBUTES.DSN#">
								select First_Name,Middle_Name, Last_Name from THRMEmpPersonalData
								where Emp_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qGetApprovalData.Approved_EmpID#"/>
								</cfquery>
								<cfif qGetEmpName.RecordCount gt 0>
								#qGetEmpName.First_Name# - #PositionName#
								<cfelse>
	                        	#PositionName#
								</cfif>
							<cfelse>
	                        	#PositionName#
							</cfif>
                            </b>
                            </font>
							<cfif is_required eq "1"><span style="color:##FF0000;">*</span></cfif>
                        </td>
                        <td style="text-align:right" valign="top">
                        	<table>
							<cfif qGetApprovalData.SettingApproval_StepData eq "">
                            <tr style="height:10px;"><td style="width:5px;background-color:###req_approval2009.color[1]#"></td></tr>
                            <cfelse>
                            <tr style="height:10px;">
								<cfset Temporary.HasEx = false />
                            	<cfloop list="#qGetApprovalData.SettingApproval_StepData#" index="x">
                                	<cfset Temporary.SettingApprovalID = ListGetAt(x,1,"|")/>
                                	<cfif ListFind(Temporary.ColorIndex,Temporary.SettingApprovalID) eq "0">
                                    	<cfset Temporary.ColorIndex = ListAppend(Temporary.ColorIndex,Temporary.SettingApprovalID)/>
                                    </cfif>
									<cfif Find("Ex",Temporary.SettingApprovalID) eq 0>
						<!--- 			
										<cfif cgi.remote_addr eq "192.168.4.62">
										<td style="width:5px;background-color:##" title="Required">
										#Temporary.ColorIndex#<HR>
										#Temporary.SettingApprovalID#<HR>
										<cfdump var="#req_approval2009.color#">
										</td>
									<cfelse> 
						--->
										<td style="width:5px;background-color:###req_approval2009.color[ListFind(Temporary.ColorIndex,Temporary.SettingApprovalID)]#" title="Required">
						<!--- 		
									</cfif> 
						--->
										</td>
									<cfelse>
										<cfif not Temporary.HasEx>
											<td style="width:5px;background-color:red">
											</td>
											<cfset Temporary.HasEx = true />
										</cfif>
									</cfif>

                                </cfloop>
                            </tr>
                            </cfif>
                            </table>
                        </td>
						<td class="formtext" valign="top">
                        <cfif temporary.HasAccess eq "true" and qGetApprovalData.Approve_Status neq 3 and qGetApprovalData.Approve_Status neq 4 and qGetApprovalData.Approve_Status neq 5>
                            <cfquery dbtype="query" name="qGetStatusName">
								select * from qStatus 
								WHERE RequestSts > 1
                            </cfquery>
							<cfset req_approval2009.IsUpdatable = "true"/>

							<input type="hidden" name="hdnDO_2009_Approval" id="hdnDO_2009_Approval" value="#req_approval2009.Position_ID#"/>
                            <input type="hidden" name="hdnApproveBy" id="hdnApproveBy" value="#qGetApprovalData.Approved_by#" />
							<input type="Hidden" name="hdnApprovedById" id="hdnApprovedById" value="#qGetApprovalData.ApprovedBy_ID#">
                            
                            
                            <select class="selApprove" name="cboStatus#qGetApprovalData.ApprovedBy_ID#">
                            <cfloop query="qGetStatusName">
								<option value="#qGetStatusName.RequestSts#" <cfif qGetApprovalData.Approve_Status eq qGetStatusName.RequestSts>Selected</cfif>>
								#DO_VAR[qGetStatusName.Request_Type]#
								</option>
                            </cfloop>
                            </select>
                            <!--- randytia 08-02-2010 --->
                            
							<cfif ATTRIBUTES.cf_Approved_By neq "">
								<!--- <cfoutput>		 --->
                                    <cfset "CALLER.#ATTRIBUTES.cf_Approved_By#" = qGetApprovalData.Approved_by>
                                <!--- </cfoutput> --->
                            </cfif>
                            
                            <cfif ATTRIBUTES.cf_ApprovedBy_ID neq "">
								<!--- <cfoutput>		 --->
                                    <cfset "CALLER.#ATTRIBUTES.cf_ApprovedBy_ID#" = qGetApprovalData.ApprovedBy_ID>
                                <!--- </cfoutput> --->
                            </cfif>
							<!--- End --->
                        <cfelse>
                            <cfquery dbtype="query" name="qGetStatusName">
                                select * from qStatus where RequestSts=#qGetApprovalData.Approve_Status#
                            </cfquery>
                        	<cfif qGetStatusName.recordCount>
                            	<b>#DO_VAR[qGetStatusName.Request_type]#</b>
                            </cfif>
                        </cfif>
                        </td>
						<td class="formtext" valign="top">
							<font color="##0076EC">
								<b>
									<cfif Len(Trim(qGetApprovalData.Approve_Date)) neq 0>
										#DateFormat(qGetApprovalData.Approve_Date,"dd mmm yyyy")# #TimeFormat(qGetApprovalData.Approve_Date,"HH:mm")#
									<cfelse>
										N/A
									</cfif>
								</b>
							</font>
                            <cfquery name="Qapp" datasource="#ATTRIBUTES.DSN#">
                            	select CheckJournal from tapplication where app_id = '#Attributes.APP_ID#'
                            </cfquery>
                            <br />
                            <input type="checkbox" name="seeJournal" value="1"  /> Check Journal
                        </td>
                        
						<td class="formtext" valign="top">
	                        <cfif temporary.HasAccess eq "true">
								<cfset txtReason = trim(qGetApprovalData.Approval_Note)>
								<cfset txtRemain = "#evaluate(300-len(txtReason))#">
								<textarea rows="2" name="txtReason#qGetApprovalData.ApprovedBy_ID#" cols="30" onKeyUp="textCounter(document.forms[0].txtReason#qGetApprovalData.ApprovedBy_ID#,document.forms[0].txtRemain#qGetApprovalData.ApprovedBy_ID#,300)">#txtReason#</textarea><br>
										&nbsp;#DO_VAR["eHRMRemains"]#:&nbsp;&nbsp; #txtRemain# <input readonly type="text" value="#txtRemain#" size="4" maxlength="4" name="txtRemain#qGetApprovalData.ApprovedBy_ID#" id="txtRemain#qGetApprovalData.ApprovedBy_ID#">
                            <cfelse>
								<cfset writeReadonly = "N/A">
								<cfif len(trim(qGetApprovalData.Approval_Note)) neq 0>
									<cfset writeReadonly = qGetApprovalData.Approval_Note>
								</cfif>
								<textarea style="color:##0076EC; font-weight:bold;" row="2" name="txtReasonRead" cols="30" readonly>#writeReadonly#</textarea>
                            </cfif>

                        </td>
                     </tr>
                </cfoutput>
                </tbody>
            </table>
			<cfoutput><span style="color:##FF0000;">*</span> <span class="formtext">#DO_VAR['eHRMRequired']#</span></cfoutput>
	     </cfif>
		
    <script language="javascript" type="text/javascript">
		function textCounter(field, countfield, maxlimit)
		{
			if (field.value.length > maxlimit) 
				field.value = field.value.substring(0, maxlimit);
			else 
				countfield.value = maxlimit - field.value.length;
		}
		
		<!---function validateApproval(){
			//var pos = document.forms[0].hdnDO_2009_Approval.value;
			var pos = document.forms[0].hdnApprovedById.value;
			var posArr = pos.split(",");
			var valid = true;
			for (var counter=0;counter<posArr.length;counter++){
				if(eval("document.forms[0].cboStatus"+posArr[counter])){
				var obj = eval("document.forms[0].cboStatus"+posArr[counter]);
				if(obj.value=='4'||obj.value=='5'){
					var objText = eval("document.forms[0].txtReason"+posArr[counter]);
					if(objText.value==""){
						<cfoutput>
							alert("#DO_VAR['eHRMAppReason']#");
						</cfoutput>
						objText.focus();
						if(document.forms[0].btnUpdate) document.forms[0].btnUpdate.disabled = false;
						if(document.forms[0].btnCancel) document.forms[0].btnCancel.disabled = false;
						valid = false;
					}
				}
				}
			}
			return valid;
		}

		window.onload = function(){
			var objForms = document.getElementsByTagName("form");
			
			if(objForms.length==0){
				return false;
			}
			
			var objForm = objForms[0];
			
			if(typeof(objForm.onsubmit)=='function'){
				var OnSubmit = objForm.onsubmit;
				objForm.onsubmit = return function(){
					if(validateApproval()){
						var retval = false;
						try{
							eval("OnSubmit");
						}catch(e){
						}
						return true;
					}
					return false;
				}
			}else{
				objForm.onsubmit = function(){
					if (validateApproval()==false) {
						return false;
					}
				}
			}
		}--->
		</script>
    </cfif>
    <!---end: Form--->


    <!---start: Saving Data--->
    <cfif req_approval2009.Action eq "Save">

		<cfparam name="ATTRIBUTES.isleader" default="0">
		<cfparam name="ATTRIBUTES.APPTYPE" default="1">
		
		<cfquery name="QCekApproval" datasource="#ATTRIBUTES.DSN#">
			SELECT		*
			FROM		tHRMApprovedBy
			WHERE		ReqApproval_Id = '#ATTRIBUTES.ReqApproval_ID#'
			ORDER BY	Approve_Status DESC
		</cfquery>
		
		
 

		<cfif NOT isDefined("ATTRIBUTES.EMPID") AND NOT isDefined("ATTRIBUTES.POSITIONID")>
			<cfquery name="qUser" datasource="#IIF(isDefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
				SELECT THRMEmpPersonalData.emp_id
				FROM THRMEmpPersonalData
				<cfif req_approval2009.Employee_ID neq "">	
					WHERE THRMEmpPersonalData.Emp_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.Employee_ID#"/>
				<cfelse>
					WHERE THRMEmpPersonalData.user_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.User_ID#"/>
				</cfif>
			</cfquery>
			<cfset ATTRIBUTES.empid = qUser.emp_id>
            
            <!--- 3AS = Approval Cek posisi ke THRMEMPPOSITION bukan ke THRMEMPCOMPANY agar dapat menghandle employee yg memiliki posisi rangkap --->
            <cfquery name="qPosition" datasource="#IIF(isDefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
				SELECT THRMEMPPOSITION.Position_ID
				FROM THRMEmpPersonalData
                inner join THRMEMPPOSITION on THRMEMPPOSITION.EMP_ID = THRMEmpPersonalData.EMP_ID
				<cfif req_approval2009.Employee_ID neq "">	
					WHERE THRMEmpPersonalData.Emp_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.Employee_ID#"/>
				<cfelse>
					WHERE THRMEmpPersonalData.user_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#req_approval2009.User_ID#"/>
				</cfif>
                AND THRMEMPPOSITION.Company_ID = #Cookie.Companyid#
			</cfquery>
            
			<cfset ATTRIBUTES.positionID = Valuelist(qPosition.position_id,",")>
            <!--- END --->
			
		</cfif>
		<!--- <cfif NOT isDefined("ATTRIBUTES.APPROVALSTATUS")>
			<cfset ATTRIBUTES.APPROVALSTATUS = evaluate("FORM.cbostatus#ATTRIBUTES.POSITIONID#")>
		</cfif>
		
		<cfif NOT isDefined("ATTRIBUTES.APPROVEREASON")>
			<cfset ATTRIBUTES.APPROVEREASON = evaluate("FORM.TXTREASON#ATTRIBUTES.POSITIONID#")>
		</cfif> --->
		
		<!--- edited by Luci 25 May 2009
		<cfparam name="LastApp_Sts" default="0"> --->
		<cfparam name="LastApp_Sts" default="2">
		<cfparam name="ListIndexAppBy" default="">
        
        <cfparam name="ListIndexApprovalStatus" default=""> <!--- 3AS : membentuk list Approval Status --->
        <cfparam name="ListIndexApprovalReason" default=""> <!--- 3AS : membentuk list Approval Reason --->
        
        <cfparam name="ListIndexPositionApproved" default="" >
        
		<cfparam name="ListAppBy_Id" default="">
		<cfparam name="ListRequiredAppBy_Id" default="">
		
        
		<cfloop query="QCekApproval">
        <cfset appr = 0 >
        <cfset idxApp = 0 >
			<!--- AW-090925 --->
			<cfif isdefined("ATTRIBUTES.APPROVEDBYID")>
				<cfif ATTRIBUTES.APPROVEDBYID EQ QCekApproval.approvedby_id>
					<cfset idxApp = 1>
					<cfif NOT isDefined("ATTRIBUTES.APPROVALSTATUS")>
						<cfset ATTRIBUTES.APPROVALSTATUS = evaluate("FORM.cbostatus#ATTRIBUTES.APPROVEDBYID#")>
					</cfif>
					
					<cfif NOT isDefined("ATTRIBUTES.APPROVEREASON")>
						<cfset ATTRIBUTES.APPROVEREASON = evaluate("FORM.TXTREASON#ATTRIBUTES.APPROVEDBYID#")>
					</cfif>
				<cfelse>
					<cfset idxApp = 0>
				</cfif>
			<cfelse>
			<!--- END: AW-090925 --->
				<cfif listfindnocase(QCekApproval.columnlist, "LstApprovedBy")>
                	<!--- 3AS : pengecekan dari list Posisinya --->
                	<cfloop list="#ATTRIBUTES.POSITIONID#" index="idxPOS" delimiters="," >
                    	<cfif ListFindNoCase(QCekApproval.LstApprovedBy,idxPOS) >
							<cfset idxApp = ListFindNoCase(QCekApproval.LstApprovedBy,idxPOS)>	                            
                        </cfif>
                    </cfloop>
                    <!--- END --->
					<cfif idxApp>      
                    	<!--- 3AS : dibuat seperti ini agar tetap bisa menghandle apabila attributes approvalStatus dikirim --->              
						<cfif NOT isDefined("ATTRIBUTES.APPROVALSTATUS")>
                        	<cfif isDefined("FORM.cbostatus#qCekApproval.ApprovedBy_ID#") >
							<!---<cfset ATTRIBUTES.APPROVALSTATUS = evaluate("FORM.cbostatus#qCekApproval.ApprovedBy_ID#")>--->
                            	<cfset appr = evaluate("FORM.cbostatus#qCekApproval.ApprovedBy_ID#")>
                            </cfif>
                        <cfelse>
                        	<cfset appr = ATTRIBUTES.APPROVALSTATUS >
						</cfif>
						
						<cfif NOT isDefined("ATTRIBUTES.APPROVEREASON")>
                        	<cfif isDefined("FORM.cbostatus#qCekApproval.ApprovedBy_ID#") >
								<cfset apprReason = evaluate("FORM.TXTREASON#qCekApproval.ApprovedBy_ID#")>
                            </cfif>
                        <cfelse>
                        	<cfset apprReason = ATTRIBUTES.APPROVEREASON >
						</cfif>
					</cfif>
				<cfelse>
                    <!--- 3AS : pengecekan dari list Posisinya --->
                	<cfloop list="#ATTRIBUTES.POSITIONID#" index="idxPOS" delimiters="," >
                    	<cfif ListFindNoCase(QCekApproval.LstApprovedBy,idxPOS) >
							<cfset idxApp = ListFindNoCase(QCekApproval.LstApprovedBy,idxPOS)>	
                        </cfif>
                    </cfloop>
                    <!--- END --->
					<cfset idxApp = ListFindNoCase(QCekApproval.approved_by,#ATTRIBUTES.POSITIONID#)>	
					<cfif idxApp>
						<cfif NOT isDefined("ATTRIBUTES.APPROVALSTATUS")>
							<cfset ATTRIBUTES.APPROVALSTATUS = evaluate("FORM.cbostatus#qCekApproval.ApprovedBy_ID#")>
                            <cfset appr = evaluate("FORM.cbostatus#qCekApproval.ApprovedBy_ID#")>
						</cfif>
						
						<cfif NOT isDefined("ATTRIBUTES.APPROVEREASON")>
							<cfset ATTRIBUTES.APPROVEREASON = evaluate("FORM.TXTREASON#qCekApproval.ApprovedBy_ID#")>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
            
			
			<cfif idxApp GT 0 AND appr GT 0>
				<!--- HK 3 Sep 2008, sharing approval, approve hampir bersamaan, selain yg pertama tidak dijalankan  --->
				<!--- AW-090924: notes tambahan:
								* ini untuk kasus dimana dia buka form inbox, tp tidak lgsg update; sementara itu ada org lain yg sudah approve duluan UNTUK STEP ITU JUGA, maka masuk ke kondisi ini
								* jadi bukan untuk mengatasi kasus dimana 2 approver klik update pada saat(detik) yang nyaris bersamaan --->
				<cfif len(trim(QCekApproval.Approved_EmpID)) neq 0 AND trim(QCekApproval.Approved_EmpID) neq ATTRIBUTES.empid>
				<!--- update AW-091008: tambahan kondisi; dengan adanya penyesuaian di form approval, dimana memungkinkan seorang alternative approver untuk mengoverwrite status "awaiting" yang diset oleh approver LAIN sebelumnya... 
										maka cek jika status sebelumnya = "awaiting", maka OK untuk ditimpa/lanjut!; jika bukan, maka munculkan alert --->
					<cfif QCekApproval.approve_status NEQ 2>
						<cfquery name="qApprovedEmp" datasource="#ATTRIBUTES.DSN#">
							SELECT	THRMEmpPersonalData.First_Name, THRMEmpPersonalData.Middle_Name, THRMEmpPersonalData.Last_Name
							FROM	THRMEmpPersonalData
							WHERE	THRMEmpPersonalData.Emp_id = '#trim(QCekApproval.Approved_EmpID)#'
						</cfquery>
						<script>	
							if (parent.top.frmMarquee != null) parent.top.frmMarquee.location.reload();
							alert("Current step is already confirmed by #qApprovedEmp.First_Name# #qApprovedEmp.Middle_Name# #qApprovedEmp.Last_Name#");
							//<!--- should be: Step number # is already confirmed.. but how to get the step number with the easiest method? --->
							history.back();
						</script>		
						<cfabort>
					</cfif>
				</cfif>
				<!--- END HK 3 Sep 2008, sharing approval, approve hampir bersamaan, selain yg pertama tidak dijalankan  --->
				
				<!--- HK 15 Jun 2009, condition : approver 1 not required, approver 2 required --->
				<!--- AW-090924: notes tambahan:
								* mirip seperti di atas, ini untuk kasus dimana dia buka form inbox, tp tidak lgsg update; sementara itu ada org lain yg sudah approve duluan UNTUK STEP LAINNYA
									yang menyebabkan last update menjadi 3 (approved), 4 (rejected) atau 5 (revising), maka masuk ke kondisi ini --->
				<cfif QCekApproval.Is_Required eq 0 AND (QCekApproval.LastApprove_Status eq 3 OR QCekApproval.LastApprove_Status eq 4 OR QCekApproval.LastApprove_Status eq 5)>
					<script>	
						if (parent.top.frmMarquee != null) parent.top.frmMarquee.location.reload();
						alert("This request is already confirmed by all required approvers!");
						history.back();
					</script>		
					<cfabort>
				</cfif>
				<!--- END HK 15 Jun 2009, condition : approver 1 not required, approver 2 required --->
				
		        <cfset ListIndexAppBy = ListAppend(ListIndexAppBy, QCekApproval.CurrentRow)>
				<cfset ListAppBy_Id = ListAppend(ListAppBy_Id, QCekApproval.ApprovedBy_Id[QCekApproval.currentrow])>
                
                <!--- 3AS : Agar List Reason tetap sama dengan List Approval Status --->
                <cfif apprReason eq "" >
                	<cfset apprReason = "-" >
                </cfif>
                <!--- END ---->
                
                <cfset ListIndexApprovalStatus = ListAppend(ListIndexApprovalStatus, appr)>
				<cfset ListIndexApprovalReason = ListAppend(ListIndexApprovalReason, apprReason)>
                
                <cfset ListIndexPositionApproved = ListAppend(ListIndexPositionApproved,ListGetAt(QCekApproval.LstApprovedBy,idxApp)) >
                
			</cfif>
		
			<cfif QCekApproval.Is_Required EQ 1>
				<cfset ListRequiredAppBy_Id = ListAppend(ListRequiredAppBy_Id,QCekApproval.ApprovedBy_Id)>			
			<!--- <cfelse>
				<cfset ListRequiredAppBy_Id = "''"> --->
			</cfif>
		</cfloop>
		
		<cfloop index="theIdx" FROM="1" to="#listLen(ListIndexAppBy)#">
			<cfset idxApp = ListGetAt(ListIndexAppBy, theIdx)>
			<cfset AppId = ListGetAt(ListAppBy_Id, theIdx)>
            
            
            <cfset approvalStatus = ListGetAt(ListIndexApprovalStatus, theIdx)> 
			<cfset approvalreason = ListGetAt(ListIndexApprovalReason, theIdx)> 
            
            <!--- 3AS : Mengembalikan reason ke "" --->
            <cfif approvalreason eq "-" >
            	<cfset approvalreason = "" >
            </cfif>
            <!--- END --->
            
            
            <cfset positionID = ListGetAt(ListIndexPositionApproved, theIdx) >
         
			<cfif idxApp GT 0>
				<cfif isDefined("QCekApproval.LstApprovedBy")>
					<cfset ListAllAppPos = valueList(QCekApproval.LstApprovedBy)>
				<cfelse>
					<cfset ListAllAppPos = valueList(QCekApproval.approved_by)>
				</cfif>
				
				<cfquery name="QDoc" datasource="#ATTRIBUTES.DSN#">
					SELECT 	RequestApproval_Id, RequestApproval_Name, ReminderType 
					FROM 	tHRMRequestApproval
					WHERE 	RequestApproval_Id = #QCekApproval.RequestApproval_Id#
				</cfquery>
				
				<!--- prosedure send mail--->
				<cfif approvalStatus EQ 4><!---REJECT ---> 
					<!--- Send Email Rejection ke requester --->
					<CF_DO_SF_V32_APPROVALMAIL TEMPLATE_NAME="eHRMConfirmRejection"  TYPE_OF_REQUEST="#QDoc.RequestApproval_Name#"  URL="http://#CGI.SERVER_NAME#/#Application.stApp.Web_Path[Attributes.VST_IDX]#/#Application.stApp.Home_URL[Attributes.VST_IDX]#/default.cfm" REQUESTER="#QCekApproval.Employee_Id[idxApp]#" REQUEST_FOR="NONE"  TO_APPROVER="NONE" APPROVER="#ATTRIBUTES.EMPID#" REQUEST_NUMBER="#Trim(ATTRIBUTES.ReqApproval_ID)#" MAIL_TO="#QCekApproval.Employee_Id[idxApp]#" IS_LEADER="#ATTRIBUTES.ISLEADER#" APP_Id="#ATTRIBUTES.APP_Id#">
					<!--- Send Email pass rejection ke Approval lain --->
					<cfquery name="QOtherApprover" datasource="#ATTRIBUTES.DSN#">
						SELECT 		tHRMEmpPersonalData.Emp_Id
						FROM		tHRMEmpPersonalData
						WHERE		
						<cfif ATTRIBUTES.APPTYPE eq 1>
							tHRMEmpPersonalData.Emp_Id IN 
							(SELECT	Emp_Id	FROM tHRMEmpCompany	WHERE Position_Id IN (#ListAllAppPos#))
						<cfelse>
							THRMEmpPersonalData.Emp_Id IN (#listqualify(ListAllAppPos,"'",",","All")#)
					 	</cfif>
									
						AND			(	tHRMEmpPersonalData.Terminate_Date >= #Now()# 
											Or
										tHRMEmpPersonalData.Terminate_Date Is Null
									)
						AND	 		tHRMEmpPersonalData.Emp_Id <> '#ATTRIBUTES.EMPID#'
					</cfquery>
					<cfloop query="QOtherApprover">
						<CF_DO_SF_V32_APPROVALMAIL TEMPLATE_NAME="eHRMPassRejection"  TYPE_OF_REQUEST="#QDoc.RequestApproval_Name#"  URL="http://#CGI.SERVER_NAME#/#Application.stApp.Web_Path[Attributes.VST_IDX]#/#Application.stApp.Home_URL[Attributes.VST_IDX]#/default.cfm" REQUESTER="#QCekApproval.Employee_Id[idxApp]#" REQUEST_FOR="NONE"  TO_APPROVER="#QOtherApprover.Emp_Id#" APPROVER="#ATTRIBUTES.EMPID#" REQUEST_NUMBER="#Trim(ATTRIBUTES.ReqApproval_ID)#" MAIL_TO="#QOtherApprover.Emp_Id#" IS_LEADER="0" APP_Id="#ATTRIBUTES.APP_Id#">
					</cfloop>
					
					<cfset LastApp_Sts = 4>
					
				<cfelseif approvalStatus EQ 3><!--- di Approve --->
					<!--- Query semua yg IS_Required = 1 --->		
					<cfif ListFindNoCase(ListRequiredAppBy_Id, AppId)>
					<!--- AW-091009: notes tambahan: if disini untuk apabila yang diapprove termasuk dalam step yang required:
									query di bawah adalah untuk count step yg required dan sudah diapprove,
									jika hasil query plus 1 lebih besar sama dengan jumlah step yg required, artinya semua yg required sudah approve, maka status akhir = approved (3),
									jika bukan kondisi di atas, artinya msh ada step required yg belum diapproved, status akhir = awaiting (2)
									 --->
						<cfquery name="QCekRequired" datasource="#ATTRIBUTES.DSN#">
							SELECT 		ApprovedBy_Id
							FROM 		tHRMApprovedBy
							WHERE  		ReqApproval_Id = '#ATTRIBUTES.ReqApproval_ID#'
							<!--- AND	ApprovedBy_Id IN (#preserveSingleQuotes(ListRequiredAppBy_Id)#) ---><!--- AW-091009 --->
							AND			Is_Required = 1
							AND			Approve_Status = 3
							<!--- AND	Approved_By <> '#qSelfPosition.Position_id#' ---><!--- AW-091009 --->

							ORDER BY	ApprovedBy_Id
						</cfquery>
						<cfif ListLen(ListRequiredAppBy_Id) LTE Val(QCekRequired.RecordCount+1)>
							<!--- yg approve ADALAH org yg punya authorize tertinggi --->
							<!---CONFIRM FINAL APPROVAL  KE Requester--->
							<CF_DO_SF_V32_APPROVALMAIL TEMPLATE_NAME="eHRMConfirmFinalApproval"  TYPE_OF_REQUEST="#QDoc.RequestApproval_Name#"  URL="http://#CGI.SERVER_NAME#/#Application.stApp.Web_Path[Attributes.VST_IDX]#/#Application.stApp.Home_URL[Attributes.VST_IDX]#/default.cfm" REQUESTER="#QCekApproval.Employee_Id[idxApp]#" REQUEST_FOR="NONE"  TO_APPROVER="NONE" APPROVER="#ATTRIBUTES.EMPID#" REQUEST_NUMBER="#Trim(ATTRIBUTES.ReqApproval_ID)#" MAIL_TO="#QCekApproval.Employee_Id[idxApp]#" IS_LEADER="#ATTRIBUTES.ISLEADER#" APP_Id="#ATTRIBUTES.APP_Id#"> 
							<cfset LastApp_Sts = 3>
						<cfelseif ListLen(ListRequiredAppBy_Id) GT Val(QCekRequired.recordCount+1)>
							<CF_DO_SF_V32_APPROVALMAIL TEMPLATE_NAME="eHRMConfirmAwaiting"  TYPE_OF_REQUEST="#QDoc.RequestApproval_Name#"  URL="http://#CGI.SERVER_NAME#/#Application.stApp.Web_Path[Attributes.VST_IDX]#/#Application.stApp.Home_URL[Attributes.VST_IDX]#/default.cfm" REQUESTER="#QCekApproval.Employee_Id[idxApp]#" REQUEST_FOR="NONE"  TO_APPROVER="NONE" APPROVER="#ATTRIBUTES.EMPID#" REQUEST_NUMBER="#Trim(ATTRIBUTES.ReqApproval_ID)#" MAIL_TO="#QCekApproval.Employee_Id[idxApp]#" IS_LEADER="#ATTRIBUTES.ISLEADER#" APP_Id="#ATTRIBUTES.APP_Id#"> 
							<cfset NextApp = "">
							<cfif QDoc.ReminderType EQ "C">
								<cfset LastApp = QCekApproval.recordCount>
							<cfelse>
								<cfset LastApp = Evaluate(idxApp+1)>
							</cfif>
							
							<!--- edited by Luci 19 June 2009 
							<cfloop index="i" FROM="#Evaluate(idxApp+1)#" to="#LastApp#">
								<cfset NextApp = listAppend(NextApp,QCekApproval.LstApprovedBy[i])>
							</cfloop>
							--->
							
							<!--- Order type : Free Order --->
							<cfif val(QCekApproval.AppOrder_Type) eq 0>
								<!--- kirim email ke semua next approval --->
								<cfloop index="i" FROM="#Evaluate(idxApp+1)#" to="#LastApp#">
									<cfset NextApp = listAppend(NextApp,QCekApproval.LstApprovedBy[i])>
								</cfloop>
							<!--- Order Type : Order by Step --->
							<cfelse>
								
								<!--- kirim email hanya ke next approval yg pertama --->
								<cfif val(QCekApproval.AppOrder_Type) eq 1>
									<cfquery name="QryApp" datasource="#ATTRIBUTES.DSN#">
										SELECT * FROM THRMApprovedBy
										WHERE ReqApproval_ID = '#ATTRIBUTES.ReqApproval_ID#'
										AND ApprovedBy_ID NOT IN ('#AppID#')
										AND Approve_Status < 3
										ORDER BY ApprovedBy_ID
									</cfquery>
									<cfif QryApp.RecordCount gt 0>
										<cfset NextApp = QryApp.LstApprovedBy[1]>
									<cfelse>
										<cfset NextApp = "">
									</cfif>
								</cfif>
							</cfif>
							<!---  --->
								
							<cfif listLen(NextApp) NEQ 0>
								<cfquery name="QOtherApprover" datasource="#ATTRIBUTES.DSN#">
									SELECT 		tHRMEmpPersonalData.Emp_Id
									FROM		tHRMEmpPersonalData
									WHERE		
									<cfif ATTRIBUTES.APPTYPE eq 1>
										tHRMEmpPersonalData.Emp_Id IN 
										( SELECT Emp_Id FROM tHRMEmpCompany WHERE Position_Id IN (#NextApp#) )
									<cfelse>
										THRMEmpPersonalData.Emp_Id IN (#listqualify(NextApp,"'",",","All")#)
								 	</cfif>
												
									AND 		(tHRMEmpPersonalData.Terminate_Date >= #Now()# OR  tHRMEmpPersonalData.Terminate_Date IS  NULL)
								</cfquery>
								<cfloop query="QOtherApprover">	
									<CF_DO_SF_V32_APPROVALMAIL TEMPLATE_NAME="eHRMSecondApproval"  TYPE_OF_REQUEST="#QDoc.RequestApproval_Name#"  URL="http://#CGI.SERVER_NAME#/#Application.stApp.Web_Path[Attributes.VST_IDX]#/#Application.stApp.Home_URL[Attributes.VST_IDX]#/default.cfm" REQUESTER="#QCekApproval.Employee_Id[idxApp]#" REQUEST_FOR="NONE"  TO_APPROVER="#QOtherApprover.Emp_Id#" APPROVER="#ATTRIBUTES.EMPID#" REQUEST_NUMBER="#Trim(ATTRIBUTES.ReqApproval_ID)#" MAIL_TO="#QOtherApprover.Emp_Id#" IS_LEADER="0" APP_Id="#ATTRIBUTES.APP_Id#">
								</cfloop>
							</cfif>
							<cfset LastApp_Sts = 2>
							<!--- <cfif QCekApproval.Approve_Status[1] eq 4><!--- jika status terakhir rejected --->
								<cfset LastApp_Sts = 4>
							</cfif> --->
						</cfif>
						
					<cfelse>
						<cfquery name="QCekRequired" datasource="#ATTRIBUTES.DSN#">
							SELECT 		ApprovedBy_Id
							FROM 		tHRMApprovedBy
							WHERE  		ReqApproval_Id = '#ATTRIBUTES.ReqApproval_ID#'
							AND			Approve_Status = 3
							<!--- AND	Approved_By <> '#qSelfPosition.Position_id#' ---><!--- AW-091009 --->
							ORDER BY	ApprovedBy_Id
						</cfquery>
							
						<cfif (QCekRequired.recordCount+1) EQ Val(QCekApproval.recordCount)>
							<!--- yg approve ADALAH org yg punya authorize tertinggi --->
							<!---CONFIRM FINAL APPROVAL  KE Requester--->
							<CF_DO_SF_V32_APPROVALMAIL TEMPLATE_NAME="eHRMConfirmFinalApproval"  TYPE_OF_REQUEST="#QDoc.RequestApproval_Name#"  URL="http://#CGI.SERVER_NAME#/#Application.stApp.Web_Path[Attributes.VST_IDX]#/#Application.stApp.Home_URL[Attributes.VST_IDX]#/default.cfm" REQUESTER="#QCekApproval.Employee_Id[idxApp]#" REQUEST_FOR="NONE"  TO_APPROVER="NONE" APPROVER="#ATTRIBUTES.EMPID#" REQUEST_NUMBER="#Trim(ATTRIBUTES.ReqApproval_ID)#" MAIL_TO="#QCekApproval.Employee_Id[idxApp]#" IS_LEADER="#ATTRIBUTES.ISLEADER#" APP_Id="#ATTRIBUTES.APP_Id#">
							<cfset LastApp_Sts = 3>
				
						<cfelse> <!--- blum semua yg Is_Required APPROVE --->
							<!---CONFIRM Awaiting ke Requester--->
							<CF_DO_SF_V32_APPROVALMAIL TEMPLATE_NAME="eHRMConfirmAWaiting"  TYPE_OF_REQUEST="#QDoc.RequestApproval_Name#"  URL="http://#CGI.SERVER_NAME#/#Application.stApp.Web_Path[Attributes.VST_IDX]#/#Application.stApp.Home_URL[Attributes.VST_IDX]#/default.cfm" REQUESTER="#QCekApproval.Employee_Id[idxApp]#" REQUEST_FOR="NONE"  TO_APPROVER="NONE" APPROVER="#ATTRIBUTES.EMPID#" REQUEST_NUMBER="#Trim(ATTRIBUTES.ReqApproval_ID)#" MAIL_TO="#QCekApproval.Employee_Id[idxApp]#" IS_LEADER="#ATTRIBUTES.ISLEADER#" APP_Id="#ATTRIBUTES.APP_Id#">
		
							<!--- send  email ke next approval --->
							<cfset NextApp = "">
							<cfif QDoc.ReminderType EQ "C">
								<cfset LastApp = QCekApproval.recordCount>
							<cfelse>
								<cfset LastApp = Evaluate(idxApp+1)>
							</cfif>
							
							<!--- Order Type : Free Order --->
							<cfif val(QCekApproval.AppOrder_Type) eq 0>
								<!--- kirim email ke semua next approval --->
								<cfloop index="i" FROM="#Evaluate(idxApp+1)#" to="#LastApp#">
									<cfif isDefined("QCekApproval.LstApprovedBy")>
										<cfset NextApp = listAppend(NextApp,QCekApproval.LstApprovedBy[i])>
									<cfelse>
										<cfset NextApp = listAppend(NextApp,QCekApproval.approved_by[i])>
									</cfif>
								</cfloop>
							<!--- Order Type : Order By Step --->
							<cfelse>
								<!--- kirim email hanya ke next approval yg pertama --->
								
								<cfif val(QCekApproval.AppOrder_Type) eq 1>
									<cfquery name="QryApp" datasource="#ATTRIBUTES.DSN#">
										SELECT * FROM THRMApprovedBy
										WHERE ReqApproval_ID = '#ATTRIBUTES.ReqApproval_ID#'
										AND ApprovedBy_ID NOT IN ('#AppID#')
										AND Approve_Status < 3
										ORDER BY ApprovedBy_ID
									</cfquery>
									<cfif QryApp.RecordCount gt 0>
										<cfif isDefined("QCekApproval.LstApprovedBy")>
											<cfset NextApp = QryApp.LstApprovedBy[1]>
										<cfelse>
											<cfset NextApp = QryApp.approved_by[1]>
										</cfif>
									<cfelse>
										<cfset NextApp = "">
									</cfif>
								</cfif>
							</cfif>
							<!---  --->
							
							<cfif listLen(NextApp) NEQ 0>
								<cfquery name="QOtherApprover" datasource="#ATTRIBUTES.DSN#">
									SELECT 		tHRMEmpPersonalData.Emp_Id
									FROM		tHRMEmpPersonalData
									WHERE	<cfif ATTRIBUTES.APPTYPE eq 1>
												tHRMEmpPersonalData.Emp_Id IN 
												( SELECT Emp_Id FROM tHRMEmpCompany WHERE Position_Id IN (#NextApp#) )
											<cfelse>
												THRMEmpPersonalData.Emp_Id IN (#listqualify(NextApp,"'",",","All")#)
										 	</cfif>
									AND 		(tHRMEmpPersonalData.Terminate_Date >= #Now()# OR  tHRMEmpPersonalData.Terminate_Date IS  NULL)
								</cfquery>
								<cfloop query="QOtherApprover">	
									<CF_DO_SF_V32_APPROVALMAIL TEMPLATE_NAME="eHRMSecondApproval"  TYPE_OF_REQUEST="#QDoc.RequestApproval_Name#"  URL="http://#CGI.SERVER_NAME#/#Application.stApp.Web_Path[Attributes.VST_IDX]#/#Application.stApp.Home_URL[Attributes.VST_IDX]#/default.cfm" REQUESTER="#QCekApproval.Employee_Id[idxApp]#" REQUEST_FOR="NONE"  TO_APPROVER="#QOtherApprover.Emp_Id#" APPROVER="#ATTRIBUTES.EMPID#" REQUEST_NUMBER="#Trim(ATTRIBUTES.ReqApproval_ID)#" MAIL_TO="#QOtherApprover.Emp_Id#" IS_LEADER="0" APP_Id="#ATTRIBUTES.APP_Id#">
								</cfloop>
							</cfif>
							<cfset LastApp_Sts = 2>			
							<cfif QCekApproval.Approve_Status[1] eq 4><!--- jika status terakhir rejected --->
								<cfset LastApp_Sts = 4>
							</cfif>	
						</cfif>			
					</cfif>
					
					<cfif isDefined("QCekApproval.LstApprovedBy")>
						<cfset PassPosID = "#QCekApproval.LstApprovedBy[idxApp]#">
					<cfelse>
						<cfset PassPosID = "#QCekApproval.approved_by[idxApp]#">
					</cfif>	
					
					<cfset PassEmp = "">
					<!--- pass rejection ke approval sebelumnya --->
					<cfif idxApp GT 1>
						<cfset idx = idxApp - 1>
						
						<cfif len(trim(QCekApproval.Approved_EmpID[idx])) EQ 0>
							<cfif isDefined("QCekApproval.LstApprovedBy")>
								<cfset PassPosID = listAppend(PassPosID,QCekApproval.LstApprovedBy[idx])>
							<cfelse>
								<cfset PassPosID = listAppend(PassPosID,QCekApproval.approved_by[idx])>
							</cfif>
						<!--- <cfelse>
							<cfset PassEmp = listAppend(passEmp,QCekApproval.Employee_Id[idx],"~")> --->
						</cfif>
					</cfif>
					<cfquery name="QOtherApprover" datasource="#ATTRIBUTES.DSN#">
						SELECT	THRMEmpPersonalData.Emp_Id
						FROM	THRMEmpPersonalData
						WHERE	
						<cfif ATTRIBUTES.APPTYPE eq 1>
							THRMEmpPersonalData.Emp_Id IN 
							(SELECT Emp_Id FROM tHRMEmpCompany WHERE Position_Id IN (#PassPosID#))
						<cfelse>
							THRMEmpPersonalData.Emp_Id IN (#listqualify(PassPosID,"'",",","All")#)
					 	</cfif>
						AND 	THRMEmpPersonalData.Emp_Id <> '#ATTRIBUTES.EMPID#'
						AND    (THRMEmpPersonalData.Terminate_Date >= #Now()# OR THRMEmpPersonalData.Terminate_Date IS  NULL)
					</cfquery>
					<cfif QDoc.ReminderType EQ "C">
						<cfloop index="EMP" list="#listAppend(valueList(QOtherApprover.Emp_Id,"~"),passEmp,"~")#" delimiters="~">
							<CF_DO_SF_V32_APPROVALMAIL TEMPLATE_NAME="eHRMPassApproval" TYPE_OF_REQUEST="#QDoc.RequestApproval_Name#"  URL="http://#CGI.SERVER_NAME#/#Application.stApp.Web_Path[Attributes.VST_IDX]#/#Application.stApp.Home_URL[Attributes.VST_IDX]#/default.cfm" REQUESTER="#QCekApproval.Employee_Id[idxApp]#" REQUEST_FOR="NONE" TO_APPROVER="#EMP#" APPROVER="#ATTRIBUTES.EMPID#" REQUEST_NUMBER="#Trim(ATTRIBUTES.ReqApproval_ID)#" MAIL_TO="#EMP#" IS_LEADER="#ATTRIBUTES.ISLEADER#" APP_Id="#ATTRIBUTES.APP_Id#">
						</cfloop>
					</cfif>	
				<cfelseif approvalStatus EQ 5><!--- revising --->
					<!--- send mail ke requester bahwa requestnya harus diperbaiki --->
					<CF_DO_SF_V32_APPROVALMAIL TEMPLATE_NAME="eHRMConfirmRevising"  TYPE_OF_REQUEST="#QDoc.RequestApproval_Name#"  URL="http://#CGI.SERVER_NAME#/#Application.stApp.Web_Path[Attributes.VST_IDX]#/#Application.stApp.Home_URL[Attributes.VST_IDX]#/default.cfm" REQUESTER="#QCekApproval.Employee_Id[idxApp]#" REQUEST_FOR="NONE"  TO_APPROVER="NONE" APPROVER="#ATTRIBUTES.EMPID#" REQUEST_NUMBER="#Trim(ATTRIBUTES.ReqApproval_ID)#" MAIL_TO="#QCekApproval.Employee_Id[idxApp]#" IS_LEADER="#ATTRIBUTES.ISLEADER#" APP_Id="#ATTRIBUTES.APP_Id#"> 
					
					<!--- Send Email pass rejection ke Approval lain --->
					<cfquery name="QOtherApprover" datasource="#ATTRIBUTES.DSN#">
						SELECT 	tHRMEmpPersonalData.Emp_Id
						FROM	tHRMEmpPersonalData
						WHERE	
						<cfif ATTRIBUTES.APPTYPE eq 1>
							tHRMEmpPersonalData.Emp_Id IN 
							(SELECT Emp_Id FROM tHRMEmpCompany WHERE Position_Id IN (#ListAllAppPos#))
						<cfelse>
							THRMEmpPersonalData.Emp_Id IN (#listqualify(ListAllAppPos,"'",",","All")#)
					 	</cfif>
						
						AND    (tHRMEmpPersonalData.Terminate_Date >= #Now()# OR  tHRMEmpPersonalData.Terminate_Date IS  NULL)
						AND 	tHRMEmpPersonalData.Emp_Id <> '#ATTRIBUTES.EMPID#'
					</cfquery>
					<cfloop query="QOtherApprover">
						<CF_DO_SF_V32_APPROVALMAIL TEMPLATE_NAME="eHRMPassRevising"  TYPE_OF_REQUEST="#QDoc.RequestApproval_Name#"  URL="http://#CGI.SERVER_NAME#/#Application.stApp.Web_Path[Attributes.VST_IDX]#/#Application.stApp.Home_URL[Attributes.VST_IDX]#/default.cfm" REQUESTER="#QCekApproval.Employee_Id[idxApp]#" REQUEST_FOR="NONE"  TO_APPROVER="#QOtherApprover.Emp_Id#" APPROVER="#ATTRIBUTES.EMPID#" REQUEST_NUMBER="#Trim(ATTRIBUTES.ReqApproval_ID)#" MAIL_TO="#QOtherApprover.Emp_Id#" IS_LEADER="0" APP_Id="#ATTRIBUTES.APP_Id#">
					</cfloop>
					<cfset LastApp_Sts = 5>
				</cfif>
				
				<!--- added by Luci 19 June 2009 --->
				<!--- Update Next Turn for Order By Step --->
				<cfif val(QCekApproval.AppOrder_Type) eq 1 AND approvalStatus GTE 3>
					<cfquery name="qNextTurn" datasource="#ATTRIBUTES.DSN#">
						SELECT * FROM THRMApprovedBy
						WHERE ReqApproval_Id = '#ATTRIBUTES.ReqApproval_ID#' 
						AND ApprovedBy_Id NOT IN ('#AppId#')
						AND Approve_Status < 3
						ORDER BY ApprovedBy_ID
					</cfquery>
					<cfif qNextTurn.RecordCount gt 0>
						<cfquery name="qUpdNextTurn" datasource="#ATTRIBUTES.DSN#">
							UPDATE THRMApprovedBy
							SET FLAG_TURN = '1'
							WHERE ReqApproval_Id = '#ATTRIBUTES.ReqApproval_ID#'
							AND ApprovedBy_Id = #qNextTurn.ApprovedBy_Id#
						</cfquery>
					</cfif>
				</cfif>
				<!---  --->
				
				<cfquery name="qUpdateLastApp_Sts" datasource="#ATTRIBUTES.DSN#">
					UPDATE	tHRMApprovedBy 
					SET 	LastApprove_Status = #LastApp_Sts#
					WHERE	ReqApproval_Id='#ATTRIBUTES.ReqApproval_ID#'
				</cfquery>
				
				<cfquery name="qUpdate" datasource="#ATTRIBUTES.DSN#">
					UPDATE tHRMApprovedBy 
					SET 
						Approve_Status=#approvalStatus#,
						Approve_Date=#CreateODBCDateTime(Now())#,
						Approved_EmpID='#ATTRIBUTES.EMPID#',
						Approval_Note  = '#trim(approvalReason)#',
						Approved_By = '#positionID#'
						<cfif QDoc.RequestApproval_Id EQ 5 and Len(trim(ATTRIBUTES.APPCOST))>
						,Approve_Value = #ATTRIBUTES.APPCOST#
						</cfif>
					WHERE  ReqApproval_Id='#ATTRIBUTES.ReqApproval_ID#' And ApprovedBy_Id=#AppId#

                    <cfif LastApp_Sts eq 5><!--- revising --->
                    INSERT INTO 
                    [THRMApprovedByHistory]
                    ([ApprovedBy_ID],[ReqApproval_ID]
                    ,[Employee_ID],[Position_id]
                    ,[Approved_By],[Approve_Status]
                    ,[LastApprove_Status],[Approve_Date]
                    ,[Approved_EmpID],[Approve_Value]
                    ,[Approve_Leave],[RequestApproval_id]
                    ,[Must_Approved],[Approval_Note])
                    select 
                    [ApprovedBy_ID],[ReqApproval_ID]
                    ,[Employee_ID],[Position_id]
                    ,[Approved_By],[Approve_Status]
                    ,[LastApprove_Status],[Approve_Date]
                    ,[Approved_EmpID],[Approve_Value]
                    ,[Approve_Leave],[RequestApproval_id]
                    ,[Must_Approved],[Approval_Note]
                    from THRMApprovedBy
					WHERE  ReqApproval_Id='#ATTRIBUTES.ReqApproval_ID#' And ApprovedBy_Id=#AppId#

                    </cfif>

				</cfquery>
				<!--- added by Luci 19 June 2009 --->
				<cfif LastApp_Sts GTE 3>
					<cfquery name="qUpdateFlagTurn" datasource="#ATTRIBUTES.DSN#">
						UPDATE THRMApprovedBy
							SET FLAG_TURN = '1'
						WHERE	ReqApproval_Id = '#ATTRIBUTES.ReqApproval_ID#'
					</cfquery>
				</cfif>
				<!---  --->
			</cfif>
		</cfloop>
		<!--- Return nilai LastApp_Sts --->
		<cfset "CALLER.#ATTRIBUTES.lastStatus#" = LastApp_Sts>
	
	
    </cfif>
    <!---end: Saving Data--->
</cfif>

<cfif isDefined("ATTRIBUTES.AutoApproval")>
	<cfif ATTRIBUTES.AutoApproval neq "">
		<cfset "CALLER.#ATTRIBUTES.AutoApproval#" = req_approval2009.AutoApproval>
	</cfif>
</cfif> 

<cfif isDefined("ATTRIBUTES.IsUpdatable")>
	<cfif ATTRIBUTES.IsUpdatable neq "">
		<cfset "CALLER.#ATTRIBUTES.IsUpdatable#" = req_approval2009.IsUpdatable>
	</cfif>
</cfif>

<cfif isDefined("ATTRIBUTES.RecordAffected")>
	<cfif ATTRIBUTES.RecordAffected neq "">
		<cfset "CALLER.#ATTRIBUTES.RecordAffected#" = req_approval2009.RecordAffected>
	</cfif>
</cfif>


<cfif thisTag.ExecutionMode eq "end">

</cfif>


<cffunction name="GenerateError" access="public" returntype="string" output="yes">
	<cfargument name="ErrorText" type="string" required="yes">
    <cfif req_approval2009.IsCSSGenerated eq "false">
    <style type="text/css">
		.notice {
			background:##FFF6BF;
			color:##514721;
			border-top:2px solid ##FFD324;
			border-bottom:2px solid ##FFD324;
			padding:2px 10px 2px 10px;
			margin:10px 2px 10px 2px;
		}
		.notice h4{
			margin:0px;
			padding:0px;
		}
		</style>
        <cfset req_approval2009.IsCSSGenerated = "true"/>
    </cfif>
    <div class="notice">
    <h4>Error Approving Document</h4>
    #ErrorText#
    </div>
    <cfabort/>
	<cfset myResult="">
	<cfreturn myResult>
</cffunction>