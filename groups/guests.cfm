<cfinclude template="/header.cfm">
<style>
	.fa-check {color:green;}
	.dropdown-remove .dropdown-item:hover {cursor: pointer;}
	#member-handcuff {display: none;}
	.onoffswitch {margin-top:5px;}
</style>
<link href="/assets/css/onoffswitch.css" type="text/css"  rel="stylesheet"/>

<cfinclude template="groupSubhead.cfm">

<cfquery datasource="#variables.DSN#" name="getGroupClub">
	select  c.*
	from clubs c 
		inner join 4some.groups g on g.club_id = c.club_id
	where g.group_id = #url.gid#
	order by group_id
</cfquery>

<cfquery datasource="#variables.DSN#" name="getNonGroupClubPlayers">
	select  c.player_id, first_name, last_name, g.date_added
	from club_players c
		inner join players p on p.player_id = c.player_id
		left outer join guests_registered g on g.player_id = c.player_id and group_id = #url.gid#
	where club_id = #getGroupClub.club_id# and c.player_id NOT IN (select player_id from group_players where group_id = #url.gid#)
</cfquery>

<cfquery datasource="#variables.DSN#" name="getUnregisteredGuests">
	select g.*, p.first_name as member_first_name, p.last_name as member_last_name
	from  guests_unregistered g
		left outer join players p on p.player_id = g.player_id_handcuff
	where g.group_id = #url.gid#
</cfquery>

<h3>Group Guest List</h3>

<ul class="nav nav-tabs" id="myTab" role="tablist">
	<li class="nav-item" role="presentation">
		<button class="nav-link active" id="home-tab" data-bs-toggle="tab" data-bs-target="#home-tab-pane" type="button" role="tab" aria-controls="home-tab-pane" aria-selected="true"><cfoutput>#getGroupClub.club_name#</cfoutput></button>
	</li>
	<li class="nav-item" role="presentation">
		<button class="nav-link" id="profile-tab" data-bs-toggle="tab" data-bs-target="#profile-tab-pane" type="button" role="tab" aria-controls="profile-tab-pane" aria-selected="false">Non-club Guests</button>
	</li>

</ul>
<div class="tab-content" id="myTabContent">
	<!--- Home club guest options --->
	<div class="tab-pane fade show active" id="home-tab-pane" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
		<cfif getNonGroupClubPlayers.recordcount GT 0>
			<p>Below are registered members available to add as a group guest. If you don't see a member, please ask them to <a href="/account/lookup.cfm">Sign Up</a> and they will automatically be available below.</p>
			<table id="tblClubMembers" class="table">
				<thead>
					<tr>
						<th class="text-center">Guest <span  class="d-none d-md-inline">Status</span></th>
						<th>Last Name</th>
						<th>First Name</th>
					</tr>
				</thead>
				<tbody>
					<cfoutput query="getNonGroupClubPlayers">
						<tr data-pid="#getNonGroupClubPlayers.player_id#">
							<td class="text-center">
								<cfif LEN(getNonGroupClubPlayers.date_added) GT 0>
									<div class="dropdown dropdown-remove">
										<button class="btn btn-xs btn-light dropdown-toggle" type="button" id="dropdownMenuButton1" data-bs-toggle="dropdown" aria-expanded="false">
											<i class="fa-solid fa-check"></i>
										</button>
										<ul class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
											<li><a class="dropdown-item">Remove</a></li>
										</ul>
									</div>
								<cfelse>
									<button class="btn btn-xs btn-light btn-add"><i class="fa-solid fa-plus" title="Add as guest"></i></button>
								</cfif>
							</td>
							<td>#getNonGroupClubPlayers.last_name#</td>
							<td>#getNonGroupClubPlayers.first_name#</td>
						</tr>
					</cfoutput>
				</tbody>
			</table>
		<cfelse>
			<p class="alert alert-info">There are currently no members of <cfoutput>#getGroupClub.club_name#</cfoutput> that are not already in your group.</p>
		</cfif>
	</div>
	<!--- Other guest options --->
	<div class="tab-pane fade" id="profile-tab-pane" role="tabpanel" aria-labelledby="profile-tab" tabindex="0">
		<!--- Guest table --->
		<cfif getUnregisteredGuests.recordcount GT 0>
			<p>Below are unregistered guests. <button class="btn btn-xs btn-secondary float-end" data-bs-toggle="modal" data-bs-target="#modalAddGuest"><i class="fa-solid fa-user-plus"></i> Add a guest</button></p>
			<table id="tblUnregisteredGuests" class="table">
				<thead>
					<tr>
						<th class="text-center">Guest <span  class="d-none d-md-inline">Status</span></th>
						<th>Last Name</th>
						<th>First Name</th>
						<th><span  class="d-none d-md-inline">Handcuffed</span> Member</th>
					</tr>
				</thead>
				<tbody>
					<cfoutput query="getUnregisteredGuests">
						<tr data-pid="#getUnregisteredGuests.guest_id#">
							<td class="text-center">

									<div class="dropdown dropdown-remove-guest">
										<button class="btn btn-xs btn-light dropdown-toggle" type="button" id="dropdownMenuButton1" data-bs-toggle="dropdown" aria-expanded="false">
											<i class="fa-solid fa-check"></i>
										</button>
										<ul class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
											<li><a class="dropdown-item">Remove</a></li>
										</ul>
									</div>

							</td>
							<td>#getUnregisteredGuests.last_name#</td>
							<td>#getUnregisteredGuests.first_name#</td>
							<td><span  class="d-none d-md-inline">#getUnregisteredGuests.member_first_name#</span> #getUnregisteredGuests.member_last_name#</td>
						</tr>
					</cfoutput>
				</tbody>
			</table>
		<cfelse>
			<p class="alert alert-info">There are currently no unregistered guests of members in your group.</p>
			<button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="#modalAddGuest"><i class="fa-solid fa-user-plus"></i> Add a guest</button>
		</cfif>

	</div>
