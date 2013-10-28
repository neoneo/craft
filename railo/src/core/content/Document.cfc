component implements="Content" accessors="true" {

	property TemplateContent template setter="false";
	property Struct sections setter="false";

	public void function init(required TemplateContent template) {
		variables.template = arguments.template
		variables.sections = {}
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitDocument(this)
	}

	public void function addSection(required Section section, required Placeholder placeholder) {

		var ref = arguments.placeholder.getRef()

		var placeholders = getTemplate().getPlaceholders()
		if (placeholders.find(function (placeholder) {
			return arguments.placeholder.getRef() == ref
		}) == 0) {
			Throw("Template has no placeholder with ref '#ref#'", "NoSuchElementException")
		}

		var sections = getSections()
		if (!sections.keyExists(ref)) {
			sections[ref] = arguments.section
		}

	}

	/**
	 * Removes the `Section` that fills the given `Placeholder`.
	 */
	public void function removeSection(required Placeholder placeholder) {
		getSections().delete(arguments.placeholder.getRef())
	}

	/**
	 * Replaces the current template with the given template.
	 * Content in placeholders is retained, if the placeholders in the new template have the same ref.
	 */
	public void function useTemplate(required TemplateContent template) {

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
					// The placeholder is not used. Remove the section.
					removeSection(placeholder)
				}
			}
		)

		variables.template = arguments.template
	}

}