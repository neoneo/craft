component {

	public void function init(required ElementFactory factory, Scope scope) {
		this.scope = arguments.scope ?: new Scope()
		this.elementBuilder = new ElementBuilder(arguments.factory, this.scope)
	}

	public Struct function build(required String path) {

		var elements = {}

		DirectoryList(arguments.path, false, "path", "*.xml").each(function (path) {
			var document = XMLParse(FileRead(arguments.path))
			var element = elements[arguments.path] = this.elementBuilder.build(document)
			if (element.ready) {
				this.scope.put(element)
			}
		})

		// Root elements may depend on other root elements. Gather all elements that are not ready.
		var deferred = []
		elements.each(function (path, element) {
			if (!arguments.element.ready) {
				deferred.append(arguments.element)
			}
		})

		// Build the deferred elements.
		while (!deferred.isEmpty()) {
			var count = deferred.len()

			deferred = deferred.filter(function (element) {
				arguments.element.construct(this.scope)

				if (arguments.element.ready) {
					this.scope.put(arguments.element)
				}

				return !arguments.element.ready;
			})

			if (count == deferred.len()) {
				Throw("Could not construct all elements", "InstantiationException", "One or more elements have undefined dependencies, or are referring to each other. Circular references cannot be resolved.");
			}
		}

		return elements;
	}

}