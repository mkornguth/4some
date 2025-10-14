<!--- <cfdump var="#form#">
<cfabort> --->

<cfif isDefined("form.gid")>
	<cftransaction action="begin">
		<cfquery datasource="#variables.DSN#" name="updatePlayer">
			update 4some.groups 
				set signup_window = #form.signup_window#
			where group_id = #form.gid#
		</cfquery>
<!--- 
		<cfquery datasource="#variables.DSN#" name="deleteGameWagers">
			delete from group_wagers
			where group_id = #form.gid#	
		</cfquery>

		<cfloop collection="#form#" item="field">
			<cfif ListGetAt(field,1,"_") eq "gameType" and len(form[field]) GT 0>
				<cfquery datasource="#variables.DSN#" name="insertGameWagers">
					insert into group_wagers (group_id, game_type_id, wager_amount)
					values (#form.gid#, #ListGetAt(field,2,"_")#, #form[field]#)
				</cfquery>
			</cfif>
		</cfloop> --->

		<cftransaction action="commit">
	</cftransaction>
</cfif>

<cflocation url="../index.cfm">