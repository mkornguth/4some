<!--- <cfdump var="#form#">
<cfoutput>#listLen(form.individualAmountWon)#</cfoutput>
<cfabort> --->

<cfif isDefined("form.matchId")>
	<!--- insert team results --->
	<cfif listLen(form.gameTypeId) eq listLen(form.winningTeamId) and listLen(form.gameTypeId) GT 0>
		<cfquery datasource="#variables.DSN#" name="deleteExistingResults">
			delete from match_results
			where match_id = #form.matchId#
		</cfquery>
		<cfloop from="1" to="#listLen(form.gameTypeId)#" index="i">
			<cfquery datasource="#variables.DSN#" name="insertResult">
				insert into match_results (match_id, game_type_id, winning_team_id, amount_won, score)
					values (
						#form.matchId#
						, #listGetAt(form.gameTypeId,i)#
						, #listGetAt(form.winningTeamId,i)#
						, <cfif listIndexExists(form.amountWon, i)>#listGetAt(form.amountWon, i)#<cfelse>null</cfif>
						, <cfif listIndexExists(form.score, i)>#listGetAt(form.score, i)#<cfelse>null</cfif>
						)
			</cfquery>
		</cfloop>
	</cfif>

	<!--- insert individual results --->
	<cfif listLen(form.individualTypeId) eq listLen(form.winningPlayerId) and listLen(form.individualTypeId) GT 0>
		<cfquery datasource="#variables.DSN#" name="deleteExistingResults">
			delete from match_results_individual
			where match_id = #form.matchId#
		</cfquery>
		<cfloop from="1" to="#listLen(form.individualTypeId)#" index="i">
			<cfquery datasource="#variables.DSN#" name="insertResult">
				insert into match_results_individual (match_id, game_type_id, winning_player_id, amount_won, score)
					values (
							#form.matchId#
							, #listGetAt(form.individualTypeId,i)#
							, #listGetAt(form.winningPlayerId,i)#
							, <cfif listIndexExists(form.individualAmountWon, i)>#listGetAt(form.individualAmountWon, i)#<cfelse>null</cfif>
							, <cfif listIndexExists(form.individualScore, i)>#listGetAt(form.individualScore, i)#<cfelse>null</cfif>
						)
			</cfquery>
		</cfloop>
	</cfif>
</cfif>

<cflocation url="/results/view.cfm?mid=#form.matchId#">