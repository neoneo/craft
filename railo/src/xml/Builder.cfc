component {

	public void function init(required ElementFactory factory, required String rootFolder, String templateFolder = "") {

		if (Len(arguments.templateFolder) > 0) {
			var loader = new Loader(arguments.factory)
			var elements = buildAll(loader, arguments.templateFolder)
		}

	}

}