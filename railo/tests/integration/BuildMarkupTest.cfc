import craft.content.*;

import craft.markup.*;

component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {

		var factory = new ElementFactory()
		factory.register("/crafttests/integration/markup/elements")
		factory.register("/craft/markup/library")

		variables.factory = factory

		variables.path = ExpandPath("/crafttests/integration/markup")

		// The markup tags should result in specific component types.
		variables.types = {
			composite: GetComponentMetaData("markup.elements.components.Composite").name,
			leaf: GetComponentMetaData("markup.elements.components.Leaf").name,
			document: GetComponentMetaData("Document").name,
			documentlayout: GetComponentMetaData("DocumentLayout").name,
			layout: GetComponentMetaData("Layout").name,
			placeholder: GetComponentMetaData("Placeholder").name,
			section: GetComponentMetaData("Section").name
		}

	}

	public void function FileBuilder_Should_ThrowException_When_ElementIsDependent() {

		var builder = new FileBuilder(variables.factory)

		var path = variables.path & "/content/document.xml"
		try {
			var element = builder.build(path)
			fail("build should have thrown an exception")
		} catch (InstantiationException e) {}

	}

	public void function DirectoryBuilder_Should_ThrowException_When_ElementIsDependent() {

		var builder = new DirectoryBuilder(variables.factory)

		var path = variables.path & "/invalid"
		try {
			var documents = builder.build(path)
			fail("build should have thrown an exception")
		} catch (InstantiationException e) {}

	}

	public void function ElementMarkup() {

		var builder = new FileBuilder(variables.factory)

		var path = variables.path & "/content/element.xml"
		var element = builder.build(path)

		// The element has constructed a component we're interested in.
		var component = element.product()

		var root = XMLParse(FileRead(path)).xmlRoot

		assertTrue(isEquivalent(component, root))

	}

	public void function DocumentMarkup() {

		// The document depends on a tree of layouts that have to be loaded with a DirectoryBuilder.
		var builder = new DirectoryBuilder(factory)

		var path = variables.path & "/documents"
		var documents = builder.build(path)

		// Compare the products with the corresponding xml documents.
		DirectoryList(path, false, "path", "*.xml").each(function (path) {
			var document = documents[arguments.path].product()
			var root = XMLParse(FileRead(arguments.path)).xmlRoot
			assertTrue(isEquivalent(document, root))
		})

	}

	private Boolean function isEquivalent(required Content content, required XML node) {

		var tagName = arguments.node.xmlName.replace(arguments.node.xmlNsPrefix & ":", "")

		// The content should be of the type specified.
		var type = variables.types[tagName]
		if (!IsInstanceOf(arguments.content, type)) {
			Throw("Node #arguments.node.xmlName####arguments.node.xmlAttributes.ref# does not produce a component of type #type#")
		}

		if (tagName == "composite" || tagName == "leaf") {
			// The ref attribute should have been passed on to the component.
			if (arguments.node.xmlAttributes.ref != arguments.content.getRef()) {
				Throw("Node #arguments.node.xmlName####arguments.node.xmlAttributes.ref# does not produce a component with this ref")
			}
		}

		// This function can only test cases where nodes and components are in a one to one correspondence.
		var children = null
		if (IsInstanceOf(arguments.content, "craft.content.Component")) {
			if (arguments.content.hasChildren()) {
				var children = arguments.content.children()
			}
		} else if (tagName == "layout") {
			var children = arguments.content.section().components()
		} else if (tagName == "documentlayout" || tagName == "document") {
			var sections = arguments.content.sections()
			// sections is a struct where the keys are the placeholder refs. We need the values (in the correct order).
			var children = sections.keyArray().sort("text").map(function (ref) {
				return sections[arguments.ref]
			})
		} else if (tagName == "section") {
			var children = arguments.content.components()
		} else {
			Throw("Unknown content instance: #tagName#")
		}

		if (children !== null) {
			var nodes = arguments.node.xmlChildren

			return children.every(function (child, index) {
				return isEquivalent(arguments.child, nodes[arguments.index])
			})
		} else {
			return true
		}
	}

}