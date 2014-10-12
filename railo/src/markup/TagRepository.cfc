import craft.util.ObjectHelper;

component {

	property Struct tagNames setter="false";

	public void function init(required ElementFactory elementFactory) {
		this.elementFactory = arguments.elementFactory // The default element factory.
		this.tags = {} // Keeps metadata of tags per namespace.
		this.factories = {} // Element factories per namespace.
		this.factoryCache = {} // Used in order to create one instance per factory class.

		this.objectHelper = new ObjectHelper()
	}

	/**
	 * Registers any `Element`s found in the mapping. A craft.ini file must be present in order for any classes to be inspected.
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

			if (this.tags.keyExists(namespace)) {
				Throw("Namespace '#namespace#' already exists", "AlreadyBoundException");
			}
			this.tags[namespace] = {}

			// The element factory for this namespace can be specified by class name.
			if (sections.craft.listFind("factory") > 0) {
				// The class name is interpreted relative to the current mapping.
				var className = arguments.mapping.listChangeDelims(".", "/") & "." & GetProfileString(settingsFile, "craft", "factory")
				if (!this.factoryCache.keyExists(className)) {
					this.factoryCache[className] = new "#className#"()
				}
				this.factories[namespace] = this.factoryCache[className]
			} else {
				// Use the default element factory.
				this.factories[namespace] = this.elementFactory
			}

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
				// Pick up all classes in this directory (recursively) and keep the ones that extend Element.
				DirectoryList(registerPath, true, "path", "*.cfc").each(function (filePath) {
					// Construct the class name. Replace the directory with the mapping, make that a dot delimited path and remove the cfc extension.
					var className = arguments.filePath.replace(registerPath, mapping & subdirectory).listChangeDelims(".", "/").reReplace("\.cfc$", "")
					var metadata = GetComponentMetadata(className)

					// Ignore classes with the abstract annotation.
					var abstract = metadata.abstract ?: false
					if (!abstract && this.extendsElement(metadata)) {
						// If a tag annotation is present, that will be the tag name. Otherwise we take the class name.
						var tagName = metadata.tag ?: metadata.name
						var data = {
							class: metadata.name,
							attributes: this.collectAttributes(metadata)
						}
						// Store the tag data.
						this.tags[tagName] = data
					}
				})
			})
		} else {
			// Call again for each subdirectory.
			var mapping = arguments.mapping
			DirectoryList(path, false, "name").each(function (name) {
				if (DirectoryExists(path & "/" & arguments.name)) {
					this.register(mapping & "/" & arguments.name)
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

			this.deregisterNamespace(namespace)

		} else {
			// Call again for each subdirectory.
			var mapping = arguments.mapping
			DirectoryList(path, false, "name").each(function (name) {
				if (DirectoryExists(path & "/" & arguments.name)) {
					this.deregister(mapping & "/" & arguments.name)
				}
			})
		}
	}

	public void function deregisterNamespace(required String namespace) {
		this.tags.delete(arguments.namespace)
		this.factories.delete(arguments.namespace)
	}

	public Struct function getTagNames() {
		return this.tags.map(function (namespace, metadata) {
			// The metadata argument is a struct where the keys are tag names.
			return arguments.metadata.keyArray();
		});
	}

	public void function setElementFactory(required String namespace, required ElementFactory elementFactory) {
		this.factories[arguments.namespace] = arguments.elementFactory
	}

	/**
	 * Creates a tree of `Element`s that represents the given xml node tree.
	 */
	public Element function instantiate(required XML node) {

		var namespace = arguments.node.xmlNsPrefix
		if (!this.tags.keyExists(namespace)) {
			Throw("Namespace '#namespace#' not found", "NoSuchElementException");
		}

		var tags = this.tags[namespace]

		var tagName = arguments.node.xmlName.replace(namespace & ":", "") // Remove the namespace prefix, if it exists.
		if (!tags.keyExists(tagName)) {
			Throw("Tag '#arguments.tagName#' not found in namespace '#arguments.namespace#'", "NoSuchElementException");
		}

		// Attribute validation and selection:
		var data = tags[arguments.tagName]
		// Create a struct with attribute name/value pairs to pass to the factory.
		var attributes = {}
		// Loop over the attributes defined in the class, and pick them up from the node attributes.
		// This means that any attributes not defined in the class are ignored.
		var nodeAttributes = arguments.node.xmlAttributes
		data.attributes.each(function (attribute) {
			var name = arguments.attribute.name
			var value = nodeAttributes[name] ?: arguments.attribute.default ?: null

			if (value === null && (arguments.attribute.required ?: false)) {
				Throw("Attribute '#name#' is required", "IllegalArgumentException");
			}

			if (value !== null) {
				// Since we'll only encounter simple values here, we can use IsValid. We assume that the property type is specified.
				if (!IsValid(arguments.attribute.type, value)) {
					Throw("Invalid value '#value#' for attribute '#name#'", "IllegalArgumentException", "Expected value of type #arguments.attribute.type#");
				}

				attributes[name] = value
			}
		})

		// Get the factory for this namespace and create the element.
		var factory = this.factories[namespace]
		var element = factory.create(data.class, attributes, arguments.node.xmlText)

		for (var child in arguments.node.xmlChildren) {
			element.add(this.instantiate(child))
		}

		return element;
	}

	/**
	 * Returns whether `Element` is in the inheritance chain of the given metadata.
	 */
	private Boolean function extendsElement(required Struct metadata) {
		return this.objectHelper.extends(arguments.metadata, GetComponentMetadata("Element").name);
	}

	private Struct[] function collectAttributes(required Struct metadata) {
		// Filter the properties for those that can be attributes.
		return this.objectHelper.collectProperties(arguments.metadata).filter(function (property) {
			// If the property has an attribute annotation (a boolean), return that. If absent, include the property.
			return arguments.property.attribute ?: true;
		});
	}

}