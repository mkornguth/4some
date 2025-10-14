<cfsetting showdebugoutput="no">
<cfset teamsGenerated = false>
<cfset dayIsBlocked = false>

<cfif NOT isDefined("cookie.GolferData") OR LEN(TRIM(cookie.GolferData)) eq 0>
	<cflocation url="/login.cfm">
	<cfabort>
</cfif>

<cfset variables.player_id = ListGetAt(cookie.GolferData, 1)>
<cfset variables.username = ListGetAt(cookie.GolferData, 2)>
<cfif IsDefined("cookie.GolferGroups") and LEN(cookie.golferGroups) GT 0>
  <cfset variables.hasGroups = true>
</cfif>

<cfquery datasource="#variables.DSN#" name="getGroupSettings">
	select *
    from 4some.groups 
    where  group_id = #url.gid#
</cfquery>

<cfquery datasource="#variables.DSN#" name="getMatch">
	select match_id, match_date
    from matches 
    where match_date = #CreateODBCDate(url.date)# and group_id = #url.gid#
</cfquery>

<cfif getMatch.recordcount GT 0>
	<cfset url.mid = getMatch.match_id>

	<cfquery datasource="#variables.DSN#" name="getGolfers">
		select p.*, m.signup_date, mt.team_id
	    from match_players m
	    	inner join players p on p.player_id = m.player_id
	    	left outer join match_teams mt on mt.match_id = #getMatch.match_id# and mt.player_id = m.player_id
	    where m.match_id = #getMatch.match_id#
	    order by signup_date
	</cfquery>

 	<cfquery datasource="#variables.DSN#" name="getMembersNotPlaying">
		select  gp.player_id, p.first_name, p.last_name
		from group_players gp
			inner join players p on p.player_id = gp.player_id
		where group_id = #url.gid# and gp.player_id <cfif getGolfers.recordcount GT 0>NOT IN (#ValueList(getGolfers.player_id)#)</cfif>
		order by first_name, last_name
	</cfquery>

	<cfquery datasource="#variables.DSN#" name="getGuests">
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
				WHEN LENGTH(handicap) > 0 THEN  handicap
				ELSE handicap_current
			END as handicap_to_use
		from
		(
		select g.match_id, g.signup_date, gu.guest_id, gr.player_id, gu.first_name as uFirst, gu.last_name as uLast, gu.is_handcuffed, gu.player_id_handcuff, gu.handicap, p.first_name as rFirst, p.last_name as rLast, p.handicap_current
			    from match_guests g
			    	left outer join guests_unregistered gu on gu.guest_id = g.guest_id and gu.group_id = #url.gid#
			    	left outer join guests_registered gr on gr.player_id = g.player_id and gr.group_id = #url.gid#
			    	left outer join players p on p.player_id = gr.player_id
			where match_id = #getMatch.match_id#
		) iq
	    
	</cfquery>

	<cfset handcuffed = ValueList(getGuests.player_id_handcuff)>

	<cfquery datasource="#variables.DSN#" name="getGuestsOther">
		SELECT null as player_id, guest_id, first_name, last_name, handicap, is_handcuffed, player_id_handcuff
		FROM 4some.guests_unregistered
		where group_id = #url.gid#
		UNION
		SELECT g.player_id, null as guest_id, p.first_name, p.last_name, handicap_current as handicap, null as is_handcuffed, null as player_id_handcuffed
		 FROM 4some.guests_registered g
		 inner join players p on p.player_id = g.player_id
		where group_id = #url.gid#
		order by first_name, last_name ;
	</cfquery>


	<cfset playerIdList = valueList(getGolfers.player_id)>

	<cfif getGolfers.team_id GT 0>
			<cfset teamsGenerated = true>
	</cfif>
<cfelse>
	<cfquery datasource="#variables.DSN#" name="getCalendarBlock">
		select *
	    from group_calendar_nomatch
	    where nomatch_date = #CreateODBCDate(url.date)# and group_id = #url.gid#
	</cfquery>
	<cfif getCalendarBlock.recordcount GT 0>
		<cfset dayIsBlocked = true>
	</cfif>
</cfif>

