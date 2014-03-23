component implements="Content" {

	variables._sections = {}

	public void function init(required LayoutContent layout) {
		variables._layout = arguments.layout
	}

	public LayoutContent function layout() {
		return variables._layout
	}

	public Struct function sections() {
		return variables._sections
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitDocument(this)
	}

	public void function addSection(required Section section, required String ref) {

		var ref = arguments.ref

		var placeholders = variables._layout.placeholders()
		if (placeholders.find(function (placeholder) {
			return arguments.placeholder.ref() == ref
		}) == 0) {
			Throw("Layout has no placeholder with ref '#ref#'", "NoSuchElementException")
		}

		if (!variables._sections.keyExists(ref)) {
			variables._sections[ref] = arguments.section
		}

	}

	/**
	 * Removes the `Section` that fills the placeholder with the given ref.
	 */
	public void function removeSection(required String ref) {
		variables._sections.delete(arguments.ref)
	}

	/**
	 * Replaces the current layout with the given layout.
	 * Content in placeholders is retained, if the placeholders in the new layout have the same ref.
	 */
	public void function useLayout(required LayoutContent layout) {

		// Check if the new layout has placeholders compatible with the old one.
		var newPlaceholders = arguments.layout.placeholders()
		// Loop over all current placeholders, and remove the section if there is no compatible new placeholder.
		variables._layout.placeholders().each(
			function (placeholder) {
				var ref = arguments.placeholder.ref()
				var index = newPlaceholders.find(function (newPlaceholder) {
					return arguments.newPlaceholder.ref() == ref
				})
				if (index == 0) {
					// The placeholder is not used. Remove the section.
					removeSection(ref)
				}
			}
		)

		variables._layout = arguments.layout

	}

}