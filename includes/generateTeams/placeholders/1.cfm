<!--- ABCD Snake Format with Placeholders --->

<!--- <cfdump var="#arrGolfersByHandicap#"> --->
<cfset placeholderIdx = 0>
<cfloop from="1" to="#teamCount#" index="i">
	<cfset a = i>

	<cfset b = (2 * teamCount) + 1 - i>
	<cfset c = a + b + i - 1>
	<cfset d = (4 * teamCount) + 1 - i>

	

	<cfquery datasource="#variables.DSN#" name="insertTeamMember">
	INSERT INTO match_teams (match_id, team_id, player_id, player_label, guest_id)
		VALUES
			<cfif arrayLen(arrGolfersByHandicap) GTE a>
				(#url.mid#, #i#, <cfif arrGolfersByHandicap[a].GolferType eq "member" OR arrGolfersByHandicap[a].GolferType eq "registered">#arrGolfersByHandicap[a].Id#<cfelse>null</cfif>, 'A', <cfif arrGolfersByHandicap[a].GolferType eq "unregistered">#arrGolfersByHandicap[a].Id#<cfelse>null</cfif>)
			</cfif>
			<cfif arrayLen(arrGolfersByHandicap) GTE b>
				,(#url.mid#, #i#, <cfif arrGolfersByHandicap[b].GolferType eq "member" OR arrGolfersByHandicap[b].GolferType eq "registered">#arrGolfersByHandicap[b].Id#<cfelse>null</cfif>, 'B', <cfif arrGolfersByHandicap[b].GolferType eq "unregistered">#arrGolfersByHandicap[b].Id#<cfelse>null</cfif>)
			</cfif>
			<cfif arrayLen(arrGolfersByHandicap) GTE c>
				,(#url.mid#, #i#, <cfif arrGolfersByHandicap[c].GolferType eq "member" OR arrGolfersByHandicap[c].GolferType eq "registered">#arrGolfersByHandicap[c].Id#<cfelse>null</cfif>, 'C', <cfif arrGolfersByHandicap[c].GolferType eq "unregistered">#arrGolfersByHandicap[c].Id#<cfelse>null</cfif>)
			<cfelse>
				<cfset placeholderIdx = placeholderIdx - 1>
				,(#url.mid#, #i#, #placeholderIdx# , 'C', null)
			</cfif>
			<cfif arrayLen(arrGolfersByHandicap) GTE d>
				,(#url.mid#, #i#, <cfif arrGolfersByHandicap[d].GolferType eq "member" OR arrGolfersByHandicap[d].GolferType eq "registered">#arrGolfersByHandicap[d].Id#<cfelse>null</cfif>, 'D', <cfif arrGolfersByHandicap[d].GolferType eq "unregistered">#arrGolfersByHandicap[d].Id#<cfelse>null</cfif>)
			<cfelse>
				<cfset placeholderIdx = placeholderIdx - 1>
				,(#url.mid#, #i#, #placeholderIdx# , 'D', null)
			</cfif>
	</cfquery>

	<!--- <cfoutput>
		<div>a = #a#</div>
		<div>b = #b#</div>
		<div>c = #c#</div>
		<div>d = #d#</div>
		<div>
		INSERT INTO match_teams (match_id, team_id, player_id, player_label, guest_id)
		VALUES
			<cfif arrayLen(arrGolfersByHandicap) GTE a>
				(#url.mid#, #i#, <cfif arrGolfersByHandicap[a].GolferType eq "member" OR arrGolfersByHandicap[a].GolferType eq "registered">#arrGolfersByHandicap[a].Id#<cfelse>null</cfif>, 'A', <cfif arrGolfersByHandicap[a].GolferType eq "unregistered">#arrGolfersByHandicap[a].Id#<cfelse>null</cfif>)
			</cfif>
			<cfif arrayLen(arrGolfersByHandicap) GTE b>
				,(#url.mid#, #i#, <cfif arrGolfersByHandicap[b].GolferType eq "member" OR arrGolfersByHandicap[b].GolferType eq "registered">#arrGolfersByHandicap[b].Id#<cfelse>null</cfif>, 'B', <cfif arrGolfersByHandicap[b].GolferType eq "unregistered">#arrGolfersByHandicap[b].Id#<cfelse>null</cfif>)
			</cfif>
			<cfif arrayLen(arrGolfersByHandicap) GTE c>
				,(#url.mid#, #i#, <cfif arrGolfersByHandicap[c].GolferType eq "member" OR arrGolfersByHandicap[c].GolferType eq "registered">#arrGolfersByHandicap[c].Id#<cfelse>null</cfif>, 'C', <cfif arrGolfersByHandicap[c].GolferType eq "unregistered">#arrGolfersByHandicap[c].Id#<cfelse>null</cfif>)
			<cfelse>
				<cfset placeholderIdx = placeholderIdx - 1>
				,(#url.mid#, #i#, #placeholderIdx# , 'D', null)
			</cfif>
			<cfif arrayLen(arrGolfersByHandicap) GTE d>
				,(#url.mid#, #i#, <cfif arrGolfersByHandicap[d].GolferType eq "member" OR arrGolfersByHandicap[d].GolferType eq "registered">#arrGolfersByHandicap[d].Id#<cfelse>null</cfif>, 'D', <cfif arrGolfersByHandicap[d].GolferType eq "unregistered">#arrGolfersByHandicap[d].Id#<cfelse>null</cfif>)
			<cfelse>
				<cfset placeholderIdx = placeholderIdx - 1>
				,(#url.mid#, #i#, #placeholderIdx# , 'D', null)
			</cfif>
		</div>
	</cfoutput>
	<hr> --->
</cfloop>

<!--- <cfabort> --->

<cfquery datasource="#variables.DSN#" name="updateMatchType">
	update matches
		set match_type_id = 1
	where match_id = #url.mid#
</cfquery>

<cfquery datasource="#variables.DSN#" name="logTeamGen">
	insert into team_gen_log (match_id, player_id, match_type_id)
		values (#url.mid#, #variables.player_id#, 1)
</cfquery>