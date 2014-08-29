import craft.markup.Element;

component {

	property Struct tagNames setter="false";

	this.tags = {} // Keeps metadata of tags per namespace.

	/**
	 * Registers any `Element`s found in the mapping. A craft.ini file must be present in order for any components to be inspected.
	 * If absent, the subdirectories are searched for craft.ini files and `register()` is then called recursively.
	 * The mapping should be passed in without a trailing slash.
	 */
	public void function register(required String mapping) {

		var path = ExpandPath(arguments.mapping)

		// See if there is a craft.ini here.
		var settingsFile = path & "/craft.ini"
		if (FileExists(settingsFile)) {
			var sections = GetProfileSections(settingsFile)
			// If there is no section named 'craft', or if this section doesn't contain a namespace key, throw an exception.
			if (!sections.keyExists("craft") || sections.craft.listFind("namespace") == 0) {
				Throw("Namespace not found in #settingsFile#", "NoSuchElementException");
			}

			var namespace = GetProfileString(settingsFile, "craft", "namespace")
			var namespaceTags = this.tags[namespace] = {}

			var registerPaths = null
			if (sections.craft.listFind("directories") > 0) {
				// The directories key contains a comma separated list of directories that should exist below the current one.
				var directories = GetProfileString(settingsFile, "craft", "directories")
				registerPaths = directories.listToArray().map(function (directory) {
					var directory = arguments.directory.trim()
					var separator = directory.startsWith("/") ? "" : "/"
					return path & separator & directory;
				})
			} else {
				registerPaths = [path]
			}

			var mapping = arguments.mapping
			registerPaths.each(function (registerPath) {
				var registerPath = arguments.registerPath
				var subdirectory = registerPath.replace(path, "")
				// Pick up all components in this directory (recursively) and keep the ones that extend Element.
				DirectoryList(registerPath, true, "path", "*.cfc").each(function (filePath) {
					// Construct the component name. Replace the directory with the mapping, make that a dot delimited path and remove the cfc extension.
					var componentName = arguments.filePath.replace(registerPath, mapping & subdirectory).listChangeDelims(".", "/").reReplace("\.cfc$", "")
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

	public void function deregister(required String mapping) {

		var path = ExpandPath(arguments.mapping)

		// See if there is a craft.ini here.
		var settingsFile = path & "/craft.ini"
		if (FileExists(settingsFile)) {
			var sections = GetProfileSections(settingsFile)
			// If there is no section named 'craft', or if this section doesn't contain a namespace key, throw an exception.
			if (!sections.keyExists("craft") || sections.craft.listFind("namespace") == 0) {
				Throw("Namespace not found in #settingsFile#", "NoSuchElementException");
			}

			var namespace = GetProfileString(settingsFile, "craft", "namespace")

			this.tags.delete(namespace)

		} else {
			// Call again for each subdirectory.
			var mapping = arguments.mapping
			DirectoryList(path, false, "name").each(function (name) {
				if (DirectoryExists(path & "/" & arguments.name)) {
					deregister(mapping & "/" & arguments.name)
				}
			})
		}
	}

	public void function deregisterNamespace(required String namespace) {
		this.tags.delete(arguments.namespace)
	}

	public Struct function getTagNames() {
		return this.tags.map(function (namespace, metadata) {
			// The metadata argument is a struct where the keys are tag names.
			return arguments.metadata.keyArray();
		});
	}

	/**
	 * Returns whether `Element` is in the inheritance chain of the given metadata.
	 */
	private Boolean function extendsElement(required Struct metadata) {

		var result = arguments.metadata.name == GetComponentMetadata("Element").name

		if (!result && arguments.metadata.keyExists("extends")) {
			result = extendsElement(arguments.metadata.extends)
		}

		return result;
	}

	/**
	 * Creates a tree of `Element`s that represents the given xml node tree.
	 */
	public Element function convert(required XML node) {

		var tagName = arguments.node.xmlName.replace(arguments.node.xmlNsPrefix & ":", "") // Remove the namespace prefix, if it exists.
		var element = create(arguments.node.xmlNsURI, tagName, arguments.node.xmlAttributes)
		for (var child in arguments.node.xmlChildren) {
			element.add(convert(child))
		}

		return element;
	}

	/**
	 * Creates `Element` instances based on namespace, tag name and optional attributes.
	 */
	public Element function create(required String namespace, required String tagName, Struct attributes = {}) {

		if (!this.tags.keyExists(arguments.namespace)) {
			Throw("Namespace '#arguments.namespace#' not found", "NoSuchElementException");
		}

		var tags = this.tags[arguments.namespace]
		if (!tags.keyExists(arguments.tagName)) {
			Throw("Tag '#arguments.tagName#' not found in namespace '#arguments.namespace#'", "NoSuchElementException");
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
			var value = values[name] ?: arguments.attribute.default ?: null

			if (value === null && (arguments.attribute.required ?: false)) {
				Throw("Attribute '#name#' is required", "IllegalArgumentException");
			}

			if (value !== null) {
				// Assuming we'll only encounter simple values here, we can use IsValid. We also assume that the property type is specified.
				if (!IsValid(arguments.attribute.type, value)) {
					Throw("Invalid value '#value#' for attribute '#name#': #arguments.attribute.type# expected", "IllegalArgumentException");
				}

				constructorArguments[name] = value
			}
		})

		return new "#data.name#"(argumentCollection: constructorArguments);
	}

	private Struct[] function collectProperties(required Struct metadata) {

		var properties = []
		var names = []
		var data = arguments.metadata

		do {
			for (var property in data.properties) {
				// Let a property in a subclass take precedence over one of the same name in a superclass.
				if (names.find(property.name) == 0) {
					properties.append(property)
					names.append(property.name)
				}
			}

			data = data.extends ?: null
		} while (data !== null);

		return properties;
	}

	private Struct[] function collectAttributes(required Struct metadata) {
		// Filter the properties for those that can be attributes.
		return collectProperties(arguments.metadata).filter(function (property) {
			// If the property has an attribute annotation (a boolean), return that. If absent, include the property.
			return arguments.property.attribute ?: true;
		});
	}

}