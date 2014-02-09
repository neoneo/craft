component extends="Loader" {

	public Element[] function load(required String path) {

		var elements = []

		DirectoryList(arguments.path, true, "path", "*.xml").each(function (path) {
			// Create a new ElementLoader for each file, because we don't want separate files to be able to refer to one another.
			var loader = new ElementLoader(factory(), this)
			var element = loader.load(arguments.path)[1]
			elements.append(element)
		})

		return elements
	}

}