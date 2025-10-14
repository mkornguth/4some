<cfset variables.pageName = 'Group Members'>
<cfinclude template="header.cfm">

<cfquery datasource="#variables.DSN#" name="getGroup">
	select g.*
	from 4some.groups g
	where g.group_id = #url.gid#
</cfquery>
<cfquery datasource="#variables.DSN#" name="getGroupMembers">
	select p.*, gp.isAdmin
	from group_players gp
		inner join players p on p.player_id = gp.player_id
	where group_id = #url.gid#
	order by first_name
</cfquery>
<h3><cfoutput>#getGroup.group_name#</cfoutput></h3>


<table class="table table-striped" id="tblGroupMembers">
	<thead>
		<tr>
			<th>Player ID</th>
			<th>Is Admin?</th>
			<th>First</th>
			<th>Last</th>
			<th>Email</th>
			<th>Handicap</th>
			<th>GHIN ID</th>
			<th></th>
		</tr>
	</thead>
	<tbody>
		<cfoutput query="getGroupMembers">
			<tr data-pid="#getGroupMembers.player_id#">
				<td>#getGroupMembers.player_id#</td>
				<td><cfif getGroupMembers.isAdmin eq 1><span class="badge bg-info">Admin</span></cfif></td>
				<td>#getGroupMembers.first_name#</td>
				<td>#getGroupMembers.last_name#</td>
				<td>#getGroupMembers.email#</td>
				<td>#getGroupMembers.handicap_current#</td>
				<td>#getGroupMembers.ghin_id#</td>
				<td><a href="impersonate.cfm?pid=#getGroupMembers.player_id#" target="_blank"><i class="fa fa-user"></i></a></td>
			</tr>
		</cfoutput>
	</tbody>
</table>
<cfinclude template="footer.cfm">

<script type="text/javascript" src="/assets/plugins/datatables/js/jquery.dataTables.min.js"></script>
<script>
	//wire up data table
	var dtGroups = $('#tblGroupMembers').dataTable({
		"autoWidth": false,
		"paging": false,
		"order": [[ 1, "desc" ], [2, "asc"]]
	});
</script>