<cfparam name="updateGhin" default="false">
<cfparam name="allowUpdate" default="true">

<cfif isDefined("form.ghin") and len(trim(form.ghin)) GT 0>
	<cfset updateGHIN = true>
</cfif>

<cfif updateGHIN>
	<!--- structure for user to login to GHIN site --->
	<cfset strUser = structNew()>
	<cfset strUser.user = structNew()>
	<cfset strUser.user.email_or_ghin = "2358110">
	<cfset strUser.user.password = "Ghin31!">
	<cfset strUser.user.remember_me = "true">
	<cfset strUser.token = "nonblank">
	<cfset json = serializeJSON(strUser)>

	<!--- login to GHIN site --->
	<cfhttp method="post" url="https://api2.ghin.com/api/v1/golfer_login.json">
	  <cfhttpparam type="header"  name="Content-Type" value="application/json; charset=utf-8">
	  <cfhttpparam type="header"  name="Accept" value="application/json">
	  <cfhttpparam type="body" value="#json#">
	</cfhttp>

	<!--- put response in variable --->
	<cfset authResponse = deserializeJSON(cfhttp.fileContent)>

	<!--- set url to perform lookup --->
	<cfset lookupUrl = "https://api.ghin.com/api/v1/golfers/search.json?per_page=1&page=1&golfer_id=" & #form.ghin#>

	<!---  lookup individual golfer--->
	<cfhttp method="get" url="#lookupUrl#">
	  <cfhttpparam type="header"  name="Authorization" value="Bearer #authResponse.golfer_user.golfer_user_token#">
	</cfhttp> 

	<!--- put golfer in results object --->
	<cfset results = deserializeJSON(cfhttp.fileContent)>
	<cfset theJSON = results.golfers[1]>

	<!--- if the last name of the looked up golfer does not match the current golfer, prevent the update --->
	<cfif lcase(trim(theJSON.last_name)) neq lcase(trim(listGetAt(cookie.golferdata, 4)))>
		<cfset allowUpdate = false>
	</cfif>
</cfif>

<cfif allowUpdate>
	<cfquery datasource="#variables.DSN#" name="updatePlayer">
		update players 
			set first_name = '#form.firstName#'
				, last_name = '#form.lastName#'
				, email = '#form.email#'
				<cfif updateGHIN>
				, ghin_id = #form.ghin#
				, handicap_current = #theJSON.hi_value#
				, handicap_low = #theJSON.low_hi_value#
				, handicap_updated = #CreateODBCDateTime(now())#
				</cfif>
		where player_id = #form.pid#
	</cfquery>

	<cflocation url="/groups/index.cfm?status=accountUpdated">
<cfelse>
	<cflocation url="/groups/index.cfm?status=ghinUpdateNameMismatch">
</cfif>