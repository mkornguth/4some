<!--- To Do: add placeholders appropriately --->

<cfset playerCount = arrayLen(arrGolfersByHandicap)>
<cfset x = 0>
<cfset i = 1>
<cfloop from="1" to="#playerCount#" index="golfer">
	<cfset x++>	
	<cfset randomId = randRange(1, arrayLen(arrGolfersByHandicap))>
	Team <cfoutput>#i#</cfoutput>
	<cfdump var="#arrGolfersByHandicap[randomId]#">
	<cfquery datasource="#variables.DSN#" name="insertTeamMember">
	INSERT INTO match_teams (match_id, team_id, player_id, player_label, guest_id)
		VALUES
		(#url.mid#, #i#, <cfif arrGolfersByHandicap[randomId].GolferType eq "member" OR arrGolfersByHandicap[randomId].GolferType eq "registered">#arrGolfersByHandicap[randomId].Id#<cfelse>null</cfif>, 'X', <cfif arrGolfersByHandicap[randomId].GolferType eq "unregistered">#arrGolfersByHandicap[randomId].Id#<cfelse>null</cfif>)
	</cfquery>
	<cfscript>
		arrayDeleteAt(arrGolfersByHandicap, randomId);
	</cfscript>
	<cfif x mod 4 eq 0>
		<cfset i++>
	</cfif>
</cfloop>

<cfquery datasource="#variables.DSN#" name="insertTeamMember">
	update matches
		set match_type_id = 4
	where match_id = #url.mid#
</cfquery>

<cfquery datasource="#variables.DSN#" name="logTeamGen">
	insert into team_gen_log (match_id, player_id, match_type_id)
		values (#url.mid#, #variables.player_id#, 4)
</cfquery>

