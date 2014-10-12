component {

	public void function init(required TagRepository repository, required Scope scope) {
		this.repository = arguments.repository
		this.scope = arguments.scope
	}

	public Element function build(required XML document) {

		var element = this.repository.instantiate(arguments.document.xmlRoot)

		/*
			Create a scope for local elements. We don't want elements from outside this document to be able to refer to inside elements.
			The parent scope contains only root elements.
		*/
		var localScope = new Scope(this.scope)

		// construct() returns an array of elements whose construction could not complete in one go.
		var deferred = this.construct(element, localScope)

		// The element may depend on other elements, outside the current scope. Remove it from the deferred elements.
		deferred.delete(element)

		// Loop through the deferred elements until there are none left. Each turn should diminish the size of the array.
		while (!deferred.isEmpty()) {
			var count = deferred.len()

			deferred = deferred.filter(function (element) {
				arguments.element.construct(localScope)

				if (arguments.element.ready) {
					localScope.put(arguments.element)
				}

				return !arguments.element.ready;
			})

			// If no elements could be completed in this loop, we have elements pointing to each other or elements depending on unknown elements.
			if (count == deferred.len()) {
				Throw("Could not construct all elements", "InstantiationException", "One or more elements have undefined dependencies, or are referring to each other. Circular references cannot be resolved.");
			}
		}

		// If the element is not ready yet, give it one more try. Just in case it was waiting for some other deferred element.
		if (!element.ready) {
			element.construct(localScope)
		}

		// Return the element whether it's ready or not. It's the responsibility of other objects to handle this.
		return element;
	}

	/**
	 * Tries to construct the element and its children. The returned array contains all elements (the given element or its descendants) that could not be constructed yet.
	 */
	private Element[] function construct(required Element element, required Scope scope) {

		var deferred = []
		// Construct the tree depth first. Most of the time, parent elements need their children to be ready.
		for (var child in arguments.element.children) {
			// The element could have been deferred before, in which case the child may have been constructed already.
			if (!child.ready) {
				// Construct the child element and append the elements that could not be constructed.
				deferred.append(this.construct(child, arguments.scope), true)
			}
		}

		arguments.element.construct(arguments.scope)

		if (!arguments.element.ready) {
			deferred.append(arguments.element)
		} else {
			arguments.scope.put(arguments.element)
		}

		return deferred;
	}

}