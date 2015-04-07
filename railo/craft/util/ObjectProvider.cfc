import craft.util.Metadata;

/**
 * Dependency injector.
 */
component {

	public void function init(ObjectProvider parent) {
		this.parent = arguments.parent ?: null
		this.metadata = new Metadata()

		this.cache = {
			objectProvider: this
		}
		this.registry = {}
		this.aliases = {}
	}

	/**
	 * Scans the mapping for classes to be provided. Classes without a singleton or transient annotation are ignored, as are classes
	 * with an abstract annotation.
	 */
	public void function registerAll(required String mapping) {

		for (var metadata in this.metadata.scan(arguments.mapping, true)) {

			var abstract = metadata.abstract ?: false
			if (!abstract) {
				var singleton = metadata.singleton ?: false
				var transient = metadata.transient ?: false
				if (singleton || transient) {
					var info = {
						class: metadata.name,
						singleton: singleton,
						constructor: null,
						setters: null
					}

					var functions = this.metadata.collectFunctions(metadata)
					// Find the constructor, if defined.
					if (this.metadata.methodExists(metadata, "init", "public")) {
						var index = functions.find(function (metadata) {
							return arguments.metadata.name == "init";
						})
						info.constructor = functions[index].parameters
					}

					if (metadata.accessors) {
						var properties = this.metadata.collectProperties(metadata)
						var setters = {}
						for (var property in properties) {
							// Only include the setter if it is public.
							if (this.metadata.methodExists(metadata, "set" & property.name, "public")) {
								setters[property.name] = {
									type: property.type,
									required: property.required ?: false
								}
							}
						}
						if (!setters.isEmpty()) {
							info.setters = setters
						}
					}

					// Try to register under a short name. Create aliases for all longer names, including packages.
					var parts = metadata.name.listToArray(".").reverse()
					var name = ""
					var registered = false
					var registerName = null
					for (var part in parts) {
						name = name.listPrepend(part, ".")
						if (!this.has(name, false)) {
							if (!registered) {
								this.registry[name] = info
								registerName = name
								registered = true
							} else {
								// Refer to the registration with an alias.
								this.aliases[name] = registerName
							}
						}
					}
					if (!registered) {
						Throw("Object '#metadata.name#' is already registered", "AlreadyBoundException");
					}
				}
			}

		}

	}

	/**
	 * Maps the given name to the given alias.
	 */
	public void function registerAlias(required String alias, required String name) {
		if (this.has(arguments.name, false)) {
			Throw("Object '#arguments.name#' is already registered", "AlreadyBoundException");
		}
		this.aliases[arguments.alias] = arguments.name
	}

	/**
	 * Registers any value (objects and constants) under the given name as a singleton.
	 */
	public void function register(required String name, required Any value) {
		if (this.has(arguments.name, false)) {
			Throw("Object '#arguments.name#' is already registered", "AlreadyBoundException");
		}

		this.cache[arguments.name] = arguments.value
	}

	/**
	 * Returns whether an object is registered under the given name.
	 */
	public Boolean function has(required String name, Boolean recursive = true) {
		var found = this.registry.keyExists(arguments.name) || this.aliases.keyExists(arguments.name)
		if (!found && arguments.recursive && this.parent !== null) {
			found = this.parent.has(arguments.name, true)
		}

		return found;
	}

	/**
	 * Returns metadata about the object registered under the name or alias. The parent provider is not searched.
	 */
	public Struct function info(required String name) {
		var register = arguments.name
		if (!this.registry.keyExists(arguments.name) && this.aliases.keyExists(arguments.name)) {
			register = this.aliases[arguments.name]
		}
		if (!this.registry.keyExists(register)) {
			Throw("Info for object '#arguments.name#' not found", "NotBoundException");
		}

		return this.registry[register];
	}

	/**
	 * Returns the object or constant registered under the given name. If necessary, the object is instantiated and, if it's a singleton, cached.
	 */
	public Any function instance(required String name, Struct properties = {}) {
		if (!this.cache.keyExists(arguments.name)) {
			if (this.has(arguments.name, false)) {
				var info = this.info(arguments.name)
				var instance = this.instantiate(info, arguments.properties)
				if (info.singleton) {
					this.cache[arguments.name] = instance
				}

				return instance;
			} else if (this.parent !== null) {
				return this.parent.instance(arguments.name, arguments.properties);
			}
		}

		return this.cache[arguments.name];
	}

	/**
	 * Returns a new instance of the class registered under the given name.
	 */
	public Component function newInstance(required String name, Struct properties = {}) {
		if (this.has(arguments.name, false)) {
			return this.instantiate(this.info(arguments.name), arguments.properties);
		} else if (this.parent !== null) {
			return this.parent.newInstance(arguments.name, arguments.properties);
		}
	}

	/**
	 * Returns an instance defined by the given info, and injects dependencies.
	 * Any property in the properties struct takes precedence over a registered object.
	 */
	private Component function instantiate(required Struct info, required Struct properties) {
		if (arguments.info.constructor !== null) {
			var collection = {}
			// The info contains the parameters array from the original function metadata.
			for (var parameter in arguments.info.constructor) {
				var name = parameter.name
				if (arguments.properties.keyExists(name)) {
					collection[name] = properties[name]
				} else if (this.has(name & "@" & info.name, true)) {
					collection[name] = this.instance(name & "@" & info.name)
				} else if (this.has(name, true)) {
					collection[name] = this.instance(name)
				} else {
					if (parameter.required) {
						Throw("Cannot find object for required constructor argument #parameter.name#");
					}
				}
			}
		}

		var instance = new "#arguments.info.class#"(argumentCollection: collection)

		if (arguments.info.setters !== null) {
			for (var name in arguments.info.setters) {
				if (arguments.properties.keyExists(name)) {
					Invoke(instance, "set" & name, [arguments.properties[name]])
				} if (this.has(name, true)) {
					Invoke(instance, "set" & name, [this.instance(name)])
				} else if (arguments.info.setters[name].required ?: false) {
					Throw("Cannot find object for required property #parameter.name#");
				}
			}
		}

		return instance;
	}

}