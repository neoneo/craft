component {

	public void function init(required ElementFactory factory, Scope scope) {
		variables._scope = arguments.scope ?: new Scope()
		variables._elementBuilder = new ElementBuilder(arguments.factory, variables._scope)
	}

	public Struct function build(required String path) {

		var elements = {}

		DirectoryList(arguments.path, false, "path", "*.xml").each(function (path) {
			var document = XMLParse(FileRead(arguments.path))
			var element = elements[arguments.path] = variables._elementBuilder.build(document)
			if (element.ready()) {
				variables._scope.put(element)
			}
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
				arguments.element.construct(variables._scope)

				if (arguments.element.ready()) {
					variables._scope.put(arguments.element)
				}

				return !arguments.element.ready()
			})

			if (count == deferred.len()) {
				Throw("Could not construct all elements", "InstantiationException", "One or more elements have undefined dependencies, or are referring to each other. Circular references cannot be resolved.")
			}
		}

		return elements
	}

}