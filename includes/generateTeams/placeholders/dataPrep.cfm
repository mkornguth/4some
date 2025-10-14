		<cfset golferCount = getMatch.recordCount + getGuests.recordcount>

		<!--- with placeholders, team count will always be the ceiling --->
		<cfset teamCount = Ceiling(golferCount / 4)>

		<cfset arrGolfersBySignup = arrayNew(1)>
		<cfset arrAlternates = arrayNew(1)>

		<!--- Group Members --->
		<cfoutput query="getMatch">
			<cfset strGolferData = structNew()>
			<cfset strGolferData.Id = getMatch.player_id>
			<cfset strGolferData.Name = getMatch.first_name & " " & getMatch.last_name>
			<cfset strGolferData.Handicap = getMatch.handicap_current>
			<cfset strGolferData.SignUpDate = getMatch.signup_date>
			<cfset strGolferData.GolferType = 'member'>

			<cfset temp = arrayAppend(arrGolfersBySignup, strGolferData)>
		</cfoutput>

		<!--- Group Guests --->
		<cfoutput query="getGuests">
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
