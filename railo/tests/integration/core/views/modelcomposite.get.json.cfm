<cfoutput>
	{
		"component": #SerializeJSON(component)#,
		"depth": #depth#,
		"constant": #SerializeJSON(constant)#,
		"content": [#__content__#]
	}
</cfoutput>