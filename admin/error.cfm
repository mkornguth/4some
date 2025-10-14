<cfset variables.pageName = "Error Detail">
<cfinclude template="header.cfm">
<cfquery datasource="#variables.DSN#" name="getError">
	select *
	from 4some.errors
	where error_id = #url.eid#
</cfquery>

<cfdump var="#getError#">

<cfinclude template="footer.cfm">