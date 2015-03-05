/**
 * Lets a document take the role of a layout. The placeholders in the layout it wraps can be replaced by fixed content, and
 * other placeholders can be inserted. The effect is that a sparse layout can be extended without losing the layout function.
 */
component extends = Document implements = LayoutContent accessors = true {

	property Array placeholders setter = false; // Placeholder[]

	/**
	 * Returns an array containing all placeholders that are not filled.
	 */
	public Placeholder[] function getPlaceholders() {

		var placeholders = []
		// Get the placeholders from the parent layout. Keep the ones that aren't used and add any new ones.
		// FIXME: for some reason, can't call getPlaceholders() using implicit notation if layout is a DocumentLayout too.
		this.layout.getPlaceholders().each(function (placeholder) {
			var ref = arguments.placeholder.ref
			if (!this.sections.keyExists(ref)) {
				// Unused placeholder.
				placeholders.append(arguments.placeholder)
			} else {
				// Get the placeholders that are descendants of this section.
				placeholders.append(this.sections[ref].placeholders, true) // Concatenate the descendants array.
			}
		})

		return placeholders;
	}

}