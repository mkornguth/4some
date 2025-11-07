<cfset redirectUnauth = false>
<cfinclude template="/header.cfm">
<style>
.banner {
    min-height: 100%;
    background: linear-gradient(0deg,rgba(222,222,222,0.7),rgba(222,222,222,0.7)),url(/assets/img/course1.jpg);
    background-position: 0px 0px;
    background-size: cover;
}
.benefit .head {
    position: relative;
    top: -5px;
    font-size: 18px;
    margin-left: 10px;
}

.benefit .text {
    margin-left: 40px;
    font-size: .9em;
    font-weight: normal;
}

.benefit {
    margin-bottom: 20px;
}




</style>

<div class="banner">
    <div class="container">
    	<div class="row text-center" style="min-height: 400px;">
    		<div class="col-md-5">
                <p><img src="/assets/img/tomSmall.jpg" class="rounded-circle" id="tom"></p>
            </div>
    		<div class="col-md-7 intro">
    			 <h1 style="font-weight:800;color:#333333;margin-top:25px;">Is your buddy, Tom, still creating your teams for the weekend?</h1>
    			<p style="color:#444444;font-weight:bold;">We provide golf group scheduling and team generation tools that do all the work for you.</p>
              
                    <ul style="color:#444444;text-align: left;">
                        <li>Group calendar allows golfers to easily join matches</li>
                        <li>Automated team generation creates equitable teams</li>
                        <li>Automated handicap updating</li>
                        <li>Allows for guests and alternates in your group</li>

                        <!--- <li>Flag unwanted partners to avoid playing with them</li> --->
                    </ul>
                    <cfif IsDefined("cookie.golferdata")>
                        <p class="text-center"><a href="/calendar/" class="btn btn-primary">View Group Calendar</a></p>
                    <cfelse>
                        <p class="text-center"><a href="/account/lookup.cfm" class="btn btn-primary">Create Your Account</a></p>
                    </cfif>
    		</div>
    	</div>
    </div>
</div>

</section>

<section class="benefits">
<div>
    <div class="container">
        <h2 class="caps" style="text-align:center;margin:30px 0 30px;">Benefits</h2>
        <div class="row">
            <div class="col-sm-6">
                <div class="benefit">
                    <span class="batch icon-48 far fa-check-circle fa-2x faa-tada"></span> <span class="head">Group calendar</span>
                    <div class="text">Forget those old methods of organizing your group. Your group members simply join the daily matches they want to play.</div>
                </div>
                <div class="benefit">
                    <span class="batch icon-48 far fa-check-circle fa-2x faa-tada"></span> <span class="head">Automated team generation</span>
                    <div class="text">Are you tired of hearing "Who made these teams?" Teams can be automatically generated based on several different match up algorithms. </div>
                </div>
                <div class="benefit">
                    <span class="batch icon-48 far fa-check-circle fa-2x faa-tada"></span> <span class="head">Automated handicap updating</span>
                    <div class="text">Let our system do the work of tracking your groups handicaps. As long as everyone is posting their scores (*cough cough*), we update everything automatically.</div>
                </div>
                <div class="benefit">
                    <span class="batch icon-48 far fa-check-circle fa-2x faa-tada"></span> <span class="head">Guests and alternates</span>
                    <div class="text">Even non-group members can be added to your teams. Guests can be included in the team generation process. If playing member counts don't make foursomes, alternates list will be automatically generated for you. </div>
                </div>
            </div><!-- /col-sm-6 -->
            <div class="col-sm-6">
                <img src="/assets/img/members.jpg" width="450px" class="img-rounded img-fluid">
            </div><!-- /col-sm-6 -->
            
        </div><!-- /row -->
    </div><!-- /container -->
</div>
</section>

<cfinclude template="/footer.cfm">
