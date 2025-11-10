<cfset redirectUnauth = false>
<cfinclude template="/header.cfm">
<h1>Delete Account</h1>
<cfif isDefined("url.status") and url.status eq "deleted">
	<div class="alert alert-info">Your account has been completely deleted from our system. We are sorry to see you go.</div>
<cfelse>
	<p>If you would like to delete your account, please review the following before clicking the Delete Account button:</p>
		<ul>
			<li>Deleting your account is permanent</li>
			<li>A user-requested deletion permanently removes the account and all associated personal data</li>
			<li>Deleting your account is not a temporary deactivation, disabling, or "freezing" of your account.</li>
			<li>Any current memberships will be cancelled immediately.</li>
		</ul>
	<div class="alert alert-danger">If you are unsure about deleting your account, we suggest aborting this process.</div>
	<div mt-3>
		<a href="deleteProcess.cfm" class="btn btn-danger">Delete my Account</a>
	</div>
</cfif>
<cfinclude template="/footer.cfm">