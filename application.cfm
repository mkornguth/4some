<cfapplication name="teams.golf" clientmanagement="false" setclientcookies="false">
<cferror template ="/error.cfm" type ="exception" exception ="any">
<cfset variables.DSN = "teams">
<cfparam name="variables.isAuthenticated" default="false">

<cfsetting showdebugoutput="false">
<cfif IsDefined("cookie.GolferData")>
	<cfset variables.GolferId = ListGetAt(cookie.GolferData,1)>
	<cfset variables.Username = ListGetAt(cookie.GolferData,2)>
</cfif>

<cfset variables.GroupList = "">
<cfif IsDefined("cookie.GolferGroups")>
	<cfset groupJSON = deserializeJSON(cookie.GolferGroups)>
	<cfloop collection="#groupJSON#" item="i">
		<cfset variables.GroupList = ListAppend(variables.GroupList, #i#)>
	</cfloop>
	<cfparam name="url.gid" default="#ListGetAt(variables.GroupList,1)#">
	<cfif structKeyExists(groupJSON, url.gid)>
		<cfset variables.IsAdmin = groupJSON[url.gid].IsAdmin>
	</cfif>
</cfif>

