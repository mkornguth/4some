<cfinclude template="/header.cfm">
<style>
	#viewTeams {display:none;}
</style>
<cfif isDefined("url.mid")>
	<!--- Get existing team results --->
	<cfset getResults = CreateObject('component', 'cfc.match').getResults(matchId=url.mid)>

	<!--- Get existing individual results --->
	<cfset getResultsIndividual = CreateObject('component', 'cfc.match').getResultsIndividual(matchId=url.mid)>

	<cfif getResults.recordcount GT 0>
		<h2>Match Results for <cfoutput>#DateFormat(getResults.match_date,"dddd, mmm d ")#</cfoutput></h2>
		<table class="table">
			<thead>
				<tr>
					<th>Game</th>
					<th>Winner</th>
					<th class="text-center">Won</th>
					<th class="text-center">Score/#</th>
				</tr>
			</thead>
			<tbody>
				<cfoutput query="getResults" group="result_id">
					<cfset teamStringAbbr = "Team " & getResults.last_name>
					<tr>
						<td>#getResults.description#</td>
						<td>
							#teamStringAbbr#
						</td>
						<td class="text-center">$#getResults.amount_won#</td>
						<td class="text-center">#getResults.score#</td>
					</tr>
				</cfoutput>
				<cfoutput query="getResultsIndividual">
					<tr>
						<td>#getResultsIndividual.description#</td>
						<td>#getResultsIndividual.first_name# #getResultsIndividual.last_name#</td>
						<td class="text-center">$#getResultsIndividual.amount_won#</td>
						<td class="text-center">#getResultsIndividual.score#</td>
					</tr>
				</cfoutput>
			</tbody>
		</table>

		<div class="row">
			<div class="col-6">
				<cfif IsAdmin>
					<a href="/results/enter.cfm?mid=<cfoutput>#url.mid#</cfoutput>" class="btn btn-primary">Edit Match Results</a>
				</cfif>
			</div>
			<div class="col-6 text-end">
				<button type="button" id="btnViewTeams" class="btn btn-light">View Teams</button>
				<a href="/groups/performance.cfm" class="btn btn-light">Performance Report</a>
			</div>
		</div>
		<div id="viewTeams">
			<hr/>
			<cfinclude template="/viewTeamsInclude.cfm">
		</div>
	<cfelse>
		<cflocation url="/results/enter.cfm?mid=#url.mid#">
	</cfif>
<cfelse>
	<cflocation url="/calendar/">
</cfif>

<script>
	$("#btnViewTeams").click(function(){
	  $('#viewTeams').toggle();

	  if ($("#btnViewTeams").text() == 'View Teams') {
	  	$("#btnViewTeams").text("Hide Teams");
	  }
	  else {
	  	$("#btnViewTeams").text("View Teams");
	  }
	});
</script>

<cfinclude template="/footer.cfm">