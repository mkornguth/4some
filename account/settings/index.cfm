<cfinclude template="/header.cfm">

<cfquery datasource="#variables.DSN#" name="getMember">
	select p.*
	from players p
	where p.player_id = #variables.player_id#
</cfquery>

<h1>Account Settings</h1>
<div class="bg-light p-3">
<h3>Password Reset</h3>
	<p>If you need to change your password for any reason, please go to the password reset page.</p>
	<a  class="btn btn-secondary" href="/account/resetPassword.cfm?email=<cfoutput>#getMember.email#</cfoutput>&token=<cfoutput>#hmac(trim(getMember.email),'skins')#</cfoutput>">Reset my Password</a>
</div>
<div class="p-3">

<h3>Sign out</h3>
	<p>If you are logged in on a shared device, make sure to sign out prior to ending your session.</p>
	<a  class="btn btn-secondary" href="/logout.cfm">Sign Out</a>
</div>
<div class="bg-light p-3">
	<h3>Delete your account</h3>
	<p>By deleting your account, you will no longer have access to any of the site features or functionality. All data related to your account and memberships will be physically deleted from our systems.</p>
	<a  class="btn btn-secondary"  href="/account/settings/delete.cfm">Delete my Account</a>
</div>

<cfinclude template="/footer.cfm">