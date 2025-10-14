<cfset navSelected = "groups">
<cfquery datasource="#variables.DSN#" name="getGroup">
	select *
	from 4some.groups
	where group_id = #url.gid#
</cfquery>

<cfinclude template="/header.cfm">

<style>
	h4 {font-weight: 400;}
</style>

<cfif isDefined("url.status") and url.status eq "insertMember">
	<cfquery datasource="#variables.DSN#" name="insertGroupPlayer">
		insert into group_players (group_id, player_id)
			values (#url.gid#, #variables.GolferId#)
	</cfquery>

	<cfquery datasource="#variables.DSN#" name="getGroups">
		select group_id, isAdmin
		from group_players
		where player_id = #variables.GolferId#
	</cfquery>

	<cfset strGroups = structNew()>
	<cfif getGroups.recordcount GT 0>
		<cfoutput query="getGroups">
			<cfset strGroups[getGroups.group_id] = structNew()>
			<cfset strGroups[getGroups.group_id].IsAdmin = getGroups.IsAdmin>
		</cfoutput>
		<cfcookie name="GolferGroups" value="#SerializeJSON(strGroups)#">
	</cfif>

	<cflocation url="invite.cfm?group=#url.gid#&code=#url.code#">
</cfif>

<cfset variables.joinUrl = "https://#cgi.SERVER_NAME#/groups/rsvp.cfm?code=#url.gid#-#getGroup.invite_code#">

<cfif IsDefined("url.code") and url.code eq getGroup.invite_code>
	<h1>Group Invitation</h1>
	<h4>You are now a member of the group <strong>'<cfoutput>#getGroup.group_name#</cfoutput>'</strong>!</h4>
<cfelse>
	<h1>Group Invitations</h1>
	<p>In order for team generation to be automated for your group, each golfer must create an account and join your group. We've made this process simple!</p>
	<p><strong>Simply copy the link below and paste it in an email</strong> to everyone you want to join the group. Once they follow the link, they will be signed up in minutes.</p>
	<div class="row" style="margin-top:20px;">
      <div class="col-lg-1">
        <button class="btn btn-primary btn-sm" onclick="copyLink();">Copy link</button>
      </div>
      <div class="col-lg-7">
        <input type="textbox" id="txtLink" class="form-control" value="<cfoutput>#variables.joinUrl#</cfoutput>" style="border-color:#cccccc;padding:5px;font-family:Courier New";></input>
      </div>
      
    </div>
    <div class="row">
      <div class="col-lg-3 col-lg-offset-8" style="margin-top:20px;">
          <div class="alert alert-success" id="copiedMessage" style="display:none;"><span class="fa fa-copy fa-lg"></span> Copied to clipboard</div>
      </div>
    </div>
</cfif>



<cfinclude template="/footer.cfm">

<script>
  function copyLink() {
    /* Get the text field */
    var copyText = document.getElementById("txtLink");

    /* Select the text field */
    copyText.select();
    copyText.setSelectionRange(0, 99999); /* For mobile devices */

    /* Copy the text inside the text field */
    document.execCommand("copy");

    /* Alert the copied text */
    $("#copiedMessage").show().delay(2000).fadeOut("slow");

  }
</script>