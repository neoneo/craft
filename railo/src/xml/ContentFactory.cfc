import craft.core.content.Content;

component accessors="true" {

	variables.mappings = {} // Maps an xml namespace to a mapping.

	/**
	 * Registers any `Content`s found in the mapping. A settings.ini file must be present in order for any components to be inspected.
	 * If absent, the subdirectories are searched for settings.ini files and `register()` is then called recursively.
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

			// Pick up all cfc's in this directory (recursively) and keep the ones that implement Content.
			DirectoryList(path, true, "path", "*.cfc").each(function (filePath) {
				// Construct the component name. First replace the directory with the mapping, then make that a dot delimited path.
				var componentName = ListChangeDelims(Replace(arguments.filePath, path, mapping), ".", "/", false)
				// Finally remove the .cfc extension.
				componentName = ListDeleteAt(componentName, ListLen(componentName, "."), ".")

				var metadata = GetComponentMetaData(componentName)

				// Ignore components with the abstract annotation.
				var abstract = metadata.abstract ?: false
				if (!abstract && implementsContent(metadata)) {
					// If a node annotation is present, that will be the node name. Otherwise we take the fully qualified component name.
					var nodeName = metadata.node ?: metadata.name
					var data = {
						name: metadata.name,
						attributes: []
					}

					do {
						// Filter the properties for those that can be attributes.
						var attributes = metadata.properties.filter(function (property) {
							// If the property has an attribute annotation (a boolean), return that. If absent, include the property.
							return property.attribute ?: true
						})
						// Fix the transformer for the property. Clone the property before modification (component metadata is cached!).
						attributes.each(function (property) {
							var attribute = Duplicate(arguments.property, false)
							if (attribute.keyExists("transformer")) {
								attribute.transformer = transformer(attribute.transformer)
							} else {
								// In absence of a transformer, interpret a value as a simple value.
								attribute.transformer = simpleValueTransformer(attribute.type ?: "String")
							}
							// The attribute is required unless the required annotation is false.
							attributes.required = attributes.required ?: true

							data.attributes.append(attribute)
						})

						metadata = metadata.extends ?: {}
					} while (!metadata.isEmpty())

					variables.mappings[namespace][nodeName] = data
				}
			})
		} else {
			// Call again for each subdirectory.

		}

	}

	/**
	 * Creates `Content` instances based on the namespace, node name and optional attributes.
	 */
	public Content function create(required String namespace, required String nodeName, Struct attributes = {}) {

		if (!variables.mappings.keyExists(arguments.namespace)) {
			Throw("Namespace '#arguments.namespace#' not found", "NoSuchElementException")
		}

		var mappings = variables.mappings[arguments.namespace]
		if (!mappings.keyExists(arguments.nodeName)) {
			Throw("Node '#arguments.nodeName#' not found in namespace '#arguments.namespace#'", "NoSuchElementException")
		}

		// Loop over the attributes defined in the component, and pick them up from the attributes that were passed in.
		// This means that any attributes not defined in the component are ignored.
		var data = mappings[arguments.nodeName]
		var constructorArguments = {}
		// Make some arguments available in the closure.
		var nodeName = arguments.nodeName
		var attributes = arguments.attributes
		data.attributes.each(function (attribute) {
			var name = arguments.attribute.name
			if (attributes.keyExists(name)) {
				// Let the transformer transform the string value from the attribute into the actual value.
				constructorArguments[name] = arguments.attribute.transformer.transform(attributes[name])
			} else if (arguments.attribute.required) {
				Throw("Attribute '#name#' is required for node '#nodeName#'", "MissingAttributeException")
			}
		})

		return new "#data.name#"(argumentCollection: constructorArguments)
	}

	/**
	 * Returns whether the component implements `Content`.
	 */
	private Boolean function implementsContent(required Struct componentMetadata) {

		var result = false

		var metadata = arguments.componentMetadata
		if (metadata.keyExists("implements")) {
			result = extendsContent(metadata.implements)
		}
		if (!result && metadata.keyExists("extends")) {
			result = implementsContent(metadata.extends)
		}

		return result
	}

	/**
	 * Returns whether the interface extends `Content`.
	 */
	private Boolean function extendsContent(required Struct interfaceMetadata) {

		// The toplevel keys are interface names. Loop over them and check.
		for (var name in arguments.interfaceMetadata) {
			var metadata = arguments.interfaceMetadata[name]
			if (metadata.name == "craft.core.content.Content") {
				return true
			} else if (metadata.keyExists("extends") && extendsContent(metadata.extends)) {
				return true
			}
		}

		return false
	}

}