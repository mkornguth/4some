<cfsetting showdebugoutput="false" enablecfoutputonly="true">

<cfquery datasource="#variables.DSN#" name="lookupEmail">
	select *
	from players
	where email = '#trim(url.email)#'
</cfquery>

<cfif lookupEmail.recordcount GT 0>
	<cfset result = "sent">
	<cfset verificationToken = hmac(url.email,"skins")>
	<cfmail subject="Password Reset Request" from="Teams.golf <no-reply@teams.golf>" to="#trim(url.email)#" type="html">
	 	<p>We have received a request to reset your password on the Teams.golf website. Please click the following link to reset your password.</p>
	 	<p>https://#CGI.SERVER_NAME#/account/resetPassword.cfm?email=#url.email#&token=#verificationToken#</p>
	</cfmail>
	
<cfelse>
	<cfset result = "not sent">
</cfif>
<cfoutput>#result#</cfoutput>

