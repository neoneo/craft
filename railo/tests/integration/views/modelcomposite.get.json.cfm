<cfoutput>
	{
		"node": #SerializeJSON(node)#,
		"depth": #depth#,
		"constant": #SerializeJSON(constant)#,
		"content": [#__content__#]
	}
</cfoutput>