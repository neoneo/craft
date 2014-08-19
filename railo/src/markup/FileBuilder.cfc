component {

	public void function init(required ElementFactory factory, Scope scope) {
		variables._factory = arguments.factory
		variables._scope = arguments.scope ?: new Scope()
	}

	public Element function build(required String path) {

		var elementBuilder = new ElementBuilder(variables._factory, variables._scope)

		var document = XMLParse(FileRead(arguments.path))
		var element = elementBuilder.build(document)

		// If the element depends on another element, we cannot resolve that.
		if (!element.ready()) {
			Throw("Could not construct element", "InstantiationException", "If the element depends on other elements, use DirectoryBuilder.")
		}

		variables._scope.put(element)

		return element
	}

}