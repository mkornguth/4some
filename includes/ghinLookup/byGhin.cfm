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
<!---<cfdump var="#authResponse#">--->
 <!--- <cfoutput>#authResponse.golfer_user.golfer_user_token#</cfoutput>  --->

<cfset lookupUrl = "https://api.ghin.com/api/v1/golfers/search.json?per_page=1&page=1&golfer_id=" & variables.ghin>

<!---  Individual golfer--->
<cfhttp method="get" url="#lookupUrl#">
  <cfhttpparam type="header"  name="Authorization" value="Bearer #authResponse.golfer_user.golfer_user_token#">
</cfhttp> 

<cfset results = deserializeJSON(cfhttp.fileContent)>