<cfset variables.golferId = ListGetAt(cookie.GolferData, 1)>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>Remote file for Bootstrap Modal</title> 
    <style>
		#msg {display:none;color:red;font-weight:bold;margin-top:5px;}
		#tblGolfers .btn-close {}
		#guest-block, #member-block {margin-left:60px; display:none;}
		.table>:not(caption)>*>* {border-bottom-width: 0px;}
		.fa-circle-xmark {cursor: pointer; font-size: .95em;}
		.btn-group {margin-top:20px;}
		.form-floating>.form-control:focus, .form-floating>.form-control:not(:placeholder-shown) {font-size: 17px;}
		.guest {font-style: italic;}
		.handcuff {display:none;}
		.trend-down {color:#5cb85c;}
		.trend-up {color:#dc3545;}
	</style> 
</head>
<body>
	

<form id="frmMatch" action="/calendar/modal/matchProcess.cfm<cfif IsDefined("url.commish")>?commish=1</cfif>" method="post" class="form">
<cfif NOT dayIsBlocked>	
	<cfif NOT teamsGenerated>
			<!--- ------------------- --->
			<!--- Teams NOT generated --->
			<!--- ------------------- --->
		
				<div class="modal-header">
					 <h2 class="modal-title"><cfoutput>#DateFormat(url.date,"ddd, mmm d ")#</cfoutput></h2>
					 <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
				</div>            <!-- /modal-header -->
				<div class="modal-body">
					<cfif DateCompare(url.date,now(),"d") GTE 0>	
						<cfif getMatch.recordcount eq 0>
							<cfif dateDiff("ww", now(), CreateODBCDate(url.date)) LTE getGroupSettings.signup_window>

								<p>No Match has been created yet. Click the button to kick things off.</p>
								<div style="margin-top:30px;">
									<button type="submit" id="btnCreate" name="btnCreate" class="btn  btn-primary">Create match</button>
								</div>
							<cfelse>
								<div class="alert alert-warning">Per your group settings, matches can only be created <cfoutput>#getGroupSettings.signup_window#</cfoutput> weeks in advance.</div>
							</cfif>
						<cfelse>
						  		<cfif IsDefined("getGolfers") and getGolfers.RecordCount GT 0>
						  			<div class="row mb-3">
						  				
						      			<div class="col-6">
						      				<p><cfoutput>#getGolfers.RecordCount + getGuests.RecordCount#</cfoutput> <cfif getGolfers.RecordCount + getGuests.RecordCount GT 1>golfers <span class="d-none d-md-inline">are<cfelse>golfer <span class="d-none d-md-inline">is</cfif> playing so far</span></p>
						      				<!--- Button group --->
						      				<div class="btn-group" role="group" aria-label="Button Group">
						      					<cfif ListFind(playerIdList,variables.player_id)>
						      						<button type="submit" id="btnRemove"class="btn btn-danger" onclick="confirmRemoval(<cfoutput>#variables.player_id#</cfoutput>,0);"><i class="fa-solid fa-circle-minus"></i></i> Remove Myself</button>
						      					 	<div class="dropdown">
													  <button class="btn btn-light dropdown-toggle" type="button" id="dropdownMenuButton1" data-bs-toggle="dropdown" aria-expanded="false">
													    Other Actions
													  </button>
													  <ul class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
													  	<cfif IsAdmin>
														  	<li><a class="dropdown-item" id="ddAddMember" name="ddAddMember"  href="#"><i class="fa-solid fa-plus-circle fa-fw"></i> Add member</a></li>
														</cfif>
													    <li><a class="dropdown-item" id="ddAddGuest" name="ddAddGuest"  href="#"><i class="fa-solid fa-user-plus fa-fw"></i> Add guest</a></li>
													    <li><a class="dropdown-item" id="btnToggleGolfers" href="#"><i class="fa-solid fa-circle-chevron-up fa-fw"></i> Hide golfer list</a></li>
													  </ul>
													</div>
						      					<cfelse>
													<button type="submit" id="btnAdd" name="btnAdd" class="btn  btn-success"><i class="fa-solid fa-circle-plus"></i> Join match</button>
												</cfif>
												<!--- <button type="button" id="btnAddGuest" name="btnAddGuest" class="btn  btn-light"><i class="fa-solid fa-circle-plus"></i> Add guest</button>
												<button type="button" id="btnToggleGolfers" class="btn btn-light"><i class="fa-solid fa-circle-chevron-down"></i> Show golfers</button>

										   --->
											</div>
						      			</div>
						      			<div class="col-6">
						      				<div class="text-end"></div>
						      			</div>
						  			</div>
						  			<div class="row mb-3">
						  				<div id="member-block">
						  					<div class="row g-3">
												<div class="col-auto form-floating mb-3">
													<select class="form-select" id="member" name="memberId" placeholder="Member">
														<option></option>
														<cfoutput query="getMembersNotPlaying">
															<option value="#getMembersNotPlaying.player_id#">#getMembersNotPlaying.first_name# #getMembersNotPlaying.last_name#</option>
														</cfoutput>
													</select>
													<label for="floatingInput">Member</label>
												</div>
												<div class="col-auto">
													<button type="submit" id="btnAddMember" name="btnAddMember" class="btn btn-primary mb-3 disabled">Add</button>
												</div>
											</div>
						  				</div>
						  				<div id="guest-block">
						  					<div class="row g-3">
						  						<cfif getGuestsOther.recordcount GT 0>
													<div class="col-auto form-floating mb-3">
														<select class="form-select" id="guest" name="guest" placeholder="Guest">
															<option></option>
															<cfoutput query="getGuestsOther">
																<cfset tempId = "">
																<cfif LEN(getGuestsOther.player_id) GT 0>
																	<cfset tempId &= "r-">
																<cfelse>
																	<cfset tempId &= "u-">
																</cfif>
																<cfif LEN(getGuestsOther.player_id) GT 0>
																	<cfset tempId &= getGuestsOther.player_id>
																<cfelse>
																	<cfset tempId &= getGuestsOther.guest_id>
																</cfif>

																<option value="#tempId#">#getGuestsOther.first_name# #getGuestsOther.last_name#</option>
															</cfoutput>
														</select>
														<label for="floatingInput">Guest</label>
													</div>
													<div class="col-auto">
														<button type="submit" name="btnAddGuest" id="btnAddGuest" class="btn btn-primary mb-3 disabled">Add</button>
													</div>
												<cfelse>
													<p>Your guest list is currently empty. 
														<cfif isAdmin eq 1>
															<a href="/groups/guests.cfm?gid=<cfoutput>#url.gid#</cfoutput>" class="btn btn-sm btn-secondary">Add guest(s)</a>
														</cfif>
													</p>
												</cfif>
											</div>
						  				</div>
						  				<table id="tblGolfers" class="table table-striped">
						  					<tr>
													<th>Golfer</th>
													<th class="text-center">Hcp</th>
													<th></th>
													<th class="text-end">Joined</th>
						  					</tr>
					  						<cfoutput query="getGolfers">
					  							<cfif IsDefined("getGolfers.handicap_current") and isDefined("getGolfers.handicap_previous") and LEN(getGolfers.handicap_previous) GT 0>
						  							<cfset trend = getGolfers.handicap_current - getGolfers.handicap_previous>
						  						<cfelse>
						  							<cfset trend = 0>
						  						</cfif>
					  							<cfset variables.signupDate = DateAdd('h',-4, getGolfers.signup_date)>
														<tr>
						  								<td><span class="d-none d-md-inline">#getGolfers.first_name#</span> #getGolfers.last_name# <cfif ListFind(handcuffed,getGolfers.player_id)><i class="fa-solid fa-link"></i></cfif> <cfif variables.golferId eq getGolfers.player_id or IsAdmin eq 1><i class="fa-regular fa-circle-xmark fa-xl fa-fw" onclick="confirmRemoval('#getGolfers.player_id#',0);"></i></cfif></td>
						  								<td align="center">#getGolfers.handicap_current#</td>
						  								<td>
																<cfif trend GT 0>
																	<div class="trend-up"><i class="fa-solid fa-caret-up"></i>  #trend#</div>
																<cfelseif trend LT 0>
																	<div class="trend-down"><i class="fa-solid fa-caret-down"></i>  #trend#</div>
																</cfif>
															</td>
						  								<td align="right">#DateFormat(variables.signupDate, "m/d")# #TimeFormat(variables.signupDate, "h:mm tt")#</td>
					      						</tr>	
					  						</cfoutput>
					  						<cfoutput query="getGuests">
					  							<cfif getGuests.guest_type eq "registered">
					  								<cfset id = "r-" & getGuests.player_id>
					  							<cfelse>
					  								<cfset id = "u-" & getGuests.guest_id>
					  							</cfif>
					  							<cfset variables.signupDate = DateAdd('h',-4, getGuests.signup_date)>
														<tr>
						  								<td><span class="d-none d-md-inline guest">#getGuests.first_name# #getGuests.last_name# (guest) <cfif getGuests.is_handcuffed eq 1><i class="fa-solid fa-link"></i></cfif></span> <cfif variables.golferId eq getGolfers.player_id or IsAdmin eq 1><i class="fa-regular fa-circle-xmark fa-xl fa-fw" onclick="confirmRemoval('#id#',1);"></i></cfif></td>
						  								<td align="center">
						  									<cfif LEN(TRIM(getGuests.handicap_to_use)) GT 0>
							  									#getGuests.handicap_to_use# 
							  								</cfif>
						  								</td>
						  								<td>
															&nbsp;
														</td>
						  								<td align="right">#DateFormat(variables.signupDate, "m/d")# #TimeFormat(variables.signupDate, "h:mm tt")#</td>
					      						</tr>	
					  						</cfoutput>
						  				</table>
						  				
						  			</div>
								<cfelse>
									<p>A match with no golfers exists for this day.</p>
									<div style="margin-top:30px;"><button type="submit" name="btnAdd" class="btn btn-success"><i class="fa-solid fa-circle-plus"></i> Join match</button></div>
								</cfif> 

						</cfif>  
					<cfelse>
						<p>No teams were created for this day.</p>
					</cfif>	
				</div>            <!-- /modal-body -->

				<div class="modal-footer">
						<cfif IsAdmin>
							<button type="submit" name="btnPreventMatch" class="btn btn-danger" onclick="return confirm('Are you sure you want to block off this day on the calendar?');">Prevent Match Today</button>
						</cfif>
						<cfif IsDefined("getGolfers") and getGolfers.RecordCount GT 0 and variables.IsAdmin>
							<div class="dropdown">
							  <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton1" data-bs-toggle="dropdown" aria-expanded="false">
							    Match Tools
							  </button>
							  <ul class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
							    <li><a class="dropdown-item" href="/generateTeams.cfm?mid=<cfoutput>#url.mid#</cfoutput>"><i class="fa-solid fa-users fa-fw"></i> Generate teams</a></li>
							    <!--- <li><a class="dropdown-item" href="#"><i class="fa-solid fa-envelope fa-fw"></i> Send confirmation email</a></li>
							    <li><a class="dropdown-item" href="#"><i class="fa-solid fa-envelope fa-fw"></i> Send 'last call' email</a></li> --->
							  </ul>
							</div>
								<!--- <button type="submit" name="btnMakeTeams" id="btnMakeTeams" class="btn btn-primary">Admin Tools</button> --->
						</cfif>
						<button type="button" class="btn btn-light" data-bs-dismiss="modal">Close</button>
				</div>
				<cfif getMatch.recordcount GT 0>
						<input type="hidden" name="MatchId" value="<cfoutput>#getMatch.match_id#</cfoutput>">
				</cfif>
				<input type="hidden" id="hidGolferId" name="GolferId" value="<cfoutput>#variables.player_id#</cfoutput>">
				<input type="hidden" name="GroupId" value="<cfoutput>#url.gid#</cfoutput>">
				<input type="hidden" name="Date" value="<cfoutput>#CreateODBCDate(url.date)#</cfoutput>">

	<cfelse>

			<!--- ----------------------- --->
			<!--- Teams already generated --->
			<!--- ----------------------- --->
			<div class="modal-header">
					 <h2 class="modal-title"><cfoutput>#DateFormat(url.date,"ddd, mmm d ")#</cfoutput></h2>
					 <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
			</div>            <!-- /modal-header -->
			<div class="modal-body">
					<cfinclude template="/viewTeamsInclude.cfm">
					<cfif NOT isJoined>
						<div><button type="submit" name="btnAlternate" class="btn btn-secondary"><i class="fa-solid fa-circle-plus"></i> Join as alternate</button></div>
						<input type="hidden" name="alternate" value="ALT<cfoutput>#nextAlternate#</cfoutput>">
					</cfif>
			</div>
			<div class="modal-footer">
				<cfif variables.IsAdmin and DateAdd("h", 16, getMatch.match_date) GTE now()>
					<button type="submit" name="btnRemoveTeams" id="btnRemoveTeams" class="btn btn-danger"  onclick="return confirm('Are you sure you want to delete the existing teams?');">Remove Teams</button>
		    	<a href="/modifyTeams.cfm?mid=<cfoutput>#url.mid#</cfoutput>" type="button" id="btnModifyTeams" class="btn btn-primary">Modify Teams</a>
		    	<cfelse>
		    		<cfset getResults = CreateObject('component', 'cfc.match').getResults(matchId=url.mid)>
		    		<cfif getResults.RecordCount GT 0>
		    			<a href="/results/view.cfm?mid=<cfoutput>#url.mid#</cfoutput>" type="button" id="btnViewResults" class="btn btn-primary">View Results</a>
		    		<cfelseif IsAdmin>
		    			<a href="/results/enter.cfm?mid=<cfoutput>#url.mid#</cfoutput>" type="button" id="btnEnterResults" class="btn btn-success">Enter Results</a>
		    		</cfif>
		    	</cfif>
		    	<button type="button" class="btn btn-light" data-bs-dismiss="modal">Close</button>
	  		</div>

	    <input type="hidden" name="GroupId" value="<cfoutput>#url.gid#</cfoutput>">
	    <cfif getMatch.recordcount GT 0>
				<input type="hidden" name="MatchId" value="<cfoutput>#getMatch.match_id#</cfoutput>">
		</cfif>
	</cfif>
<cfelse>
	<!--- Day is blocked --->
	  <div class="modal-header">
        <h5 class="modal-title">Day Blocked</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <p>Your administrator has prevented a match from being created for this day.</p>
      </div>
      <div class="modal-footer">
      	<cfif IsAdmin>
      	<button type="submit" name="btnAllowMatch" class="btn btn-success" onclick="return confirm('Are you sure you want to allow sign ups for this day?');">Allow Match Today</button>
        </cfif>
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
      </div>
      <input type="hidden" name="GroupId" value="<cfoutput>#url.gid#</cfoutput>">
		<input type="hidden" name="Date" value="<cfoutput>#CreateODBCDate(url.date)#</cfoutput>">
</cfif>
</form>
</body>

<script>
	function confirmRemoval(guestId,isGuest)
	{
		if (confirm('Are you sure you want to remove this player from the match?') == true){
			$("#hidGolferId").val(guestId);
			$('#frmMatch').append('<input type="hidden" name="btnRemove"/>');
			$('#frmMatch').append('<input type="hidden" name="isGuest" value="' + isGuest + '"/>');
			$("#frmMatch").submit();
		} 
	}

	$( "#btnToggleGolfers" ).click(function() {
		$( "#tblGolfers" ).toggle();
		$(this).html($(this).html() == '<i class="fa-solid fa-circle-chevron-down"></i> Show golfers' ? '<i class="fa-solid fa-circle-chevron-up"></i> Hide golfers' : '<i class="fa-solid fa-circle-chevron-down"></i> Show golfer list');
	});

	$( "#ddAddGuest" ).click(function() {
		$( "#guest-block" ).toggle();
		$( "#member-block" ).hide();
	});

	$( "#ddAddMember" ).click(function() {
		$( "#member-block" ).toggle();
		$( "#guest-block" ).hide();
	});

	$( "#member" ).change(function() {
		if($(this).val() > 0){
			$( "#btnAddMember" ).removeClass("disabled");
			}
		else {
			$( "#btnAddMember" ).removeClass("disabled").addClass("disabled");
		}
	});

	$( "#guest" ).change(function() {
		if($(this).val().length > 0){
			$( "#btnAddGuest" ).removeClass("disabled");
			}
		else {
			$( "#btnAddGuest" ).removeClass("disabled").addClass("disabled");
		}
	});


	$( ".fa-circle-xmark" ).hover(
	  function() {
	    $( this ).addClass( "fa-solid" );
	    $( this ).removeClass( "fa-regular" );
	  }, function() {
	  	$( this ).addClass( "fa-regular" );
	    $( this ).removeClass( "fa-solid" );
	  }
	);


</script>
</html>
