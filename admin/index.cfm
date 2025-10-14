<cfset redirectUnauth = false>
<cfset variables.pageName = "Dashboard">
<cfinclude template="header.cfm">
<style>
	#tblGroups, #tblErrors tbody tr:hover {background-color: #FFFFA7; cursor: pointer;}
	#tblGroups, #tblErrors tbody td, #tblErrors tbody td {font-size:13px;}
</style>

<cfquery datasource="#variables.DSN#" name="getLatestGroups">
	select g.group_id, g.group_name, c.club_name, (select count(*) from group_players where group_id = g.group_id) as group_count
	from 4some.groups g
		left outer join 4some.clubs c on c.club_id = g.club_id
	order by group_id desc
</cfquery>

<cfquery datasource="#variables.DSN#" name="getLatestErrors">
	select *
	from 4some.errors
	order by error_id desc
</cfquery>

<h3>Groups</h3>
<table class="table table-striped" id="tblGroups">
	<thead>
		<tr>
			<th>Group ID</th>
			<th>Name</th>
			<td align="center"><strong>Club</strong></th>
			<td class="d-none d-md-block" align="center"><strong>Member Count</strong></th>
		</tr>
	</thead>
	<tbody>
		<cfoutput query="getLatestGroups">
			<tr data-gid="#getLatestGroups.group_id#">
				<td>#getLatestGroups.group_id#</td>
				<td>#getLatestGroups.group_name#</td>
				<td align="center">#getLatestGroups.club_name#</td>
				<td class="d-none d-md-block" align="center">#getLatestGroups.group_count#</td>
			</tr>
		</cfoutput>
	</tbody>
</table>
<h3>Errors</h3>
<table class="table table-striped" id="tblErrors">
	<thead>
		<tr>
			<th>Error ID</th>
			<th>Type</th>
			<th>Message</th>
			<th class="d-none d-md-block">Template</th>
		</tr>
	</thead>
	<tbody>
		<cfoutput query="getLatestErrors">
			<tr data-gid="#getLatestErrors.error_id#">
				<td>#getLatestErrors.error_id#</td>
				<td>#getLatestErrors.type#</td>
				<td>#getLatestErrors.message#</td>
				<td class="d-none d-md-block">#getLatestErrors.template#</td>
			</tr>
		</cfoutput>
	</tbody>
</table>


<cfinclude template="footer.cfm">

<script type="text/javascript" src="/assets/plugins/datatables/js/jquery.dataTables.min.js"></script>
<script>
	//wire up Groups data table
	var dtGroups = $('#tblGroups').dataTable({
		"autoWidth": false,
		"paging": true,
		"order": [[ 0, "desc" ]]
	});
 
	$("#tblGroups").on('click', 'tbody tr', function () {
	    window.location.href="group.cfm?gid=" + $(this).data('gid') ;
	});

	//wire up Groups data table
	var dtErrors = $('#tblErrors').dataTable({
		"autoWidth": false,
		"paging": true,
		"order": [[ 0, "desc" ]]
	});
 
	$("#tblErrors").on('click', 'tbody tr', function () {
	    window.location.href="error.cfm?eid=" + $(this).data('gid') ;
	});


</script>