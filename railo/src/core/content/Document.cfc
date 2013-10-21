component extends="DocumentFoundation" {

	public void function replaceTemplate(required TemplateContent template) {

		// Check if the new template has placeholders compatible with the old one.
		var newPlaceholders = arguments.template.getPlaceholders()
		// Loop over all current placeholders, and remove the section if there is no compatible new placeholder.
		getTemplate().getPlaceholders().each(
			function (placeholder) {
				var placeholder = arguments.placeholder
				var index = newPlaceholders.find(function (newPlaceholder) {
					return arguments.newPlaceholder.getRef() == placeholder.getRef()
				})
				if (index == 0) {
					// The placeholder is not used. Remove the sectopm.
					removeSection(placeholder)
				}
			}
		)

		setTemplate(arguments.template)

	}

}