<cfquery datasource="#variables.DSN#" name="updatePlayer">
	update players 
		set first_name = '#form.firstName#'
			, last_name = '#form.lastName#'
			, email = '#form.email#'
			<cfif isDefined("form.ghin") and len(form.ghin) GT 0>
			,ghin_id = #form.ghin#
			</cfif>
	where player_id = #form.pid#
</cfquery>


<cflocation url="/index.cfm">