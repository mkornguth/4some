<cfinclude template="/header.cfm">

<cfquery datasource="#variables.DSN#" name="getUser">
	select isAdmin
	from group_players gp
	where group_id = #url.gid# and player_id = #variables.player_id#
</cfquery>

<cfif getUser.recordcount eq 1 and getUser.isAdmin eq 1>
	<cftransaction action="begin">
		<cfquery datasource="#variables.DSN#" name="deleteGroupMembers">
			delete from group_players
			where group_id = #url.gid#
		</cfquery>
		<cfquery datasource="#variables.DSN#" name="deleteGroup">
			delete from 4some.groups
			where group_id = #url.gid#
		</cfquery>
		<cftransaction action="commit">
	</cftransaction>
	<cflocation url="/groups/index.cfm?status=groupDeleted">
<cfelse>
	<h2>You are not authorized to delete this group.</h2>
	<cfinclude template="/footer.cfm">
</cfif>