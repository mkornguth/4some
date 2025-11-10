<cfif isDefined("cookie.GolferData")>
	<cftransaction action="begin">
		<cfquery datasource="#variables.DSN#" name="deleteClubPlayer">
			delete from 4some.club_players
				where player_id = #listGetAt(cookie.golferdata, 1)#
		</cfquery>
		<cfquery datasource="#variables.DSN#" name="deleteGroupPlayer">
			delete from 4some.group_players
				where player_id = #listGetAt(cookie.golferdata, 1)#
		</cfquery>
		<cfquery datasource="#variables.DSN#" name="deleteGuestRegistered">
			delete from 4some.guests_registered
				where player_id = #listGetAt(cookie.golferdata, 1)#
		</cfquery>
		<cfquery datasource="#variables.DSN#" name="deleteMatchGuests">
			delete from 4some.match_guests
				where player_id = #listGetAt(cookie.golferdata, 1)#
		</cfquery>
		<cfquery datasource="#variables.DSN#" name="deleteMatchPlayers">
			delete from 4some.match_players
				where player_id = #listGetAt(cookie.golferdata, 1)#
		</cfquery>
		<cfquery datasource="#variables.DSN#" name="deleteMatchResultsIndividual">
			delete from 4some.match_results_individual
				where winning_player_id = #listGetAt(cookie.golferdata, 1)#
		</cfquery>
		<cfquery datasource="#variables.DSN#" name="deleteMatchTeams">
			delete from 4some.match_teams
				where player_id = #listGetAt(cookie.golferdata, 1)#
		</cfquery>
		<cfquery datasource="#variables.DSN#" name="deletePlayer">
			delete from 4some.players
				where player_id = #listGetAt(cookie.golferdata, 1)#
		</cfquery>
		<cftransaction action="commit">
	</cftransaction>
	<cfcookie name="GolferData" expires="Now">
</cfif>
<cfif isDefined("cookie.GolferGroups")>
	<cfcookie name="GolferGroups" expires="Now">
</cfif>


<cflocation url="delete.cfm?status=deleted">