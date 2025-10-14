<cfinclude template="/header.cfm">
<cfparam name="url.rid" default="1">

<cfquery datasource="#variables.DSN#" name="getGameTypesPlayed">
	SELECT distinct game_type_id 
	FROM match_results 
	order by game_type_id
</cfquery>

<!--Load the AJAX API-->
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>



<h2>Group Performance</h2>

<form action="performance.cfm" method="get">
	<div class="row">
		<div class="col-auto">
			<label for="selectReport" class="col-form-label">Report:</label>
		</div>
		<div class="col-auto">
			<select id="selectReport" name="rid" class="form-select" onchange="this.form.submit();">
				<option value="1" <cfif url.rid eq 1>selected</cfif>>Money Winnings</option>
				<option value="2" <cfif url.rid eq 2>selected</cfif>>Wins by Game Type</option>
			</select>
		</div>
	</div>
</form>
<hr/>

<cfswitch expression="#url.rid#">
	<!--- Money Winnings --->
	<cfcase value="1">
		<cfquery datasource="#variables.DSN#" name="getWinnings">
			select player_id, last_name, sum(amount_won) as amountWon
		    from
		    (
				SELECT m.match_id, mr.game_type_id, p.player_id, p.last_name,  (mr.amount_won /
					(select count(*) from 4some.match_teams where match_id = mr.match_id and team_id = mr.winning_team_id)) as amount_won
				FROM 4some.match_results mr
					inner join 4some.matches m on m.match_id = mr.match_id
					inner join 4some.match_teams mt on m.match_id = mt.match_id and mt.team_id = mr.winning_team_id
					inner join 4some.players p on p.player_id = mt.player_id
				where group_id = #url.gid#
				UNION
				SELECT mr.match_id, mr.game_type_id, p.player_id, p.last_name, mr.amount_won
				FROM 4some.match_results_individual mr
					inner join 4some.matches m on m.match_id = mr.match_id
					inner join 4some.players p on p.player_id = mr.winning_player_id
				where group_id = #url.gid#
		    ) innerQuery
		    group by player_id, last_name
		    order by amountWon desc
		</cfquery>

			<script type="text/javascript">    
				google.charts.load('current', {packages:['corechart']});
				google.charts.setOnLoadCallback(drawChart);
				function drawChart() {
					var data = google.visualization.arrayToDataTable([
						['Name', 'Amount'],
						<cfoutput query="getWinnings">
						['#getWinnings.last_name#', #getWinnings.amountWon#],
						</cfoutput>
					]);
					var options = {
						title: "Total Winnings",
						titleTextStyle: {fontSize:'16'},
						width: 800,
						height: 600,
						bar: {groupWidth: '90%'},
						legend: { position: 'none' },
						hAxis: {format: '0'},
					};
					var chart = new google.visualization.BarChart(document.getElementById('totalWinnings'));
					chart.draw(data, options);
				}
			</script>
	    	<div id="totalWinnings"></div>

	</cfcase>
	<!--- Wins By Game Type --->
	<cfcase value="2">
		<cfquery datasource="#variables.DSN#" name="getWinsByGameType">
			select game_type_id, last_name, description, count(*) as gameTypeWins
		    from
		    (
		    SELECT mr.game_type_id, p.player_id, p.last_name, gt.description
			FROM 4some.match_results mr
				inner join 4some.matches m on m.match_id = mr.match_id
				inner join 4some.match_teams mt on m.match_id = mt.match_id and mt.team_id = mr.winning_team_id
				inner join 4some.players p on p.player_id = mt.player_id
		        inner join 4some.game_types gt on gt.game_type_id = mr.game_type_id
			where group_id = #url.gid#
		    ) innerq
		    group by game_type_id, last_name, description
		    order by description, game_type_id, gameTypeWins desc
		</cfquery>

		<cfquery datasource="#variables.DSN#" name="getIndividualWinsByGameType">
			select game_type_id, player_id, last_name, description, sum(score) as gameTypeWins
		    from
		    (
		    SELECT mr.game_type_id, p.player_id, p.last_name, gt.description, mr.score
			FROM 4some.match_results_individual mr
				inner join 4some.matches m on m.match_id = mr.match_id
				inner join 4some.players p on p.player_id = mr.winning_player_id
		        inner join 4some.game_types gt on gt.game_type_id = mr.game_type_id
			where group_id = #url.gid#
		    ) innerq
		    group by game_type_id, player_id, last_name, description
		    order by description, game_type_id, gameTypeWins desc
		</cfquery>


		<cfoutput query="getWinsByGameType" group="game_type_id">
			<script type="text/javascript">    
				google.charts.load('current', {packages:['corechart']});
				google.charts.setOnLoadCallback(drawChart);
				function drawChart() {
					var data = google.visualization.arrayToDataTable([
						['Name', 'Win Count'],
						<cfoutput>
						['#getWinsByGameType.last_name#', #getWinsByGameType.gameTypeWins#],
						</cfoutput>
					]);
					var options = {
						title: "#getWinsByGameType.description#",
						titleTextStyle: {fontSize:'16'},
						width: 600,
						height: 400,
						bar: {groupWidth: '90%'},
						legend: { position: 'none' },
						hAxis: {format: '0'},
					};
					var chart = new google.visualization.BarChart(document.getElementById('gameType_#getWinsByGameType.game_type_id#'));
					chart.draw(data, options);
				}
			</script>
	    	<div id="gameType_#getWinsByGameType.game_type_id#"></div>
		</cfoutput>

		<cfoutput query="getIndividualWinsByGameType" group="game_type_id">
			<script type="text/javascript">    
				google.charts.load('current', {packages:['corechart']});
				google.charts.setOnLoadCallback(drawChart);
				function drawChart() {
					var data = google.visualization.arrayToDataTable([
						['Name', 'Win Count'],
						<cfoutput group="player_id">
						['#getIndividualWinsByGameType.last_name#', #getIndividualWinsByGameType.gameTypeWins#],
						</cfoutput>
					]);
					var options = {
						title: "#getIndividualWinsByGameType.description#",
						titleTextStyle: {fontSize:'16'},
						width: 600,
						height: 400,
						bar: {groupWidth: '90%'},
						legend: { position: 'none' },
						hAxis: {format: '0'},
					};
					var chart = new google.visualization.BarChart(document.getElementById('gameType_#getIndividualWinsByGameType.game_type_id#'));
					chart.draw(data, options);
				}
			</script>
	    	<div id="gameType_#getIndividualWinsByGameType.game_type_id#"></div>
		</cfoutput>

		

		</cfcase>
</cfswitch>


<cfinclude template="/footer.cfm">