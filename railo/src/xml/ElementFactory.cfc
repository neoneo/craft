component {

	variables._mappings = {} // Maps an xml namespace to a mapping.

	/**
	 * Registers any `Element`s found in the mapping. A settings.ini file must be present in order for any components to be inspected.
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
			variables._mappings[namespace] = {
				mapping: arguments.mapping
			}

			// Pick up all cfc's in this directory (recursively) and keep the ones that extend Element.
			DirectoryList(path, true, "path", "*.cfc").each(function (filePath) {
				// Construct the component name. First replace the directory with the mapping, then make that a dot delimited path.
				var componentName = ListChangeDelims(Replace(arguments.filePath, path, mapping), ".", "/", false)
				// Finally remove the .cfc extension.
				componentName = ListDeleteAt(componentName, ListLen(componentName, "."), ".")

				var metadata = GetComponentMetaData(componentName)

				// Ignore components with the abstract annotation.
				var abstract = metadata.abstract ?: false
				if (!abstract && extendsElement(metadata)) {
					// If a tag annotation is present, that will be the tag name. Otherwise we take the fully qualified component name.
					var tagName = metadata.tag ?: metadata.name
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
						data.attributes.append(attributes, true)

						metadata = metadata.extends ?: null
					} while (!IsNull(metadata))

					variables._mappings[namespace][tagName] = data
				}
			})
		} else {
			// Call again for each subdirectory.
			var mapping = arguments.mapping
			DirectoryList(path, false, "name").each(function (name) {
				if (DirectoryExists(path & "/" & arguments.name)) {
					register(mapping & "/" & arguments.name)
				}
			})
		}

	}

	public Struct function mappings() {
		return variables._mappings
	}

	/**
	 * Returns whether the component extends `Element`.
	 */
	private Boolean function extendsElement(required Struct metadata) {

		var metadata = arguments.metadata

		var result = arguments.metadata.name == "craft.xml.Element"

		if (!result && metadata.keyExists("extends")) {
			result = extendsElement(metadata.extends)
		}

		return result
	}

	/**
	 * Creates `Element` instances based on the namespace, node name and optional attributes.
	 */
	public Element function create(required String namespace, required String tagName, Struct attributes = {}) {

		if (!variables._mappings.keyExists(arguments.namespace)) {
			Throw("Namespace '#arguments.namespace#' not found", "NoSuchElementException")
		}

		var mappings = variables._mappings[arguments.namespace]
		if (!mappings.keyExists(arguments.tagName)) {
			Throw("Element '#arguments.tagName#' not found in namespace '#arguments.namespace#'", "NoSuchElementException")
		}

		// Loop over the attributes defined in the component, and pick them up from the attributes that were passed in.
		// This means that any attributes not defined in the component are ignored.
		var data = mappings[arguments.tagName]
		var constructorArguments = {}
		// Make some arguments available in the closure.
		var tagName = arguments.tagName
		var attributes = arguments.attributes
		data.attributes.each(function (attribute) {
			var name = arguments.attribute.name
			if (attributes.keyExists(name)) {
				constructorArguments[name] = attributes[name]
			}
		})

		return new "#data.name#"(argumentCollection: constructorArguments)
	}

}