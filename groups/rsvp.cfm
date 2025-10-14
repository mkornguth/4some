<cfset redirectUnauth = false>
<cfinclude template="/header.cfm">

<cfif isDefined("url.code") and listLen(trim(url.code),"-") eq 2>
	<cfset variables.gid = ListGetAt(url.code,1,"-")>
	<cfquery datasource="#variables.DSN#" name="getGroup">
		select *
		from 4some.groups
		where group_id = #variables.gid#
	</cfquery>
	<cfif Compare(ListGetAt(url.code,2,"-"),getGroup.invite_code) eq 0>
		<cfset cookie.inviteCode = url.code>
		<cfif variables.isAuthenticated>
			<cfinclude template="/account/includes/inviteProcess.cfm">
		<cfelse>
			<cflocation url="/account/lookup.cfm?code=#trim(url.code)#">
		</cfif>
		
	<cfelse>
		<h1>Invalid Code</h1>
		<h4>Please check your link and verify the code.</h4>
	</cfif>
<cfelse>
	<h1>Invalid Code</h1>
	<h4>Please check your link and verify the code.</h4>
</cfif>

<cfinclude template="/footer.cfm">