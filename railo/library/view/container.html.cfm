<cfset properties = "">
<cfif not IsNull(id)>
	<cfset properties = " id=" & Chr(34) & id & Chr(34)>
</cfif>
<cfif not IsNull(classes)>
	<cfset properties &= " class=" & Chr(34) & classes & Chr(34)>
</cfif>
<cfoutput>
	<div#properties#>
		#children#
	</div>
</cfoutput>