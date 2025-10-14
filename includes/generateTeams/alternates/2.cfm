<!--- Create arrays for each player tier --->
<cfset tierList = "A,B,C,D">
<cfset arrA = arrayNew(1)>
<cfset arrB = arrayNew(1)>
<cfset arrC = arrayNew(1)>
<cfset arrD = arrayNew(1)>


<cfloop from="1" to="#teamCount#" index="i">
	<cfset a = i>
	<cfset b = i + 4>
	<cfset c = i + 8>
	<cfset d = i + 12>

	<cfset arrA[i] = #arrGolfersByHandicap[a].Id#>
	<cfset arrB[i] = #arrGolfersByHandicap[b].Id#>
	<cfset arrC[i] = #arrGolfersByHandicap[c].Id#>
	<cfset arrD[i] = #arrGolfersByHandicap[d].Id#>
</cfloop>

<cfdump var="#arrA#">
<cfdump var="#arrB#">
<cfdump var="#arrC#">
<cfdump var="#arrD#"> 
<cfset i = 0>

<!--- Assign each A player a random golfer remaining from each tier --->
<cfloop array="#arrA#" index="playerAId">
	<cfset i++>
	<h3><cfoutput>#playerAId#</cfoutput></h3>
	<cfset randomIndexB = randRange(1,arrayLen(arrB))>
	<cfset randomIndexC = randRange(1,arrayLen(arrC))>
	<cfset randomIndexD = randRange(1,arrayLen(arrD))>
	<cfset playerBId = arrB[randomIndexB]>
	<cfset playerCId = arrC[randomIndexC]>
	<cfset playerDId = arrD[randomIndexD]>
	<cfscript>
		arrayDeleteAt(arrB, randomIndexB);
		arrayDeleteAt(arrC, randomIndexC);
		arrayDeleteAt(arrD, randomIndexD);
	</cfscript>
	<cfoutput>#playerBId#</cfoutput>
	<cfoutput>#playerCId#</cfoutput>
	<cfoutput>#playerDId#</cfoutput>

	<cfquery datasource="#variables.DSN#" name="insertTeamMember">
	INSERT INTO match_teams (match_id, team_id, player_id, player_label, guest_id)
		VALUES
			<cfif arrayLen(arrGolfersByHandicap) GTE a>
				(#url.mid#, #i#, <cfif arrGolfersByHandicap[a].GolferType eq "member" OR arrGolfersByHandicap[a].GolferType eq "registered">#playerAId#<cfelse>null</cfif>, 'A', <cfif arrGolfersByHandicap[a].GolferType eq "unregistered">#playerAId#<cfelse>null</cfif>)
			</cfif>
			<cfif arrayLen(arrGolfersByHandicap) GTE b>
				,(#url.mid#, #i#, <cfif arrGolfersByHandicap[b].GolferType eq "member" OR arrGolfersByHandicap[b].GolferType eq "registered">#playerBId#<cfelse>null</cfif>, 'B', <cfif arrGolfersByHandicap[b].GolferType eq "unregistered">#playerBId#<cfelse>null</cfif>)
			</cfif>
			<cfif arrayLen(arrGolfersByHandicap) GTE c>
				,(#url.mid#, #i#, <cfif arrGolfersByHandicap[c].GolferType eq "member" OR arrGolfersByHandicap[c].GolferType eq "registered">#playerCId#<cfelse>null</cfif>, 'C', <cfif arrGolfersByHandicap[c].GolferType eq "unregistered">#playerCId#<cfelse>null</cfif>)
			</cfif>
			<cfif arrayLen(arrGolfersByHandicap) GTE d>
				,(#url.mid#, #i#, <cfif arrGolfersByHandicap[d].GolferType eq "member" OR arrGolfersByHandicap[d].GolferType eq "registered">#playerDId#<cfelse>null</cfif>, 'D', <cfif arrGolfersByHandicap[d].GolferType eq "unregistered">#playerDId#<cfelse>null</cfif>)
			</cfif>
	</cfquery> 
</cfloop>

<cfquery datasource="#variables.DSN#" name="insertTeamMember">
	update matches
		set match_type_id = 2
	where match_id = #url.mid#
</cfquery>

<cfquery datasource="#variables.DSN#" name="logTeamGen">
	insert into team_gen_log (match_id, player_id, match_type_id)
		values (#url.mid#, #variables.player_id#, 2)
</cfquery>

