import craft.core.request.Context

component extends="DocumentFoundation" {

	public String function render(required Context context) {

		var output = super.render(arguments.context)
		// remove the placeholders for unused regions
		for (var region in getRegions()) {
			output = Replace(output, region.getPlaceholder().getInsert(), "")
		}

		return output
	}

	public void function replaceTemplate(required TemplateContent template) {

		// check if the new template has placeholders compatible with the old one
		var newPlaceholders = arguments.template.getPlaceholders()
		// loop over all current regions, and remove the content if there is no compatible new region
		getTemplate.getPlaceholders().each(
			function (placeholder) {
				var placeholder = arguments.placeholder
				var index = newPlaceholders.find(function (newPlaceholder) {
					return arguments.newPlaceholder.getRef() == placeholder.getRef()
				})
				if (index == 0) {
					// remove the content
					removeRegion(arguments.placeholder)
				}
			}
		)

		setTemplate(arguments.template)

	}

}