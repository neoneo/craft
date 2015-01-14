component {

	public void function init(required TagRepository tagRepository, required Scope scope) {
		this.tagRepository = arguments.tagRepository
		this.scope = arguments.scope
	}

	public Element function build(required XML document) {

		var element = this.instantiate(arguments.document.xmlRoot)

		/*
			Create a scope for local elements. We don't want elements from outside this document to be able to refer to inside elements.
			The parent scope contains only root elements.
		*/
		var localScope = new Scope(this.scope)

		// construct() returns an array of elements whose construction could not complete in one go.
		var deferred = this.construct(element, localScope)

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

		// If the element is not ready yet, give it one more try. Just in case it was waiting for some descendant element.
		if (!element.ready) {
			element.construct(localScope)
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

		var tag = this.tagRepository.get(namespace, tagName)

		// Create a struct with attribute name/value pairs to pass to the factory.
		var attributes = {}

		// Attribute validation and selection:
		// Loop over the attributes defined in the tag, and pick them up from the node attributes.
		// This means that any attributes not defined in the tag are ignored.
		var nodeAttributes = arguments.node.xmlAttributes
		tag.attributes.each(function (attribute) {
			var name = arguments.attribute.name
			var value = nodeAttributes[name] ?: arguments.attribute.default ?: null

			if (value === null && (arguments.attribute.required ?: false)) {
				Throw("Attribute '#name#' is required", "MissingArgumentException");
			}

			if (value !== null) {
				// Since we'll only encounter simple values here, we can use IsValid. We assume that the property type is specified.
				if (!IsValid(arguments.attribute.type, value)) {
					Throw("Invalid value '#value#' for attribute '#name#'", "IllegalArgumentException", "Expected value of type #arguments.attribute.type#");
				}

				attributes[name] = value
			}
		})

		// Get the factory for this namespace and create the element.
		var factory = this.tagRepository.elementFactory(namespace)
		var element = factory.create(tag.class, attributes, arguments.node.xmlText)

		for (var child in arguments.node.xmlChildren) {
			element.add(this.instantiate(child))
		}

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

		// The root element may depend on other elements, outside the current scope, so don't push it on the deferred elements array.
		// Neither put it in the current scope.
		if (arguments.element.hasParent) {
			if (!arguments.element.ready) {
				deferred.append(arguments.element)
			} else {
				arguments.scope.put(arguments.element)
			}
		}

		return deferred;
	}

}