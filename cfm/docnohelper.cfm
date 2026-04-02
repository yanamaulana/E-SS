<!--- Last Edit by IND Oct 15 , 2008 - Multi Company Fix --->
<cfinclude template="#Application.stApp.CFWeb_Path[1]#/include/appvars.cfm">
<cfif not isDefined("ATTRIBUTES.DocumentType")>
	ATTRIBUTES.DocumentType is required
	<cfabort>
</cfif>
<cfif not isDefined("ATTRIBUTES.TABLENAME")>
   ATTRIBUTES.TABLENAME is required
   <cfabort>
</cfif>

<cfparam name="ATTRIBUTES.DocumentNo" default="DocumentNo">
<cfparam name="ATTRIBUTES.TYPE" default="VALUE">
<cfparam name="ATTRIBUTES.ShowCompanyAndLocation" default="1">
<cfparam name="ATTRIBUTES.CompanyID" default="#cookie.companyid#">
<cfparam name="ATTRIBUTES.LocationID" default="#cookie.location_ID#">
<cfparam name="ATTRIBUTES.TrxNo" default="TrxNo">
<cfparam name="wh" default="">

<!--- untuk mengambil regional number --->
<cfquery name="qReg" datasource="#ATTRIBUTES.DSN#">
	select list_wh_id from TAccPattern
	WHERE PatternGroup = '#ATTRIBUTES.DocumentType#' 
	and list_wh_id is not null
	AND Company_ID = #ATTRIBUTES.CompanyID#
</cfquery>
<!--- bila ada, maka menggunakan regional dan transaction number --->
<cfif qReg.recordCount neq 0>
	<cfloop query="qReg">
		<cfset x = qReg.list_wh_id>
		<cfloop list="#x#" index="temp">
			<cfif ATTRIBUTES.LocationID eq temp>
				<cfset wh = x>
			</cfif>
		</cfloop>
	</cfloop>
</cfif>

<!--- bila menggunakan transaction number --->
<cfif wh neq ''>
	<cfquery name="qReg" datasource="#ATTRIBUTES.DSN#">
		select lastNumber, length, increment from taccpattern 
		where patterngroup = '#ATTRIBUTES.DocumentType#'
		and list_wh_id = '#wh#'
	</cfquery>
	
	<cfif ATTRIBUTES.TYPE eq "Pattern">
		<cfset afix = repeatstring ('x', qReg.length)>
	<cfelse>
		<cfset no = val (qReg.lastNumber) + val (qReg.increment)>
		<cfset temp = val (qReg.length) - val (Len (no))>
		<cfset afix = repeatString (0, temp) & no>
		
		<cfquery name="qUpdate" datasource="#ATTRIBUTES.DSN#">
			update taccpattern set
			lastNumber = #no#
			where patterngroup = '#ATTRIBUTES.DocumentType#'
			and list_wh_id = '#wh#' 
		</cfquery>
	</cfif>
	
	<cfquery name="qInternal" datasource="#ATTRIBUTES.DSN#">
		select lastNumber from taccpattern
		where patterngroup = '#ATTRIBUTES.DocumentType#'
		and fieldName = 'Code'
	</cfquery> 
	<cfquery name="qTrans" datasource="#ATTRIBUTES.DSN#">
		select lastNumber from taccpattern
		where patterngroup = '#ATTRIBUTES.DocumentType#'
		and fieldName = 'TransactionNumber'
	</cfquery>
	<cfquery name="qDelimiter" datasource="#ATTRIBUTES.DSN#">
		select lastNumber from taccPattern
		where patterngroup = '#ATTRIBUTES.DocumentType#'
		and fieldName = 'Delimiter'
	</cfquery>
	
	<cfset temp = ''>
	<cfloop list="#wh#" index="list">
		<cfset length = 2 - val (Len (list))>
		<cfset x = repeatString (0, length)>
		<cfset temp = temp & x & list>
	</cfloop>
	
	<cfoutput>
	<cfset temp2 = ''>
	<cfloop from="1" to="20" index="i">
		<cfquery name="qLoop" datasource="#ATTRIBUTES.DSN#">
			select wh_id, order_id, lastNumber from taccPattern
			where patterngroup = '#ATTRIBUTES.DocumentType#'
			and order_id = #i# 
		</cfquery>
		<cfif qLoop.wh_id eq 'null' or qLoop.wh_id eq ''>
			<cfbreak>
		<cfelseif qLoop.order_id neq 1>
			<cfif findNoCase ("##", qLoop.lastNumber) neq 0>
				<cfset x = evaluate ("#qLoop.lastNumber#")>
			<cfelse>
				<cfset x = qLoop.lastNumber>
			</cfif>
			<cfset temp2 = temp2 & x>
		</cfif>
	</cfloop>
	</cfoutput>
	
	<cfset internal = qInternal.lastNumber & cookie.companyID & temp & temp2 & afix>
	<cfset transaction = qTrans.lastNumber & qDelimiter.lastNumber & afix>
	
	<cfoutput>				
	    <cfset "CALLER.#ATTRIBUTES.DocumentNo#" = #internal#>
		<cfset "CALLER.#ATTRIBUTES.TrxNo#" = #transaction#>
	</cfoutput>
	
