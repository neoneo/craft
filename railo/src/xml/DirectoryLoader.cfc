component extends="Loader" {

	public Struct function load(required String path) {

		var contents = {}

		DirectoryList(arguments.path, false, "path", "*.xml").each(function (path) {
			// Create a new ElementLoader for each file, because we don't want separate files to be able to refer to one another.
			var loader = new ElementLoader(factory(), this)
			contents.append(loader.load(arguments.path))
		})
		contents.each(function (path, element) {
			keep(arguments.element)
		})

		return contents
	}

}