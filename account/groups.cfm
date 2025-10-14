<cfinclude template="/header.cfm">

<link rel="stylesheet" href="/assets/css/choice.css" />
<style>
    .pricing-square-border {min-height: 250px;}
    .pricing-content {min-height: 150px; background-color: #FFFFFF;padding:20px;}
    .pricing-footer {margin:20px;}
    .error {color:#CC0000;}
    h2 {margin-bottom: 30px;}
</style>

<cfif IsDefined("url.status") and url.status eq "accountSuccess">
    <h1>Congratulations!</h1>
    <h2>Your account has been setup successfully.</h2>
</cfif>
<div class="container">
    <cfif isDefined("url.gid") and isDefined("variables.GroupList") and ListFind(variables.GroupList, url.gid)>
        <cfquery datasource="#variables.DSN#" name="getGroup">
            select *
            from 4some.groups
            where group_id = #url.gid#
        </cfquery>
        <cfif IsDefined("url.groupStatus")>
            <cfif url.groupStatus eq "success">
                <div id="pageAlert" class="alert alert-success"><i class="fa-solid fa-users fa-fw"></i> You have also been successfully added to the group <strong>'<cfoutput>#getGroup.group_name#</cfoutput>'</strong></div>
            <cfelseif url.groupStatus eq "additional">
                <h1>Congratulations!</h1>
                <div>Your have been successfully added to the group <strong>'<cfoutput>#getGroup.group_name#</cfoutput>'</strong>.</div>
                <p><a href="/groups/index.cfm?gid=<cfoutput>#url.gid#</cfoutput>" class="btn btn-primary">View this Group</a></p>
            <cfelse>
                <div id="pageAlert" class="alert alert-danger"></div>
            </cfif>
        </cfif>
    <cfelse>
        <div id="pageAlert" class="alert alert-info"><p>We notice that you are not currently in a golfer group. To get started, you can create your own group or join an existing group.</p></div>
        <div class="row">
            <div class="col-md-6 col-lg-6 pricing-medium-light">
                <div class="pricing hover-effect pricing-square-border">
                <div class="pricing-head">
                    <h3>Create a Group</h3>
                </div>
               
                <div class="pricing-content"> 
                    <div>Choose this option if you want to start a group of golfers and become an administrator of that group.</div>
                    <div><em>Note:</em> After starting a group, you will invite your golfers to join your group.</div>
                </div>

                <div class="pricing-footer text-center">
                    <a href="/groups/create.cfm" class="btn btn-primary">Start a Group</a>
                </div>                    
                </div>
            </div>
            <div class="col-md-6 col-lg-6 pricing-medium-light">
                <div class="pricing hover-effect pricing-square-border">
                <div class="pricing-head">
                    <h3>Enter Group Invite Code</h3>
                </div>
               <!---  <ul class="pricing-content list-unstyled">
                    <li>
                        Select the number of individual entries to add:
                    </li>
                </ul> --->
                <div class="pricing-content"> 
                    <div>If you have been invited to join an existing group by a group administrator, you can enter your invite code below.</div> 
                    <div id="para2">Once joined, you will be able to choose the days you'll play with the group.</div>
                </div>

                <div class="pricing-footer text-center">

                    <div class="row g3 align-items-center">
                        <div class="col-2"></div>
                      <div class="col-6">
                        <input type="text"  id="inviteCode"  placeholder="Enter Code" class="form-control">
                      </div>
                      <div class="col-3">
                        <input type="button" id="btnVerifyCode" class="btn btn-primary" value="Submit" >
                      </div>
                    </div>

                </div>                    
                </div>
            </div>
        </div>
    </cfif>
    
</div>
<script>
$( "#btnVerifyCode" ).click(function() {
        var code = $("#inviteCode").val();
        var arrCode = code.split('-');
        $.ajax({
            type: "GET",
            url: "/groups/ajax/inviteConfirm.cfm?code="+ code,
            success: function (result) {
                   if(result.trim() == "true"){
                        window.location.href="/groups/invite.cfm?gid=" + arrCode[0] + "&code=" + arrCode[1] + "&status=insertMember";
                    }
                    else {
                        $("#para2").addClass("error").html("<i class='fa-solid fa-triangle-exclamation'></i> Invalid invite code. Please check the code carefully.")
                    }
                },
                error: function (request, status, error) {
                     alert("invalid code entered");
                 }
        });

        
    })
</script>
<cfinclude template="/footer.cfm">