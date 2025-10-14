<cfset redirectUnauth = false>
 <cfinclude template="/header.cfm">

 <link rel="stylesheet" type="text/css" href="/assets/plugins/datatables/css/jquery.dataTables.min.css"/>

<style>
	.signup-box {max-width:800px; margin:0 auto;}
	.signup-box h1 {text-align: center;margin-bottom: 20px;}
	.form-floating>.form-control:focus, .form-floating>.form-control:not(:placeholder-shown) {font-size: 17px;}
	#formGHINLookup .btn-primary {height: 58px;}
	#tblGolfers tbody tr:hover {background-color: #FFFFA7; cursor: pointer;}
</style>

<div class="signup-box">
		<h1>Create Your Account</h1>
		<cfif isDefined("cookie.inviteCode") and listLen(cookie.inviteCode,"-") eq 2>
			<cfset variables.gid = ListGetAt(cookie.inviteCode,1,"-")>
			<cfquery datasource="#variables.DSN#" name="getGroup">
				select *
				from 4some.groups
				where group_id = #variables.gid#
			</cfquery>
			<div class="alert alert-info">In order to join the group <strong>'<cfoutput>#getGroup.group_name#</cfoutput>'</strong>, you must first create an account.</div>
		</cfif>
		<form action="lookup.cfm" method="post" id="formGHINLookup">	
			<div class="row mt-3">
				<div class="col-3 col-xs-12">
					<div class="form-floating mb-3">
						<input type="text" class="form-control" id="firstName" name="firstName"  placeholder="First name">
						<label for="floatingInput">First name/initial</label>
					</div>
				</div>
				<div class="col-3 col-xs-12">
					<div class="col form-floating mb-3">
						<input type="text" class="form-control" id="lastName" name="lastName" placeholder="Last name" required>
						<label for="floatingInput">Last name</label>
					</div>
				</div>
				<div class="col-3 col-xs-12">
					<div class="col form-floating mb-3">
						<select class="form-select" id="state" name="state" placeholder="State" required>
							<option></option>
							<option value="AL">Alabama</option>
							<option value="AK">Alaska</option>
							<option value="AZ">Arizona</option>
							<option value="AR">Arkansas</option>
							<option value="CA">California</option>
							<option value="CO">Colorado</option>
							<option value="CT">Connecticut</option>
							<option value="DE">Delaware</option>
							<option value="DC">District Of Columbia</option>
							<option value="FL">Florida</option>
							<option value="GA">Georgia</option>
							<option value="HI">Hawaii</option>
							<option value="ID">Idaho</option>
							<option value="IL">Illinois</option>
							<option value="IN">Indiana</option>
							<option value="IA">Iowa</option>
							<option value="KS">Kansas</option>
							<option value="KY">Kentucky</option>
							<option value="LA">Louisiana</option>
							<option value="ME">Maine</option>
							<option value="MD">Maryland</option>
							<option value="MA">Massachusetts</option>
							<option value="MI">Michigan</option>
							<option value="MN">Minnesota</option>
							<option value="MS">Mississippi</option>
							<option value="MO">Missouri</option>
							<option value="MT">Montana</option>
							<option value="NE">Nebraska</option>
							<option value="NV">Nevada</option>
							<option value="NH">New Hampshire</option>
							<option value="NJ">New Jersey</option>
							<option value="NM">New Mexico</option>
							<option value="NY">New York</option>
							<option value="NC">North Carolina</option>
							<option value="ND">North Dakota</option>
							<option value="OH">Ohio</option>
							<option value="OK">Oklahoma</option>
							<option value="OR">Oregon</option>
							<option value="PA">Pennsylvania</option>
							<option value="RI">Rhode Island</option>
							<option value="SC">South Carolina</option>
							<option value="SD">South Dakota</option>
							<option value="TN">Tennessee</option>
							<option value="TX">Texas</option>
							<option value="UT">Utah</option>
							<option value="VT">Vermont</option>
							<option value="VA">Virginia</option>
							<option value="WA">Washington</option>
							<option value="WV">West Virginia</option>
							<option value="WI">Wisconsin</option>
							<option value="WY">Wyoming</option>
						</select>
						<label for="floatingInput">State</label>
					</div>
				</div>
				<div class="col-3 col-xs-12">
					<input type="submit" class="btn btn-primary" value="Submit">
				</div>
			</div>
		</form>
	</div>
	
