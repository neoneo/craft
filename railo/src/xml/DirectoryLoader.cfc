component {

	public void function init(required ElementFactory factory, required Repository repository) {
		variables._fileLoader = new FileLoader(arguments.factory, arguments.repository)
	}

	public Struct function load(required String path) {

		var elements = {}

		DirectoryList(arguments.path, false, "path", "*.xml").each(function (path) {
			elements[arguments.path] = variables._fileLoader.load(arguments.path)
		})

		return elements
	}

}