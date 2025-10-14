<cfset strUser = structNew()>
<cfset strUser.user = structNew()>
<cfset strUser.user.email_or_ghin = "2358110">
<cfset strUser.user.password = "Ghin31!">
<cfset strUser.user.remember_me = "true">
<cfset strUser.token = "nonblank">
<cfset json = serializeJSON(strUser)>


<cfhttp method="post" url="https://api2.ghin.com/api/v1/golfer_login.json">
  <cfhttpparam type="header"  name="Content-Type" value="application/json; charset=utf-8">
  <cfhttpparam type="header"  name="Accept" value="application/json">
  <cfhttpparam type="body" value="#json#">
</cfhttp>

<cfset authResponse = deserializeJSON(cfhttp.fileContent)>
<cfset maxResults = 25>

<cfset lookupUrl = "https://api2.ghin.com/api/v1/golfers.json?status=Active&from_ghin=true&per_page=" & maxResults & "&sorting_criteria=full_name&order=asc&page=1&state=" & variables.state & "&last_name=" & variables.lastName &"&first_name=" & variables.firstName & "&source=GHINcom">

<!--- Search last name --->
<cfhttp method="get" url="#lookupUrl#">
  <cfhttpparam type="header"  name="Authorization" value="Bearer #authResponse.golfer_user.golfer_user_token#">
</cfhttp> 

<cfset results = deserializeJSON(cfhttp.fileContent)>

<cfset resultsCount = ArrayLen(results.golfers)>

<!--- <cfdump var="#results#"> --->