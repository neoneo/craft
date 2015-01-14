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
	public Boolean function methodExists(required Struct metadata, required String methodName, String requiredAccess = "private") {

		var metadata = arguments.metadata
		var methodName = arguments.methodName
		var accessLevel = this.accessLevels[arguments.requiredAccess]

		do {
			if (metadata.keyExists("functions")) {
				var index = metadata.functions.find(function (metadata) {
					return arguments.metadata.name == methodName;
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

		var success = arguments.metadata.name == arguments.className

		if (!success && arguments.metadata.keyExists("extends")) {
			success = this.extends(arguments.metadata.extends, arguments.className)
		}

		return success;
	}

	/**
	 * Initializes the object. Applicable if the object is not created using `new`.
	 */
	public void function initialize(required Component object, Struct parameters = {}) {

		// If the instance has a public init method, invoke it. Otherwise, run setters for each item in the argument collection.
		var metadata = GetMetadata(arguments.object)
		if (this.methodExists(metadata, "init", "public")) {
			arguments.object.init(argumentCollection: arguments.parameters)
		} else {
			var object = arguments.object
			arguments.parameters.each(function (name, value) {
				var setter = "set" & arguments.name
				if (this.methodExists(metadata, setter, "public")) {
					Invoke(object, setter, [arguments.value])
				}
			})
		}

	}

	/**
	 * Injects all public and remote functions defined in the trait into the object.
	 */
	public void function mixin(required Component object, required Component trait) {

		var accessLevel = this.accessLevels.public

		var object = arguments.object
		var trait = arguments.trait
		this.collectFunctions(GetMetadata(arguments.trait)).each(function (metadata) {
			if (this.accessLevels[arguments.metadata.access] >= accessLevel) {
				var name = arguments.metadata.name
				object[name] = trait[name]
			}
		})

	}

	/**
	 * Returns the metadata of all properties defined in the given metadata (obtained using `GetMetadata` or `GetComponentMetadata`).
	 */
	public Struct[] function collectProperties(required Struct metadata) {
		return collect("properties", arguments.metadata);
	}

	public Struct[] function collectFunctions(required Struct metadata) {
		return collect("functions", arguments.metadata);
	}

	private Struct[] function collect(required String type, required Struct metadata) {
		var items = []
		var names = []
		var metadata = arguments.metadata

		while (metadata !== null && metadata.keyExists(arguments.type)) {
			for (var item in metadata[arguments.type]) {
				// Let an item in a subclass take precedence over one of the same name in a superclass.
				if (names.find(item.name) == 0) {
					items.append(item)
					names.append(item.name)
				}
			}

			metadata = metadata.extends ?: null
		};

		return items;
	}


}