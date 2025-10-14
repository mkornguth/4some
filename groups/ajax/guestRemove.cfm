<cfsetting showdebugoutput="false">
<cfset status = "called">
<cfif isDefined("url.gid")>
	<cfif isDefined("url.pid")>
		<cfquery datasource="#variables.DSN#" name="removeRegistered">
			delete from guests_registered
			where group_id = #url.gid# and player_id = #url.pid#
		</cfquery>
		<cfset status = "removed">
	<cfelseif IsDefined("url.guestId")>
		<cfquery datasource="#variables.DSN#" name="removeUnregistered">
			delete from guests_unregistered
			where guest_id = #url.guestId#
		</cfquery>
		<cfset status = "removed">
	<cfelse>
		<cfset status &= ",invalidParams">
	</cfif>
</cfif>

<cfoutput>#status#</cfoutput>