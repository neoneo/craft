component {

	public void function init(required ElementFactory factory, required Repository repository) {
		variables._factory = arguments.factory
		variables._repository = arguments.repository
	}

	public Struct function load(required String path) {

		var contents = {}

		DirectoryList(arguments.path, false, "path", "*.xml").each(function (path) {
			// Create a new ElementLoader for each file, because we don't want separate files to be able to refer to one another.
			var loader = new ElementLoader(variables._factory, variables._repository)
			var element = loader.load(arguments.path)
			contents[arguments.path] = element
			variables._repository.store(element)
		})

		return contents
	}

}