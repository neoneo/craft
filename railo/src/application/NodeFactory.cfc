import craft.core.layout.Node
import craft.dsl.transformer.Transformer

component implements="craft.dsl.factory.NodeFactory" {

	variables.definitions = {}
	variables.transformers = {}

	public Node function create(required Xml element) {

		var name = arguments.element.xmlName
		// check if the type exists in the definitions
		if (variables.definitions.keyExists(name)) {
			var definition = variables.definitions[name]
			var type = definition.type

			var attributes = filterAttributes(arguments.element)
			var properties = {}
			// a definition has as many sets of properties as there are ancestor definitions
			for (var propertySet in definition.propertySets) {
				propertySet.each(function (name, metadata) {
					if (!properties.keyExists(name)) {
						var value = attributes.keyExists(name) ? attributes[name] : metadata._default
						if (value == null && metadata.required) {
							Throw("Attribute #name# is required")
						}
						properties[name] = getTransformer(metadata.type).transform(value)
					}
				})
			}
		} else {
			// the type must be a fully qualified path to a component
			// there is no transformer so the properties should match the constructor arguments
			var type = arguments.element.xmlName
			var properties = filterAttributes(arguments.element)
		}

		// create the instance, implicitly setting all known properties
		return new "#type#"(properties)
	}

	public void function readDefinitions(required String folder) {

		var paths = DirectoryList(ExpandPath(arguments.folder), true, "path", "*.xml", "directory asc, name asc")

		// definitions can extend one another so first read all files and then create the definitions
		for (var path in paths) {
			var xmlDocument = XmlParse(FileRead(path))
			// xmlRoot should be a package element
			var package = xmlDocument.xmlRoot
			var namespaces = getNamespaces(package)
			for (var element in package.xmlChildren) {
				defineElement(element, namespaces, package.xmlAttributes.name)
			}
		}

		// get all definitions with an extends attribute
		var extendingItems = variables.definitions.findKey("extends", "all")
		// use the count to check for circular references
		var count = extendingItems.len()
		while (!extendingItems.isEmpty()) {
			if (count == 0) {
				Throw("Circular reference detected")
			}

			for (var item in extendingItems) {
				// the owner key contains the original definition that we are going to change
				var definition = item.owner
				var extendedDefinition = variables.definitions[definition.extends]
				// if the definition being extended does itself not extend another definition, we can incorporate it
				if (!extendedDefinition.keyExists("extends")) {
					// append the property sets from the incoming definition
					definition.propertySets.append(extendedDefinition.propertySets, true)
					// take the type from the definition
					definition.type = extendedDefinition.type
					definition.delete("extends")
				}
			}

			count--
			extendingItems = variables.definitions.findKey("extends", "all")
		}

	}

	public void function addTransformer(required Transformer transformer, required String type) {
		variables.transformers[arguments.type] = arguments.transformer
	}

	private void function defineElement(required Xml element, required Struct namespaces, required String packageName) {

		var attributes = arguments.element.xmlAttributes
		// type or extends must be specified
		if (!attributes.keyExists("type") && !attributes.keyExists("extends")) {
			Throw("Type and/or extends attribute must be specified")
		}

		// the namespace prefix could be different among xml files, so normalize using the namespace URI
		var namespaces = getNamespaces(arguments.element) // pick up namespaces if defined on the element itself
		namespaces.append(arguments.namespaces, false) // append the namespaces from the root

		var name = normalizeNamespace(arguments.element.xmlName, namespaces)
		if (variables.definitions.keyExists(name)) {
			Throw("Definition '#arguments.element.xmlName#' already exists")
		}

		var definition = {}

		if (attributes.keyExists("type")) {
			// a class name
			definition.type = arguments.packageName & "." & attributes.type
		}
		if (attributes.keyExists("extends")) {
			// another element definition
			definition.extends = normalizeNamespace(attributes.extends, namespaces)
		}

		var properties = {}
		// the child elements define attributes
		for (var childElement in arguments.element.xmlChildren) {
			var metadata = filterAttributes(childElement)
			metadata.default = Len(childElement.xmlText) > 0 ? childElement.xmlText : null
			if (!metadata.keyExists("required")) {
				metadata.required = false
			}
			properties[childElement.xmlName] = metadata
		}

		// a definition can contain multiple sets of properties (due to 'inheritance')
		// the order of the sets determines which property is used if names clash
		// at definition time, this array will contain one struct of properties
		definition.propertySets = [properties]

		variables.definitions[name] = definition

	}

	private Struct function getNamespaces(required Xml element) {

		var namespaces = {}
		for (var name in arguments.element.xmlAttributes) {
			if (Left(name, 5) == "xmlns") {
				// pick up the prefix from the xmlns attribute
				var prefix = ""
				if (name contains ":") {
					prefix = ListLast(name, ":")
				}
				namespaces[prefix] = xmlnsAttributes[name]
			}
		}

		return namespaces
	}

	private String function normalizeNamespace(required String name, required Struct namespaces) {

		var prefix = ""
		if (arguments.name contains ":") {
			prefix = ListFirst(arguments.name, ":")
		}

		if (!arguments.namespaces.keyExists(prefix)) {
			Throw("No namespace with prefix '#prefix#' exists")
		}

		// replace the prefix by the namespace URI
		return arguments.namespaces[prefix] & ":" & ListLast(arguments.name, ":")
	}

	private Struct function filterAttributes(required Xml element) {
		return arguments.element.xmlAttributes.filter(function (name) {
			return Left(name, 3) != "xml"
		})
	}

}