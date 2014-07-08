component {

	public void function init(required ElementFactory factory, Scope scope) {
		variables._scope = arguments.scope ?: new Scope()
		variables._elementBuilder = new ElementBuilder(arguments.factory, variables._scope)
	}

	public Element function build(required String path) {

		var document = XMLParse(FileRead(arguments.path))
		var element = variables._elementBuilder.build(document)

		// If the element depends on another element, we cannot resolve that.
		if (!element.ready()) {
			Throw("Could not construct element", "InstantiationException", "If the element depends on other elements, use DirectoryBuilder.")
		}

		variables._scope.put(element)

		return element
	}

}