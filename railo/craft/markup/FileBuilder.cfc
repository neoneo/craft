/**
 * @transient
 */
component {

	public void function init(required ElementBuilder elementBuilder) {
		this.elementBuilder = arguments.elementBuilder
	}

	/**
	 * Builds the xml file at the given path. The resulting `Element` is stored in the `Scope`, and is available
	 * as a dependency for subsequent calls.
	 */
	public Element function build(required String path) {

		var document = XMLParse(FileRead(arguments.path))
		var element = this.elementBuilder.build(document)

		if (!element.ready) {
			// The element builder only returns if all child elements are ready, so it can only be this element that's not ready.
			Throw("Could not construct element", "InstantiationException", "The element has an undefined dependency.");
		}

		return element;
	}

}