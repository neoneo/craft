component {

	public void function init(required ElementFactory factory) {
		variables._scope = new Scope()
		variables._fileBuilder = new FileBuilder(arguments.factory, variables._scope)
	}

	public Struct function build(required String path) {

		var elements = {}

		DirectoryList(arguments.path, false, "path", "*.xml").each(function (path) {
			elements[arguments.path] = variables._fileBuilder.build(arguments.path)
		})

		// Root elements may depend on other root elements. Gather all elements that are not ready.
		var deferred = []
		elements.each(function (path, element) {
			if (!arguments.element.ready()) {
				deferred.append(arguments.element)
			}
		})

		// Build the deferred elements.
		while (!deferred.isEmpty()) {
			var count = deferred.len()

			deferred = deferred.filter(function (element) {
				arguments.element.build(variables._scope)

				if (arguments.element.ready()) {
					variables._scope.store(arguments.element)
				}

				return !arguments.element.ready()
			})

			if (count == deferred.len()) {
				Throw("Could not build all elements", "InstantiationException", "One or more elements have undefined dependencies, or are referring to each other. Circular references cannot be resolved.")
			}

		}

		return elements
	}

}