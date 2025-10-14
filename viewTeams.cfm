<cfinclude template="header.cfm">
<style>
    .btnRow {margin-l}
</style>
<section class="bg-white">
    <div class="container"> 
        <cfinclude template="viewTeamsInclude.cfm">
    </div>
    <div class="row mt-3">
        <div>
            <a href="/modifyTeams.cfm?mid=<cfoutput>#url.mid#</cfoutput>" class="btn btn-primary float-end">Modify Teams</a>
        </div>
    </div>
</section>

<cfinclude template="footer.cfm">