import craft.util.ObjectProvider;

/**
 * @singleton
 */
component accessors = true {

	property Array namespaces setter = false;

	this.objectProviders = {} // Object providers per namespace.

	public void function init(required ObjectProvider objectProvider) {
		this.objectProvider = arguments.objectProvider
	}

	/**
	 * Registers any classes found in the mapping. A craft.ini file must be present in order for any classes to be registered.
	 * If absent, the subdirectories are searched for craft.ini files and `register()` is then called recursively.
	 * The mapping should be passed in without a trailing slash.
	 */
	public void function register(required String mapping) {

		var mapping = arguments.mapping
		var path = ExpandPath(mapping)

		// See if there is a craft.ini here.
		var settingsFile = path & "/craft.ini"
		if (FileExists(settingsFile)) {
			var sections = GetProfileSections(settingsFile)
			// If there is no section named 'craft', or if this section doesn't contain a namespace key, throw an exception.
			if (!sections.keyExists("craft") || sections.craft.listFind("namespace") == 0) {
				Throw("Namespace not found in #settingsFile#", "ConfigurationException");
			}

			var namespace = GetProfileString(settingsFile, "craft", "namespace")

			if (this.objectProviders.keyExists(namespace)) {
				Throw("Namespace '#namespace#' already exists", "AlreadyBoundException");
			}

			var objectProvider = this.objectProviders[namespace] = this.objectProvider.spawn()

			var registerMappings = null
			if (sections.craft.listFind("directories") > 0) {
				// The directories key contains a comma separated list of directories that should exist below the current one.
				var directories = GetProfileString(settingsFile, "craft", "directories")
				registerMappings = directories.listToArray().map(function (directory) {
					var directory = arguments.directory.trim()
					var separator = directory.startsWith("/") ? "" : "/"
					return mapping & separator & directory;
				})
			} else {
				registerMappings = [mapping]
			}

			registerMappings.each(function (mapping) {
				objectProvider.registerAll(arguments.mapping)
			})
		} else {
			// Call again for each subdirectory.
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
		this.objectProviders.delete(arguments.namespace)
	}

	public ObjectProvider function get(required String namespace) {
		if (!this.objectProviders.keyExists(arguments.namespace)) {
			Throw("Namespace '#arguments.namespace#' does not exist", "NotBoundException");
		}

		return this.objectProviders[arguments.namespace];
	}

	public String[] function getNamespaces() {
		return this.objectProviders.keyArray();
	}

}