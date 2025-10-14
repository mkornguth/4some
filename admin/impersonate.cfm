<cfquery datasource="#variables.DSN#" name="lookupPlayer">
	select *
	from players
	where player_id = #url.pid#
</cfquery>

<cfcookie name="GolferData" value="#url.pid#,#trim(lookupPlayer.email)#, #trim(lookupPlayer.first_name)#, #trim(lookupPlayer.last_name)#">
	
<cfquery datasource="#variables.DSN#" name="getGroups">
	select group_id, isAdmin
	from group_players
	where player_id = #url.pid#
	order by isAdmin desc, group_id
</cfquery>

<cfif getGroups.recordcount GT 0>
	<cfset local.groupList = "">
	<cfoutput query="getGroups">
		<cfset listItem = '"' & getGroups.group_id & '":{"ISADMIN":' & getGroups.isAdmin & '}'>
		<cfset local.groupList = listAppend(local.groupList, listItem)>
	</cfoutput>
	<cfset local.groupList = "{" & local.groupList & "}">
	<cfcookie name="GolferGroups" value="#local.groupList#">
</cfif>

<cfif getGroups.recordcount GT 0>
	<CFHEADER STATUSCODE="302" STATUSTEXT="Object Temporarily Moved" />
	<CFHEADER NAME="location" VALUE="http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT#/calendar/index.cfm?gid=#getGroups.group_id#" />
<cfelse>
	<CFHEADER STATUSCODE="302" STATUSTEXT="Object Temporarily Moved" />
	<CFHEADER NAME="location" VALUE="http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT#/account/groups.cfm" />
</cfif>