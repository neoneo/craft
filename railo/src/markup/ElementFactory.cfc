import craft.markup.Element;

component {

	variables._tags = {} // Keeps metadata of tags per namespace.

	/**
	 * Registers any `Element`s found in the mapping. A settings.ini file must be present in order for any components to be inspected.
	 * If absent, the subdirectories are searched for settings.ini files and `register()` is then called recursively.
	 * The mapping should be passed in without a trailing slash.
	 */
	public void function register(required String mapping) {

		var mapping = arguments.mapping
		var path = ExpandPath(mapping)

		// See if there is a settings.ini here.
		var settingsFile = path & "/settings.ini"
		if (FileExists(settingsFile)) {
			var sections = GetProfileSections(settingsFile)
			// If there is no section named 'craft', or if this section doesn't contain a namespace key, throw an exception.
			if (!sections.keyExists("craft") || sections.craft.listFind("namespace") == 0) {
				Throw("Namespace not found in #settingsFile#", "NoSuchElementException")
			}

			var namespace = GetProfileString(settingsFile, "craft", "namespace")
			var namespaceTags = variables._tags[namespace] = {}

			if (sections.craft.listFind("directories") > 0) {
				// The directories key contains a comma separated list of directories that should exist below the current one.
				var directories = GetProfileString(settingsFile, "craft", "directories")
				var registerPaths = directories.listToArray().map(function (directory) {
					var directory = arguments.directory.trim()
					var separator = directory.startsWith("/") ? "" : "/"
					return path & separator & directory
				})
			} else {
				var registerPaths = [path]
			}

			registerPaths.each(function (registerPath) {
				var registerPath = arguments.registerPath
				var subdirectory = registerPath.replace(path, "")
				// Pick up all components in this directory (recursively) and keep the ones that extend Element.
				DirectoryList(registerPath, true, "path", "*.cfc").each(function (filePath) {
					// Construct the component name. Replace the directory with the mapping, make that a dot delimited path and remove the cfc extension.
					arguments.filePath.replace(registerPath, mapping & subdirectory).listChangeDelims(".", "/").reReplace("\.cfc$", "")
					var metadata = GetComponentMetadata(componentName)

					// Ignore components with the abstract annotation.
					var abstract = metadata.abstract ?: false
					if (!abstract && extendsElement(metadata)) {
						// If a tag annotation is present, that will be the tag name. Otherwise we take the fully qualified component name.
						var tagName = metadata.tag ?: metadata.name
						var data = {
							name: metadata.name,
							attributes: collectAttributes(metadata)
						}
						// Store the tag data.
						namespaceTags[tagName] = data
					}
				})
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

	public Struct function tags() {

		var tags = {}
		variables._tags.each(function (namespace, metadata) {
			// The metadata argument is a struct where the keys are tag names.
			tags[arguments.namespace] = arguments.metadata.keyArray()
		})

		return tags
	}

	/**
	 * Returns whether `Element` is in the inheritance chain of the given metadata.
	 */
	private Boolean function extendsElement(required Struct metadata) {

		var result = arguments.metadata.name == GetComponentMetadata("Element").name

		if (!result && arguments.metadata.keyExists("extends")) {
			result = extendsElement(arguments.metadata.extends)
		}

		return result
	}

	/**
	 * Creates a tree of `Element`s that represents the given xml node tree.
	 */
	public Element function convert(required XML node) {

		var element = create(arguments.node.xmlNsURI, arguments.node.xmlName, arguments.node.xmlAttributes)
		for (var child in arguments.node.xmlChildren) {
			element.add(convert(child))
		}

		return element
	}

	/**
	 * Creates `Element` instances based on namespace, tag name and optional attributes.
	 */
	public Element function create(required String namespace, required String tagName, Struct attributes = {}) {

		if (!variables._tags.keyExists(arguments.namespace)) {
			Throw("Namespace '#arguments.namespace#' not found", "NoSuchElementException")
		}

		var tags = variables._tags[arguments.namespace]
		if (!tags.keyExists(arguments.tagName)) {
			Throw("Tag '#arguments.tagName#' not found in namespace '#arguments.namespace#'", "NoSuchElementException")
		}

		var data = tags[arguments.tagName]
		// Create an argument collection for the constructor. Passing this in will call setters for each argument.
		var constructorArguments = {}
		// Loop over the attributes defined in the component, and pick them up from the attributes that were passed in.
		// This means that any attributes not defined in the component are ignored.
		// Make the attribute values available in the closure.
		var values = arguments.attributes
		data.attributes.each(function (attribute) {
			var name = arguments.attribute.name
			var value = values[name] ?: arguments.attribute.default ?: NullValue()

			if (IsNull(value) && (arguments.attribute.required ?: false)) {
				Throw("Attribute '#name#' is required", "IllegalArgumentException")
			}

			// Assuming we'll only encounter simple values here, we can use IsValid. We also assume that the property type is specified.
			if (!IsValid(arguments.attribute.type, value)) {
				Throw("Invalid value '#value#' for attribute '#name#': #arguments.attribute.type# expected", "IllegalArgumentException")
			}

			constructorArguments[name] = value
		})

		return new "#data.name#"(argumentCollection: constructorArguments)
	}

	private Struct[] function collectProperties(required Struct metadata) {

		var properties = []
		var names = []
		var metadata = arguments.metadata

		do {
			for (var property in metadata.properties) {
				// Let a property in a subclass take precedence over one of the same name in a superclass.
				if (names.find(property.name) == 0) {
					properties.append(property)
					names.append(property.name)
				}
			}

			metadata = metadata.extends ?: NullValue()
		} while (!IsNull(metadata))

		return properties
	}

	private Struct[] function collectAttributes(required Struct metadata) {
		// Filter the properties for those that can be attributes.
		return collectProperties(arguments.metadata).filter(function (property) {
			// If the property has an attribute annotation (a boolean), return that. If absent, include the property.
			return arguments.property.attribute ?: true
		})
	}

}