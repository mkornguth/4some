<cfset navSelected = "calendar">
<cfinclude template="/header.cfm">
<style>
    .popover .noMatch {border:1px solid #CCCCCC; width: 20px; height: 20px; display:inline-block; margin-right:10px;}
    .popover .match {border:1px solid #CCCCCC; background-color: #1d86c8; width: 20px; height: 20px; display:inline-block; margin-right:10px;}
    .popover .fa-circle-check {color:#888888; margin-left:3px; margin-right:13px;}
    .popover .bg-secondary-border {border:1px solid #1d86c8;margin-right:10px;}
    .popover .bg-dark-border {border:1px solid #000000;;margin-right:10px;}
</style>

<cfif NOT listFind(variables.GroupList, url.gid)>
    <h1>Access Denied</h1>
    <h4>You are not a member of this group.</h4>
    <cfabort>
    <cfinclude template="/footer.cfm">
</cfif>

<!-- Responsive slider -->
<link href="/assets/plugins/responsive-calendar/0.9/css/responsive-calendar.css" rel="stylesheet">

<!--- <cfquery datasource="#variables.DSN#" name="getGroups">
    select *
    from 4some.groups
    where group_id IN (#variables.GroupList#)
</cfquery> --->

<cfquery datasource="#variables.DSN#" name="getGroups">
    select g.*, (select isAdmin from group_players where group_id = g.group_id and player_id = #variables.player_id#) as isAdmin
    from 4some.groups g
    where g.group_id IN (#variables.GroupList#)
    order by isAdmin desc, group_id
</cfquery>

<cfquery datasource="#variables.DSN#" name="getMatches">
    select m.match_date 
        , CASE
            WHEN mp.player_id is null THEN false
            ELSE true
        END as isPlaying
        ,(select count(*) from match_players where match_id = m.match_id) + (select count(*) from match_guests where match_id = m.match_id)  playerCount
        ,(select count(distinct team_id) from match_teams where match_id = m.match_id and team_id <> 99) teamCount
    from matches m
        left outer join match_players mp on mp.match_id = m.match_id and mp.player_id = #variables.player_id#
    where group_id = #url.gid#
</cfquery>

<cfquery datasource="#variables.DSN#" name="getCalendarBlocks">
    select *
    from group_calendar_nomatch
    where group_id = #url.gid#
</cfquery>

<cfif isDefined("url.status")>
    <div class="alert alert-success alert-calendar-status mb-5" role="alert">
    <cfswitch expression="#url.status#">
        <cfcase value="newGroup">
            
            <h4 class="alert-heading">Your group has been successfully created. <button type="button" class="btn-close float-end" data-bs-dismiss="alert" aria-label="Close"></button></h4>

            <p>Below is your group calendar. The group calendar allows group members to choose which days they will play. Simply click a day to set up a match for that day.</p>

            <p class="mb-0">However, your first and most important step is to <a href="/groups/invite.cfm">invite members to join your group</a>. </p>
            
        </cfcase>
        <cfcase value="playerRemoved">
            <i class="fa-solid fa-circle-minus"></i> Player removed successfully.
        </cfcase>
        <cfcase value="playerAdded">
            <i class="fa-solid fa-circle-plus"></i>  Player added successfully.
        </cfcase>
         <cfcase value="guestAdded">
            <i class="fa-solid fa-circle-plus"></i>  Guest added successfully.
        </cfcase>
        <cfcase value="matchCreated">
            Match created and player added successfully.
        </cfcase>
        <cfcase value="teamsRemoved">
            Teams have been removed and must be recreated when ready.
        </cfcase>
    </cfswitch>
    </div>
</cfif>

<div class="container">
<cfif getGroups.recordcount eq 1>
    <h1 class="text-center"><cfoutput>#getGroups.group_name#</cfoutput></h1> 
<cfelse>
    <div class="row mb-3">
        <div class="col-md-4 col-12-sm mx-auto">
            <form action="index.cfm" method="get">
                <select class="form-select" aria-label="Default select example" id="group-select" name="gid" onchange="this.form.submit();" style="text-align: center;">
                    <cfoutput query="getGroups">
                        <option value="#getGroups.group_id#" <cfif url.gid eq getGroups.group_id>selected</cfif>>#getGroups.group_name#</option>
                    </cfoutput>
                </select>

            </form>
        </div>
    </div>
</cfif>
  <!-- Responsive calendar - START -->
  <div class="responsive-calendar">
      <div class="controls">
          <a class="float-start" data-go="prev"><div class="btn btn-primary">Prev</div></a>
          <h4><span data-head-year></span> <span data-head-month></span></h4>
          <a class="float-end" data-go="next"><div class="btn btn-primary">Next</div></a>
      </div><hr/>
      <div class="day-headers">
        <div class="day header">Mon</div>
        <div class="day header">Tue</div>
        <div class="day header">Wed</div>
        <div class="day header">Thu</div>
        <div class="day header">Fri</div>
        <div class="day header">Sat</div>
        <div class="day header">Sun</div>
      </div>
      <div class="days" data-group="days">
        
      </div>
    </div>
    <!-- Responsive calendar - END -->

    <!--- Legend --->
    <cfset variables.legendContent = "
    <div><div class='noMatch'>&nbsp;</div>No match</div>
    <div><div class='match'>&nbsp;</div>Match created</div>
    <div><i class='fa-regular fa-circle-check'></i>You are playing</div>
    <div><span class='badge bg-secondary bg-secondary-border'>##</span>Count (still open)</div>
    <div><span class='badge bg-dark bg-dark-border'>##</span>Count (teams generated)</div>
    ">
    <div class="text-center">
        <a tabindex="0" class="btn btn-sm btn-light" role="button" data-bs-placement="top" data-bs-toggle="popover" data-bs-trigger="focus" title="Calendar Legend" data-bs-html="true" data-bs-content="<cfoutput>#variables.legendContent#</cfoutput>"><i class="fa-regular fa-circle-question"></i> Legend</a>
    </div>
    <!--- /Legend --->
</div>  
<script src="/assets/plugins/responsive-calendar/0.9/js/jquery.js"></script>
<script src="/assets/plugins/responsive-calendar/0.9/js/bootstrap.min.js"></script>
<script src="/assets/plugins/responsive-calendar/0.9/js/responsive-calendar.js"></script>
<script type="text/javascript">
    $(document).ready(function () {
      $(".responsive-calendar").responsiveCalendar({
        time: '<cfoutput>#DateFormat(now(),"yyyy-mm")#</cfoutput>',
        events: {
          //"2022-12-30": {"number": 5, "url": "http://w3widgets.com/responsive-slider"}
            <cfoutput query="getMatches">
                <cfif getMatches.playerCount GT 0>"#DateFormat(getMatches.match_date,"yyyy-mm-dd")#": {"number": #getMatches.playerCount#<cfif getMatches.isPlaying>, "playing":true</cfif><cfif getMatches.teamCount GT 0>, "teamsGenerated":true</cfif>}<cfif getMatches.recordcount GT getMatches.currentrow OR getCalendarBlocks.recordcount GT 0>,</cfif></cfif>
            </cfoutput>
            <cfif getCalendarBlocks.recordcount GT 0>
                <cfoutput query="getCalendarBlocks">
                "#DateFormat(getCalendarBlocks.nomatch_date,"yyyy-mm-dd")#": {"blocked":true}<cfif getCalendarBlocks.recordcount GT getCalendarBlocks.currentrow>,</cfif>
                </cfoutput>
            </cfif>
        },
        onDayClick: function(events) { 
            //if clicked day is today, in future, or was selected in the past, allow it to be viewed
            if($(this).closest(".day").is('.future, .today, .active')){
                $('#basicModal .modal-content').load('modal/MatchDate.cfm?gid=' + <cfoutput>#url.gid#</cfoutput> + '&date=' + $(this).data('year') + '-' + $(this).data('month') + '-' + $(this).data('day'));
                $('#basicModal').modal('show');
            }
        }
      });

        var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
        var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
          return new bootstrap.Popover(popoverTriggerEl)
        })



    });

    <cfif IsDefined("url.status") and url.status neq "newGroup">
        $(".alert-calendar-status").fadeTo(2500, 500).fadeOut(500, function(){
            //$(".alert-calendar-status").slideUp(500);
        });
    </cfif>
</script>

 <!-- Modal -->
<div class="modal fade" id="basicModal" tabindex="-1" role="dialog" aria-labelledby="basicModal" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
        </div> <!-- /.modal-content -->
    </div> <!-- /.modal-dialog -->
</div> <!-- /.modal -->

<cfinclude template="/footer.cfm">