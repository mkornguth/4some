<cfsetting showdebugoutput="false">
<cfparam name="url.month" default="#month(now())#">

<cfquery datasource="#variables.DSN#" name="getMatches">
    select m.match_date, (select count(*) from match_players where match_id = m.match_id)  playerCount
    from matches m
    where group_id = #url.gid# and Month(match_date) = #url.month#
    order by m.match_date
</cfquery>

<cfset arrMatches = arrayNew(1)>

<cfoutput query="getMatches">
    <cfset strMatch = structNew()>
    <cfset strMatch.match_date = getMatches.match_date>
    <cfset strMatch.playerCount = getMatches.playerCount>
    <cfset temp = arrayAppend(arrMatches, strMatch)>
</cfoutput>

<cfoutput>#serializeJSON(arrMatches)#</cfoutput>
<!--- <cfoutput>#ValueList(getMatches.DayofMonth)#</cfoutput> --->
