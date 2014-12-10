component {

	public void function init(Scope parent) {
		this.parent = arguments.parent ?: null
		this.elements = {}
	}

	/**
	 * Returns if an `Element` with the given ref exists in this scope or the parent.
	 */
	public Boolean function has(required String ref) {
		return this.elements.keyExists(arguments.ref) || this.parent !== null && this.parent.has(arguments.ref);
	}

	/**
	 * Returns the `Element` with the given ref.
	 */
	public Element function get(required String ref) {

		if (this.elements.keyExists(arguments.ref)) {
			return this.elements[arguments.ref];
		} else if (this.parent !== null) {
			return this.parent.get(arguments.ref);
		}

		Throw("Element '#arguments.ref#' not found", "NoSuchElementException");
	}

	/**
	 * Stores the `Element`.
	 */
	public void function put(required Element element) {
		var ref = arguments.element.ref
		if (ref !== null) {
			// The ref may not exist in this scope or the parent scope, because the client might then get an unexpected element back.
			if (this.has(ref)) {
				Throw("Element '#ref#' already exists", "AlreadyBoundException")
			}
			this.elements[ref] = arguments.element
		}
	}

}