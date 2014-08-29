component {

	public void function init(required ElementFactory factory, Scope scope) {
		this.factory = arguments.factory
		this.scope = arguments.scope ?: new Scope()
	}

	public Element function build(required String path) {

		var elementBuilder = new ElementBuilder(this.factory, this.scope)

		var document = XMLParse(FileRead(arguments.path))
		var element = elementBuilder.build(document)

		// If the element depends on another element, we cannot resolve that.
		if (!element.ready) {
			Throw("Could not construct element", "InstantiationException", "If the element depends on other elements, use DirectoryBuilder.");
		}

		this.scope.put(element)

		return element;
	}

}