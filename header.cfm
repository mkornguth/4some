<cfparam name="redirectUnauth" default="true">
<cfparam name="navSelected" default="">
<cfset variables.hasGroups = false>

<cfif IsDefined("cookie.GolferData")>
	<cfset variables.player_id = ListGetAt(cookie.GolferData, 1)>
	<cfset variables.username = ListGetAt(cookie.GolferData, 2)>
	<cfset variables.firstName = ListGetAt(cookie.GolferData, 3)>
	<cfset variables.lastName = ListGetAt(cookie.GolferData, 4)>
	<cfif IsDefined("cookie.GolferGroups") and LEN(cookie.golferGroups) GT 0>
		<cfset variables.hasGroups = true>
	</cfif>
	<cfset variables.isAuthenticated = true>
<cfelseif redirectUnauth>
	<cflocation url="/login.cfm">
	<cfset variables.isAuthenticated = false>
</cfif>

<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<Cfoutput>
			<meta name="viewport" content="width=device-width, initial-scale=1,viewport-fit=cover">
			<meta name="robots" content="index,follow" />
			<meta name="author" content="">
			<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon">
			<link rel="icon" href="/favicon.ico" type="image/x-icon">
			
			<title>Teams.Golf - Golf Team Generator</title>
		</cfoutput>
		
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4" crossorigin="anonymous"></script>
		
		<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
		<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
		
		<!--- Replaced with jquery above on 2015.01.14, in the event something breaks --->
		<!--- <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script> --->
		
		<!-- Custom styles for this template -->
		<link href="/assets/css/main.css?r=3" rel="stylesheet">
		
		<!-- Resources -->
		<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.11.2/css/all.min.css">
		<link href='https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700|Ubuntu:300,400,500,700' rel='stylesheet' type='text/css'>
		<link href="https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700%7CRoboto%7CJosefin+Sans:100,300,400,500" rel="stylesheet" type="text/css">
		
		<!--- Fontawesome --->
		<link href="/assets/fontawesome/css/all.min.css" rel="stylesheet">
		
		<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
		<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
		<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
		<link rel="manifest" href="/manifest.json?v=2025-11-07">
		<script>
			if ("serviceWorker" in navigator) {
				navigator.serviceWorker.register("/service-worker.js")
				.then((reg) => console.log("SW registered", reg))
				.catch((err) => console.error("SW registration failed", err));
			}
		</script>
		<style>	
			
			
			.authentication {margin-left:30px;}
			
			
			<cfset variables.brandingClass = "branding-standard">
			<cfset variables.headerImageWidth = "300">
			<cfset variables.headerImageHeight = "75">
			<cfset variables.headerHref = "/">
			<cfset variables.headerBgColor = "262626">
			<cfset variables.headerTextColor = "000000">
			<cfset variables.headerMenuButtonBgColor = "ffffff">
			<cfset variables.headerMenuButtonBorderColor = "ffffff">
			<cfset variables.usernameCharactersAllowed = 15>
			
			
			<cfoutput>
				@media (min-width:992px) {
					.branding-custom.navbar-default {background-color: ###variables.headerBgColor# !important}
					.branding-custom.navbar-default .navbar-nav>li>a:focus, .branding-custom.navbar-default .navbar-nav>li>a:hover,.branding-custom.navbar-default .navbar-nav > li > a {color:###variables.headerTextColor#;}
				}
				@media (max-width:992px) {
					.branding-custom .navbar-header {background-color: ###variables.headerBgColor# !important}
					##tom {height:75%; width:75%;}
				}
				
				@media (max-width: 550px) {
					.navbar > .container .navbar-brand {min-height:50px;;}
					.menu-container {padding-top:3px;}
					##logoRight {display:none;}
					.navbar-brand {width:250px;}
					##logo {width:90%; height:90%;}
					##tom {display:none;}
				}
				
				.navbar-default .navbar-toggle {border-color:##bbb;background-color:##262626}
				##leagueName {color:###variables.headerTextColor# !important;}
				
			</cfoutput>
			
		</style>
	</head>
	<body>
		
		
		
		<div class="container"> 
			<nav class="navbar navbar-expand-lg bg-body-tertiary navbar-dark">
				<div class="container-fluid">
					<cfoutput><a class="navbar-brand" href="#variables.headerHref#"><img src="/assets/img/brand.png" height="75" id="logo"></a></cfoutput>
					
					<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
						<span class="navbar-toggler-icon"></span>
					</button>
					<div class="collapse navbar-collapse" id="navbarSupportedContent">
						<ul class="navbar-nav ms-auto mb-2 mb-lg-0">
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
												<li><a class="dropdown-item" href="#" id="myAccount">My Account</a></li>
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
			</div>
			
			<!-- Modal -->
			<div class="modal fade" id="basicModal" tabindex="-1" role="dialog" aria-labelledby="basicModal" aria-hidden="true">
				<div class="modal-dialog">
					<div class="modal-content">
					</div> <!-- /.modal-content -->
				</div> <!-- /.modal-dialog -->
			</div> <!-- /.modal -->
			
			<script>
				$( "#myAccount" ).click(function() {
					$('#basicModal .modal-content').load('/account/modal/myAccount.cfm');
					$('#basicModal').modal('show');
				});
			</script>
			
			<div class="wrapper" <cfif NOT cgi.script_name eq "/index.cfm">id="wrapperMain"</cfif>>
				<cfif NOT cgi.script_name eq "/index.cfm">
					<div class="container">
					</cfif>
					
					
					
