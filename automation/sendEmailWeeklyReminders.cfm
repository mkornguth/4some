<cfquery datasource="#variables.DSN#" name="getMatchSummary">
	select  m.group_id, m.match_id, g.group_name, (select count(*) from match_players where match_id = m.match_id) as playingCount
	from matches m 
		inner join 4some.groups g on g.group_id = m.group_id
	where week(match_date,1) = week(now(),1) and year(match_date) = year(now())
	group by group_id, match_id, group_name;
</cfquery>

<cfset strMatchCounts = structNew()>
<cfoutput query="getMatchSummary">
	<cfset strMatchCounts[getMatchSummary.match_id] = getMatchSummary.playingCount>
</cfoutput>


<cfloop query="getMatchSummary" group="group_id">
	<cfquery datasource="#variables.DSN#" name="getMatchesForWeek">
		select m.match_id, m.match_date, mp.player_id, mp.signup_date, p.first_name, p.last_name
		from matches m
			inner join match_players mp on mp.match_id = m.match_id
		    inner join players p on p.player_id = mp.player_id
		where week(match_date,1) = week(now(),1) and year(match_date) = year(now()) and m.group_id = #getMatchSummary.group_id#
		group by m.match_id, m.match_date, mp.player_id, mp.signup_date, p.first_name, p.last_name
		order by match_date, last_name
	</cfquery>

	<cfquery datasource="#variables.DSN#" name="getGroupEmails">
		select p.email
		from group_players g
			inner join players p on p.player_id = g.player_id
		where group_id =#getMatchSummary.group_id#
	</cfquery>

	<cfmail subject="#getMatchSummary.group_name# This Week" from="Teams.golf <no-reply@teams.golf>" to="#valueList(getGroupEmails.email)#" type="html">
		<style>
			##logo {text-align: center;}
			.wrapper {width:500px; margin:0 auto; font-family:sans-serif;}
		</style>

		<div class="wrapper">
			<div id="logo"><a href="https://www.teams.golf"><img src="http://www.teams.golf/assets/img/logo2.jpg"></a></div>
			<h1><cfoutput>#getMatchSummary.group_name#</cfoutput> This Week</h1>
			<p>Please review the matches below and change your match status, as necessary, by logging in at <a href="https://www.teams.golf/login.cfm">Teams.golf</a>.</p>
			<cfoutput query="getMatchesForWeek" group="match_id">
				<h2>#DayOfWeekAsString(DayOfWeek(getMatchesForWeek.match_date))# #DateFormat(getMatchesForWeek.match_date, "mmmm dd")#</h2>
				<h4>Currently, there are #strMatchCounts[getMatchesForWeek.match_id]# players:</h4>
				<ul>
					<cfoutput>
						<li>#getMatchesForWeek.first_name# #getMatchesForWeek.last_name#</li>
					</cfoutput>
				</ul>
			</cfoutput>
		</div>
	</cfmail>
</cfloop>