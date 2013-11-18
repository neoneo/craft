/**
 * A `Reader` traverses the elements in an xml document and creates the corresponding tree of `Node`s that is used to generate the content.
 * In terms of the builder pattern, the `Reader` is the director.
 */
component {

	public void function init(required ElementFactory factory) {
		variables._factory = arguments.factory
		// Create a repository of elements that we can look up by ref.
		variables._elements = {}
	}

	public Element function read(required String path) {

		var root = XMLParse(FileRead(arguments.path)).xmlRoot

		return build(root)
	}

	public Element function build(required XML xml) {

		var element = variables._factory.create(arguments.xml.xmlNsURI, arguments.xml.xmlName, arguments.xml.xmlAttributes)
		for (var child in element.xmlChildren) {
			element.add(build(child))
		}
		if (!IsNull(element.getRef())) {
			variables._elements[element.getRef()] = element
		}

		return element
	}

	public void function hasElement(required String ref) {
		return variables._elements.keyExists(arguments.ref)
	}

	public Element function element(required String ref) {
		return variables._elements[arguments.ref]
	}

}