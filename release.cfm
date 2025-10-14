<cfset redirectUnauth = false>
<cfinclude template="/header.cfm">
<style>
	section {margin-top:30px;}
</style>

<h1>Release Notes</h1>
<section>
	<h4>February 18th, 2025</h4>
	<ul>
		<li>Email addresses added for administration (admin@teams.golf) and support (support@teams.golf).</li>
		<li>Menu items for missing functionality removed.</li>
		<li>Terms of service, website privacy, and contact pages added.</li>
	</ul>
</section>
<section>
	<h4>February 15th, 2025</h4>
	<ul>
		<li>Group dministrators can now add and administrate more than one group.</li>
		<li>Groups can now be deleted (deletion only applies to the group ... group members are not deleted from the system).</li>
		<li>New site logo added.</li>
		<li>Group invitation bug fixed for players in multiple groups.</li>
	</ul>
</section>
<section>
	<h4>February 8th, 2025</h4>
	<ul>
		<li>Placeholder bug fixed.</li>
	</ul>
</section>
<section>
	<h4>January 15th, 2025</h4>
	<ul>
		<li>Team generation process now asks whether to create alternates (fewer teams) or placeholders (more teams) when the number of teams does not break perfectly into foursomes.</li>
		<li>Manual team creation option added.</li>
		<li>Manul drag and drop team modification added.</li>
	</ul>
</section>
<section>
	<h4>July 23rd, 2024</h4>
	<ul>
		<li>New team generation algorithms added.</li>
		<li>Match results tracking added.</li>
		<li>Minor UI fixes.</li>
	</ul>
</section>
<section>
	<h4>June 12th, 2024</h4>
	<ul>
		<li>Support for guests added.</li>
		<li>Algorithm modification to prevent team captains having the same players in subsequent matches.</li>
		<li>Handicap index trend added.</li>
		<li>Support for multiple group administrators.</li>
	</ul>
</section>
<section>
	<h4>April 4th, 2024</h4>
	<ul><li>Initial product release.</li></ul>
</section>

<cfinclude template="/footer.cfm">