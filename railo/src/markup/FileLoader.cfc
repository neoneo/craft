component {

	public void function init(required ElementFactory factory, required Scope scope) {
		variables._factory = arguments.factory
		variables._scope = arguments.scope
		variables._builder = new Builder()
	}

	public Element function load(required String path) {

		var node = XMLParse(FileRead(arguments.path)).xmlRoot
		var element = variables._factory.convert(node)
		variables._builder.build(element, variables._scope)

		variables._scope.store(element)

		return element
	}

}