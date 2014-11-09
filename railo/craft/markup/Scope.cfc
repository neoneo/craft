component {

	public void function init(Scope parent) {
		this.parent = arguments.parent ?: null
		this.elements = {}
	}

	public Boolean function has(required String ref) {
		return this.elements.keyExists(arguments.ref) || this.parent !== null && this.parent.has(arguments.ref);
	}

	public Element function get(required String ref) {

		if (!this.has(arguments.ref)) {
			Throw("Element '#arguments.ref#' not found", "NoSuchElementException");
		}

		// The element exists, so if it does not exist in this scope, we know there is a parent that has it.
		return this.elements.keyExists(arguments.ref) ? this.elements[arguments.ref] : this.parent.get(arguments.ref);
	}

	public void function put(required Element element) {
		var ref = arguments.element.ref
		if (ref !== null) {
			if (has(ref)) {
				Throw("Element '#ref#' already exists", "AlreadyBoundException")
			}
			this.elements[ref] = arguments.element
		}
	}

}