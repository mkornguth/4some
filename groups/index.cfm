<cfset navSelected = "groups">
<style>
	#group-select {font-size:18px !important;}
	#tblMembers tbody tr:hover {background-color: #FFFFA7; cursor: pointer;}
	.trend-down {color:#5cb85c;}
	.trend-up {color:#dc3545;}
</style>
<cfinclude template="/header.cfm">

<cfinclude template="groupSubhead.cfm">


<table id="tblMembers" class="table">
	<thead>
		<tr>
			<th>Name</th>
			<th class="text-center">Index</th>
			<th></th>
			<th class="d-none d-md-block">Email</th>

		</tr>
	</thead>
	<tbody>
		<cfoutput query="getGroupMembers">
			<cfset trend = 0>
			<cfif IsDefined("getGroupMembers.handicap_current") and isDefined("getGroupMembers.handicap_previous") and LEN(getGroupMembers.handicap_previous) GT 0>
				<cfset trend = getGroupMembers.handicap_current - getGroupMembers.handicap_previous>
			</cfif>

			<tr data-pid="#getGroupMembers.player_id#">
				<td>#getGroupMembers.first_name# #getGroupMembers.last_name# <cfif getGroupMembers.isAdmin eq 1><span class="badge bg-info">Admin</span></cfif></td>
				<td class="text-center">#NumberFormat(getGroupMembers.handicap_current,"__._")# </td>
				<td>
					<cfif trend GT 0>
						<div class="trend-up"><i class="fa-solid fa-caret-up"></i>  #trend#</div>
					<cfelseif trend LT 0>
						<div class="trend-down"><i class="fa-solid fa-caret-down"></i>  #trend#</div>
					</cfif>
				</td>
				<td class="d-none d-md-block">#getGroupMembers.email#</td>
			</tr>
		</cfoutput>
	</tbody>
</table>

<!-- Modal -->
<div class="modal fade" id="basicModal" tabindex="-1" role="dialog" aria-labelledby="basicModal" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
        </div> <!-- /.modal-content -->
    </div> <!-- /.modal-dialog -->
</div> <!-- /.modal -->

<cfinclude template="/footer.cfm">
<script type="text/javascript" src="/assets/plugins/datatables/js/jquery.dataTables.min.js"></script>
<script>
	$( "#tblMembers tbody tr" ).click(function() {
		$('#basicModal .modal-content').load('modal/memberEdit.cfm?pid=' +  $(this).data('pid') + '&gid=' + <cfoutput>#url.gid#</cfoutput> );
        $('#basicModal').modal('show');

	});

	$( "#lnkSettings" ).click(function() {
		$('#basicModal .modal-content').load('modal/settings.cfm?gid=' + <cfoutput>#url.gid#</cfoutput> );
        $('#basicModal').modal('show');

	});
</script>