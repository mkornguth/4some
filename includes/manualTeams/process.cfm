<cfdump var="#form#">

	 	<cfquery datasource="#variables.DSN#" name="deleteTeams">
			delete from match_teams
			where match_id = #form.mid#
		</cfquery>

		<cfloop list="#form.playerSubmissionList#" item="pid" index="i">
			<cfswitch expression="#i mod 4#">
				<cfcase value="1"><cfset playerLabel = "A"></cfcase>
				<cfcase value="2"><cfset playerLabel = "B"></cfcase>
				<cfcase value="3"><cfset playerLabel = "C"></cfcase>
				<cfcase value="0"><cfset playerLabel = "D"></cfcase>
			</cfswitch>
			
			<cfset tid = ceiling(i / 4)>
			<!--- team id 99 is the alternates team --->
			<!--- player id that is negatgive is a placeholder --->
			<cfif tid GT form.teamCount and pid LTE 0>
				<!--- don't insert placeholders not on a team --->
			<cfelseif LEFT(pid,2) eq "u-">
				<cfquery datasource="#variables.DSN#" name="insertTeamMember">
					INSERT INTO match_teams (match_id, team_id, player_id, player_label, guest_id)
					VALUES
						(#form.mid#, #tid#, null, '#playerLabel#', #listGetAt(pid, 2, "-")#)
					</cfquery>
				<!--- <cfoutput>
					<div>INSERT INTO match_teams (match_id, team_id, player_id, player_label, guest_id)
					VALUES
						(#form.mid#, #tid#, null, '#playerLabel#', #listGetAt(pid, 2, "-")#)</div> - #tid#/#pid#
				</cfoutput> --->
			<cfelse>
				<cfif tid GT form.teamCount>
					<cfset tid = 99>
				</cfif>
				<cfquery datasource="#variables.DSN#" name="insertTeamMember">
					INSERT INTO match_teams (match_id, team_id, player_id, player_label, guest_id)
					VALUES
						(#form.mid#, #tid#, #pid#, '#playerLabel#', null)
				</cfquery>

		
				<!--- <cfoutput>
					<div>INSERT INTO match_teams (match_id, team_id, player_id, player_label, guest_id)
					VALUES
						(#form.mid#, #tid#, #pid#, '#playerLabel#', null)</div> - #tid#/#pid#
				</cfoutput> --->

			</cfif>



		</cfloop>

	<!--- <cfabort> --->

	<cfquery datasource="#variables.DSN#" name="updateMatchType">
		update matches
			set match_type_id = 5
		where match_id = #url.mid#
	</cfquery>

	<cfquery datasource="#variables.DSN#" name="logTeamGen">
		insert into team_gen_log (match_id, player_id, match_type_id)
			values (#url.mid#, #variables.player_id#, 5)
	</cfquery>

	<!--- <CFABORT> --->
	<cflocation url="/calendar/">