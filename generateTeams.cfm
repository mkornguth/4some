<cfinclude template="header.cfm">
<cfif isDefined("url.mid")>
	<cfquery datasource="#variables.DSN#" name="getMatch">
		select m.match_date, mp.player_id, mp.signup_date, p.first_name, p.last_name, p.handicap_current, mt.team_id
		from matches m
			inner join match_players mp on mp.match_id = m.match_id
			inner join players p on p.player_id = mp.player_id
			left outer join match_teams mt on mt.player_id = mp.player_id and mt.match_id = m.match_id
		where m.match_id = #url.mid#
		order by mp.signup_date
	</cfquery>

	<!--- Get guests in Match --->
		<cfset getGuests = CreateObject('component', 'cfc.match').getGuests(matchId=url.mid)>



<!--- 		<cfdump var="#getMatch#">
		<cfdump var="#getGuests#">
		<cfabort>
 --->


	<cfif getMatch.team_id GT 0>
		<section class="bg-white">
	    <div class="container"> 
				Teams have already been generated.
			</div>
		</section>
		<cfabort>
	</cfif>

	<h1>Team Generation</h1>

	<!--- Generation algorithm selected --->
	<cfif isDefined("url.typeid")>
		

		


		<!--- Data prep --->
		<cfinclude template="/includes/generateTeams/#url.teamStructure#/dataPrep.cfm">

		<!--- Team insertion --->
		<!--- <cfoutput>#url.teamStructure#</cfoutput><cfabort> --->
		<cfparam name="url.teamStructure" default="alternates">
		<cfinclude template="/includes/generateTeams/#url.teamStructure#/#url.typeId#.cfm">

								
		<cfif arrayLen(arrAlternates) GT 0>
			  <cfset i = 0>
				<cfloop array="#arrAlternates#" index="id">
					<cfset i++>
				<cfquery datasource="#variables.DSN#" name="insertAlternate">
						INSERT INTO match_teams (match_id, team_id, player_id, player_label)
							VALUES (#url.mid#, 99, #id#, 'ALT#i#')
				</cfquery>
			</cfloop>
		</cfif>

		<!--- HANDCUFF REPLACEMENTS --->
		<cfquery datasource="#variables.DSN#" name="getHandcuffs">
		    select mt.guest_id, mt.team_id as guestTeam, mt.player_label as guestLabel, mt2.team_id as memberTeam, mt2.player_label as memberLabel
		    from match_teams mt
		        inner join guests_unregistered gu on gu.guest_id = mt.guest_id
		        inner join players p on p.player_id = gu.player_id_handcuff
		        left outer join match_teams mt2 on mt2.player_id = gu.player_id_handcuff and mt2.match_id = #url.mid#
		    where mt.match_id = #url.mid# and mt.guest_id is not null
		</cfquery>


		<cfif getHandcuffs.recordcount GT 0>
			<cfoutput query="getHandcuffs">
			    <cfif getHandcuffs.guestTeam neq getHandcuffs.memberTeam>
			        <cfif getHandcuffs.guestLabel neq getHandcuffs.memberLabel>
			            <cfquery datasource="#variables.DSN#" name="switchA">
			                update match_teams
			                set team_id = #getHandcuffs.guestTeam#
			                where match_id = #url.mid# and team_id = #getHandcuffs.memberTeam# and player_label = '#getHandcuffs.guestLabel#'
			            </cfquery>

			            <cfquery datasource="#variables.DSN#" name="switchB">
			                update match_teams
			                set team_id = #getHandcuffs.memberTeam#
			                where match_id = #url.mid# and guest_id = #getHandcuffs.guest_id#
			            </cfquery>
			        </cfif>
			    </cfif>
			</cfoutput>
		<!--- /HANDCUFF REPLACEMENTS --->
		<cfelse>

			<!--- TEAMMATE FREQUENCY REPLACEMENTS (only performed if no handcuffed players exist)
			-commented 3/31/25, now that manual team modifications are available
			<cfinclude template="/includes/generateTeams/playerSwapAuto.cfm">
			--->
		</cfif>

		<cflocation url="viewTeams.cfm?mid=#url.mid#">
	<cfelse>
		<cfset baseTeamCount = floor((getMatch.recordCount + getGuests.recordcount) / 4)>
		<cfset alternateCount = (getMatch.recordCount + getGuests.recordcount) MOD 4>
		<!--- if 4 or less players, put them on the same team. No selections necessary--->
		<cfif baseTeamCount eq 0>
			<cflocation url="/generateTeams.cfm?mid=#url.mid#&typeId=1&teamStructure=placeholders">
		</cfif>

		<!--- Player count NOT divisible by 4 AND haven't already picked a alternate/placeholder layout--->
		<cfif NOT IsDefined("url.teamLayout")>
			<div class="alert alert-info">With <strong><cfoutput>#getMatch.recordCount + getGuests.recordcount#</cfoutput> players</strong> signed up, how would you like to set up the teams?</div>
			<div class="row">
				<form action="" method="get">
						<div class="form">
							<cfif alternateCount neq 0> 
								<div class="form-check">
								  <input class="form-check-input" type="radio" name="teamLayout" value="alternates" id="alternates" checked>
								  <label class="form-check-label" for="alternates">
								    <cfoutput>#baseTeamCount# teams (with #alternateCount# alternates)</cfoutput>
								  </label>
								</div>
								<div class="form-check">
								  <input class="form-check-input" type="radio" name="teamLayout" value="placeholders" id="placeholders">
								  <label class="form-check-label" for="placeholders">
								    <cfoutput>#baseTeamCount + 1# teams (with #4 -alternateCount# placeholders)</cfoutput>
								  </label>
								</div>
							<cfelse>
								<div class="form-check">
								  <input class="form-check-input" type="radio" name="teamLayout" value="placeholders" id="auto" checked>
								  <label class="form-check-label" for="placeholders">
								    <cfoutput>Automatically create teams</cfoutput>
								  </label>
								</div>
							</cfif>
							<div class="form-check">
							  <input class="form-check-input" type="radio" name="teamLayout" value="manual" id="manual">
							  <label class="form-check-label" for="manual">
							    <cfoutput>Manually create teams</cfoutput>
							  </label>
							</div>
							<div class="row mt-3"><div class="col-12"><input type="submit" class="btn btn-primary" value="Continue" id="btnTeamLayout"></div></div>

						</div>
					<input type="hidden" name="mid" value="<cfoutput>#url.mid#</cfoutput>">
				</form>
			</div>
		<!--- Team layout selected --->
		<cfelseif url.teamLayout neq "manual">
			<style>
				.typeDescription {display:none;}
			</style>
			<div class="row">
				<p>Choose the type of team generation you want to use: <br/>(select an option for a detailed description)</p>
			</div>
			<form action="" method="get">
				<div class="row mb-5">
					
						<div class="col-auto">
							<select class="form-select" id="typeId" name="typeId" placeholder="Member">
								<option value=""></option>
								<option value="1" selected>ABCD - traditional</option>
								<option value="2">ABCD - randomized</option>
			 					<option value="3">AAAA - tiers</option>
								<option value="4">Random</option>
							</select>
							<span class="instructions"><a id="a_description" href="#" onclick="toggleFormatDescription();">Show format description</a></span>
						</div>
						<div class="col-auto">
							<input type="submit" class="btn btn-primary" value="Generate Teams" id="btnGenerateTeams">
						</div>

				</div>
				<input type="hidden" name="mid" value="<cfoutput>#url.mid#</cfoutput>">
				<input type="hidden" name="teamStructure" value="<cfoutput>#url.teamLayout#</cfoutput>">
			</form>
			<div class="row" id="rowTypeDescription" style="display:none;">
				<div class="col-12">
					<div id="desc1" class="typeDescription">
						<h4><strong>'ABCD - traditional' explained</strong></h4>
						<p>In an ABCD format,  players are sorted into A-, B-, C- and D-level players (A's being the lowest handicappers, D's being the highest). Therefore, ABCD refers to each team consisting of one player from each handicap level.</p>
						<p>In the traditional ABCD, the best A player is teamed with the lowest B player, the highest C player, and the lowest D player. The following example has 4 foursomes. Out of the 16 golfers, A1 indicates the player with the best overall handicap and D4 indicates the player with the worst overall handicap.</p>
						<div class="row">
		
							<div class="col-12 col-sm-6 col-lg-3">
						  		<div class="card">
						  			<div class="card-body">	<div>A1 - Jeff Brodeur - +0.3</div><div>B4 - James Miller - 9.6</div><div>C1 - Rahul Singh - 10.7</div><div>D4 - Brent Celone - 16.9</div>
									</div>
								</div>
							</div>
						
							<div class="col-12 col-sm-6 col-lg-3">
						  		<div class="card">
						  			<div class="card-body"><div>A2 - Mike O'Connor -  3.7</div><div>B3 - Alphonse Romano -  9.5</div><div>C2 - Jim Matthews - 10.8</div><div>D3 - Scott Lyons - 15.4</div>
										
									</div>
								</div>
							</div>
						
							<div class="col-12 col-sm-6 col-lg-3">
						  		<div class="card">
						  			<div class="card-body"><div>A3 - Jamal Johnson - 4.7</div><div class="highlight">B2 - Matt Considine - 9.0</div><div>C3 - David Small - 11.2</div><div>D2 - Donald Gladwin - 12.0</div>
									</div>
								</div>
							</div>
						
							<div class="col-12 col-sm-6 col-lg-3">
						  		<div class="card">
						  			<div class="card-body"><div>A4 - Dave Kucinich -  4.9</div><div>B1 - Darnell Stephens -  6.3</div><div>C4 - Greg Riccio - 11.4</div><div>D1 - Jeffrey Meiselman - 11.5</div>
										
									</div>
								</div>
							</div>
							
						</div>
					</div>
					<div id="desc2" class="typeDescription">
						<h4><strong>'ABCD - randomized' explained</strong></h4>
						<p>In an ABCD format,  players are sorted into A-, B-, C- and D-level players (A's being the lowest handicappers, D's being the highest). Therefore, ABCD refers to each team consisting of one player from each handicap level.</p>
						<p>In a randomized ABCD, all A players are teamed with random B, C, and D players, regardess of handicap. The following example has 4 foursomes.</p>
						<div class="row">
		
							<div class="col-12 col-sm-6 col-lg-3">
						  		<div class="card">
						  			<div class="card-body">	<div>A1 - Jeff Brodeur - +0.3</div><div>B? </div><div>C?</div><div>D?</div>
									</div>
								</div>
							</div>
						
							<div class="col-12 col-sm-6 col-lg-3">
						  		<div class="card">
						  			<div class="card-body"><div>A2 - Mike O'Connor -  3.7</div><div>B?</div><div>C?</div><div>D?</div>
										
									</div>
								</div>
							</div>
						
							<div class="col-12 col-sm-6 col-lg-3">
						  		<div class="card">
						  			<div class="card-body"><div>A3 - Jamal Johnson - 4.7</div><div class="highlight">B?</div><div>C?</div><div>D?</div>
									</div>
								</div>
							</div>
						
							<div class="col-12 col-sm-6 col-lg-3">
						  		<div class="card">
						  			<div class="card-body"><div>A4 - Dave Kucinich -  4.9</div><div>B?</div><div>C?</div><div>D?</div>
										
									</div>
								</div>
							</div>
							
						</div>
					</div>
				</div>
			</div>
		<!--- Manual team creation --->
		<cfelse>
			<cflocation url="modifyTeams.cfm?mid=#url.mid#">
		</cfif> <!--- Team layout selected --->
	</cfif> <!--- url.typeid --->
<cfelse>
</cfif> <!--- url.mid --->

<cfinclude template="/footer.cfm">

<script>
	$( "#typeId" ).change(function() {
		$( "#rowTypeDescription" ).hide();
		$('#a_description').text("Show format description"); 
	});

	function toggleFormatDescription(a){
		var linkText = $('#a_description').text();
		var selectedIdx = $('#typeId option:selected').val();
		if (linkText.substring(0,4) == "Show"){
			if (selectedIdx > 0){
				$( "#rowTypeDescription" ).show();
				$( ".typeDescription").hide();
				$( "#desc" + selectedIdx).show();
			}
			else {
				$( "#rowTypeDescription" ).hide();
			}
			$('#a_description').text("Hide format description"); 
		}
		else {
			$( ".typeDescription").hide();
			$( "#rowTypeDescription" ).hide();
			$('#a_description').text("Show format description"); 
		}
	}
</script>



<!-------------------------------->

<!--- Functions --->
<cffunction name="ArrayOfStructSort" returntype="array" access="public" output="no">
  <cfargument name="base" type="array" required="yes" />
  <cfargument name="sortType" type="string" required="no" default="text" />
  <cfargument name="sortOrder" type="string" required="no" default="ASC" />
  <cfargument name="pathToSubElement" type="string" required="no" default="" />

  <cfset var tmpStruct = StructNew()>
  <cfset var returnVal = ArrayNew(1)>
  <cfset var i = 0>
  <cfset var keys = "">

  <cfloop from="1" to="#ArrayLen(base)#" index="i">
    <cfset tmpStruct[i] = base[i]>
  </cfloop>

  <cfset keys = StructSort(tmpStruct, sortType, sortOrder, pathToSubElement)>

  <cfloop from="1" to="#ArrayLen(keys)#" index="i">
    <cfset returnVal[i] = tmpStruct[keys[i]]>
  </cfloop>

  <cfreturn returnVal>
</cffunction>



