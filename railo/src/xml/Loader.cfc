import craft.core.content.Content;

/**
 * A `Loader` traverses the elements in an xml document and creates the corresponding tree of `Element`s that is used to create the `Content`.
 */
component {

	public void function init(required ElementFactory factory, Struct elements) {
		variables._factory = arguments.factory
		// If an elements collection is passed in, make a shallow copy of it.
		variables._elements = IsNull(arguments.elements) ? {} : Duplicate(arguments.elements, false)
	}

	public Content function load(required String path) {

		var root = XMLParse(FileRead(arguments.path)).xmlRoot

		var element = build(parse(root))

		return element.product()
	}

	/**
	 * Creates a tree of `Element`s that represents the given xml node tree.
	 */
	public Element function parse(required XML node) {

		var element = variables._factory.create(arguments.node.xmlNsURI, arguments.node.xmlName, arguments.node.xmlAttributes)
		for (var child in arguments.node.xmlChildren) {
			element.add(parse(child))
		}
		if (!IsNull(element.getRef())) {
			variables._elements[element.getRef()] = element
		}

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
				element.construct(this)
				if (!element.ready()) {
					remaining.append(element)
				}
			}

			// If no elements could be constructed in this loop, we have elements pointing to each other.
			if (remaining.len() == deferred.len()) {
				// TODO: put the list in the exception in a meaningful way.
				Throw("Could not construct all elements", "ConstructionException")
			}

			deferred = remaining
		}

		// Construction is done. Return the product.
		//return arguments.root.product()
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

		arguments.element.construct(this)

		if (!arguments.element.ready()) {
			deferred.append(arguments.element)
		}

		return deferred
	}

	public Boolean function hasElement(required String ref) {
		return variables._elements.keyExists(arguments.ref)
	}

	public Element function element(required String ref) {

		if (!hasElement(arguments.ref)) {
			Throw("Element '#arguments.ref#' not found", "NoSuchElementException")
		}

		return variables._elements[arguments.ref]
	}

	public Struct function elements() {
		return variables._elements
	}

}