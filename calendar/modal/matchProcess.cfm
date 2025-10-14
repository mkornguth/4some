<!--- <cfdump var="#form#"><cfabort> --->
<cfinclude template="/header.cfm">
<cfset status = "">
<cfif IsDefined("form.btnCreate")>
	<cfquery datasource="#variables.DSN#" name="insertNewMatch">
		insert into matches (match_date, group_id)
			values (#form.date#, #form.GroupId#)
	</cfquery>

	<cfquery datasource="#variables.DSN#" name="getMatchIdentity">
		select max(match_id) as match_id from matches 
	</cfquery>

	<cfquery datasource="#variables.DSN#" name="addGolfer">
		insert into match_players (match_id, player_id, signup_date)
			values (#getMatchIdentity.match_id#, #variables.player_id#, #CreateODBCDateTime(now())#)
	</cfquery>
	<cfset status = "matchCreated">
<cfelseif IsDefined("form.btnAdd") and IsDefined("form.MatchId")>
	<cfquery datasource="#variables.DSN#" name="addGolfer">
		insert into match_players (match_id, player_id, signup_date)
			values (#form.MatchId#, #variables.golferId#, #now()#)
	</cfquery>
	<cfset status = "playerAdded">
<cfelseif IsDefined("form.btnRemove") and IsDefined("form.MatchId")>
	<cfif form.isGuest eq 0>
		<cfquery datasource="#variables.DSN#" name="removeGolfer">
			delete from match_players 
			where player_id = #form.golferId# and match_id = #form.MatchId#
		</cfquery>
		<cfquery datasource="#variables.DSN#" name="removeGolfer">
			delete from match_guests 
			where player_id = #form.golferId# and match_id = #form.MatchId#
		</cfquery>
	<cfelse>
		<cfset prefix = ListGetAt(#form.golferId#,1,"-")>
		<cfset id = ListGetAt(#form.golferId#,2,"-")>
		<cfif prefix eq "u">
			<cfquery datasource="#variables.DSN#" name="removeGuest">
				delete from match_guests 
				where guest_id = #id# and match_id = #form.MatchId#
			</cfquery>
		<cfelse>
			<cfquery datasource="#variables.DSN#" name="removeGuest">
				delete from match_guests 
				where player_id = #id# and match_id = #form.MatchId#
			</cfquery>
		</cfif>
	</cfif>

	<cfset status = "playerRemoved">
<cfelseif IsDefined("form.btnMakeTeams") and IsDefined("form.MatchId")>
	<cflocation url="/calendar/generateTeams.cfm?mid=#form.MatchId#">
	<cfset status = "teamsGenerated">
<cfelseif IsDefined("form.btnRemoveTeams") and IsDefined("form.MatchId")>
	<cfquery datasource="#variables.DSN#" name="removeGolfer">
		delete from match_teams
		where match_id = #form.MatchId#
	</cfquery>
	<cfset status = "teamsRemoved">
<cfelseif IsDefined("form.btnAlternate") and IsDefined("form.MatchId")>
	<cfquery datasource="#variables.DSN#" name="addGolfer">
		insert into match_players (match_id, player_id, signup_date)
			values (#form.MatchId#, #variables.golferId#, #now()#)
	</cfquery>
	<cfquery datasource="#variables.DSN#" name="addToTeam">
		insert into match_teams (match_id, team_id, player_id, player_label)
			values (#form.MatchId#, 99, #variables.golferId#, '#form.alternate#')
	</cfquery>

	<cfset status = "playerAdded">
<cfelseif IsDefined("form.btnAddGuest") and IsDefined("form.guest")>
	<cfset prefix = ListGetAt(#form.guest#,1,"-")>
	<cfset id = ListGetAt(#form.guest#,2,"-")>
	<cfif prefix eq "r">
		<cfquery datasource="#variables.DSN#" name="addGolfer">
			insert into match_guests(match_id, player_id)
				values (#form.MatchId#, #id#)
		</cfquery>
	<cfelse>
		<cfquery datasource="#variables.DSN#" name="addGolfer">
			insert into match_guests(match_id, guest_id)
				values (#form.MatchId#, #id#)
		</cfquery>
	</cfif>

	<cfset status = "guestAdded">
<cfelseif IsDefined("form.btnAddMember") and IsDefined("form.memberId")>
	<cfquery datasource="#variables.DSN#" name="addGolfer">
		insert into match_players (match_id, player_id)
			values (#form.MatchId#, #form.memberId#)
	</cfquery>
	<cfset status = "memberAdded">
<cfelseif IsDefined("form.btnPreventMatch")>
	<cfquery datasource="#variables.DSN#" name="addGolfer">
		insert into group_calendar_nomatch (group_id, nomatch_date)
			values (#form.groupId#, #form.date#)
	</cfquery>
<cfelseif IsDefined("form.btnAllowMatch")>
	<cfquery datasource="#variables.DSN#" name="addGolfer">
		delete from group_calendar_nomatch
			where group_id = #form.groupId# and nomatch_date = #form.date#
	</cfquery>
</cfif>

<cflocation url="/calendar/index.cfm?gid=#form.GroupId#&status=#status#">

