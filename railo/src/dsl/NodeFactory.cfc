component accessors="true" {

	variables.mappings = {} // Maps an xml namespace to a mapping.

	/**
	 * Registers a mapping under the given namespace URI. All `Node`s found under this mapping are inspected.
	 */
	public void function register(required String mapping) {

		var path = ExpandPath(arguments.mapping)

		// See if there is a settings.ini here.
		var settingsFile = path & "/settings.ini"
		if (FileExists(settingsFile)) {
			var sections = GetProfileSections(settingsFile)
			// If there is no section named 'craft', or if this section doesn't contain a namespace key, throw an exception.
			if (!sections.keyExists("craft") || ListFind(sections.craft, "namespace") == 0) {
				Throw("Namespace not found in #settingsFile#", "NoSuchElementException")
			}

			var namespace = GetProfileString(settingsFile, "craft", "namespace")
			variables.mappings[namespace] = {
				mapping: arguments.mapping
			}

			// Pick up all cfc's in this directory (recursively) and keep the ones that extend Node.
			DirectoryList(path, true, "path", "*.cfc").each(function (filePath)) {
				// Construct the component name. First replace the directory with the mapping, then make that a dot delimited path.
				var componentName = ListChangeDelims(Replace(arguments.filePath, path, mapping), ".", "/", false)
				// Finally remove the .cfc extension.
				componentName = ListDeleteAt(componentName, ListLen(componentName, "."), ".")

				var metadata = GetComponentMetaData(componentName)

				// We assume that most cfc's will be nodes, so collect the properties already.
				var nodeName = metadata.node ?: metadata.name
				var data = {
					name: metadata.name,
					attributes: []
				}

				var extendsNode = false
				while (metadata.keyExists("extends")) {
					// Filter the properties for those that can be attributes.
					var attributes = metadata.properties.filter(function (property) {
						// If the property has an attribute annotation (a boolean), return that. If absent, include the property.
						return property.attribute ?: true
					})
					// Fix the transformer for the property. We can modify the attributes array, because it is a new array (component metadata is cached).
					attributes.each(function (property) {
						if (arguments.property.keyExists("transformer")) {
							arguments.property.transformer = transformer(arguments.property.transformer)
						} else {
							// In absence of a transformer, interpret a value as a simple value.
							arguments.property.transformer = simpleValueTransformer(arguments.property.type ?: "String")
						}
					})
					data.attributes.append(attributes, true)

					metadata = metadata.extends
					if (metadata.name == "craft.core.content.Node") {
						extendsNode = true
					}
				}

				if (extendsNode) {
					variables.mappings[namespace][nodeName] = data
				}
			}
		}

	}

	public Node function create() {

	}

}