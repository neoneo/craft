/**
 * Lets a document take the role of a template. The placeholders in the template it wraps can be replaced by fixed content, and other placeholders can be inserted. The effect is that a sparse template
 * can be extended without losing the template function.
 */
component extends="Document" implements="TemplateContent" {

	/**
	 * Returns an array containing all placeholders that are not filled.
	 **/
	public Array function getPlaceholders() {

		var placeholders = []
		var sections = getSections()
		// Get the placeholders from the parent template. Keep the ones that aren't used and add any new ones.
		getTemplate().getPlaceholders().each(function (placeholder) {
			var ref = arguments.placeholder.getRef()
			if (!sections.keyExists(ref)) {
				// Unused placeholder.
				placeholders.append(arguments.placeholder)
			} else {
				// Get the placeholders that are descendants of this section.
				placeholders.append(sections[ref].getPlaceholders(), true)
			}
		})

		return placeholders
	}

}