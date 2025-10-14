<cfparam name="redirectUnauth" default="true">
<cfset variables.hasGroups = false>

<cfif IsDefined("cookie.GolferData")>
	<cfset variables.player_id = ListGetAt(cookie.GolferData, 1)>
	<cfset variables.username = ListGetAt(cookie.GolferData, 2)>
  <cfif IsDefined("cookie.GolferGroups") and LEN(cookie.golferGroups) GT 0>
    <cfset variables.hasGroups = true>
  </cfif>
<cfelseif redirectUnauth>
	<cflocation url="/login.cfm">
</cfif>

<!doctype html>
<html lang="en" dir="ltr">
  <head>

    <title>4some Generator</title>
    <meta name="description" content="...">

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <!-- Theme -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Rubik:wght@300;400;500;700&display=swap">
    <link rel="stylesheet" href="/assets/css/main.css">
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="../favicon.ico">

    <!--- Bootstrap --->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4" crossorigin="anonymous"></script>
    <!--- <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css"> --->
  
    <!--- Fontawesome --->
    <link href="/assets/fontawesome/css/all.min.css" rel="stylesheet">
  </head>

  <body>


    <!-- Navbar -->
    <nav class="py-3 mb-5 navbar navbar-expand-lg navbar-light bg-white shadow navbar-autohide">

      <div class="container">

        <!-- brand / logo -->
        <a class="navbar-brand" href="/">
          <img src="/assets/img/foursome-silhouettes.png"> <span class="navbar-brand-title">Foursome Generator</span>
        </a>
       
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMainContent" aria-controls="navbarMainContent" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>
       
        <div class="collapse navbar-collapse" id="navbarMainContent">

          <!-- mobile close -->
          <div class="d-flex d-lg-none pb-3 justify-content-between align-items-center">
            <img src="/assets/img/foursome-silhouettes.png"> <span class="navbar-brand-title">4some Generator</span>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMainContent" aria-controls="navbarMainContent" aria-expanded="false" aria-label="Toggle navigation">
              <svg height="28px" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>

          <ul class="navbar-nav ms-auto">

           
            <cfif variables.hasGroups>
              <li class="nav-item">
              	<a class="nav-link px-3 dropdown-toggle" href="/calendar/" id="navbarCalendar">Calendar</a>
              </li>
            </cfif>

            <li class="nav-item dropdown">
            	<cfset variables.usernameCharactersAllowed = 15>
              <cfif IsDefined("variables.username") and variables.username neq "" and cgi.script_name neq "/logout.cfm">    
      					<div class="authentication logged-in text-center">
      					  <a class="btn btn-primary btn-sm dropdown-toggle" href="#" id="usernameDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
      					    <i class="fas fa-user"></i> <span><cfoutput><cfif Len(variables.username) gt variables.usernameCharactersAllowed>#left(variables.username,variables.usernameCharactersAllowed)#...<cfelse>#variables.username#</cfif></cfoutput></span>
      					  </a>
      					   <ul class="dropdown-menu">
      					    <li><a class="dropdown-item" href="#">Edit Profile</a></li>
      					    <li><a class="dropdown-item" href="/logout.cfm">Logout</a></li>
      					  </ul>
      					</div>
    				</cfif>
            </li>

          </ul>

        </div>

      </div>

    </nav>
    <!-- /Navbar -->
<div class="container">
