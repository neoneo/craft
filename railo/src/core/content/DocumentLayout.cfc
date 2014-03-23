/**
 * Lets a document take the role of a layout. The placeholders in the layout it wraps can be replaced by fixed content, and
 * other placeholders can be inserted. The effect is that a sparse layout can be extended without losing the layout function.
 */
component extends="Document" implements="LayoutContent" {

	/**
	 * Returns an array containing all placeholders that are not filled.
	 */
	public Placeholder[] function placeholders() {

		var placeholders = []
		var sections = sections()
		// Get the placeholders from the parent layout. Keep the ones that aren't used and add any new ones.
		layout().placeholders().each(function (placeholder) {
			var ref = arguments.placeholder.ref()
			if (!sections.keyExists(ref)) {
				// Unused placeholder.
				placeholders.append(arguments.placeholder)
			} else {
				// Get the placeholders that are descendants of this section.
				placeholders.append(sections[ref].placeholders(), true) // Concatenate the descendants array.
			}
		})

		return placeholders
	}

}