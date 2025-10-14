<cfdump var="#form#">

<cfset variables.handcuff = 0>
<cfif IsDefined("form.handcuff") and isDefined("form.member")>
	<cfset variables.handcuff = 1>
</cfif>

<cfquery datasource="#variables.DSN#" name="insertUnregisteredGuest">
	insert into guests_unregistered (group_id,first_name, last_name, handicap, is_handcuffed<cfif variables.handcuff eq 1>, player_id_handcuff</cfif>)
		values(#form.gid#, '#form.firstName#','#form.lastName#', #form.handicap#, #variables.handcuff#<cfif variables.handcuff eq 1>, #form.member#</cfif>)
</cfquery>

<cflocation url="guests.cfm">