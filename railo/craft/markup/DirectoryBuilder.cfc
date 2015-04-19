/**
 * @transient
 */
component {

	public void function init(required ElementBuilder elementBuilder) {
		this.elementBuilder = arguments.elementBuilder
	}

	/**
	 * Builds all xml files in the given directory and returns a struct with the resulting `Element`s, where keys are file names.
	 */
	public Struct function build(required String path) {

		var elements = {}

		DirectoryList(arguments.path, false, "path", "*.xml").each(function (path) {
			var document = XMLParse(FileRead(arguments.path))
			var element = elements[GetFileFromPath(arguments.path)] = this.elementBuilder.build(document)
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
				return this.elementBuilder.construct(arguments.element);
			})

			if (count == deferred.len()) {
				Throw("Could not construct all elements", "InstantiationException", "One or more elements have undefined dependencies, or are referring to each other. Circular references cannot be resolved.");
			}
		}

		return elements;
	}

}