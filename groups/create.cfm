<cfinclude template="/header.cfm">

<cfif IsDefined("form.groupName")>
	
	<!--- Create group invite code --->
	<cfset strAlpha = "abcdefghijklmnopqrstuvwxyzABCDEDFGHIJKLMNOPQRSTUVWXYZ" />
	<cfset arrPassword = ArrayNew(1) />
	<cfloop	index="intChar"	from="1" to="5">
		<cfset arrPassword[intChar] = Mid(strAlpha,RandRange(1, Len(strAlpha)),1) />
	</cfloop>
	<cfset groupPassword = ArrayToList(arrPassword,"") />
	
	<cftransaction action="begin">
		<cfquery datasource="#variables.DSN#" name="insertGroup">
			insert into 4some.groups (group_name, invite_code <cfif form.club GT 0>, club_id</cfif>)
				values ('#trim(form.groupName)#', '#groupPassword#'<cfif form.club GT 0>, #form.club#</cfif>);
		</cfquery>
		<cfquery datasource="#variables.DSN#" name="getGroupIdentity">
			SELECT MAX(group_id) as group_id FROM 4some.groups;
		</cfquery>

		<cfquery datasource="#variables.DSN#" name="insertGroupPlayer">
			insert into 4some.group_players (group_id, player_id, isAdmin)
				values (#getGroupIdentity.group_id#, #variables.player_id#, 1);
		</cfquery>

		<cfquery datasource="#variables.DSN#" name="getGroups">
			select group_id, IsAdmin
			from group_players
			where player_id = #variables.player_id#
		</cfquery>
		<cftransaction action="commit" />
	</cftransaction>

	<cfset strGroups = structNew()>
	<cfif getGroups.recordcount GT 0>
		<cfoutput query="getGroups">
			<cfset strGroups[getGroups.group_id] = structNew()>
			<cfset strGroups[getGroups.group_id].IsAdmin = getGroups.IsAdmin>
		</cfoutput>

		<cfcookie name="GolferGroups" value="#SerializeJSON(strGroups)#">
	</cfif>

	<cflocation url="/calendar/index.cfm?group=#getGroupIdentity.group_id#&status=newGroup">

<cfelse>
	<!--- Group creation form --->
	<style>
		.signup-box {margin:0 auto; max-width: 400px;}
		.signup-box h1 {text-align: center;margin-bottom: 20px;}
		.form-floating>.form-control:focus, .form-floating>.form-control:not(:placeholder-shown) {font-size: 17px;}
	</style>

	<cfquery datasource="#variables.DSN#" name="getPlayersClubs">
		select c.club_id, c.club_name
		from club_players cp
			inner join clubs c on c.club_id = cp.club_id
		where cp.player_id = #variables.player_id#
	</cfquery>

	<div class="signup-box">
		<h1>Create <cfif isDefined("url.status") and url.status eq "add">Another<cfelse>Your</cfif> Group</h1>
		<form action="create.cfm" method="post">
			<div class="form-floating mb-3">
				<input type="text" class="form-control" id="groupName" name="groupName"  placeholder="Group name" required>
				<label for="floatingInput">Group name</label>
			</div>
			<div class="form-floating mb-3">
				<select class="form-select" id="club" name="club" placeholder="Group club" required>
					<cfoutput query="getPlayersClubs"> 
						<option value="#getPlayersClubs.club_id#">#getPlayersClubs.club_name#</option>
					</cfoutput>
					<option value="0">Group not associated with a club</option>
				</select>
				<label for="floatingInput">Group Club</label>
			</div>
			<div class="form-floating mb-3">
				<input type="submit" id="btnSubmit" class="btn btn-primary" value="Create Group">
			</div>
		</form>
	</div>

	<script>
		$( document ).ready(function() {
		  $("#groupName").focus();
		});
	</script>
</cfif>

<cfinclude template="/footer.cfm">