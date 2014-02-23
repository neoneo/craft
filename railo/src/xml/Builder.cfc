import craft.core.content.Content;

/**
 * Builds the `Content` of the `Element` and its children.
 */
component {

	public void function build(required Element root, required Repository repository) {
		/*
			Create a repository for local elements. We don't want elements from outside this document to be able to refer to inside elements.
			The parent repository contains only root elements.
		*/
		var localRepository = new Repository(arguments.repository)

		// construct() returns an array of elements whose construction could not complete in one go.
		var deferred = construct(arguments.root, localRepository)
		// If the root itself could not be constructed, it is the last element in deferred. Remove it.
		if (!deferred.isEmpty() && deferred.last() === arguments.root) {
			deferred.deleteAt(deferred.len())
		}

		// Loop through the deferred elements until there are none left. Each turn should diminish the size of the array.
		while (!deferred.isEmpty()) {
			// Create an empty array to keep elements that need to be deferred still longer.
			var remaining = []
			for (var element in deferred) {
				element.construct(localRepository)
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

	private Element[] function construct(required Element element, required Repository repository) {

		var deferred = []
		// Construct the tree depth first. Most of the time, parent elements need their children to be ready.
		for (var child in arguments.element.children()) {
			// The element could have been deferred before, in which case the child may have been constructed already.
			if (!child.ready()) {
				// Construct the child element and append the elements that could not be constructed.
				deferred.append(construct(child, arguments.repository), true)
			}
		}

		arguments.element.construct(arguments.repository)

		if (!arguments.element.ready()) {
			deferred.append(arguments.element)
		} else {
			variables._repository.store(arguments.element)
		}

		return deferred
	}

}