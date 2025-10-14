<h1>Handicap Parser</h1>
<cfquery datasource="#variables.DSN#" name="getGolfers">
	select player_id, ghin_id, first_name, last_name, handicap_current
	from players
	where ghin_id is not null
</cfquery>

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

<!--- Loop over golfers --->
<cfoutput query="getGolfers">
	<!--- set url to perform lookup --->
	<cfset lookupUrl = "https://api.ghin.com/api/v1/golfers/search.json?per_page=1&page=1&golfer_id=" & getGolfers.ghin_id>

	<!---  lookup individual golfer--->
	<cfhttp method="get" url="#lookupUrl#">
	  <cfhttpparam type="header"  name="Authorization" value="Bearer #authResponse.golfer_user.golfer_user_token#">
	</cfhttp> 

	<!--- put golfer in results object --->
	<cfset results = deserializeJSON(cfhttp.fileContent)>
	<div>
	#getGolfers.last_name# - 
	<cfset theJSON = results.golfers[1]>
	<!--- <cfdump var="#theJSON#"> --->
	
		#theJSON.ghin# - #theJSON.first_name# #theJSON.last_name# - #theJSON.hi_value#
	</div>

	<cftry>
		<cfquery datasource="#variables.DSN#" name="updateGolfer">
			update players
				set handicap_current = #theJSON.hi_value#
					, handicap_low = #theJSON.low_hi_value#
					, handicap_updated = #CreateODBCDateTime(now())#
					<cfif LEN(getGolfers.handicap_current) GT 0 and getGolfers.handicap_current neq theJSON.hi_value>
					, handicap_previous = #getGolfers.handicap_current#
					</cfif>
					<cfif len(trim(getGolfers.first_name)) eq 0 and len(trim(getGolfers.last_name)) eq 0>
					, first_name = '#theJSON.first_name#'
					, last_name = '#theJSON.last_name#'
					</cfif>
			where player_id = #getGolfers.player_id#
		</cfquery>
		<cfcatch>
		</cfcatch>
	</cftry>
	
</cfoutput>

<cfmail subject="Handicap Parser" from="Teams.golf <no-reply@teams.golf>" to="admin@teams.golf" type="html">
 	<p>Handicaps have been successfully updated.</p>
</cfmail>

<h3>Done</h3>