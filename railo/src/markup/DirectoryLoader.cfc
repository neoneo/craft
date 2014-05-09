component {

	public void function init(required ElementFactory factory, required Scope scope) {
		variables._fileLoader = new FileLoader(arguments.factory, arguments.scope)
	}

	public Struct function load(required String path) {

		var elements = {}

		DirectoryList(arguments.path, false, "path", "*.xml").each(function (path) {
			elements[arguments.path] = variables._fileLoader.load(arguments.path)
		})

		return elements
	}

}