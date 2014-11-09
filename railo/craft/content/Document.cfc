component implements="Content" {

	property LayoutContent layout setter="false";
	property Struct sections setter="false";

	this.sections = {}

	public void function init(required LayoutContent layout) {
		this.layout = arguments.layout
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitDocument(this)
	}

	public void function addSection(required Section section, required String ref) {

		var ref = arguments.ref

		var placeholders = this.layout.getPlaceholders()
		if (placeholders.find(
			function (placeholder) {
				return arguments.placeholder.ref == ref;
			}
		) == 0) {
			Throw("Layout has no placeholder with ref '#ref#'", "NoSuchElementException");
		}

		if (!this.sections.keyExists(ref)) {
			this.sections[ref] = arguments.section
		}

	}

	/**
	 * Removes the `Section` that fills the placeholder with the given ref.
	 */
	public void function removeSection(required String ref) {
		this.sections.delete(arguments.ref)
	}

	/**
	 * Replaces the current layout with the given layout.
	 * Content in placeholders is retained, if the placeholders in the new layout have the same ref.
	 */
	public void function useLayout(required LayoutContent layout) {

		// Check if the new layout has placeholders compatible with the old one.
		var newPlaceholders = arguments.layout.getPlaceholders()
		// Loop over all current placeholders, and remove the section if there is no compatible new placeholder.
		this.layout.getPlaceholders().each(
			function (placeholder) {
				var ref = arguments.placeholder.ref
				var index = newPlaceholders.find(function (newPlaceholder) {
					return arguments.newPlaceholder.ref == ref;
				})
				if (index == 0) {
					// The placeholder is not used. Remove the section.
					removeSection(ref)
				}
			}
		)

		this.layout = arguments.layout

	}

}