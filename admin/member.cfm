<cfset variables.pageName = "Member Detail">
<cfinclude template="header.cfm">
<cfquery datasource="#variables.DSN#" name="getMember">
	select *
	from 4some.players
	where player_id = #url.pid#
</cfquery>

<cfdump var="#getMember#">

<cfinclude template="footer.cfm">