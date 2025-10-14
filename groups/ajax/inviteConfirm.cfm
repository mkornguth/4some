<cfsetting showdebugoutput="false">
<cfif isDefined("url.code") and url.code contains "-" and listLen(url.code,"-") eq 2>
	<cfset groupId = ListGetAt(url.code,1,"-")>
	<cfset inviteCode = ListGetAt(url.code,2,"-")>

	<cfquery datasource="#variables.DSN#" name="lookupInviteCode">
		select invite_code
		from 4some.groups
		where group_id = #groupId#
	</cfquery>
	<cfif lookupInviteCode.recordcount GT 0 and lookupInviteCode.invite_code eq inviteCode>
		<cfset isCodeValid = true>
	<cfelse>
		<cfset isCodeValid = false>
	</cfif>

	<cfoutput>#isCodeValid#</cfoutput>
</cfif>