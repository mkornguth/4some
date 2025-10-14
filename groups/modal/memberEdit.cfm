<cfsetting showdebugoutput="no">
<cfset teamsGenerated = false>

<cfset variables.player_id = ListGetAt(cookie.GolferData, 1)>
<cfset variables.username = ListGetAt(cookie.GolferData, 2)>
<cfif IsDefined("cookie.GolferGroups") and LEN(cookie.golferGroups) GT 0>
  <cfset variables.hasGroups = true>
</cfif>

<cfquery datasource="#variables.DSN#" name="getMember">
	select p.*, gp.isAdmin
	from players p
		inner join group_players gp on gp.player_id = p.player_id and gp.group_id = #url.gid#
	where p.player_id = #url.pid#
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
		#msg {display:none;color:red;font-weight:bold;margin-top:5px;}
		#tblGolfers {display: none;}
		#tblGolfers .btn-close {}
		#guest-block {margin-left:60px; display:none;}
		.table>:not(caption)>*>* {border-bottom-width: 0px;}
		.fa-circle-xmark {cursor: pointer; font-size: .95em;}
		.btn-group {margin-top:20px;}
		.form-floating>.form-control:focus, .form-floating>.form-control:not(:placeholder-shown) {font-size: 17px;}
		.guest {font-style: italic;}
	</style>

	<form id="frmMatch" action="modal/memberEditProcess.cfm" method="post" class="form">
		<div class="modal-header">
			<h5 class="modal-title"><cfoutput>#getMember.first_name# #getMember.last_name#</cfoutput></h5>
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
			
			<div class="row mb-3">
				<div class="col-6">
					<label for="handicap" class="form-label">Current handicap</label>
					<input style="width:150px;" type="number" class="form-control" id="handicap" name="handicap" placeholder="Handicap"  value="<cfoutput>#getMember.handicap_current#</cfoutput>" pattern="[0-9]+([\,|\.][0-9])?" step="0.1" title="Must contain at least one number and one uppercase and lowercase letter, and at least 8 or more characters" required>
				</div>
				<div class="col-6">
					<label for="handicap" class="form-label">Group admin</label>
					<div class="onoffswitch">
						<input type="checkbox" name="isAdmin" class="onoffswitch-checkbox" id="isAdmin" <cfif getMember.isAdmin>checked</cfif>>
						<label class="onoffswitch-label" for="isAdmin">
							<div class="onoffswitch-inner"></div>
							<div class="onoffswitch-switch"></div>
						</label>
					</div>
				</div>
			</div>
			<div class="mb-3">
				<label for="email" class="form-label">Email address</label>
				<input type="text" class="form-control" id="email" name="email" value="<cfoutput>#getMember.email#</cfoutput>">
			</div>
		</div>
		<div class="modal-footer" style="display:inline-block;width:100%;">
			<button type="submit" class="btn btn-danger" name="btnRemove" onclick="return confirm('Are you sure you want to remove this member from the group?');">Remove Member</button>
			<div class="float-end">
				<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
				<button type="submit" class="btn btn-primary">Save changes</button>
			</div>
		</div>

		<input type="hidden" name="pid" value="<cfoutput>#url.pid#</cfoutput>">
		<input type="hidden" name="gid" value="<cfoutput>#url.gid#</cfoutput>">
	</form>
</body>

<script>
	
</script>
</html>
