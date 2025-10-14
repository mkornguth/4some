<cfset redirectUnauth = false>
<cfinclude template="/header.cfm">
<link rel="stylesheet" href="/assets/css/passwordValidation.css">
<style>
	#emailErrMsg {font-size:.8em; color:#cc0000; display:none; text-align: center;}
	.form-floating>.form-control:focus, .form-floating>.form-control:not(:placeholder-shown) {font-size: 17px;}
	.instructions {font-size:.7em; font-style: italic;}
	#passwordMismatch {font-size:.8em; color:#cc0000; display: none;}
	.info {margin-bottom:20px;text-align: center;}
</style>

<div id="loginBox">
    <h1 style="margin-top:0px;text-align:center;">Reset Password</h1>
	<cfif isDefined("url.email") and isDefined("url.token") and hmac(url.email,"skins") eq url.token>
		<cfset emailVerified = true>
		<div class="info">Type and confirm your new password below.</div>
		<div id="passwordFields">
			<form action="resetPassword.cfm" method="post">
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
				<input type="submit" id="btnSubmit" name="btnSubmit" class="btn btn-primary" value="Reset Password">
				<input type="hidden" name="email" value="<cfoutput>#trim(url.email)#</cfoutput>">
			</form>
		</div>
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
	<cfelseif IsDefined("form.password") and IsDefined("form.email")>
		<cfquery datasource="#variables.DSN#" name="updatePassword">
    		update  players
    			set password = '#hmac(trim(form.password),'skins')#'
    			where email = '#trim(form.email)#';
    	</cfquery>
    	<div class="alert alert-success">Your password has been reset and you can now login using it.</div>
    	<div class="text-center"><a href="/login.cfm" class="btn btn-primary">Login</a></div>
    <cfelse>
		<div id="reset-block">
			<form action="test.cfm" method="post">
			<div class="info">Enter your email address.<br/>We will send you a link to reset your password.</div>
			<div class="errMsg alert alert-danger" style="display:none;"></div>
			<div class="control">
				<input id="email" name="email" placeholder="Email" type="email" class="form-control" type="text" required />
				<div id="emailErrMsg">Invalid e-mail address</div>
			</div>
			<div class="mt-3"><input class="btn btn-primary btn-lg d-block mx-auto" type="button" id="btnResetPassword" value="Reset Password" /></div>
			
    		</form>
    	</div>
    	<div id="sent-block" style="display:none;">
    		<div class="alert alert-success">A password reset link has been sent to the email address submitted.</div>
    	</div>
    </cfif>
</div>

<script>
$( "#btnResetPassword" ).click(function() {	
	var email = $("#email").val();
	
	if (isEmail(email)){
		$.ajax({
		    type: "GET",
		    url: "ajax/resetPassword.cfm?email="+ email,
		    success: function (result) {
		       if(result == "sent"){
		       		$('#reset-block').hide();
		       		$('#sent-block').show();
		       	}
		    },
		    error: function (request, status, error) {
		         alert("Error sending email.");
		     }
		});
	}
	else {
		$('#emailErrMsg').show();
	}
})

$( "#btnSubmit" ).click(function() {
  if ($("#password").val() != $("#password2").val()){
  	$("#passwordMismatch").show();
  	return false;
  }
});

function isEmail(email) {
  var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
  return regex.test(email);
}
</script>


<cfinclude template="/footer.cfm">