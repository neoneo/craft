component {

	public void function init(Scope parent) {
		variables._parent = arguments.parent ?: NullValue()
		variables._elements = {}
	}

	public Boolean function hasElement(required String ref) {
		return variables._elements.keyExists(arguments.ref) || !IsNull(variables._parent) && variables._parent.hasElement(arguments.ref)
	}

	public Element function element(required String ref) {

		if (!hasElement(arguments.ref)) {
			Throw("Element '#arguments.ref#' not found", "NoSuchElementException")
		}

		// The element exists, so if it does not exist in this scope, we know there is a parent that has it.
		return variables._elements.keyExists(arguments.ref) ? variables._elements[arguments.ref] : variables._parent.element(arguments.ref)
	}

	public void function store(required Element element) {
		var ref = arguments.element.getRef()
		if (!IsNull(ref)) {
			if (hasElement(ref)) {
				Throw("Element '#ref#' already exists", "AlreadyBoundException")
			}
			variables._elements[ref] = arguments.element
		}
	}

}