<cfsetting showdebugoutput="no">
<cfset teamsGenerated = false>
<cfset variables.player_id = ListGetAt(cookie.GolferData, 1)>
<cfquery datasource="#variables.DSN#" name="getMember">
	select p.*
	from players p
	where p.player_id = #variables.player_id#
</cfquery>


<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=UTF-8">
  <title>Remote file for Bootstrap Modal</title>  
  <link href="/assets/css/onoffswitch.css" type="text/css"  rel="stylesheet"/>
</head>
<body>
	<style>
	/*	#msg {display:none;color:red;font-weight:bold;margin-top:5px;}
		#tblGolfers {display: none;}
		#tblGolfers .btn-close {}
		#guest-block {margin-left:60px; display:none;}
		.table>:not(caption)>*>* {border-bottom-width: 0px;}
		.fa-circle-xmark {cursor: pointer; font-size: .95em;}
		.btn-group {margin-top:20px;}
		.form-floating>.form-control:focus, .form-floating>.form-control:not(:placeholder-shown) {font-size: 17px;}
		.guest {font-style: italic;}*/
	</style>

	<form id="frmMatch" action="/account/modal/myAccountProcess.cfm" method="post" class="form">
		<div class="modal-header">
			<h5 class="modal-title"><cfoutput>My Account</cfoutput></h5>
			<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		</div>
		<div class="modal-body">
			<div class="row mb-3">
				<div class="col-6">
					<label for="firstName" class="form-label">First name</label>
					<input type="text" class="form-control" id="firstName" name="firstName" value="<cfoutput>#getMember.first_name#</cfoutput>">
				</div>
				<div class="col-6">
					<label for="lastName" class="form-label">Last name</label>
				<input type="text" class="form-control" id="lastName" name="lastName" value="<cfoutput>#getMember.last_name#</cfoutput>">
				</div>
			</div>
			
	
			<div class="mb-3">
				<label for="email" class="form-label">Email address</label>
				<input type="text" class="form-control" id="email" name="email" value="<cfoutput>#getMember.email#</cfoutput>">
			</div>
			<div class="mb-3">
				<cfif getMember.ghin_id GT 0>
					<label for="ghin" class="form-label">GHIN Id: <cfoutput>#getMember.ghin_id#</cfoutput></label> 
				<cfelse>
					<label for="ghin" class="form-label">GHIN Id</label>
					<input type="text" class="form-control" id="ghin" name="ghin" value="<cfoutput>#getMember.ghin_id#</cfoutput>">
				</cfif>
			</div>
		</div>
		<div class="modal-footer" style="display:inline-block;width:100%;">
			<a  class="btn btn-warning" href="/account/resetPassword.cfm?email=<cfoutput>#getMember.email#</cfoutput>&token=<cfoutput>#hmac(trim(getMember.email),'skins')#</cfoutput>">Reset my Password</a>
			<div class="float-end">
				<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
				<button type="submit" class="btn btn-primary">Save changes</button>
			</div>
		</div>

		<input type="hidden" name="pid" value="<cfoutput>#variables.player_id#</cfoutput>">
	</form>
</body>

<script>
	
</script>
</html>
