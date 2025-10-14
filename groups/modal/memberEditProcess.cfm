<!--- <cfdump var="#form#"><cfabort> --->

<cfif isDefined("form.gid") and isDefined("form.pid")>
	<cfif IsDefined("form.btnRemove")>
		<cfquery datasource="#variables.DSN#" name="updateIsAdmin">
			delete from group_players 
			where player_id = #form.pid# and group_id = #form.gid#
		</cfquery>
	<cfelse>
		<cfif IsDefined("form.isAdmin")>
			<cfset variables.isAdmin = 1>
		<cfelse>
			<cfset variables.isAdmin = 0>
		</cfif>

		<cfquery datasource="#variables.DSN#" name="updatePlayer">
			update players 
				set first_name = '#form.firstName#'
					, last_name = '#form.lastName#'
					, handicap_current = #form.handicap#
					, email = '#form.email#'
			where player_id = #form.pid#
		</cfquery>
		<cfquery datasource="#variables.DSN#" name="updateIsAdmin">
			update group_players 
				set isAdmin = #variables.isAdmin#
			where player_id = #form.pid# and group_id = #form.gid#
		</cfquery>
	</cfif>
</cfif>

<cflocation url="../index.cfm">