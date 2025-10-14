<cfcomponent>
	<cffunction name="getTeams" output="true" returntype="query">
		<cfargument name="matchId" type="numeric" required="true">
		<cfargument name="includeAlternates" type="boolean" default="false">
		<cfquery datasource="Teams" name="getTeams">
			select *,
					CASE
						WHEN LENGTH(uFirst) > 0 THEN  uFirst
						ELSE rFirst
					END as first_name,
				    CASE
						WHEN LENGTH(uLAST) > 0 THEN  uLast
						ELSE rLast
					END as last_name,
				    CASE
						WHEN LENGTH(uLAST) > 0 THEN  'unregistered'
						ELSE 'registered'
					END as guest_type,
		            CASE
						WHEN LENGTH(handicap) > 0 THEN handicap
						ELSE handicap_current
					END as handicap_to_use
				from
			(
				select g.player_id, g.first_name as rfirst, g.last_name as rLast, g.ghin_id, g.handicap_current, mt.player_label, mt.team_id, mt.shuffled_id, m.match_date, gu.first_name as uFirst, gu.last_name as uLast, gu.handicap, gu.is_handcuffed, gu.player_id_handcuff, gu.guest_id, t.description
				from matches m
					inner join match_teams mt on mt.match_id = m.match_id
					left outer join players g on g.player_id = mt.player_id
					left outer join guests_unregistered gu on gu.guest_id = mt.guest_id
					left outer join match_types t on t.match_type_id = m.match_type_id
				
				where m.match_id = #matchId# 
					<cfif includeAlternates eq false>and mt.team_id <> 99</cfif>
				
				group by mt.team_id, g.player_id, g.first_name, g.last_name, g.ghin_id, g.handicap_current, mt.player_label, mt.shuffled_id, m.match_date, gu.first_name, gu.last_name, gu.handicap, gu.is_handcuffed, gu.player_id_handcuff, gu.guest_id, t.description
			) iq
			order by team_id, player_label
		</cfquery>

		<cfreturn getTeams>
	</cffunction>

	<cffunction name="getAlternates" output="true" returntype="query">
		<cfargument name="matchId" type="numeric" required="true">
		<cfquery datasource="Teams" name="getAlternates">
			select *,
					CASE
						WHEN LENGTH(uFirst) > 0 THEN  uFirst
						ELSE rFirst
					END as first_name,
				    CASE
						WHEN LENGTH(uLAST) > 0 THEN  uLast
						ELSE rLast
					END as last_name,
				    CASE
						WHEN LENGTH(uLAST) > 0 THEN  'unregistered'
						ELSE 'registered'
					END as guest_type,
		            CASE
						WHEN LENGTH(handicap) > 0 THEN handicap
						ELSE handicap_current
					END as handicap_to_use
				from
			(
				select g.player_id, g.first_name as rfirst, g.last_name as rLast, g.ghin_id, g.handicap_current, mt.player_label, mt.team_id, mt.shuffled_id, m.match_date, gu.first_name as uFirst, gu.last_name as uLast, gu.handicap, gu.is_handcuffed, gu.player_id_handcuff, gu.guest_id, t.description
				from matches m
					inner join match_teams mt on mt.match_id = m.match_id
					left outer join players g on g.player_id = mt.player_id
					left outer join guests_unregistered gu on gu.guest_id = mt.guest_id
					left outer join match_types t on t.match_type_id = m.match_type_id
				where m.match_id = #matchId# and mt.team_id = 99
				group by mt.team_id, g.player_id, g.first_name, g.last_name, g.ghin_id, g.handicap_current, mt.player_label, mt.shuffled_id, m.match_date, gu.first_name, gu.last_name, gu.handicap, gu.is_handcuffed, gu.player_id_handcuff, gu.guest_id, t.description
			) iq
			order by team_id, player_label
		</cfquery>

		<cfreturn getAlternates>
	</cffunction>

	<cffunction name="getResults" output="true" returntype="query">
		<cfargument name="matchId" type="numeric" required="true">

		<cfquery datasource="Teams" name="getResults">
			select result_id, score, r.game_type_id, r.winning_team_id, r.amount_won, description, last_name, match_date
			from match_results r
				inner join game_types gt on gt.game_type_id = r.game_type_id
				inner join match_teams mt on mt.match_id = #matchId# and mt.team_id = r.winning_team_id
				inner join matches m on m.match_id = mt.match_id
				inner join players p on p.player_id = mt.player_id
			where r.match_id = #matchId#
			group by result_id, score, description, last_name, match_date
		</cfquery>

		<cfreturn getResults>
	</cffunction>

	<cffunction name="getResultsIndividual" output="true" returntype="query">
		<cfargument name="matchId" type="numeric" required="true">

		<cfquery datasource="Teams" name="getResults">
			select result_id, score, r.game_type_id, r.winning_player_id, r.amount_won, description, last_name, first_name
			from match_results_individual r
				inner join game_types gt on gt.game_type_id = r.game_type_id
				inner join players p on p.player_id = r.winning_player_id
			where r.match_id = #matchId#
			group by result_id, score, description, last_name
		</cfquery>

		<cfreturn getResults>
	</cffunction>

	<cffunction name="getGuests" output="true" returntype="query">
		<cfargument name="matchId" type="numeric" required="true">

		<cfquery datasource="Teams" name="getGroupIdFromMatch">
			select group_id
			from matches
			where match_id = #matchId#
		</cfquery>

		<cfset groupId = getGroupIdFromMatch.group_id>

		<cfquery datasource="Teams" name="getGuests">
				select *,
					CASE
						WHEN LENGTH(uFirst) > 0 THEN  uFirst
						ELSE rFirst
					END as first_name,
				    CASE
						WHEN LENGTH(uLAST) > 0 THEN  uLast
						ELSE rLast
					END as last_name,
				    CASE
						WHEN LENGTH(uLAST) > 0 THEN  'unregistered'
						ELSE 'registered'
					END as guest_type,
		            CASE
						WHEN LENGTH(handicap) > 0 THEN handicap
						ELSE handicap_current
					END as handicap_to_use
				from
				(
				select g.match_id, g.signup_date, gu.guest_id, gr.player_id, gu.first_name as uFirst, gu.last_name as uLast, gu.is_handcuffed, gu.player_id_handcuff, gu.handicap, p.first_name as rFirst, p.last_name as rLast, p.handicap_current
					    from match_guests g
					    	left outer join guests_unregistered gu on gu.guest_id = g.guest_id and gu.group_id = #groupId#
			    			left outer join guests_registered gr on gr.player_id = g.player_id and gr.group_id = #groupId#
					    	left outer join players p on p.player_id = gr.player_id
					where match_id = #matchId#
				) iq
			    
			</cfquery>

		<cfreturn getGuests>
	</cffunction>
</cfcomponent>