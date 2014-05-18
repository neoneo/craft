component {

	public void function init(required ElementFactory factory) {
		variables._scope = new Scope()
		variables._fileLoader = new FileLoader(arguments.factory, variables._scope)
		variables._elements = []
	}

	public Struct function load(required String path) {

		var elements = {}

		DirectoryList(arguments.path, false, "path", "*.xml").each(function (path) {
			elements[arguments.path] = variables._fileLoader.load(arguments.path)
		})

		// Root elements may depend on other root elements. Gather all elements that are not ready.
		elements.each(function (path, element) {
			if (!arguments.element.ready()) {
				variables._elements.append(arguments.element)
			}
		})

		/*
			Loop through the elements and try to build them. Repeat this until no more elements were completed in the last cycle.
			This doesn't guarantee that all elements are ready, and it doesn't detect circular references.
		*/
		do {
			var count = variables._elements.len()
			variables._elements = variables._elements.filter(function (element) {
				if (!arguments.element.ready()) {
					// It's only the root element that's not constructed yet. Descendants would have thrown exceptions earlier.
					arguments.element.build(variables._scope)
				}

				return !arguments.element.ready()
			})
		} while (count > variables._elements.len())

		return elements
	}

	/**
	 * Returns whether all loaded elements are ready.
	 * Clients can use this to check for undefined layouts or circular references.
	 */
	public Boolean function ready() {
		return variables._elements.isEmpty()
	}

}