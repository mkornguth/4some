		<!--- set team count variable and declare arrays --->
		<cfset golferCount = getMatch.recordCount + getGuests.recordcount>
		<cfif golferCount GT 4>
			<cfset teamCount = Floor(golferCount / 4)>
		<cfelse>
			<cfset teamCount = Ceiling(golferCount / 4)>
		</cfif>
		<cfset arrGolfersBySignup = arrayNew(1)>
		<cfset arrAlternates = arrayNew(1)>

		<!--- Group Members --->
		<cfoutput query="getMatch" startrow="1" maxrows="#teamCount * 4#">
			<cfset strGolferData = structNew()>
			<cfset strGolferData.Id = getMatch.player_id>
			<cfset strGolferData.Name = getMatch.first_name & " " & getMatch.last_name>
			<cfset strGolferData.Handicap = getMatch.handicap_current>
			<cfset strGolferData.SignUpDate = getMatch.signup_date>
			<cfset strGolferData.GolferType = 'member'>

			<cfset temp = arrayAppend(arrGolfersBySignup, strGolferData)>
		</cfoutput>

		<!--- Group Guests --->
		<cfoutput query="getGuests" startrow="1" maxrows="#teamCount * 4#">
			<cfset strGolferData = structNew()>
			<cfif getGuests.guest_type eq 'registered'>
				<cfset strGolferData.Id = getGuests.player_id>
			<cfelse>
				<cfset strGolferData.Id = getGuests.guest_id>
				<cfset strGolferData.IsHandcuffed = getGuests.is_handcuffed>
				<cfset strGolferData.HandcuffedPlayerId = getGuests.player_id_handcuff>
			</cfif>
			<cfset strGolferData.Name = getGuests.first_name & " " & getGuests.last_name>
			<cfset strGolferData.Handicap = getGuests.handicap_to_use>
			<cfset strGolferData.SignUpDate = getGuests.signup_date>
			<cfset strGolferData.GolferType = getGuests.guest_type>

			<cfset temp = arrayAppend(arrGolfersBySignup, strGolferData)>
		</cfoutput>

		<!--- Sort by handicap --->
		<cfset arrGolfersByHandicap = ArrayOfStructSort(arrGolfersBySignup, "numeric", "asc", "Handicap")>


		<cfoutput query="getMatch" startrow="#(teamCount * 4) + 1#">
			<cfset temp = arrayAppend(arrAlternates, getMatch.player_id)>
		</cfoutput>