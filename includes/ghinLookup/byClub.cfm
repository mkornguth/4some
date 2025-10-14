<!--- structure for user to login to GHIN site --->
<cfset strUser = structNew()>
<cfset strUser.user = structNew()>
<cfset strUser.user.email_or_ghin = "2358110">
<cfset strUser.user.password = "Ghin31!">
<cfset strUser.user.remember_me = "true">
<cfset strUser.token = "nonblank">
<cfset json = serializeJSON(strUser)>

<!--- login to GHIN site --->
<cfhttp method="post" url="https://api2.ghin.com/api/v1/golfer_login.json">
  <cfhttpparam type="header"  name="Content-Type" value="application/json; charset=utf-8">
  <cfhttpparam type="header"  name="Accept" value="application/json">
  <cfhttpparam type="body" value="#json#">
</cfhttp>

<!--- put response in variable --->
<cfset authResponse = deserializeJSON(cfhttp.fileContent)>

<cfset variables.clubId = 18362>

<!--- set url to perform search --->
<cfset lookupUrl = "https://api2.ghin.com/api/v1/clubs/" & variables.clubId & "/golfers.json?status=Active&per_page=1&sorting_criteria=last_name&order=asc&page=1&source=GHINcom">

<!---  lookup all club golfers using auth token--->
<cfhttp method="get" url="#lookupUrl#">
  <cfhttpparam type="header"  name="Authorization" value="Bearer #authResponse.golfer_user.golfer_user_token#">
</cfhttp> 

<!--- put golfers in results object --->
<cfset results = deserializeJSON(cfhttp.fileContent)>

<cfdump var="#results#">