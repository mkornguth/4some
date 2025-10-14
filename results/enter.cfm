<cfinclude template="/header.cfm">
<style>
	#tblTemplate {display: none;}
	#tblTeamResults > tbody > tr > td {border-style: none;}
	#tblTeamResults > tbody {border-bottom:1px solid #dedede;}
	.fa-trash-can {position:relative;top:5px;}
	.fa-trash-can:hover {cursor: pointer;}
</style>



<!--- Get teams in Match --->
<cfset getTeams = CreateObject('component', 'cfc.match').getTeams(matchId=url.mid)>

<cfif getTeams.recordcount GT 0>
	<!--- Get existing results --->
	<cfset getResults = CreateObject('component', 'cfc.match').getResults(matchId=url.mid)>
	<cfset getResultsIndividual = CreateObject('component', 'cfc.match').getResultsIndividual(matchId=url.mid)>

	<cfquery datasource="#variables.DSN#" name="getTeamGameTypes">
		select game_type_id, description
		from game_types
		where is_individual = 0
		order by description
	</cfquery>

	<cfquery datasource="#variables.DSN#" name="getIndividualGameTypes">
		select game_type_id, description
		from game_types
		where is_individual = 1
		order by description
	</cfquery>

	<cfquery dbtype="query" name="getMatchPlayers">
		select player_id, first_name, last_name
		from getTeams
		order by first_name
	</cfquery>

	<h2>Enter Match Results for <cfoutput>#DateFormat(getTeams.match_date,"dddd, mmm d ")#</cfoutput></h2>
	<p>Each match can consist one or more games or bets. For example, a group's match may be made up of three games, a team Nassau, team "Junk" (sandies, greenies, etc.), and individual skins.<p>
	<p>Please enter the results for each game of your match:</p>
	<ul class="nav nav-pills mt-3" id="myTab" role="tablist">
		<li class="nav-item" role="presentation">
			<button class="nav-link active" id="home-tab" data-bs-toggle="tab" data-bs-target="#team-tab-pane" type="button" role="tab" aria-controls="team-tab-pane" aria-selected="true">Team Results</button>
		</li>
		<li class="nav-item" role="presentation">
			<button class="nav-link" id="profile-tab" data-bs-toggle="tab" data-bs-target="#individual-tab-pane" type="button" role="tab" aria-controls="individual-tab-pane" aria-selected="false">Individual Results</button>
		</li>

	</ul>
	<form action="/results/process.cfm" method="post">
	<div class="tab-content" id="myTabContent">
		<!--- team results --->
		<div class="tab-pane fade show active" id="team-tab-pane" role="tabpanel" aria-labelledby="team-tab" tabindex="0">
			
				<table id="tblTeamResults" class="table mt-3">
					<thead>
						<tr>
							<th>Game Type</th>
							<th>Winner</th>
							<th>$ Won</th>
							<th>Score</th>
						</tr>
					</thead>
					<tbody>

					</tbody>
				</table>
				<button type="button" id="btnAddGame" class="btn btn-light"><i class="fa-regular fa-square-plus"></i> Add Game</button>
		</div>
		<!--- Individual results --->
		<div class="tab-pane fade" id="individual-tab-pane" role="tabpanel" aria-labelledby="individual-tab" tabindex="0">
			
				<table id="tblIndividualResults" class="table mt-3">
					<thead>
						<tr>
							<th>Game Type</th>
							<th>Winner</th>
							<th>$ Won</th>
							<th>Number</th>
						</tr>
					</thead>
					<tbody>

					</tbody>
				</table>
				<button type="button" id="btnAddIndividualGame" class="btn btn-light"><i class="fa-regular fa-square-plus"></i> Add Game</button>				
		</div>
	</div>
	<div class="text-center"><input type="submit" value="Submit Match Results" class="btn btn-primary"></div>
	<input type="hidden" name="matchId" value="<cfoutput>#url.mid#</cfoutput>">
	</form>
