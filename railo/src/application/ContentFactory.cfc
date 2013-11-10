import craft.core.layout.Node;
import craft.core.layout.Content;
import craft.core.layout.Document;
import craft.core.layout.Template;

component {

	variables.nodeFactories = {}
	variables.templates = {}
	variables.contents = {}

	public void function readTemplateDefinitions(required String folder) {

		var paths = DirectoryList(ExpandPath(arguments.folder), true, "path", "*.xml", "directory asc, name asc")

		for (var path in paths) {
			var xmlDocument = XmlParse(FileRead(path))
			var template = constructNode(xmlDocument.xmlRoot)
			variables.templates[xmlDocument.xmlRoot.xmlAttributes.ref] = template
		}

	}

	public Content function create(required Xml element) {

		var content = null
		if (arguments.element.xmlName == "page") {
			content = createNode(arguments.element)
			// a page element can contain only region elements
			for (var regionElement in arguments.element.region) {
				// get the region from the template
				var region = template.getRegion(regionElement.xmlAttributes.ref)
				for (var nodeElement in regionElement.xmlChildren) {
					// create composites and add them to the region
					var composite = constructNode(nodeElement)
					content.addComposite(composite, region)
				}
			}
		} else {
			content = constructNode(arguments.element)
		}

		return content
	}

	public void function registerNodeFactory(required craft.dsl.factory.NodeFactory nodeFactory, required String xmlNamespace) {
		variables.nodeFactories[arguments.xmlNamespace] = arguments.nodeFactory
	}

	private Template function getTemplate(required String ref) {
		return variables.templates[arguments.ref]
	}

	private Node function createNode(required Xml element) {
		return getNodeFactory(arguments.element.xmlNsURI).create(arguments.element)
	}

	private Node function constructNode(required Xml element) {

		var node = createNode(arguments.element)

		for (var childElement in element.xmlChildren) {
			node.addChild(createNode(childElement))
		}

		return node
	}

	private craft.dsl.factory.NodeFactory function getNodeFactory(required String xmlNamespace) {

		if (!variables.nodeFactories.keyExists(arguments.xmlNamespace)) {
			Throw("No node factory registered for xml namespace #arguments.xmlNamespace#")
		}

		return variables.nodeFactories[arguments.xmlNamespace]
	}

}