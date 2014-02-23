import craft.core.content.Content;

/**
 * This `Loader` traverses the elements in an xml document and creates the corresponding tree of `Element`s that is used to create the `Content`.
 */
component {

	public void function init(required ElementFactory factory, required Repository repository) {
		variables._factory = arguments.factory
		/*
			Create a repository for local elements. We will store elements from this document in it, but we don't want elements from outside
			this document to be able to refer to inside elements. The parent repository contains only root elements.
		*/
		variables._repository = new Repository(arguments.repository)
	}

	public Element function load(required String path) {

		var node = XMLParse(FileRead(arguments.path)).xmlRoot
		var element = variables._factory.construct(node)
		build(element)

		return element
	}

	public void function build(required Element root) {

		// construct() returns an array of elements whose construction could not complete in one go.
		var deferred = construct(arguments.root)
		// If the root itself could not be constructed, it is the last element in deferred. Remove it.
		if (!deferred.isEmpty() && deferred.last() === arguments.root) {
			deferred.deleteAt(deferred.len())
		}

		// Loop through the deferred elements until there are none left. Each turn should diminish the size of the array.
		while (!deferred.isEmpty()) {
			// Create an empty array to keep elements that need to be deferred still longer.
			var remaining = []
			for (var element in deferred) {
				element.construct(variables._repository)
				if (!element.ready()) {
					remaining.append(element)
				}
			}

			// If no elements could be constructed in this loop, we have elements pointing to each other.
			if (remaining.len() == deferred.len()) {
				// TODO: put the list in the exception in a meaningful way.
				Throw("Could not construct all elements", "InstantiationException")
			}

			deferred = remaining
		}

	}

	private Element[] function construct(required Element element) {

		var deferred = []
		// Construct the tree depth first. Most of the time, parent elements need their children to be ready.
		for (var child in arguments.element.children()) {
			// The element could have been deferred before, in which case the child may have been constructed already.
			if (!child.ready()) {
				// Construct the child element and append the elements that could not be constructed.
				deferred.append(construct(child), true)
			}
		}

		arguments.element.construct(variables._repository)

		if (!arguments.element.ready()) {
			deferred.append(arguments.element)
		} else {
			variables._repository.store(arguments.element)
		}

		return deferred
	}

}