<style>
	.highlight {color:#1d86c8;}
	.card {margin-top:10px;}
	.place-holder {font-style: italic; color:#CBCBCB;}
	#tblTeamGenLog {font-size:10px; display:none;}
	#btnTeamGenLog {width:200px;}
</style>

<!--- Get teams in Match --->
<cfset getTeams = CreateObject('component', 'cfc.match').getTeams(matchId=url.mid)>

<!--- <cfdump var="#getTeams#"> --->

<cfset handcuffed = valueList(getTeams.player_id_handcuff)>

<cfquery datasource="#variables.DSN#" name="getAlternates">
	select g.player_id, g.first_name, g.last_name, g.ghin_id, g.handicap_current, mt.player_label
	from matches m
		inner join match_teams mt on mt.match_id = m.match_id
		inner join players g on g.player_id = mt.player_id
	where m.match_id = #url.mid# and mt.team_id = 99
	order by mt.team_id, mt.player_label
</cfquery>

<cfquery datasource="#variables.DSN#" name="getRegisteredGuests">
	select *
	from match_guests
	where match_id = #url.mid# and player_id is not null
</cfquery>
<cfset listRegisteredGuests = valueList(getRegisteredGuests.player_id)>

<cfquery datasource="#variables.DSN#" name="getTeamGenLog">
	select log_id, date_time, p.first_name, p.last_name, mt.description
	from team_gen_log l
		inner join players p on p.player_id = l.player_id
		inner join match_types mt on mt.match_type_id = l.match_type_id
	where match_id = #url.mid#
	order by date_time desc
</cfquery>

<cfset nextAlternate = getAlternates.recordcount + 1>
<cfset isJoined = false>

<cfif NOT cgi.script_name contains "matchDate.cfm">
<h2>Teams for <cfoutput>#DateFormat(getTeams.match_date, "mmm d, yyyy")#</cfoutput></h2 >
</cfif>
<div>Format: <strong><cfoutput>#getTeams.description#</cfoutput></strong></div>
<div class="row">
	<cfoutput query="getTeams" group="team_id">
		<div class="col-12 <cfif NOT cgi.SCRIPT_NAME CONTAINS "MatchDate.cfm">col-sm-6 col-lg-4</cfif>">
	  		<div class="card">
	  			<div class="card-body">
					<cfoutput>
						<div <cfif getTeams.player_id eq variables.player_id>class="highlight" <cfset isJoined = true></cfif>>
							<cfif getTeams.player_id GT 0 OR getTeams.guest_id GT 0>
								#getTeams.player_label# - #getTeams.first_name# #getTeams.last_name# 
							<cfelse>
								#getTeams.player_label# - <span class="place-holder">Placeholder</span>
							</cfif>
							<cfif LEN(getTeams.guest_id) GT 0 OR ListFind(listRegisteredGuests, getTeams.player_id)><em>(g)</em></cfif><cfif LEN(getTeams.guest_id) GT 0> - #numberFormat(getTeams.handicap_to_use,"__._")#</cfif> 
							<cfif getTeams.is_handcuffed eq 1 or ListFind(handcuffed,getTeams.player_id)><i class="fa-solid fa-link"></i></cfif><cfif getTeams.player_id GT 0> - #numberFormat(getTeams.handicap_to_use,"__._")#</cfif>
							<cfif getTeams.shuffled_id GT 0><i class="fa-solid fa-right-left"></i></cfif>
						</div>
					</cfoutput>
				</div>
			</div>
		</div>
	</cfoutput>
	<cfif getAlternates.recordcount GT 0>
		<div class="col-12 <cfif NOT cgi.SCRIPT_NAME CONTAINS "MatchDate.cfm">col-sm-6 col-lg-4</cfif>">
			<div style="margin-top: 20px;">
				Alternates:
				<ol>
				<cfoutput query="getAlternates">
					<li <cfif getAlternates.player_id eq variables.player_id>class="highlight" <cfset isJoined = true></cfif>>#getAlternates.first_name# #getAlternates.last_name#</li>
				</cfoutput>
				</ol>
			</div>
		</div>
	</cfif>
	<hr/>
	<a href="#" class="btn btn-light btn-sm" id="btnTeamGenLog" role="button" data-bs-toggle="button">Show Team Generation Log</a>
	<table class="table table-bordered" id="tblTeamGenLog">
		<tbody>
			<cfoutput query="getTeamGenLog">
			<tr>
				<td>#DateFormat(getTeamGenLog.date_time, "m/d/yy")# #TimeFormat(getTeamGenLog.date_time, "h:mm tt")#</td>
				<td><cfif getTeamGenLog.currentRow eq getTeamGenLog.recordcount>Created<cfelse>Changed</cfif></td>
				<td>by #getTeamGenLog.first_name# #getTeamGenLog.last_name#</td>
				<td>#getTeamGenLog.description#</td>
			</tr>
			</cfoutput>
		</tbody>
	</table>
</div>
<script>
$(document).ready(function() {
  $("#btnTeamGenLog").click(function() {
    if ($("#tblTeamGenLog").is(":visible")){
    	$("#tblTeamGenLog").hide();
    	$("#btnTeamGenLog").text("Show Team Generation Log");
    }
    else {
    	$("#tblTeamGenLog").show();
    	$("#btnTeamGenLog").text("Hide Team Generation Log");
    }

    
  });
});
</script>