<!--- ------------------- --->
<!--- Lookup via GHIN API --->
<!--- ------------------- --->
<cfif IsDefined("form.lastName") and IsDefined("form.state")>
	<hr/>
	<!--- Lookup golfer's GHIN --->
	
	<cfset variables.lastName = trim(form.lastName)>
	<cfset variables.firstName = trim(form.firstName)>
	<cfset variables.state = trim(form.state)>

	<cfinclude template="/includes/ghinLookup/byName.cfm">

	<!--- <cfhttp url="https://app.golfnet.com/api/golfers/getUSGAGolferSearch?firstName=&lastName=#trim(form.lastName)#&state=#trim(form.state)#&activeOnly=true" /> --->
	
	<cfset arrMatchedGolfers = arrayNew()>
	<cfloop array="#results.golfers#" item="golfer" index="i">
		<cfif golfer.first_name eq form.firstName>
			<cfset temp = arrayAppend(arrMatchedGolfers, golfer)>
		</cfif>
	</cfloop>
	
	<cfif ArrayLen(arrMatchedGolfers) EQ 1>
		<p>Is this golfer you? If so, click the row to continue.</p>
		<cfset tableDatasource = arrMatchedGolfers>
	<cfelseif ArrayLen(arrMatchedGolfers) GT 1>
		<p>Are you any of these golfers? If so, click the row to continue.</p>
		<cfset tableDatasource = arrMatchedGolfers>
	<cfelse>
		<cfset tableDatasource = results.golfers>
		<!--- Show full list --->
		<!--- <p>The only golfers with a GHIN Handicap in <strong><cfoutput>#UCASE(form.state)#</cfoutput></strong> with that last name '<strong><cfoutput>#UCASE(form.lastName)#</cfoutput></strong>' are shown below.  </p> --->
		<p>If you find yourself, click the row to continue.</p>
	</cfif>
	<p>If not, we can get you <a href="create.cfm">set up from scratch</a>.</p>
	<cfif resultsCount eq maxResults>
		<div class="alert alert-warning"><i class="fa-solid fa-triangle-exclamation"></i> Note: There are more matches than shown below. If necessary, please enter more specific search criteria.</div>
	</cfif>
	<table class="table table-striped" id="tblGolfers">
			<thead>
				<tr>
					<th>Name</th>
					<th>Club</th>
					<td align="center"><strong>Handicap</strong></th>
					<td class="d-none d-md-block" align="center"><strong>GHIN Number</strong></th>
				</tr>
			</thead>
			<tbody>
				<cfloop array="#tableDatasource#" index="matchedGolfer">
					<cfoutput>
						<tr data-ghin="#matchedGolfer.ghin#" data-clubid="#matchedGolfer.club_id#">
							<td>#matchedGolfer.first_name# #matchedGolfer.last_name#</td>
							<td>#matchedGolfer.club_name#</td>
							<td align="center">#matchedGolfer.handicap_index#</td>
							<td class="d-none d-md-block" align="center">#matchedGolfer.ghin#</td>
						</tr>
					</cfoutput>
				</cfloop>

			</tbody>
		</table>
</cfif>

<cfinclude template="/footer.cfm">
<script type="text/javascript" src="/assets/plugins/datatables/js/jquery.dataTables.min.js"></script>
<script>
	//wire up data table
	var dtGolfers = $('#tblGolfers').dataTable({
		"autoWidth": false,
		"paging": false,
		"order": [[ 0, "asc" ]]
	});

	$( "#tblGolfers tbody tr" ).click(function() {
		window.location.href="/account/create.cfm?ghin=" + $(this).data('ghin') + "&clubId=" +$(this).data('clubid') ;
	});
</script>