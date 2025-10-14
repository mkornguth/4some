<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4" crossorigin="anonymous"></script>

<cfif isDefined("form.password")>
	<cfif form.password eq "Teams31!">
		<cfcookie name="teamsAdmin" value="true">
		<cflocation url="index.cfm">
	<cfelse>
		<cflocation url="login.cfm?status=incorrectPassword">
	</cfif>
<cfelse>
	<div class="container"> 
		<form action="login.cfm" method="post">
			<div class="row">
				<div class="col-3 mb-3">
				  <label for="password" class="form-label">Password</label>
				  <input type="password" class="form-control" id="password" name="password">
				  
				</div>
			</div>
			<div class="row">
				<div class="col-3 mb-3">
					<input type="submit" class="btn btn-primary">
				</div>
			</div>
		</form>
	</div>
</cfif>