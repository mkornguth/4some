<cfset redirectUnauth = false>
<cfinclude template="/header.cfm">
<style>
	#accordionDiagnostics {margin-top:200px;}
	.accordion-header {margin-top: 0;}
	.accordion-button {font-size:.5em;}
</style>


<!--- 	<cfquery datasource="#variables.dsn#" name="insertError">
		insert into 4some.errors (type, message, template, ip<cfif isDefined("variables.GolferId">, player_id</cfif><cfif error.type eq "database" and isDefined("error.additional.sql")>,sql</cfif>)
			values ('#error.type#','#error.message#', '#error.template#', '#error.remote_address#'<cfif isDefined("variables.GolferId">, #variables.GolferId#</cfif><cfif error.type eq "database" and isDefined("error.additional.sql")>,'#error.additional.sql#'</cfif>)
	</cfquery> --->

<!--- <cfoutput>#variables.GolferId#</cfoutput><cfabort> --->

<cfquery datasource="#variables.dsn#" name="insertError">
	insert into 4some.errors (type, message, template, ip<cfif isDefined("variables.GolferId")>, player_id</cfif><cfif error.type eq "database" and isDefined("error.additional.sql")>,error_sql</cfif>)
		values ('#error.type#','#error.message#', '#error.template#', '#error.remoteAddress#'<cfif isDefined("variables.GolferId")>, #variables.GolferId#</cfif><cfif error.type eq "database" and isDefined("error.additional.sql")>,'#error.additional.sql#'</cfif>)
</cfquery>

<cfquery datasource="#variables.DSN#" name="getErrorIdentity">
	SELECT MAX(error_id) as error_id FROM errors
</cfquery>

<h3>We're sorry ... an error has occurred</h3>
<p>The details of the issue have been logged in our system.</p>
<p>To expedite resolution of the issue, you can email <a href="mailto:support@teams.golf">support@teams.golf</a> and give them <strong>incident #<cfoutput>#getErrorIdentity.error_id#</cfoutput></strong>.</p>
<div class="accordion" id="accordionDiagnostics">
  <div class="accordion-item">
    <h2 class="accordion-header" id="headingOne">
      <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseOne" aria-expanded="false" aria-controls="collapseOne">
        Diagnostics
      </button>
    </h2>
    <div id="collapseOne" class="accordion-collapse collapse" aria-labelledby="headingOne" data-bs-parent="#accordionDiagnostics">
      <div class="accordion-body">
      	<cfoutput>
	        
	        <table class="table">
	        	<tr>
	        		<td><strong>Type</strong></td>
	        		<td>#error.type#</td>
	        	</tr>
	        	<tr>
	        		<td><strong>Message</strong></td>
	        		<td>#error.message#</td>
	        	</tr>
	        	<tr>
	        		<td><strong>Template</strong></td>
	        		<td>#error.template#</td>
	        	</tr>
	        	<tr>
	        		<td><strong>Detail</strong></td>
	        		<td>#error.diagnostics#</td>
	        	</tr>
	        	<cfif error.type eq "database" and isDefined("error.additional.sql")>
		        	<tr>
		        		<td><strong>SQL</strong></td>
		        		<td>#error.additional.sql#</td>
		        	</tr>
		        </cfif>
	        </table>
	    </cfoutput>
      </div>
    </div>
  </div>
  
 
</div>

<cfinclude template="/footer.cfm">