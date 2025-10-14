<cfquery datasource="#variables.dsn#" name="insertError">
		insert into 4some.errors (type, message, template, ip<cfif isDefined("variables.GolferId")>, player_id</cfif>,error_sql)
			values ('a','b', 'c', 'd'<cfif isDefined("variables.GolferId")>, #variables.GolferId#</cfif>, 'test')
	</cfquery>