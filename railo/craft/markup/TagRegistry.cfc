import craft.util.ObjectHelper;

component accessors="true" {

	property Struct tagNames setter="false";

	this.elementClassName = GetComponentMetadata("Element").name
	this.factories = {} // Element factories per namespace.
	this.factoryCache = {} // Used in order to create one instance per factory class.
	this.tags = {} // Metadata of tags per namespace.

	this.objectHelper = new ObjectHelper()

	public void function init(required ElementFactory elementFactory) {
		this.defaultElementFactory = arguments.elementFactory
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
				Throw("Namespace not found in #settingsFile#", "ConfigurationException");
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
				this.factories[namespace] = this.defaultElementFactory
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
					if (!abstract && this.objectHelper.extends(metadata, this.elementClassName)) {
						// If a tag annotation is present, that will be the tag name. Otherwise we take the class name.
						var tagName = metadata.tag ?: metadata.name
						var data = {
							class: metadata.name,
							attributes: this.objectHelper.collectProperties(metadata).filter(function (property) {
								// If the property has an attribute annotation (a boolean), return that. If absent, include the property.
								return arguments.property.attribute ?: true;
							})
						}
						if (this.tags[namespace].keyExists(tagName)) {
							Throw("Tag '#tagName#' already exists in namespace '#namespace#'", "AlreadyBoundException");
						}
						// Store the tag data.
						this.tags[namespace][tagName] = data
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

	/**
	 * Deregisters the `Element`s found in the given mapping (as specified bij craft.ini).
	 */
	public void function deregister(required String mapping) {

		var path = ExpandPath(arguments.mapping)

		// See if there is a craft.ini here.
		var settingsFile = path & "/craft.ini"
		if (FileExists(settingsFile)) {
			var sections = GetProfileSections(settingsFile)
			// If there is no section named 'craft', or if this section doesn't contain a namespace key, throw an exception.
			if (!sections.keyExists("craft") || sections.craft.listFind("namespace") == 0) {
				Throw("Namespace not found in #settingsFile#", "NotBoundException");
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

	/**
	 * Returns the available tag names per namespace.
	 */
	public Struct function getTagNames() {
		return this.tags.map(function (namespace, metadata) {
			// The metadata argument is a struct where the keys are tag names.
			return arguments.metadata.keyArray();
		});
	}

	/**
	 * Returns metadata for the given tag in the given namespace.
	 */
	public Struct function get(required String namespace, required String tagName) {

		if (!this.tags.keyExists(arguments.namespace)) {
			Throw("Namespace '#arguments.namespace#' not found", "NotBoundException");
		}

		var tags = this.tags[arguments.namespace]

		if (!tags.keyExists(arguments.tagName)) {
			Throw("Tag '#arguments.tagName#' not found in namespace '#arguments.namespace#'", "NotBoundException");
		}

		return tags[arguments.tagName];
	}

	/**
	 * Returns the `ElementFactory` to be used for creating the `Element`s in the given namespace.
	 */
	public ElementFactory function elementFactory(required String namespace) {
		if (!this.factories.keyExists(arguments.namespace)) {
			Throw("Namespace '#arguments.namespace#' not found", "NotBoundException");
		}

		return this.factories[arguments.namespace];
	}

	public void function setElementFactory(required String namespace, required ElementFactory elementFactory) {
		if (!this.tags.keyExists(arguments.namespace)) {
			Throw("Namespace '#arguments.namespace#' not found", "NotBoundException");
		}

		this.factories[arguments.namespace] = arguments.elementFactory
	}

}