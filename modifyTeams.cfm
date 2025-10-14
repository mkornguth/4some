<cfinclude template="/header.cfm">
<link rel="stylesheet" type="text/css" href="/assets/css/draggableLists.css"/>
<script language="JavaScript" type="text/javascript" src="/assets/js/draggableLists/core.js"></script>
<script language="JavaScript" type="text/javascript" src="/assets/js/draggableLists/events.js"></script>
<script language="JavaScript" type="text/javascript" src="/assets/js/draggableLists/css.js"></script>
<script language="JavaScript" type="text/javascript" src="/assets/js/draggableLists/coordinates.js"></script>
<script language="JavaScript" type="text/javascript" src="/assets/js/draggableLists/drag.js"></script>
<script language="JavaScript" type="text/javascript" src="/assets/js/draggableLists/dragsort.js"></script>
<script language="JavaScript" type="text/javascript" src="/assets/js/draggableLists/runyourpool.js"></script>
</script>

<style>
	.teamRow {border-bottom: 1px solid #ccc;}
	.teamRowFirst {border-bottom: 1px solid #ccc; border-top: 1px solid #ccc;}
	.teamColumn {text-align: center; font-size:1.2em; line-height: 50px;}
	.playerLabel {height: 25px; border:1px solid #ccc; text-align: center; min-width: 30px;}
	#playerList li {height: 25px;}
	.playerName {min-width: 120px;}
	.playerHcp {font-size: .85em; padding-top:2px;}

	.team1 {background-color: #eeeeee;}
	.team2 {background-color: #d2eded;}
	.team3 {background-color: #f8e5e5;}
	.team4 {background-color: #f8f3e5;}
	.place-holder {font-style: italic;}

</style>

<cfset originalTeamCount = 0>

<!--- if team modifications have been made, process them --->
<cfif isDefined("form.mid") and isDefined("form.teamCount")>

	<cfinclude template="/includes/manualTeams/process.cfm">
	
<!--- if team modifications have NOT been made  yet--->	
<cfelseif isDefined("url.mid")>
	<!--- Get teams in Match --->
	<cfset getTeams = CreateObject('component', 'cfc.match').getTeams(matchId=url.mid,includeAlternates=true)>

	<!--- <cfdump var="#getTeams#"> --->

	<!--- Get registered guests --->
	<cfquery datasource="#variables.DSN#" name="getRegisteredGuests">
		select *
		from match_guests
		where match_id = #url.mid# and player_id is not null
	</cfquery>
	<cfset listRegisteredGuests = valueList(getRegisteredGuests.player_id)>

	<cfif getTeams.recordcount EQ 0>
		<cfquery datasource="#variables.DSN#" name="getTeams"> 
			select *, ceiling(rn/4) as team_id
			from ( 
				select p.player_id, p.first_name, p.last_name, p.ghin_id, p.handicap_current as handicap_to_use, m.signup_date, null as guest_id, @rownum := @rownum + 1 as rn
			    from match_players m
					cross join (select @rownum := 0) r
			    	inner join players p on p.player_id = m.player_id
			    	left outer join match_teams mt on mt.match_id = #url.mid# and mt.player_id = m.player_id
			    where m.match_id = #url.mid#
			    ) innerQuery
		</cfquery>

		<!--- Get guests in Match --->
		<cfset getGuests = CreateObject('component', 'cfc.match').getGuests(matchId=url.mid)>

		<!--- Add guets to teams query --->
		<cfset i = 0>
		<cfoutput query="getGuests">
			<cfset temp = QueryAddRow(getTeams)> 
			<cfset local.teamId = ceiling((getTeams.recordcount + 1)/4)>
			<cfset Temp = QuerySetCell(getTeams, "player_id", getGuests.player_id)> 
			<cfset Temp = QuerySetCell(getTeams, "first_name", getGuests.first_name)> 
			<cfset Temp = QuerySetCell(getTeams, "last_name", getGuests.last_name)> 
			<cfset Temp = QuerySetCell(getTeams, "handicap_to_use", getGuests.handicap_to_use)>
			<cfset Temp = QuerySetCell(getTeams, "signup_date", getGuests.signup_date)>
			<cfset Temp = QuerySetCell(getTeams, "guest_id", getGuests.guest_id)>
			<cfset Temp = QuerySetCell(getTeams, "rn", getTeams.recordcount + 1)>
			<cfset Temp = QuerySetCell(getTeams, "team_id", local.teamId)>
		</cfoutput>


		<h1>Create Teams</h1>
		<p><strong>Players were temporarily added to teams in the order they signed up.</strong> Drag players to change their teams.</p>
	<cfelse>
		<h1>Modify Teams</h1>
	</cfif>


		<!---  <cfdump var="#getTeams#">
<cfdump var="#getGuests#">
		<cfabort> --->



		<form action="" method="post">
			<div class="row">
				<!--- column with team/label headings --->
				<div class="col-1">

					<cfoutput query="getTeams" group="team_id">
						<cfif team_id LT 99>
							<h4>&nbsp;</h4>
							<cfloop list="A,B,C,D" index="label">
								<div class="playerLabel">#label#</div>
							</cfloop>
						</cfif>
					</cfoutput>
				</div>
				<!--- draggable column --->
				<div class="col-6">
					<cfset teamIndex = 0>	
					<ul id="playerList" class="sortable boxy">
						<cfset placeholderIdx = -100>
						<cfoutput query="getTeams" group="team_id">
							<cfif getTeams.team_id neq 99>
								<cfset originalTeamCount = originalTeamCount + 1>
							</cfif>
							<h4><cfif team_id LT 99>Team #team_id#<cfelse>Alternates</cfif></h5>
							<cfoutput>
								<cfif LEN(getTeams.player_id) eq 0>
									<cfif LEN(getTeams.guest_id) eq 0>
										<cfset placeholderIdx = placeholderIdx - 1>
										<cfset local.pid = placeholderIdx>
									<cfelse>
			  							<cfset local.pid  = "u-" & getTeams.guest_id>
									</cfif>
								<cfelse>
									<cfset local.pid = getTeams.player_id>
								</cfif>
								<li class="team#getTeams.team_id#"  name="#local.pid#" id="#local.pid#" isDisabled="false" onmouseup="dropped(this);" data-team="#getTeams.team_id#">
							        <div class="handle">
							            <div class="playerBox">
							                <div class="playerDetail">
								                <div class="playerName float-start">
								                	<cfif LEN(getTeams.player_id) GT 0 OR LEN(getTeams.guest_id) GT 0>
								                		#getTeams.first_name# #getTeams.last_name# <cfif LEN(getTeams.guest_id) GT 0 OR ListFind(listRegisteredGuests, getTeams.player_id)><em>(g)</em></cfif>
								                	<cfelse>
									                	&nbsp;
									                </cfif>
								                </div>
								                <div class="playerHcp float-end">#getTeams.handicap_to_use#</div>
								            </div>
							            </div>
							        </div>
							    </li>
							</cfoutput>
						</cfoutput>
						<h4>Placeholders</h5>
						<cfloop from="1" to="4" index="i">
							 <li class="place-holder"  name="0" id="-<cfoutput>#i#</cfoutput>" isDisabled="false" onmouseup="dropped(this);">
						        <div class="handle">
						            <div class="playerBox">
						                <div class="playerDetail">
							                <div class="playerName float-start">Placeholder</div>
							            </div>
						            </div>
						        </div>
						    </li>
						 </cfloop>
					</ul>

					<div style="margin-top:25px;"><input type="submit" class="btn btn-primary" value="Submit" onclick="getList();return validate();"></div>
				</div>
			</div>

		
			<input type="hidden" id="playerSubmissionList" name="playerSubmissionList">
			<input type="hidden" id="teamCount" name="teamCount" value="<cfoutput>#originalTeamCount#</cfoutput>">
			<input type="hidden" name="mid"  value="<cfoutput>#url.mid#</cfoutput>">
		</form>

	
</cfif>

<div class="modal fade" id="modalInvalidTeams" tabindex="-1" aria-labelledby="modalInvalidTeamslLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h1 class="modal-title fs-5" id="exampleModalLabel">Invalid Team Assignment</h1>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <p>Each team must have exactly four (4) players.</p>
        <p>If necessary, drag a 'Placeholder' player into a team to ensure the correct number.</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>

      </div>
    </div>
  </div>
</div>


<script>
	function getList(){
		map=Function.prototype.call.bind([].map)
		list=document.getElementById("playerList").querySelectorAll("li");
		playerSubmissionList = map(list, function(x){return x.id});
		document.getElementById("playerSubmissionList").value = playerSubmissionList;
	}



	function dropped(player){
		//alert(player.id);
		findNewPosition(player);
	}

	function findNewPosition(player){
		// alert("find id " + id)
		var newIndex = $('#playerList').find("#" + player.id).index();

		switch(true){
			case (newIndex <=5):
				newTeam = 1;
				break;
			case (newIndex <=10):
				newTeam = 2;
				break;
			case (newIndex <=15):
				newTeam = 3;
				break;
			case (newIndex <=20):
				newTeam = 4;
				break;
			case (newIndex <=25):
				newTeam = 5;
				break;
			case (newIndex <=30):
				newTeam = 6;
				break;
		}
		
		$('#' + player.id).attr("data-team",newTeam);

	    return false;
	}

	function validate(){
		var teams = {};

		var team_count = parseInt($('#teamCount').val()) + 1;
		var isValid = true
		for (let i = 1; i < team_count ; i++) {
		   if ($('#playerList li[data-team=' + i + ']').length != 4){
		   	isValid = false;
		   }
		}

		var modalInvalidTeams = new bootstrap.Modal(document.getElementById('modalInvalidTeams'), {
		  keyboard: false
		});
		if (!isValid){
			modalInvalidTeams.show();
		}
		return isValid;

	}
</script>



<cfinclude template="/footer.cfm">