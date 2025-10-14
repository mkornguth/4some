<cfparam name="navSelected" default="">

<style>
  .authentication {margin-top:30px;}
</style>

<cfparam name="showRegisterLink" default="false">

<nav class="navbar navbar-expand-lg bg-body-tertiary">
  <div class="container-fluid">
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNavDropdown">
      <ul class="navbar-nav">
        <li class="nav-item">
          <a class="nav-link <cfif navSelected eq "groups">active</cfif>"  href="/groups/">Groups</a>
        </li>
        <li class="nav-item">
          <a class="nav-link <cfif navSelected eq "calendar">active</cfif>" href="/calendar/">Calendar</a>
        </li>

        <cfif IsDefined("variables.username") and variables.username neq "" and cgi.script_name neq "/logout.cfm">  
          <li class="nav-item dropdown">
            <cfset variables.usernameCharactersAllowed = 15>
            <cfset variables.fullName = variables.firstName & " " & variables.lastName>
              
              <div class="authentication logged-in text-center">
                <a class="btn btn-primary btn-sm dropdown-toggle" href="#" id="usernameDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                  <i class="fas fa-user"></i> <span><cfoutput><cfif Len(variables.fullName) gt variables.usernameCharactersAllowed>#left(variables.fullName,variables.usernameCharactersAllowed)#...<cfelse>#variables.fullName#</cfif></cfoutput></span>
                </a>
                 <ul class="dropdown-menu">
                  <li><a class="dropdown-item" href="#">Edit Profile</a></li>
                  <li><a class="dropdown-item" href="/logout.cfm">Logout</a></li>
                </ul>
              </div>
            
          </li>
        <cfelse>
          <li class="nav-item">
            <a class="nav-link <cfif navSelected eq "login">active</cfif>" href="/login.cfm">Login</a>
          </li>
        </cfif> 
      </ul>
    </div>
  </div>
</nav>
