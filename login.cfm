<cfset navSelected = "login">
<cfsetting showdebugoutput="false">
<cfset redirectUnauth = false>
<cfinclude template="header.cfm">
<style type="text/css">
.wrapper > .container {min-height:500px;}


.errMsg {border-radius: 8px !important;max-width:350px;margin:auto !important;margin-bottom: 30px !important;}

#otherBox {max-width:350px;margin:auto;margin-top:25px;color:#666666;text-align:center;border-radius: 8px;padding:15px;}

.alert {padding:8px !important;font-weight:bold;border-radius:0px;text-align:center;margin-left:-15px;margin-right:-15px;border-left-width:0px;border-right-width:0px;}

.navbar-toggle.collapsed {display:none;}
<Cfif not isDefined("url.persistent")>
#loginBox .persistantLogin {display:none;}
</Cfif>

<cfif IsDefined("url.branding")>
.nav.navbar-nav li:nth-child(1) {display:none;}
.nav.navbar-nav li:nth-child(2) {display:none;}
.nav.navbar-nav li:nth-child(3) {display:none;}
.nav.navbar-nav li:nth-child(4) {display:none;}
</cfif>

@media (max-width: 767px) {
	body {background-color:#262626;}
	.wrapper > .container {min-height:inherit;}
	#loginBox {border-width:0px;margin-top:10px;}
	#otherBox {background-color:#eeeeee;padding:10px;border:solid 1px #dddddd;max-width:inherit;}
	.footerRowExtended {margin-top:20px;}
	#footerMain {padding-left:0px;padding-right:0px;}
	#loginBox .persistantLogin {display:block;}
}

@media (max-width: 380px) {
	.headerRow {height:inherit !important;}
}

#loginBox .control {clear:both;margin-top:20px;}
#loginBox .info {text-align: center;margin-bottom:30px;}
#loginBox input {max-width:300px;margin:auto;}
#loginBox .button .btn {clear:both;margin-top:25px;}
#loginBox .loginHelp {margin-top:25px;text-align:Center;}
#loginBox .persistantLogin {margin-top:15px;text-align:Center;}
</style>
<cfif isDefined("form.email") and isDefined("form.password")>

	<cfquery datasource="#variables.DSN#" name="lookupPlayer">
		select *
		from players
		where email = '#trim(lcase(form.email))#' and password = '#hmac(trim(form.password), 'skins')#'
	</cfquery>

	<cfif lookupPlayer.RecordCount GT 0>
		<cfcookie name="GolferData" value="#lookupPlayer.player_id#,#trim(form.email)#, #trim(lookupPlayer.first_name)#, #trim(lookupPlayer.last_name)#" expires="30">

		<!--- if an existing member is joining a new group and is logging in to their existing account, add their new group --->
		<cfif isDefined("url.gid") and isDefined("url.action") and url.action eq "groupJoin">
			<cfset variables.player_id = lookupPlayer.player_id>
			<cfinclude template="/account/includes/inviteProcess.cfm">
	    <!--- NORMAL LOGIN --->
	    <cfelse>
	    	<cfquery datasource="#variables.DSN#" name="getGroups">
				select group_id, isAdmin
				from group_players
				where player_id = #lookupPlayer.player_id#
				order by isAdmin desc, group_id
			</cfquery>

			<cfif getGroups.recordcount GT 0>
				<cfset local.groupList = "">
				<cfoutput query="getGroups">
					<cfset listItem = '"' & getGroups.group_id & '":{"ISADMIN":' & getGroups.isAdmin & '}'>
					<cfset local.groupList = listAppend(local.groupList, listItem)>
				</cfoutput>
				<cfset local.groupList = "{" & local.groupList & "}">
				<cfcookie name="GolferGroups" value="#local.groupList#" expires="30">
			</cfif>
			


			<cfif getGroups.recordcount GT 0>
				<CFHEADER STATUSCODE="302" STATUSTEXT="Object Temporarily Moved" />
				<CFHEADER NAME="location" VALUE="http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT#/calendar/index.cfm?gid=#getGroups.group_id#" />
			<cfelse>
				<CFHEADER STATUSCODE="302" STATUSTEXT="Object Temporarily Moved" />
				<CFHEADER NAME="location" VALUE="http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT#/account/groups.cfm" />
			</cfif>
		</cfif>

		
	<cfelse>
		<cflocation url="/login.cfm?status=invalidLogin">
	</cfif>
<cfelse>
	<form action="<cfoutput>#cgi.script_name#?#cgi.query_string#</cfoutput>" method="post" name="frmLogin">
		<cfif isDefined("url.status")>
			<br/>
			<div class="alert alert-danger">
				<cfswitch expression="#url.status#">
					<cfcase value="authError">
						<cfcookie name="GolferData" expires="NOW" value="bye" >

						<div>Your session has timed out.</div>
						<div style="font-weight:normal;">If you continue to receive this message after logging in, your browser or corporate network may be blocking cookies.</div>
					</cfcase>
					<cfcase value="invalidLogin">
						<div>Your credentials were not recognized.</div>
						<div style="font-weight:normal;">Please try again.</div>
					</cfcase>
				</cfswitch>
			</div>
		</cfif>
	    <div id="loginBox">
	        <cfif IsDefined("variables.username") and variables.username neq "" and cgi.script_name does not contain "logout.cfm" and cgi.query_string does not contain "redirected" and (not IsDefined("url.status") or url.status neq "authError") and not IsDefined("url.errMsg")>
				<cflocation url="http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT#/account/groups.cfm">
	        <cfelse>
	          <h1 style="margin-top:0px;text-align:center;">Member Login</h1>
	          <div class="info">Log in with your existing account below.</div>
						<div class="errMsg alert alert-danger" style="display:none;"></div>
						<div class="control"><input id="emailBox" name="email" placeholder="Email" type="email" class="form-control" type="text" <cfif IsDefined("url.email")>value="<cfoutput>#url.email#</cfoutput>"</cfif> /></div>
						<div class="control"><input id="passwordBox" name="password" placeholder="Password" class="form-control" type="password" /></div>
						<div class="persistantLogin"><input type="checkbox" name="remember"> Keep me logged in</div>
						<div class="button"><input class="btn btn-primary btn-lg d-block mx-auto" type="submit" value="Log In"  /></div>
						<!--- <div class="loginHelp"><a href="/forgot.cfm" style="text-decoration:underline;">Having trouble logging in?</a></div> --->
	        </cfif>
	        <hr/>
	        <div class="row">
	        	<div class="text-center"><a href="/account/resetPassword.cfm" >I forgot my password</a></div>
	        </div>
	        <div class="row">
		        <div class="text-center mt-3">Don't have an account yet? <a href="/account/lookup.cfm" class="btn btn-sm btn-light">Sign Up</a></div>
		    </div>
	    </div>
	<!--- 	<div id="otherBox"><strong>Don't have an account?</strong><br>You will either need to <a href="/start_pool/">start your own pool</a>, or be invited by an existing administrator who will send you join instructions.</div> --->
	</form>
</cfif>
<!--- <cf_htmlfoot> --->
<script>
	document.domain = "runyourpool.com";
	
	<script>
	$(document).ready(function() {
		//$("#usernameBox").focus();
		<cfif IsDefined("url.errMsg")>
			<cfif url.errMsg eq "missingField">
			$(".errMsg").html("Username and password are required");
			<cfelse>
			$(".errMsg").html("Invalid username and/or password");
			</cfif>
			$(".errMsg").show();
		</cfif>
		$(window).width();
	});
	</script>
	
</script>
<!--- </cf_htmlfoot> --->
<cfinclude template="footer.cfm">