</div>

<script>
	var addBtnHtml = '<button class="btn btn-xs btn-light btn-add"><i class="fa-solid fa-plus" title="Add as guest"></i></button>';
	var removeBtnHtml = '<div class="dropdown dropdown-remove"><button class="btn btn-xs btn-light dropdown-toggle" type="button" id="dropdownMenuButton1" data-bs-toggle="dropdown" aria-expanded="false"><i class="fa-solid fa-check"></i></button><ul class="dropdown-menu" aria-labelledby="dropdownMenuButton1"><li><a class="dropdown-item" href="##">Remove</a></li></ul></div>';
	
	$("#tblClubMembers").on("click", ".btn-add", function(event){
    	var pid = $(this).closest('tr').data('pid');
		var btn = $(this);
        $.ajax({
            type: "GET",
            url: "/groups/ajax/guestAdd.cfm?gid=<cfoutput>#url.gid#</cfoutput>&pid=" + pid,
            success: function (result) {
            	//alert(result);


                   if(result.trim() == "added"){
                        btn.hide();
                        btn.parent().html(removeBtnHtml);
                    }

                },
                error: function (request, status, error) {
                     alert("invalid request");
                 }
        });
	});

	//remove registered guests
	$("#tblClubMembers").on("click", ".dropdown-remove .dropdown-item", function(event){
    	var pid = $(this).closest('tr').data('pid');
		var btn = $(this).closest('.dropdown-remove');
        $.ajax({
            type: "GET",
            url: "/groups/ajax/guestRemove.cfm?gid=<cfoutput>#url.gid#</cfoutput>&pid=" + pid,
            success: function (result) {
                   if(result.trim() == "removed"){
                        btn.hide();
                        btn.parent().html(addBtnHtml);
                    }

                },
                error: function (request, status, error) {
                     alert("invalid request");
                 }
        });
    })

	//remove unregisteredd guests
    $("#tblUnregisteredGuests").on("click", ".dropdown-remove-guest .dropdown-item", function(event){
    	var row = $(this).closest('tr');
    	var pid = $(this).closest('tr').data('pid');
		var btn = $(this).closest('.dropdown-remove');
        $.ajax({
            type: "GET",
            url: "/groups/ajax/guestRemove.cfm?gid=<cfoutput>#url.gid#</cfoutput>&guestId=" + pid,
            success: function (result) {
            	alert(result);
                   if(result.trim() == "removed"){
                        btn.hide();
                        btn.parent().html(addBtnHtml);
                        row.hide();
                    }

                },
                error: function (request, status, error) {
                     alert("invalid request");
                 }
        });
    })
</script>

<!-- Add Guest Modal -->
<div class="modal fade" id="modalAddGuest" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Add a Guest</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <form action="guestAdd.cfm" method="post">
      <div class="modal-body">
        <div class="form-floating mb-3">
			<input type="text" class="form-control" id="firstName" name="firstName" placeholder="First name" required>
			<label for="floatingInput">First name</label>
			
		</div>
		<div class="form-floating mb-3">
			<input type="text" class="form-control" id="lastName" name="lastName" placeholder="Last name" required>
			<label for="floatingInput">Last name</label>
		</div>
		<div class="form-floating mb-3">
			<input style="width:150px;" type="number" class="form-control" id="handicap" name="handicap" placeholder="Handicap" pattern="[0-9]+([\,|\.][0-9])?" step="0.1" title="Must contain at least one number and one uppercase and lowercase letter, and at least 8 or more characters" required>
			<label for="floatingInput">Handicap</label>
		</div>
		<div class="row mb-3">
				<label class="col-sm-6 col-form-label">Handcuff guest to a member?</label>
			<div class="col-sm-6">
				<div class="onoffswitch">
					<input type="checkbox" name="handcuff" class="onoffswitch-checkbox" id="handcuff">
					<label class="onoffswitch-label" for="handcuff">
						<div class="onoffswitch-inner"></div>
						<div class="onoffswitch-switch"></div>
					</label>
				</div>
			</div>
		</div>
		<div class="col form-floating mb-3" id="member-handcuff">
			<select class="form-select" id="member" name="member" placeholder="Member">
				<option></option>
				<cfoutput query="getGroupMembers">
					<option value="#getGroupMembers.player_id#">#getGroupMembers.first_name# #getGroupMembers.last_name#</option>
				</cfoutput>
			</select>
			<label for="floatingInput">Member</label>
		</div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
        <button type="submit" class="btn btn-primary">Add Guest</button>
      </div>
      	<input type="hidden" name="gid" value="<cfoutput>#url.gid#</cfoutput>">
  		</form>
    </div>
  </div>
</div>

<script>
	$( "#handcuff" ).click(function() {
		$("#member-handcuff").toggle();
	})
</script>

<cfinclude template="/footer.cfm">