<cfset redirectUnauth = false>
<cfset emailVerified = false>
<cfset wasLookedUp = false>
<cfinclude template="/header.cfm">
<link rel="stylesheet" href="/assets/css/passwordValidation.css">

<style>
	.signup-box {margin:0 auto; max-width: 400px;}
	.signup-box h1 {text-align: center;margin-bottom: 20px;}
	.form-floating>.form-control:focus, .form-floating>.form-control:not(:placeholder-shown) {font-size: 17px;}
	.instructions {font-size:.7em; font-style: italic;}
	#passwordMismatch {font-size:.8em; color:#cc0000; display: none;}
	#emailErrMsg {font-size:.8em; color:#cc0000; display:none;}
	.error {border-color: #cc0000;}
</style>

<cfif isDefined("url.email") and isDefined("url.token") and hmac(url.email,"skins") eq url.token>
	<cfset emailVerified = true>
	<cfif isDefined("url.code") and NOT isDefined("cookie.inviteCode")>
		<cfset cookie.inviteCode = trim(url.code)>
	</cfif>
</cfif>


<cfif isDefined("url.ghin") and isNumeric(url.ghin)>
	<cfquery datasource="#variables.DSN#" name="lookupPlayer">
		select *
		from players
		where ghin_id = #trim(url.ghin)#
	</cfquery>

	<cfif lookupPlayer.RecordCount GT 0>
		<h1>Account Already Exists</h1>
		<p>
			Good news! You are already a registered user. 
			<cfif isDefined("cookie.inviteCode") and listLen(cookie.inviteCode,"-") eq 2>
				<cfset variables.gid = ListGetAt(cookie.inviteCode,1,"-")>
				Please <a href="/login.cfm?gid=<cfoutput>#variables.gid#</cfoutput>&action=groupJoin">login</a> using your email address to join this group.
				<div class="mt-3"><a href="/login.cfm?gid=<cfoutput>#variables.gid#</cfoutput>&action=groupJoin" class="btn btn-primary">Login to Join this Group</a>
			<cfelse>
				Please <a href="/login.cfm">login</a> using your email address.
			</cfif>
		</p>
		<cfinclude template="/footer.cfm">
		<cfabort>
	</cfif>

	<!--- USGA lookup --->
	<cfset variables.ghin = trim(url.ghin)>
	<cfinclude template="/includes/ghinLookup/byGhin.cfm">
	<cfset theJSON = results.golfers[1]>
	<cfset wasLookedUp = true>

</cfif>

<cfif isDefined("form.email")>
	<!--- <cfdump var="#form#"><cfabort> --->
	<cfif isDefined("form.token")>
		<!--- ---------------- --->
		<!--- Database Inserts --->
		<!--- ---------------- --->
		<cftransaction action="begin">
			<!--- insert player --->
			<cfif isDefined("form.ghinId")>
				<cfquery datasource="#variables.DSN#" name="insertPlayer">
					insert into players (first_name, last_name, email, password, ghin_id, handicap_current, handicap_low)
						values ('#trim(form.firstName)#', '#trim(form.lastName)#', '#trim(form.email)#', '#hmac(trim(form.password),'skins')#', #form.ghinId#, #form.handicapCurrent#, #form.handicapLow#);
				</cfquery>
			<cfelse>
				<cfquery datasource="#variables.DSN#" name="insertPlayer">
					insert into players (first_name, last_name, email, password, handicap_current)
						values ('#trim(form.firstName)#', '#trim(form.lastName)#', '#trim(form.email)#', '#hmac(trim(form.password),'skins')#',  #form.handicap#);
				</cfquery>
			</cfif>

			<cfquery datasource="#variables.DSN#" name="getPlayerIdentity">
				SELECT MAX(player_id) as player_id FROM players
			</cfquery>

		    <cfset variables.player_id = getPlayerIdentity.player_id>

		    <!--- lookup/insert club --->
		    <cfif IsDefined("form.homeClubId")>
		    	<cfquery datasource="#variables.DSN#" name="lookupClub">
		    		select *
		    		from clubs
		    		where usga_club_id = #form.homeClubId#;
			    </cfquery>
			    <cfif lookupClub.RecordCount eq 0>
			    	<cfquery datasource="#variables.DSN#" name="insertClub">
			    		insert into clubs (club_name, usga_club_id)
			    			values ('#trim(form.homeClubName)#', #form.homeClubId#);
			    	</cfquery>

			    	<cfquery datasource="#variables.DSN#" name="getClubIdentity">
							SELECT MAX(club_id) as club_id FROM clubs
						</cfquery>

			    	<cfset variables.club_id = getClubIdentity.club_id>
			    <cfelse>
			    	<cfset variables.club_id = lookupClub.club_id>
			    </cfif>

			    <cfquery datasource="#variables.DSN#" name="insertClubPlayer">
		    		insert club_players (club_id, player_id)
		    			values (#variables.club_id#, #variables.player_id#)
		    	</cfquery>
		    </cfif>

		    <cfset groupStatus = "">
		    <cfif isDefined("cookie.inviteCode") and listLen(cookie.inviteCode,"-") eq 2>
		    	<cfset variables.group_id = ListGetAt(cookie.inviteCode,1,"-")>
	    		<cfif listLen(trim(cookie.inviteCode),"-") eq 2>
					<cfquery datasource="#variables.DSN#" name="getGroup">
						select *
						from 4some.groups
						where group_id = #variables.group_id#
					</cfquery>
					<cfif Compare(ListGetAt(cookie.inviteCode,2,"-"),getGroup.invite_code) eq 0>
						<cfquery datasource="#variables.DSN#" name="insertGroupPlayer">
				    		insert group_players (group_id, player_id)
				    			values (#variables.group_id#, #variables.player_id#)
				    	</cfquery>
				    	<cfset groupStatus="success">
				    	<cfset strGroups = structNew()>
						<cfset strGroups[variables.group_id] = structNew()>
						<cfset strGroups[variables.group_id].IsAdmin = 0>
						<cfcookie name="GolferGroups" value="#SerializeJSON(strGroups)#">

					<cfelse>
						<cfset groupStatus="fail">
					</cfif>
				</cfif>
	    	</cfif>

		    <cftransaction action="commit">
		</cftransaction>

	    <cfcookie name="GolferData" value="#variables.player_id#,#trim(form.email)#, #trim(form.firstName)#, #trim(form.lastName)#">

	    <cfset redirectUrl = "groups.cfm?status=accountSuccess">
	    <cfif isDefined("variables.group_id")>
	    	<cfset redirectUrl &= "&gid=" & variables.group_id & "&groupStatus=" & groupStatus>
	    </cfif>

	    <cflocation url="#redirectUrl#">
	<cfelse>
		<!--- ---------------------- --->
		<!--- Send email verification--->
		<!--- ---------------------- --->
		<cfset verificationToken = hmac(form.email,"skins")>
		<cfmail subject="Email Verification Request" from="Teams.golf <no-reply@teams.golf>" to="#trim(form.email)#" bcc="admin@teams.golf" type="html">
		 	<p>We have received a request to authorize this email address for use with the Teams.golf website. If you requested this verification, please go to the following URL to confirm that you are authorized to use this email address:</p>
		 	<p>https://www.teams.golf/account/create.cfm?<cfif IsDefined("form.ghinID")>ghin=#form.ghinId#&</cfif><cfif IsDefined("form.homeClubId")>clubId=#form.homeClubId#&</cfif>email=#form.email#&token=#verificationToken#<cfif isDefined("cookie.inviteCode")>&code=#trim(cookie.inviteCode)#</cfif></p>
		</cfmail>
		
		<h1>Verification Email Sent</h1>
		<h4>Please check your email for a verification email and click the link.</h4>
		<p>An email has been sent to <strong><cfoutput>#form.email#</cfoutput></strong>. For security purposes and in order to continue your account creation, you will need to click the link in the email sent to you to verify that email address belongs to you.</p>
		<p>You may close this browser window now. The link in your email will launch a new one.</p>
	</cfif>
<cfelse>
	<!--- Account form --->
	<div class="signup-box">
		<h1>Create Your Account</h1>
		<form id="frmCreate" action="/account/create.cfm" method="post">
			<cfif wasLookedUp or emailVerified>
				<div class="<cfif wasLookedUp>input-group</cfif> form-floating mb-3">
					<input type="text" class="form-control" id="firstName" name="firstName" placeholder="First name" required <cfif IsDefined("theJSON.first_name")>value="<cfoutput>#theJSON.first_name#</cfoutput>" disabled</cfif>>
					<label for="floatingInput">First name</label>
					<cfif wasLookedUp><span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-check"></i></span></cfif>
				</div>
				<div class="<cfif wasLookedUp>input-group</cfif> form-floating mb-3">
					<input type="text" class="form-control" id="lastName" name="lastName" placeholder="Last name" required <cfif IsDefined("theJSON.last_name")>value="<cfoutput>#theJSON.last_name#</cfoutput>" disabled</cfif>>
					<label for="floatingInput">Last name</label>
					<cfif wasLookedUp><span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-check"></i></span></cfif>
				</div>
			</cfif>
			<cfif wasLookedUp>
				<div class="input-group form-floating mb-3">
					<input type="text" class="form-control" id="clubId" name="clubId" placeholder="Home club" required <cfif IsDefined("theJSON.club_name")>value="<cfoutput>#theJSON.club_name#</cfoutput>" disabled</cfif>>
					<label for="floatingInput">Home club</label>
					<span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-check"></i></span>
				</div>
			</cfif>
			<p id="instructions" class="instructions">Please provide your email for verification:</p>
			<div class="<cfif emailVerified>input-group</cfif> form-floating mb-3">
				<input type="email" class="form-control" id="email" name="email" placeholder="Email" required <cfif emailVerified>value="<cfoutput>#url.email#</cfoutput>" disabled </cfif>>
				<label for="floatingInput">Email</label>
				<cfif emailVerified>
					<span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-check"></i></span>
				</cfif>
				<div id="emailErrMsg">Invalid e-mail address</div>
			</div>

			<cfif emailVerified>
				<div id="passwordFields">
					<div class="form-floating mb-3">
						<input type="password" class="form-control" id="password" name="password" placeholder="Password" pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}" title="Must contain at least one number and one uppercase and lowercase letter, and at least 8 or more characters" required>
						<label for="floatingInput">Password</label>
					</div>
					<div id="message" class="mb-3">
						<div>Password must contain the following:</div>
						<div id="letter" class="invalid">A <b>lowercase</b> letter</div>
						<div id="capital" class="invalid">A <b>capital (uppercase)</b> letter</div>
						<div id="number" class="invalid">A <b>number</b></div>
						<div id="length" class="invalid">Minimum <b>8 characters</b></div>
					</div>
					<div class="form-floating mb-3">
						<input type="password" class="form-control" id="password2" name="password2" placeholder="Re-type password" required>
						<label for="floatingInput">Re-type password</label>
						<div id="passwordMismatch">The passwords do not match. Please retype them.</div>
					</div>
				</div>
				<cfif NOT wasLookedUp>
					<div class="form-floating mb-3">
						<input style="width:150px;" type="number" class="form-control" id="handicap" name="handicap" placeholder="Handicap" pattern="[0-9]+([\,|\.][0-9])?" step="0.1" title="Must contain at least one number and one uppercase and lowercase letter, and at least 8 or more characters" required>
						<label for="floatingInput">Handicap</label>
					</div>
				</cfif>
			</cfif>
			<div class="form-floating mb-3">
				<cfif emailVerified>
					<input type="submit" id="btnSubmit" name="btnSubmit" class="btn btn-primary" value="Create Account">
				<cfelse>
					<input type="button" id="btnVerifyEmail" class="btn btn-primary" value="Verify Email" >
				</cfif>
				<cfif wasLookedUp>
					<input type="hidden" name="firstName" value='<cfoutput>#theJSON.first_name#</cfoutput>'>
					<input type="hidden" name="lastName" value='<cfoutput>#theJSON.last_name#</cfoutput>'>
					<input type="hidden" name="ghinId" value='<cfoutput>#url.ghin#</cfoutput>'>
					<input type="hidden" name="homeClubName" value='<cfoutput>#theJSON.club_name#</cfoutput>'>
					<input type="hidden" name="homeClubId" value='<cfoutput>#url.clubId#</cfoutput>'>
					<input type="hidden" name="handicapCurrent" value='<cfoutput>#theJSON.handicap_index#</cfoutput>'>
					<input type="hidden" name="handicapLow" value='<cfoutput>#theJSON.low_hi#</cfoutput>'>
				</cfif>
				<cfif emailVerified>
					<input type="hidden" name="email" value='<cfoutput>#url.email#</cfoutput>'>
					<input type="hidden" name="token" value='<cfoutput>#url.token#</cfoutput>'>
				</cfif>
			</div>
		</form>
		
	</div>
</cfif>


<script>
	<cfif emailVerified>
		$("#instructions").insertBefore("#passwordFields").html("Please enter a password to complete your account creation.");
	</cfif>

	$( "#btnSubmit" ).click(function() {
	  if ($("#password").val() != $("#password2").val()){
	  	$("#passwordMismatch").show();
	  	return false;
	  }
	});

	$("#password, #password2").focus(function() {
		$("#passwordMismatch").hide();
	});

	$( "#btnVerifyEmail" ).click(function() {
		var email = $("#email").val();
		if (isEmail(email)){
			var result;
	        $.ajax({
	            type: "GET",
	            url: "ajax/emailLookup.cfm?email="+ email,
	            success: function (result) {
	               if(result == "true"){
	               		$('#email').addClass('error');
	               		$('#modalEmail').modal('show');
	               	}
	               	else {
	               		$('#frmCreate').submit();
	               	}
	            },
	            error: function (request, status, error) {
	                 alert("Email duplication check error.");
	             }
	        });
	    }
	    else {
	    	$('#email').addClass('error');
	    	$('#emailErrMsg').show();
		}
		
    })

    $( "#email" ).focus(function() {
    	$(this).removeClass('error');
    	$('#emailErrMsg').hide();
    })

    function isEmail(email) {
	  var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
	  return regex.test(email);
	}
</script>

<script>

	var myInput = document.getElementById("password");
	var letter = document.getElementById("letter");
	var capital = document.getElementById("capital");
	var number = document.getElementById("number");
	var length = document.getElementById("length");

	// When the user clicks on the password field, show the message box
	myInput.onfocus = function() {
	  document.getElementById("message").style.display = "block";
	}

	// When the user clicks outside of the password field, hide the message box
	myInput.onblur = function() {
	  document.getElementById("message").style.display = "none";
	}

	var lcValid = false;
	var ucValid = false;
	var numValid = false;
	var lenValid = false;
	// When the user starts to type something inside the password field
	myInput.onkeyup = function() {
	  // Validate lowercase letters
	  var lowerCaseLetters = /[a-z]/g;
	  if(myInput.value.match(lowerCaseLetters)) {
	    letter.classList.remove("invalid");
	    letter.classList.add("valid");
	    lcValid = true;
	  } else {
	    letter.classList.remove("valid");
	    letter.classList.add("invalid");
	    lcValid = false;
	  }	

	  // Validate capital letters
	  var upperCaseLetters = /[A-Z]/g;
	  if(myInput.value.match(upperCaseLetters)) {
	    capital.classList.remove("invalid");
	    capital.classList.add("valid");
	    ucValid = true;
	  } else {
	    capital.classList.remove("valid");
	    capital.classList.add("invalid");
	    ucValid = false;
	  }

	  // Validate numbers
	  var numbers = /[0-9]/g;
	  if(myInput.value.match(numbers)) {
	    number.classList.remove("invalid");
	    number.classList.add("valid");
	    numValid = true;
	  } else {
	    number.classList.remove("valid");
	    number.classList.add("invalid");
	    numValid = false;
	  }

	  // Validate length
	  if(myInput.value.length >= 8) {
	    length.classList.remove("invalid");
	    length.classList.add("valid");
	    lenValid = true;
	  } else {
	    length.classList.remove("valid");
	    length.classList.add("invalid");
	    lenValid = false;
	  }

	  
	  if (lcValid && ucValid && numValid && lenValid)
	  {
	  	document.getElementById("message").style.display = "none";
	  }
	  else
	  {
	  	document.getElementById("message").style.display = "block";
	  }
	}
</script>

<!-- Modal -->
<div class="modal fade" id="modalEmail" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Account Exists</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <p>That email address already exists in our system. Please login to your existing account.</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
        <a href="/login.cfm" class="btn btn-primary">Login</a>
      </div>
    </div>
  </div>
</div>


<cfinclude template="/footer.cfm">