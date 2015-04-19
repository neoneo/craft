/**
 * @transient
 */
component {

	public void function init(required TagRegistry tagRegistry, required Scope scope) {
		this.tagRegistry = arguments.tagRegistry
		this.scope = arguments.scope
	}

	public Element function build(required XML document) {

		var element = this.instantiate(arguments.document.xmlRoot)

		// Create a scope for local elements. We don't want elements from outside this document to be able to refer to inside elements.
		// The parent scope contains only root elements.
		var localScope = this.scope.spawn()

		var remaining = -1
		var count = -1
		// Loop through the deferred elements until there are none left. Each turn should diminish the number of remaining elements.
		while (remaining > 0 || remaining == -1) {
			// construct() returns the number of elements whose construction was not successful.
			remaining = this.constructTree(element, localScope)

			// If no elements could be completed in this loop, we have elements pointing to each other or elements depending on unknown elements.
			if (remaining == count) {
				Throw("Could not construct all elements", "InstantiationException", "One or more elements have undefined dependencies, or are referring to each other. Circular references cannot be resolved.");
			}

			count = remaining
		}

		// If the element (= root) is not ready yet, give it one more try. Just in case it was waiting for some descendant element.
		if (!element.ready) {
			element.construct(localScope)
		}
		if (element.ready) {
			this.scope.put(element)
		}

		// Return the element whether it's ready or not. It's the responsibility of other objects to handle this.
		return element;
	}

	/**
	 * Creates a tree of `Element`s that represents the given xml node tree.
	 */
	private Element function instantiate(required XML node) {

		var namespace = arguments.node.xmlNsURI
		var tagName = arguments.node.xmlName.replace(arguments.node.xmlNsPrefix & ":", "") // Remove the namespace prefix, if it exists.
		var attributes = arguments.node.xmlAttributes.copy()
		attributes.textContent = arguments.node.xmlText

		var objectProvider = this.tagRegistry.get(namespace)
		var element = objectProvider.instance(tagName, attributes)

		for (var child in arguments.node.xmlChildren) {
			element.add(this.instantiate(child))
		}

		return element;
	}

	/**
	 * Tries to construct the `Element` and its children, and returns the number of elements in the tree that were NOT constructed successfully.
	 */
	private Numeric function constructTree(required Element element, required Scope scope) {

		var remaining = 0
		// Construct the tree depth first. Most of the time, parent elements need their children to be ready.
		for (var child in arguments.element.children) {
			remaining += this.constructTree(child, arguments.scope)
		}

		if (!arguments.element.ready) {
			arguments.element.construct(arguments.scope)
		}

		// The root element may depend on other elements, outside the current scope, so don't count it. Neither put it in the current scope.
		if (arguments.element.hasParent) {
			if (!arguments.element.ready) {
				remaining += 1
			} else {
				var ref = arguments.element.ref
				if (ref !== null) {
					// Store the element in the scope unless it is already stored there.
					if (!arguments.scope.has(ref) || arguments.element !== arguments.scope.get(ref)) {
						arguments.scope.put(arguments.element)
					}
				}
			}
		}

		return remaining;
	}

	/**
	 * Tries to construct the `Element` and returns whether construction was successful.
	 */
	public Boolean function construct(required Element element) {
		arguments.element.construct(this.scope)

		return arguments.element.ready;
	}

}