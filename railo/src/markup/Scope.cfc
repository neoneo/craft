component {

	public void function init(Scope parent) {
		variables._parent = arguments.parent ?: null
		variables._elements = {}
	}

	public Boolean function has(required String ref) {
		return variables._elements.keyExists(arguments.ref) || variables._parent !== null && variables._parent.has(arguments.ref)
	}

	public Element function get(required String ref) {

		if (!has(arguments.ref)) {
			Throw("Element '#arguments.ref#' not found", "NoSuchElementException")
		}

		// The element exists, so if it does not exist in this scope, we know there is a parent that has it.
		return variables._elements.keyExists(arguments.ref) ? variables._elements[arguments.ref] : variables._parent.get(arguments.ref)
	}

	public void function put(required Element element) {
		var ref = arguments.element.getRef()
		if (ref !== null) {
			if (has(ref)) {
				Throw("Element '#ref#' already exists", "AlreadyBoundException")
			}
			variables._elements[ref] = arguments.element
		}
	}

}