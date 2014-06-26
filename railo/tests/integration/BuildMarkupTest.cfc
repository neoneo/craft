import craft.core.content.*;

import craft.markup.*;

component extends="mxunit.framework.TestCase" {


	public void function beforeTests() {

		var factory = new ElementFactory()
		factory.register("/crafttests/integration/elements")

		var builder = new DirectoryBuilder(factory)
		variables.path = ExpandPath("/crafttests/integration/markup")
		variables.documents = builder.build(variables.path)

		// The markup tags should result in specific component types.
		variables.types = {
			composite: GetComponentMetaData("components.Composite").name,
			leaf: GetComponentMetaData("components.Leaf").name
		}

	}

	public void function SimpleMarkup() {

		var path = variables.path & "/simple.xml"
		// The element has constructed a component we're interested in.
		var component = variables.documents[path].product()

		var root = XMLParse(FileRead(path)).xmlRoot

		assertTrue(isEquivalent(component, root))

	}

	private Boolean function isEquivalent(required Component component, required XML node) {

		// The component should be of the type specified.
		var type = variables.types[arguments.node.xmlName]
		if (!IsInstanceOf(arguments.component, type)) {
			Throw("Node #arguments.node.xmlName####arguments.node.xmlAttributes.name# does not produce a component of type #type#")
		}

		// The name attribute should have been passed on to the component.
		if (arguments.node.xmlAttributes.name != arguments.component.getName()) {
			Throw("Node #arguments.node.xmlName####arguments.node.xmlAttributes.name# does not produce a component with this name")
		}

		// This function can only test cases where nodes and components are in a one to one correspondence.
		if (arguments.component.hasChildren()) {
			var components = arguments.component.children()
			var nodes = arguments.node.xmlChildren

			return components.every(function (component, index) {
				return isEquivalent(arguments.component, nodes[arguments.index])
			})
		} else {
			return true
		}
	}

}