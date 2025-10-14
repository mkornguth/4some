<cfsetting showdebugoutput="false">
<cfquery datasource="#variables.DSN#" name="lookupEmail">
	select *
	from players
	where email = '#url.email#'
</cfquery>
<cfif lookupEmail.recordcount GT 0>
	<cfset emailExists = true>
<cfelse>
	<cfset emailExists = false>
</cfif>

<cfoutput>#emailExists#</cfoutput>