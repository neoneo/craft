component extends="Loader" {

	public Struct function load(required String path) {

		var contents = {}

		DirectoryList(arguments.path, true, "path", "*.xml").each(function (path) {
			// Create a new ElementLoader for each file, because we don't want separate files to be able to refer to one another.
			var loader = new ElementLoader(factory(), this)
			var element = loader.load(arguments.path)[1]
			contents[arguments.path] = element.product()
		})

		return contents
	}

}