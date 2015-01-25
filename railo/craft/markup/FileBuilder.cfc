component {

	public void function init(required TagRegistry tagRegistry, Scope scope) {
		this.scope = arguments.scope ?: new Scope()
		this.elementBuilder = new ElementBuilder(arguments.tagRegistry, this.scope)
	}

	/**
	 * Builds the xml file at the given path. The resulting `Element` is stored in the `Scope`, and is available
	 * as a dependency for subsequent calls.
	 */
	public Element function build(required String path) {

		var document = XMLParse(FileRead(arguments.path))
		var element = this.elementBuilder.build(document)

		if (!element.ready) {
			// The element builder only returns if all child elements are ready, so it can only be this element that's not ready.
			Throw("Could not construct element", "InstantiationException", "The element has an undefined dependency.");
		}

		this.scope.put(element)

		return element;
	}

}