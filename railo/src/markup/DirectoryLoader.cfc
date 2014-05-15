component {

	public void function init(required ElementFactory factory) {
		variables._fileLoader = new FileLoader(arguments.factory, new Scope())
	}

	public Struct function load(required String path) {

		var elements = {}

		DirectoryList(arguments.path, false, "path", "*.xml").each(function (path) {
			elements[arguments.path] = variables._fileLoader.load(arguments.path)
		})

		return elements
	}

}