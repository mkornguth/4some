<cfquery datasource="#variables.DSN#" name="getGroups">
	select g.*, (select isAdmin from group_players where group_id = g.group_id and player_id = #variables.player_id#) as isAdmin
	from 4some.groups g
	where g.group_id IN (#variables.GroupList#)
	order by isAdmin desc, group_id
</cfquery>

<cfquery datasource="#variables.DSN#" name="getGroupMembers">
	select p.*, gp.isAdmin
	from group_players gp
		inner join players p on p.player_id = gp.player_id
	where group_id = #url.gid#
	order by first_name
</cfquery>

<h1>Your Groups</h1>
<cfif isDefined("url.status")>
    
    <cfswitch expression="#url.status#">
        <cfcase value="groupDeleted">
            <div class="alert alert-success alert-calendar-status mb-5" role="alert">
            <h4 class="alert-heading">Your group has been successfully deleted. <button type="button" class="btn-close float-end" data-bs-dismiss="alert" aria-label="Close"></button></h4>
            </div>
        </cfcase>
        <cfcase value="ghinUpdateNameMismatch">
            <div class="alert alert-danger alert-calendar-status mb-5" role="alert">
            <h4 class="alert-heading">Your GHIN has <strong>NOT</strong> been updated, due to a last name mismatch with the GHIN number provided. <button type="button" class="btn-close float-end" data-bs-dismiss="alert" aria-label="Close"></button></h4>
            </div>
        </cfcase>
        <cfcase value="accountUpdated">
            <div class="alert alert-success alert-calendar-status mb-5" role="alert">
            <h4 class="alert-heading">Your account has been successfully updated. <button type="button" class="btn-close float-end" data-bs-dismiss="alert" aria-label="Close"></button></h4>
            </div>
        </cfcase>
    </cfswitch>
    
</cfif>
<div class="row">
	<div class="col-6">
		<form action="index.cfm" method="get">
			<select class="form-select" aria-label="Default select example" id="group-select" name="gid" onchange="this.form.submit();">
				<cfoutput query="getGroups">
					<option value="#getGroups.group_id#" <cfif url.gid eq getGroups.group_id>selected</cfif>>#getGroups.group_name#</option>
				</cfoutput>
			</select>

		</form>
	</div>
	<div class="col-6 text-right">
		<cfif IsAdmin>
			<div class="dropdown">
			  <button class="btn btn-light dropdown-toggle" type="button" id="dropdownMenuButton1" data-bs-toggle="dropdown" aria-expanded="false">
			   Group Options
			  </button>
			  <ul class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
			    <li><a class="dropdown-item" href="invite.cfm?gid=<cfoutput>#url.gid#</cfoutput>"><i class="fa-solid fa-envelope-open-text fa-fw"></i> Invite Members</a></li>
			    <!--- <li><a class="dropdown-item" href="#"><i class="fa-regular fa-envelope fa-fw"></i> Email Group</a></li> --->
			    <li><a class="dropdown-item" id="lnkSettings" href="#"><i class="fa-solid fa-gear fa-fw"></i> Group Settings</a></li>
			    <cfif cgi.script_name contains "guests.cfm">
			    	<li><a class="dropdown-item" href="index.cfm" ><i class="fa-solid fa-list fa-fw"></i></i> Member List</a></li>
			    <cfelse>
				    <li><a class="dropdown-item" href="guests.cfm" ><i class="fa-solid fa-list fa-fw"></i></i> Guest List</a></li>
				</cfif>
				<li><hr class="dropdown-divider"></li>
				<li><a class="dropdown-item" href="/groups/create.cfm?status=add"><i class="fa-solid fa-plus fa-fw"></i> Create new group</a></li>
				<li><a class="dropdown-item" href="" data-bs-toggle="modal" data-bs-target="#modalDeleteGroup" onclick="replaceGroupName();"><i class="fa-solid fa-trash fa-fw"></i> Delete this group</a></li>
			  </ul>
			</div>
		</cfif>
	</div>
</div>

<!-- Modal -->
<div class="modal fade" id="modalDeleteGroup" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Delete Group</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <p><strong>Are you sure you want to delete the group '<span id="groupNameForDeletion"></span>'?</strong></p>
        <p>The group will be deleted<cfif getGroupMembers.recordcount GT 1> and all <cfoutput>#getGroupMembers.recordcount#</cfoutput> members will be removed</cfif>. Members will not be deleted from our system, only removed from this group.</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <a type="button" class="btn btn-danger" href="/groups/delete.cfm?gid=<cfoutput>#url.gid#</cfoutput>">Delete group</a>
      </div>
    </div>
  </div>
</div>

<script>
	function replaceGroupName(){
		$("#groupNameForDeletion").text($("#group-select option:selected").text());
	}
</script>