<cfsetting showdebugoutput="false">
<cfset status = "called">
<cfif isDefined("url.gid")>
	<cfif isDefined("url.pid")>
		<cfquery datasource="#variables.DSN#" name="addGuest">
		insert guests_registered (player_id, group_id)
			values(#url.pid#,#url.gid#)
		</cfquery>
		<cfset status = "added">
	<cfelseif IsDefined("url.guestName")>

	<cfelse>
		<cfset status &= ",invalidParams">
	</cfif>
</cfif>

<cfoutput>#status#</cfoutput>