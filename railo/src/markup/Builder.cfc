import craft.core.content.Content;

/**
 * Builds the `Content` of the `Element` and its children.
 */
component {

	public void function build(required Element root, required Scope scope) {
		/*
			Create a scope for local elements. We don't want elements from outside this document to be able to refer to inside elements.
			The parent scope contains only root elements.
		*/
		var localScope = new Scope(arguments.scope)

		// construct() returns an array of elements whose construction could not complete in one go.
		var deferred = construct(arguments.root, localScope)
		/*
			The root element may depend on other elements, outside the current scope.
			If the root could not be constructed, it is the last element in deferred. Remove it.
		*/
		if (!deferred.isEmpty() && deferred.last() === arguments.root) {
			deferred.deleteAt(deferred.len())
		}

		// Loop through the deferred elements until there are none left. Each turn should diminish the size of the array.
		while (!deferred.isEmpty()) {
			// Create an empty array to keep elements that need to be deferred still longer.
			var remaining = []
			for (var element in deferred) {
				// We cannot reuse our private construct method because that might lead to elements being pushed on the remaining array multiple times.
				element.build(localScope)
				if (!element.ready()) {
					remaining.append(element)
				} else {
					localScope.store(arguments.element)
				}
			}

			// If no elements could be constructed in this loop, we have elements pointing to each other.
			if (remaining.len() == deferred.len()) {
				Throw("Could not build all elements", "InstantiationException", "One or more elements are referring to eachother. Circular references cannot be resolved.")
			}

			deferred = remaining
		}

	}

	/**
	 * Tries to construct the element and its children. The returned array contains all elements (the given element or its descendants) that could not be constructed yet.
	 */
	private Element[] function construct(required Element element, required Scope scope) {

		var deferred = []
		// Construct the tree depth first. Most of the time, parent elements need their children to be ready.
		for (var child in arguments.element.children()) {
			// The element could have been deferred before, in which case the child may have been constructed already.
			if (!child.ready()) {
				// Construct the child element and append the elements that could not be constructed.
				deferred.append(construct(child, arguments.scope), true)
			}
		}

		arguments.element.build(arguments.scope)

		if (!arguments.element.ready()) {
			deferred.append(arguments.element)
		} else {
			arguments.scope.store(arguments.element)
		}

		return deferred
	}

}