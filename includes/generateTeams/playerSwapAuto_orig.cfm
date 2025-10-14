<cfset url.mid = 18>
<cfset getMatch.match_date = "2023-04-30">

<!--- Get newly generated teams --->
<cfquery datasource="#variables.DSN#" name="getTeams">
    select g.player_id, mt.player_label, mt.team_id
    from matches m
      inner join match_teams mt on mt.match_id = m.match_id
      left outer join players g on g.player_id = mt.player_id
      left outer join guests_unregistered gu on gu.guest_id = mt.guest_id
    where m.match_id = #url.mid# and mt.team_id <> 99
    group by  mt.team_id, g.player_id, mt.player_label
  order by team_id, player_label
</cfquery>


<!--- Create structure for comparison --->
<cfset arrCurrentMatch = arrayNew(1)>
<cfoutput query="getTeams" group="team_id">
    <cfset tId = getTeams.team_id>
    <cfset arrCurrentMatch[tId] = "">
    <cfoutput>
        <cfset arrCurrentMatch[tId] = ListAppend(arrCurrentMatch[tId], #getTeams.player_id#) >
    </cfoutput>
</cfoutput>

<cfdump var="#arrCurrentMatch#">

<!--- Get the ID of the previous match --->
<cfquery datasource="#variables.DSN#" name="getPreviousMatch">
    SELECT match_id, match_date 
    FROM 4some.matches
    where group_id = 8 and match_date < '#getMatch.match_date#'
    order by match_date desc
    limit 1;
</cfquery>

<!--- Get teams from the previous match  --->
<cfquery datasource="#variables.DSN#" name="getTeamsPreviousMatch">
    select g.player_id, mt.player_label, mt.team_id
    from matches m
      inner join match_teams mt on mt.match_id = m.match_id
      left outer join players g on g.player_id = mt.player_id
      left outer join guests_unregistered gu on gu.guest_id = mt.guest_id
    where m.match_id = #getPreviousMatch.match_id# and mt.team_id <> 99
  order by team_id, player_label
</cfquery>

<!--- Create the other structure for comparison --->
<cfset arrPreviousMatch = arrayNew(1)>
<cfoutput query="getTeamsPreviousMatch" group="team_id">
    <cfset tId = getTeamsPreviousMatch.team_id>
    <cfset arrPreviousMatch[tId] = "">
    <cfoutput>
        <cfset arrPreviousMatch[tId] = ListAppend(arrPreviousMatch[tId], #getTeamsPreviousMatch.player_id#) >
    </cfoutput>
</cfoutput>

<!--- <cfdump var="#arrPreviousMatch#"> --->

<!--- Loop over the current match, looking for players who played for the same captain in the previous match --->
<cfloop array="#arrCurrentMatch#" index="teamId" item="teamCurrent">
    <div>
        <cfoutput>
            <cfset captainId = ListGetAt(teamCurrent,1)>
            #teamId# - #captainId#
            <cfloop array="#arrPreviousMatch#" index="teamPrevious">
                <cfif ListGetAt(teamPrevious,1) eq captainId>
                    <ul>
                        <cfloop list="#listCommon(teamCurrent, teamPrevious)#" index="playerToShuffle">
                            <cfif playerToShuffle neq captainId>
                                <li>
                                    <cfoutput>#playerToShuffle#
                                        <cfif teamId LT arrayLen(arrCurrentMatch)>
                                            <cfset newTeam = teamId + 1>
                                        <cfelse>
                                            <cfset newTeam = 1>
                                        </cfif>

                                        <cfswitch expression="#ListFind(teamCurrent, playerToShuffle)#">
                                            <cfcase value="2"><cfset playerLabel = "B"></cfcase>
                                            <cfcase value="3"><cfset playerLabel = "C"></cfcase>
                                            <cfcase value="4"><cfset playerLabel = "D"></cfcase>
                                            <cfdefaultcase><cfset playerLabel = "A"></cfdefaultcase>
                                        </cfswitch>

                                        <!--- find player to switch with --->
                                        <cfset playerIdToSwap =  ListGetAt(arrCurrentMatch[newTeam], ListFind(teamCurrent, playerToShuffle))>

                                        <!--- TODO: check if player to swap with was on captain's team the day before --->

                                         <cfquery datasource="#variables.DSN#" name="switchPlayer1">
                                            update match_teams
                                            set team_id = #newTeam#, shuffled_id = 1
                                            where match_id = #url.mid# and player_id = #playerToShuffle#
                                         </cfquery>

                                        <cfquery datasource="#variables.DSN#" name="switchPlayer2">
                                            update match_teams
                                            set team_id = #teamId#, shuffled_id = 1
                                            where match_id = #url.mid# and player_id = #playerIdToSwap#
                                        </cfquery>
                                    </cfoutput>
                                </li>
                            </cfif>
                        </cfloop>
                    </ul>
                </cfif>
            </cfloop>
        </cfoutput>
    </div>
</cfloop>

<cffunction name="listCommon" output="false" returnType="string">
    <cfargument name="list1" type="string" required="true" />
    <cfargument name="list2" type="string" required="true" />

    <cfset var list1Array = ListToArray(arguments.List1) />
    <cfset var list2Array = ListToArray(arguments.List2) />

    <cfset list1Array.retainAll(list2Array) />

    <cfreturn ArrayToList(list1Array) />
</cffunction>

