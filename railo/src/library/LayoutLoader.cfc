import craft.markup.Builder;
import craft.markup.DirectoryLoader;
import craft.markup.Scope;

/**
 * `Layout`s can extend eachother, so a mechanism is needed for them to find another.
 * The `LayoutLoader` extends `DirectoryLoader` and collects all elements created by its `load()` method.
 * When the client has loaded all directories, a (single) call to `build()` finishes the construction.
 */
component extends="DirectoryLoader" {

	variables._scope = new Scope()
	variables._elements = []

	public Struct function load(required String path) {

		var elements = super.load(arguments.path)
		elements.each(function (path, element) {
			variables._scope.store(arguments.element)
			variables._elements.append(arguments.element)
		})

		return elements
	}

	public void function build() {

		variables._elements.each(function (element) {
			if (!arguments.element.ready()) {
				// It's only the root element that's not constructed yet. Descendants would have thrown exceptions earlier.
				arguments.element.build(variables._scope)
				// If still not ready, the element depends on something that is not in scope.
				if (!arguments.element.ready()) {
					Throw("Could not build layout '#arguments.element.getRef()#'", "InstantiationException", "The layout depends on content that is not available.")
				}
			}
		})

	}

}