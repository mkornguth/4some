<cfif isDefined("cookie.inviteCode") and listLen(cookie.inviteCode,"-") eq 2>

	<cfset variables.group_id = ListGetAt(cookie.inviteCode,1,"-")>
	<cfif listLen(trim(cookie.inviteCode),"-") eq 2>
		<cfquery datasource="#variables.DSN#" name="getGroup">
			select *, (select player_id from 4some.group_players where player_id = #variables.player_id# and group_id = 62) as alreadyGroupMember
			from 4some.groups
			where group_id = #variables.group_id#
		</cfquery>
		<cfif getGroup.alreadyGroupMember GT 0>
			<cfset groupStatus="success">
	    	<cfset strGroups = structNew()>
			<cfset strGroups[variables.group_id] = structNew()>
			<cfset strGroups[variables.group_id].IsAdmin = 0>
			<cfcookie name="GolferGroups" value="#SerializeJSON(strGroups)#">
			<h2>You are already a member of the group named '<cfoutput>#getGroup.group_name#</cfoutput>'.</h2>
			<a href="/groups/index.cfm?gid=<cfoutput>#variables.group_id#</cfoutput>" class="btn btn-primary">View this Group</a>
			<cfabort>
		<cfelseif Compare(ListGetAt(cookie.inviteCode,2,"-"),getGroup.invite_code) eq 0>
			<cfquery datasource="#variables.DSN#" name="insertGroupPlayer">
	    		insert group_players (group_id, player_id)
	    			values (#variables.group_id#, #variables.player_id#)
	    	</cfquery>
	    	<cfset groupStatus="success">
	    	<cfset strGroups = structNew()>
			<cfset strGroups[variables.group_id] = structNew()>
			<cfset strGroups[variables.group_id].IsAdmin = 0>
			<cfcookie name="GolferGroups" value="#SerializeJSON(strGroups)#">

		<cfelse>
			<cfset groupStatus="fail">
		</cfif>

		<cfset redirectUrl = "/account/groups.cfm?groupStatus=additional&gid=" & variables.group_id>

	    <cflocation url="#redirectUrl#">

	</cfif>
</cfif>