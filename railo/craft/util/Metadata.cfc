/**
 * The reflector provides methods for inspecting and modifying object instances.
 */
component {

	this.accessLevels = {
		private: 1,
		package: 2,
		public: 3,
		remote: 4
	}

	/**
	 * Returns whether the method is defined in the given metadata and has an access level at or above the required access level.
	 */
	public Boolean function functionExists(required Struct metadata, required String functionName, String requiredAccess = "private") {

		var metadata = arguments.metadata
		var functionName = arguments.functionName
		var accessLevel = this.accessLevels[arguments.requiredAccess]

		do {
			if (metadata.keyExists("functions")) {
				var index = metadata.functions.find(function (metadata) {
					return arguments.metadata.name == functionName;
				})

				if (index > 0) {
					// The method is found, so return immediately.
					return this.accessLevels[metadata.functions[index].access] >= accessLevel;
				}
			}

			metadata = metadata.extends ?: null
		} while (metadata !== null);

		return false;
	}

	/**
	 * Returns whether the given class is in the inheritance chain of the given metadata. Equivalent with `IsInstanceOf`, for metadata
	 * obtained with `GetComponentMetadata`.
	 */
	 public Boolean function extends(required Struct metadata, required String className) {
		if (arguments.metadata.name == arguments.className) {
			return true;
		}

		if (arguments.metadata.keyExists("extends")) {
			return this.extends(arguments.metadata.extends, arguments.className);
		}

		return false;
	}

	/**
	 * Returns the metadata of all properties defined in the given metadata (obtained using `GetMetadata` or `GetComponentMetadata`).
	 */
	public Struct function collectProperties(required Struct metadata) {
		return this.collect("properties", arguments.metadata);
	}

	/**
	 * Returns the metadata of all functions defined in the given metadata.
	 */
	public Struct function collectFunctions(required Struct metadata) {
		return this.collect("functions", arguments.metadata);
	}

	private Struct function collect(required String type, required Struct metadata) {

		var items = {}
		var metadata = arguments.metadata

		while (metadata !== null && metadata.keyExists(arguments.type)) {
			for (var item in metadata[arguments.type]) {
				// Let an item in a subclass take precedence over one of the same name in a superclass.
				if (!items.keyExists(item.name)) {
					items[item.name] = item
				}
			}

			metadata = metadata.extends ?: null
		}

		return items;
	}

	/**
	 * Returns the metadata for all classes found under the mapping.
	 */
	public Struct[] function list(required String mapping, Boolean recursive = true) {

		var mapping = arguments.mapping
		var directory = ExpandPath(mapping)
		return DirectoryList(directory, arguments.recursive, "path", "*.cfc").map(function (path) {
			// Construct the class name. Replace the directory with the mapping, make that a dot delimited path and remove the cfc extension.
			var className = arguments.path.replace(directory, mapping).listChangeDelims(".", "/").reReplace("\.cfc$", "")
			return GetComponentMetadata(className);
		}).filter(function (metadata) {
			return arguments.metadata.type == "component";
		});
	}

	/**
	 * Returns the value of the annotation if the metadata or its inheritance chain owns it.
	 */
	public Any function annotation(required Struct metadata, required String name) {
		if (arguments.metadata.keyExists(arguments.name)) {
			return arguments.metadata[arguments.name];
		}

		if (arguments.metadata.keyExists("extends")) {
			return this.annotation(arguments.metadata.extends, arguments.name);
		}

		return null;
	}

}