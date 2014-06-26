component {

	public void function init(required ElementFactory factory) {
		variables._scope = new Scope()
		variables._documentBuilder = new DocumentBuilder(arguments.factory, variables._scope)
	}

	public Element function build(required String path) {

		var document = XMLParse(FileRead(arguments.path))
		var element = variables._documentBuilder.build(document)

		// If the element depends on another element, we cannot resolve that.
		if (!element.ready()) {
			Throw("Could not construct element", "InstantiationException", "If the element depends on other elements, use DirectoryBuilder.")
		}

		return element
	}

}