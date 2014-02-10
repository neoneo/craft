/**
 * Lets a document take the role of a template. The placeholders in the template it wraps can be replaced by fixed content, and
 * other placeholders can be inserted. The effect is that a sparse template can be extended without losing the template function.
 */
component extends="Document" implements="TemplateContent" {

	/**
	 * Returns an array containing all placeholders that are not filled.
	 */
	public Placeholder[] function placeholders() {

		var placeholders = []
		var sections = sections()
		// Get the placeholders from the parent template. Keep the ones that aren't used and add any new ones.
		template().placeholders().each(function (placeholder) {
			var ref = arguments.placeholder.ref()
			if (!sections.keyExists(ref)) {
				// Unused placeholder.
				placeholders.append(arguments.placeholder)
			} else {
				// Get the placeholders that are descendants of this section.
				placeholders.append(sections[ref].placeholders(), true)
			}
		})

		return placeholders
	}

}