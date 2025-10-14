<cfsetting showdebugoutput="no">
<cfset teamsGenerated = false>

<cfset variables.player_id = ListGetAt(cookie.GolferData, 1)>
<cfset variables.username = ListGetAt(cookie.GolferData, 2)>
<cfif IsDefined("cookie.GolferGroups") and LEN(cookie.golferGroups) GT 0>
  <cfset variables.hasGroups = true>
</cfif>

<cfquery datasource="#variables.DSN#" name="getGroup">
	select *
	from 4some.groups
	where group_id = #url.gid#
</cfquery>

<cfquery datasource="#variables.DSN#" name="getTeamGameTypes">
	select *
	from game_types
	where is_individual = 0
	order by description, game_type_id
</cfquery>

<cfquery datasource="#variables.DSN#" name="getIndividualGameTypes">
	select *
	from game_types
	where is_individual = 1
	order by description, game_type_id
</cfquery>
<!--- 
<cfquery datasource="#variables.DSN#" name="getGroupWagers">
	select *
	from group_wagers
	where group_id = #url.gid#
</cfquery>

<cfset strGroupWagers = structNew()>
<cfoutput query="getGroupWagers">
	<cfset strGroupWagers[game_type_id] = wager_amount>
</cfoutput> --->

<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=UTF-8">
  <title>Remote file for Bootstrap Modal</title>  
  <link href="/assets/css/onoffswitch.css" type="text/css"  rel="stylesheet"/>
</head>
<body>
	<style>
		#msg {display:none;color:red;font-weight:bold;margin-top:5px;}
		#tblGolfers {display: none;}
		#tblGolfers .btn-close {}
		#guest-block {margin-left:60px; display:none;}
		.table>:not(caption)>*>* {border-bottom-width: 0px;}
		.fa-circle-xmark {cursor: pointer; font-size: .95em;}
		.btn-group {margin-top:20px;}
		.form-floating>.form-control:focus, .form-floating>.form-control:not(:placeholder-shown) {font-size: 17px;}
		.guest {font-style: italic;}
		#signup-window {width:100px; display:inline;}
		.form-select {font-size:14px;}
		#teamAmounts,#individualAmounts {margin-top:10px;display:none;}
		.input-group-text {font-size:14px;}
	</style>

	<form id="frmMatch" action="modal/settingsProcess.cfm" method="post" class="form">
		<div class="modal-header">
			<h5 class="modal-title">Group Settings</h5>
			<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		</div>
		<div class="modal-body">
			<div class="row mb-3">
			    <label for="signup_window" class="col-sm-4 col-form-label">Signup window</label>
			    <div class="col-sm-8">
					<select class="form-select" name="signup_window">
					  <option value="1" <cfif getGroup.signup_window eq 1>selected</cfif>>One week in advance</option>
					  <option value="2" <cfif getGroup.signup_window eq 2>selected</cfif>>Two weeks in advance</option>
					  <option value="3" <cfif getGroup.signup_window eq 3>selected</cfif>>Three weeks in advance</option>
					  <option value="4" <cfif getGroup.signup_window eq 4>selected</cfif>>Four weeks in advance</option>
					  <option value="8" <cfif getGroup.signup_window eq 8>selected</cfif>>Eight weeks in advance</option>
					  <option value="52" <cfif getGroup.signup_window eq 52>selected</cfif>>No window</option>
					</select>
			    </div>
			</div>
			<!--- <div class="row mb-3">
				<label for="signup_window" class="col-sm-4 col-form-label">Team Wagers</label>
			    <div class="col-sm-8">

					<button type="button" class="btn btn-light"  id="btnTeamWagers">Set Amounts</button>
					<div id="teamAmounts">
						<table id="tblWagerAmounts" class="table">
							<tbody>
								<cfoutput query="getTeamGameTypes">
								<tr>
									<td class="col-6">#getTeamGameTypes.Description#</td>
									<td class="col-6">
										<!--- <input type="text" class="form-control" name="gameType_#getGameTypes.game_type_id#"> --->
										<div class="input-group mb-3">
										  <span class="input-group-text">$</span>
										  <input type="text" class="form-control text-end" aria-label="Amount (to the nearest dollar)" name="gameType_#getTeamGameTypes.game_type_id#"
										  value="<cfif structKeyExists(strGroupWagers, getTeamGameTypes.game_type_id)>#strGroupWagers[getTeamGameTypes.game_type_id]#</cfif>">
										  <span class="input-group-text">.00</span>
										</div>
									</td>
								</tr>
								</cfoutput>
							</tbody>
						</table>
					</div>
			    </div>
			</div>
			<div class="row mb-3">
				<label for="signup_window" class="col-sm-4 col-form-label">Individual Wagers</label>
			    <div class="col-sm-8">

					<button type="button" class="btn btn-light"  id="btnIndividualWagers">Set Amounts</button>
					<div id="individualAmounts">
						<table id="tblIndividualAmounts" class="table">
							<tbody>
								<cfoutput query="getIndividualGameTypes">
								<tr>
									<td class="col-6">#getIndividualGameTypes.Description#</td>
									<td class="col-6">
										<!--- <input type="text" class="form-control" name="gameType_#getGameTypes.game_type_id#"> --->
										<div class="input-group mb-3">
										  <span class="input-group-text">$</span>
										  <input type="text" class="form-control text-end" aria-label="Amount (to the nearest dollar)" name="gameType_#getIndividualGameTypes.game_type_id#"
										  value="<cfif structKeyExists(strGroupWagers, getIndividualGameTypes.game_type_id)>#strGroupWagers[getIndividualGameTypes.game_type_id]#</cfif>">
										  <span class="input-group-text">.00</span>
										</div>
									</td>
								</tr>
								</cfoutput>
							</tbody>
						</table>
					</div>
			    </div>
			</div>
		</div> --->
		<div class="modal-footer">
			<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
			<button type="submit" class="btn btn-primary">Save changes</button>
		</div>

		<input type="hidden" name="gid" value="<cfoutput>#url.gid#</cfoutput>">
	</form>

		<!-- Modal -->
	<div class="modal fade" id="settingsSubModal" tabindex="-1" role="dialog" aria-labelledby="settingsSubModal" aria-hidden="true">
	    <div class="modal-dialog">
	        <div class="modal-content">
	        </div> <!-- /.modal-content -->
	    </div> <!-- /.modal-dialog -->
	</div> <!-- /.modal -->
</body>

<script>
	$( "#btnTeamWagers" ).click(function() {
		$('#teamAmounts').toggle();

	  if ($("#btnTeamWagers").text() == 'Set Amounts') {
	  	$("#btnTeamWagers").text("Hide Amounts");
	  }
	  else {
	  	$("#btnTeamWagers").text("Set Amounts");
	  }
	});

	$( "#btnIndividualWagers" ).click(function() {
		$('#individualAmounts').toggle();

	  if ($("#btnIndividualWagers").text() == 'Set Amounts') {
	  	$("#btnIndividualWagers").text("Hide Amounts");
	  }
	  else {
	  	$("#btnIndividualWagers").text("Set Amounts");
	  }
	});
</script>
</html>
