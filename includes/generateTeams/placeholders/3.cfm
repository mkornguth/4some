<!--- To Do: add placeholders appropriately --->

<cfset x = 0>
<cfset i = 1>
<cfloop array="#arrGolfersByHandicap#" index="golfer">
	<cfset x++>	
	<!--- Team <cfoutput>#i#</cfoutput>
	<cfdump var="#golfer#"> --->
	<cfswitch expression="#i#">
		<cfcase value="1"><cfset tier = "A"></cfcase>
		<cfcase value="2"><cfset tier = "B"></cfcase>
		<cfcase value="3"><cfset tier = "C"></cfcase>
		<cfcase value="4"><cfset tier = "D"></cfcase>
		<cfcase value="5"><cfset tier = "E"></cfcase>
	</cfswitch>
	<cfquery datasource="#variables.DSN#" name="insertTeamMember">
	INSERT INTO match_teams (match_id, team_id, player_id, player_label, guest_id)
		VALUES
			<cfif arrayLen(arrGolfersByHandicap) GTE x>
				(#url.mid#, #i#, <cfif arrGolfersByHandicap[x].GolferType eq "member" OR arrGolfersByHandicap[x].GolferType eq "registered">#arrGolfersByHandicap[x].Id#<cfelse>null</cfif>, '#tier#', <cfif arrGolfersByHandicap[x].GolferType eq "unregistered">#arrGolfersByHandicap[x].Id#<cfelse>null</cfif>)
			</cfif>
	</cfquery>
	<cfif x mod 4 eq 0>
		<cfset i++>
	</cfif>
</cfloop>

<cfquery datasource="#variables.DSN#" name="insertTeamMember">
	update matches
		set match_type_id = 3
	where match_id = #url.mid#
</cfquery>

<cfquery datasource="#variables.DSN#" name="logTeamGen">
	insert into team_gen_log (match_id, player_id, match_type_id)
		values (#url.mid#, #variables.player_id#, 3)
</cfquery>