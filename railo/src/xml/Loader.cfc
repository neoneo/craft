component {

	public void function init(required ElementFactory factory, Loader parent) {
		variables._factory = arguments.factory
		variables._parent = arguments.parent ?: null
		variables._elements = {}
	}

	public Boolean function hasElement(required String ref) {
		return variables._elements.keyExists(arguments.ref) || !IsNull(variables._parent) && variables._parent.hasElement(arguments.ref)
	}

	public Element function element(required String ref) {

		if (!hasElement(arguments.ref)) {
			Throw("Element '#arguments.ref#' not found", "NoSuchElementException")
		}

		// The element exists, so if it does not exist in this loader, we know there is a parent that has it.
		return variables._elements.keyExists(arguments.ref) ? variables._elements[arguments.ref] : variables._parent.element(arguments.ref)
	}

	private ElementFactory function factory() {
		return variables._factory
	}

	private void function keep(required Element element) {
		if (!IsNull(arguments.element.getRef())) {
			variables._elements[arguments.element.getRef()] = arguments.element
		}
	}

	/**
	 * Reads one or more XML files located at the given path, and builds the corresponding `Content` instance.
	 * Each key of the returned struct is a path to an XML file, the value is the associated `Content` instance.
	 */
	public Struct function load(required String path) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NoSuchMethodException")
	}

}