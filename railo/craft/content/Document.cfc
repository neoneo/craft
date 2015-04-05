component implements = Content accessors = true {

	property LayoutContent layout setter = false;
	property Struct sections setter = false;

	this.sections = {}

	public void function init(required LayoutContent layout) {
		this.layout = arguments.layout
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitDocument(this)
	}

	public Boolean function fillPlaceholder(required String ref, required Section section) {

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
			return true;
		}

		return false;
	}

	/**
	 * Removes the `Section` that fills the placeholder with the given ref.
	 */
	public Boolean function clearPlaceholder(required String ref) {
		return this.sections.delete(arguments.ref, true);
	}

	/**
	 * Replaces the current layout with the given layout.
	 * Content in placeholders is retained, if the placeholders in the new layout have the same ref.
	 */
	public void function replaceLayout(required LayoutContent layout) {

		// Check if the new layout has placeholders compatible with the old one.
		var newPlaceholders = arguments.layout.getPlaceholders()
		// Loop over all current placeholders, and remove the section if there is no compatible new placeholder.
		for (var placeholder in this.layout.getPlaceholders()) {
			var ref = placeholder.ref
			var index = newPlaceholders.find(function (newPlaceholder) {
				return arguments.newPlaceholder.ref == ref;
			})
			if (index == 0) {
				// The placeholder is not used. Remove the section.
				this.clearPlaceholder(ref)
			}
		}

		this.layout = arguments.layout

	}

}