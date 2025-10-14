<cfset adminAuthorized = false>
<cfif isDefined("cookie.teamsAdmin")>
	<cfset adminAuthorized = true>
</cfif>

<cfif NOT adminAuthorized>
	<cflocation url="login.cfm">
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
 <link rel="stylesheet" type="text/css" href="/assets/plugins/datatables/css/jquery.dataTables.min.css"/>   
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

	
	
  </head>
  <body>

	<div class="wrapper" <cfif NOT cgi.script_name eq "/index.cfm">id="wrapperMain"</cfif>>
	<cfif NOT cgi.script_name eq "/index.cfm">
		<div class="container">
	</cfif>