<cfelse>
<!----------------------------------------------------------- proses biasa --->
	<cfif ATTRIBUTES.LocationID neq "">
	  <cfif ATTRIBUTES.DocumentType NEQ "Acc_ID"> <!--- untuk COA tidak ada per warehouse --->
		<cfquery name="qDataStandAlone" datasource="#ATTRIBUTES.DSN#" cachedwithin="#CreateTimeSpan(0,0,30,0)#">
			SELECT StandAloneDoc, Company_ID FROM TAccWHLocation WHERE WH_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ATTRIBUTES.LocationID#">
		</cfquery>
	  <cfelse>
	  	<cfquery name="qDataStandAlone" datasource="#ATTRIBUTES.DSN#">
			SELECT 0 StandAloneDoc, #Cookie.CompanyID# Company_ID
		</cfquery>
	  </cfif>
	  <cfset ATTRIBUTES.CompanyID = "#qDataStandAlone.Company_ID#">
	</cfif>
	
	<cfquery name="qData" datasource="#ATTRIBUTES.DSN#">
		SELECT * FROM #ATTRIBUTES.TABLENAME#
		WHERE PatternGroup = '#ATTRIBUTES.DocumentType#' 
			AND Increment <> 1
	<!--- 		<cfif len(trim(attributes.companyID))>  --->
			AND Company_id = #attributes.companyID#
	<!--- 		</cfif> --->
		UNION
		<cfif isDefined("qDataStandAlone") and qDataStandAlone.StandAloneDoc eq 1>
			SELECT * FROM #ATTRIBUTES.TABLENAME#
			WHERE PatternGroup = '#ATTRIBUTES.DocumentType#' 
				AND Increment = 1
				AND WH_ID = #ATTRIBUTES.LocationID#
				<!--- <cfif len(trim(attributes.companyID))> --->
					AND Company_id = #attributes.companyID#
				<!---</cfif>  --->
		<cfelse>
			SELECT * FROM #ATTRIBUTES.TABLENAME#
			WHERE PatternGroup = '#ATTRIBUTES.DocumentType#' 
				AND Increment = 1
				AND WH_ID is NULL
				<!--- <cfif len(trim(attributes.companyID))> --->
					AND Company_id = #attributes.companyID#
				<!---</cfif>  --->
		</cfif>
		ORDER BY Order_ID
	</cfquery>

	<cfif qData.recordcount eq 0>
		<cfoutput>You haven't set #ATTRIBUTES.DocumentType# as Document Type yet !</cfoutput>
		<cfabort>
	<cfelse>
		<cfset number="">
		<cfloop query="qData">
			<cfset spFieldName = qData.FieldName>
			<cfset spLengthGrap = qData.Length>
			
			<cftry>
				<cfset temp = evaluate("#qData.LastNumber#")>
				<cfcatch type="Any">
					<cfset temp = qData.LastNumber>
				</cfcatch>
			</cftry>
			
			<!--- Untuk Diff Number --->
			<cfif qData.Increment gt 0>
				<cfif ATTRIBUTES.TYPE eq "Pattern">
					<cfset temp = #RepeatString("x",qData.Length)#>
				<cfelse>
					<!--- Tiono : Cek apakah tabel TAccPattern sudah ada field reset_flag. Jika ada maka last number memakai last number yang di maintain di tabel terpisah,
					Jika tidak ada maka last number langsung saja diambil dari tabel taccpattern ditambah increment.
					 --->
					<cfif isDefined("qData.reset_flag")>
						<cfquery name="qCekDiffNum" datasource="#IIF(isDefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
							SELECT ID, lastnumber
							FROM TAccPatternDiffNumber
							WHERE pattern_id = #qData.pattern_id#
							<cfif qData.reset_flag eq 1 OR qData.reset_flag eq 2>
								AND year = #year(now())#
							</cfif>
							<cfif qData.reset_flag eq 2>
								AND month = #month(now())#
							</cfif>
						</cfquery>
						
						<cfif qCekDiffNum.recordcount>
							<cfset temp = val(qCekDiffNum.lastnumber) + qData.Increment>
							
							<cfquery name="qUpdateDiffNum" datasource="#IIF(isDefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
								UPDATE TAccPatternDiffNumber SET lastnumber = #temp# WHERE ID = #qCekDiffNum.ID#
							</cfquery>
						<cfelse>
							<cfquery name="qInsertDiffNum" datasource="#IIF(isDefined('DSN'),'DSN','ATTRIBUTES.DSN')#">
								INSERT INTO TAccPatternDiffNumber (
									pattern_id, 
								<cfif qData.reset_flag eq 1 OR qData.reset_flag eq 2>	
									year,
								</cfif>
								<cfif qData.reset_flag eq 2>
									month,
								</cfif>
									lastnumber
								)
								VALUES (
									#qData.pattern_id#,
								<cfif qData.reset_flag eq 1 OR qData.reset_flag eq 2>
									#Year(now())#,
								</cfif>
								<cfif qData.reset_flag eq 2>
									#month(now())#,
								</cfif>
									1
								)
							</cfquery>
							<cfset temp = 1>
						</cfif>
					<cfelse>
						<cfset temp = temp + qData.Increment>	
					</cfif> 
					 
					<cfif isDefined("qDataStandAlone") and qDataStandAlone.StandAloneDoc eq 1>
						<cfquery datasource="#ATTRIBUTES.DSN#">
							UPDATE #ATTRIBUTES.TABLENAME#
							SET LastNumber = '#temp#'
							WHERE FieldName= '#qData.FieldName#'
								AND PatternGroup = '#ATTRIBUTES.DocumentType#'
								AND WH_ID = #ATTRIBUTES.LocationID#
								<!--- <cfif len(trim(attributes.companyID))>--->
								AND Company_id = #attributes.companyID#	
								<!---</cfif> --->
						</cfquery>
					<cfelse>
						<cfquery datasource="#ATTRIBUTES.DSN#">
							UPDATE #ATTRIBUTES.TABLENAME#
							SET LastNumber = '#temp#'
							WHERE FieldName= '#qData.FieldName#'
								AND PatternGroup = '#ATTRIBUTES.DocumentType#'
								AND WH_ID is NULL
								<!--- <cfif len(trim(attributes.companyID))>--->
									AND Company_id = #attributes.companyID#	
								<!--- </cfif> --->
						</cfquery>
					</cfif>				
					
					<cfif Len(Trim(temp)) neq qData.Length>
						<cfset count = qData.Length - Len(trim(temp))>
						<cfset temp = #RepeatString("0",count)#&#temp#>
					</cfif>
				</cfif>
			</cfif>
			
			<cfset number = number&temp>
			<cfif trim(qData.FieldName) eq "Code" >
				<!--- ATTRIBUTES.ShowCompanyAndLocation , added by Arjuna
				untuk dokumen pattern yanbg tidak memerlukan companyID dan location id
				misal u/ Bank Giro
				--->
				<cfif ATTRIBUTES.ShowCompanyAndLocation eq "1">
					<cfif ATTRIBUTES.LocationID neq "" >
						<cfif Len(ATTRIBUTES.LocationID) lt 2>
							<cfset LID = "0" & ATTRIBUTES.LocationID>
						<cfelse>
							<cfset LID = ATTRIBUTES.LocationID>
						</cfif>
						<cfset number=number & attributes.CompanyID & LID>			
					<cfelse>	
						<cfset number=number & attributes.CompanyID>			
					</cfif>
				</cfif>		
			</cfif>
		</cfloop>
		<cfoutput>
			<cfset "CALLER.#ATTRIBUTES.DocumentNo#" = #Number#>
			<cfset "CALLER.#ATTRIBUTES.TrxNo#" = #Number#>
		</cfoutput>
	</cfif>
</cfif>