component {

	public void function init(required ElementFactory factory, required Repository repository) {
		variables._factory = arguments.factory
		variables._repository = arguments.repository
		variables._builder = new Builder()
	}

	public Element function load(required String path) {

		var node = XMLParse(FileRead(arguments.path)).xmlRoot
		var element = variables._factory.construct(node)
		variables._builder.build(element, variables._repository)

		variables._repository.store(element)

		return element
	}

}