<hr>
	<!--- Rows to be cloned when added --->
	<table id="tblTemplate">
		<tbody>
			<tr class="gameRow">
				<td class="col-3">
					<select class="form-select" name="gameTypeId">
						<option value=""></option>
						<cfoutput query="getTeamGameTypes">
							<option value="#getTeamGameTypes.game_type_id#">#getTeamGameTypes.description#</option>
						</cfoutput>
					</select>
				</td>
				<td class="col-6">
					<select class="form-select" name="winningTeamId">
						<option value=""></option>
						
						<cfoutput query="getTeams" group="team_id">
							<cfset teamStringAbbr = "Team " & getTeams.last_name>
							<option value="#getTeams.team_id#">
								#teamStringAbbr#
							</option>									
						</cfoutput>
					</select>
				</td>
				<td class="col-1">
					<input type="text" name="amountWon" class="form-control">
				</td>
				<td class="col-1">
					<input type="text" name="score" class="form-control">
				</td>
				<td class="col-1"><i class="fa-regular fa-trash-can" onclick="deleteGameRow(this);"></i></td>
			</tr>
			<tr class="individualRow">
				<td class="col-3">
					<select class="form-select" name="individualTypeId">
						<option value=""></option>
						<cfoutput query="getIndividualGameTypes">
							<option value="#getIndividualGameTypes.game_type_id#">#getIndividualGameTypes.description#</option>
						</cfoutput>
					</select>
				</td>
				<td class="col-6">
					<select class="form-select" name="winningPlayerId">
						<option value=""></option>
						
						<cfoutput query="getMatchPlayers">
							<option value="#getMatchPlayers.player_id#">
								#getMatchPlayers.first_name# #getMatchPlayers.last_name#
							</option>									
						</cfoutput>
					</select>
				</td>
				<td class="col-1">
					<input type="text" name="individualAmountWon" class="form-control">
				</td>
				<td class="col-1">
					<input type="text" name="individualScore" class="form-control">
				</td>
				<td class="col-1"><i class="fa-regular fa-trash-can" onclick="deleteIndividualRow(this);"></i></td>
			</tr>
		</tbody>
	</table>
	
</cfif>
<cfinclude template="/footer.cfm">

<script>
	$(function() {
		<cfif getResults.recordcount GT 0>
			<cfoutput query="getResults" group="result_id">
				createGameRow();
				$('##tblTeamResults > tbody  tr:last select[name="gameTypeId"]').val(#getResults.game_type_id#);
				$('##tblTeamResults > tbody  tr:last select[name="winningTeamId"]').val(#getResults.winning_team_id#);
				$('##tblTeamResults > tbody  tr:last input[name="amountWon"]').val(#getResults.amount_won#);
				$('##tblTeamResults > tbody  tr:last input[name="score"]').val(#getResults.score#);
			</cfoutput>
		<cfelse>
	    	createGameRow();
	    </cfif>

	    <cfif getResultsIndividual.recordcount GT 0>
			<cfoutput query="getResultsIndividual" group="result_id">
				createIndividualRow();
				$('##tblIndividualResults > tbody  tr:last select[name="individualTypeId"]').val(#getResultsIndividual.game_type_id#);
				$('##tblIndividualResults > tbody  tr:last select[name="winningPlayerId"]').val(#getResultsIndividual.winning_player_id#);
				$('##tblIndividualResults > tbody  tr:last input[name="individualAmountWon"]').val(#getResultsIndividual.amount_won#);
				$('##tblIndividualResults > tbody  tr:last input[name="individualScore"]').val(#getResultsIndividual.score#);
			</cfoutput>
		<cfelse>
	    	createIndividualRow();
	    </cfif>
	});

	$("#btnAddGame").click(function(){
	  createGameRow();
	});

	function deleteGameRow(row){
		var rowId = row.parentNode.parentNode.rowIndex;
		document.getElementById('tblTeamResults').deleteRow(rowId);
	}

	function createGameRow(){
		var newRow = $("#tblTemplate").find(".gameRow").clone();
		$("#tblTeamResults").append(newRow);
	}

	$("#btnAddIndividualGame").click(function(){
	  createIndividualRow();
	});

	function createIndividualRow(){
		var newRow = $("#tblTemplate").find(".individualRow").clone();
		$("#tblIndividualResults").append(newRow);
	}
</script>

