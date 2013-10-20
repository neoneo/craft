component extends="DocumentFoundation" {

	public void function replaceTemplate(required TemplateContent template) {

		// check if the new template has placeholders compatible with the old one
		var newPlaceholders = arguments.template.getPlaceholders()
		// loop over all current placeholders, and remove the content if there is no compatible new placeholder
		getTemplate().getPlaceholders().each(
			function (placeholder) {
				var placeholder = arguments.placeholder
				var index = newPlaceholders.find(function (newPlaceholder) {
					return arguments.newPlaceholder.getRef() == placeholder.getRef()
				})
				if (index == 0) {
					// remove the content
					removeSection(placeholder)
				}
			}
		)

		setTemplate(arguments.template)

	}

}