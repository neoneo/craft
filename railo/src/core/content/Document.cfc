component implements="Content" accessors="true" {

	property TemplateContent template;

	variables.sections = {}

	public Struct function getSections() {
		return variables.sections
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
	public void function setTemplate(required TemplateContent template) {

		var currentTemplate = getTemplate()
		if (!IsNull(currentTemplate)) {
			// Check if the new template has placeholders compatible with the old one.
			var newPlaceholders = arguments.template.getPlaceholders()
			// Loop over all current placeholders, and remove the section if there is no compatible new placeholder.
			currentTemplate.getPlaceholders().each(
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
		}

		variables.template = arguments.template
	}

}