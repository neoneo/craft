import craft.util.Metadata;

/**
 * Dependency injector.
 */
component accessors = true {

	property ObjectProvider parent setter = false;

	this.cache = {
		objectProvider: this
	}
	this.registry = {}
	this.aliases = {}

	this.metadata = new Metadata()

	public void function init(ObjectProvider parent) {
		this.parent = arguments.parent ?: null
	}

	/**
	 * Scans the mapping for classes to be provided. Classes without a singleton or transient annotation are ignored, as are classes
	 * with an abstract annotation.
	 */
	public void function registerAll(required String mapping) {
		this.metadata.list(arguments.mapping, true).each(function (metadata) {
			this.registerMetadata(arguments.metadata)
		})
	}

	public void function register(required String mapping) {
		this.registerMetadata(GetComponentMetadata(arguments.mapping))
	}

	private void function registerMetadata(required Struct metadata) {
		var abstract = arguments.arguments.metadata.abstract ?: false
		if (!abstract) {
			// Search for the @singleton and @transient annotations in the class or its superclasses.
			var singleton = this.metadata.annotation(arguments.metadata, "singleton") ?: false
			var transient = !singleton && (this.metadata.annotation(arguments.metadata, "transient") ?: false)
			if (singleton || transient) {
				var functions = this.metadata.collectFunctions(arguments.metadata)
				var info = {
					name: null, // The name this class is registered under.
					class: arguments.metadata.name,
					singleton: singleton,
					constructor: null,
					setters: null,
					configure: functions.keyExists("configure") && functions.configure.access == "public"
				}

				// Find the constructor, if defined.
				if (functions.keyExists("init") && functions.init.access == "public") {
					if (functions.init.inject ?: true) {
						info.constructor = functions.init.parameters.filter(function (parameter) {
							return arguments.parameter.inject ?: true;
						})
					}
				}

				if (arguments.metadata.accessors) {
					var properties = this.metadata.collectProperties(arguments.metadata)
					var setters = properties.filter(function (name, property) {
						// Only include the setter if it is public, and has no @inject = false annotation.
						var setter = "set" & arguments.name
						return functions.keyExists(setter) && functions[setter].access == "public" && (arguments.property.inject ?: true);
					}).map(function (name, property) {
						return {
							type: arguments.property.type,
							required: arguments.property.required ?: false
						}
					})
					if (!setters.isEmpty()) {
						info.setters = setters
					}
				}

				// Try to register under a short name. Create aliases for all longer names, including packages.
				var parts = arguments.metadata.name.listToArray(".").reverse()
				var name = ""
				for (var part in parts) {
					name = name.listPrepend(part, ".")
					if (!this.has(name, false)) {
						if (info.name === null) {
							this.registry[name] = info
							info.name = name
						} else {
							// Refer to the registration with an alias.
							this.aliases[name] = info.name
						}
					}
				}
				if (info.name === null) {
					// Could not register this class, probably because it is already registered since all of its possible aliases are already taken.
					Throw("Object '#arguments.metadata.name#' is already registered", "AlreadyBoundException");
				}

				var alias = this.metadata.annotation(arguments.metadata, "alias")
				if (alias !== null) {
					this.registerAlias(info.name, alias)
				}
			}
		}
	}

	/**
	 * Maps the given alias to the given name.
	 */
	public void function registerAlias(required String name, required String alias) {
		if (!this.has(arguments.name, false)) {
			Throw("Object '#arguments.name#' is not registered", "NotBoundException");
		}
		if (this.has(arguments.alias, false)) {
			Throw("Object '#arguments.alias#' is already registered", "AlreadyBoundException");
		}

		this.aliases[arguments.alias] = arguments.name
	}

	/**
	 * Registers any value under the given name as a singleton.
	 */
	public void function registerValue(required String name, required Any value) {
		if (this.has(arguments.name, false)) {
			Throw("Object '#arguments.name#' is already registered", "AlreadyBoundException");
		}

		this.cache[arguments.name] = arguments.value
	}

	/**
	 * Returns whether an object is registered under the given name.
	 */
	public Boolean function has(required String name, Boolean recursive = true) {
		if (this.cache.keyExists(arguments.name) || this.registry.keyExists(arguments.name) || this.aliases.keyExists(arguments.name)) {
			return true;
		}

		if (arguments.recursive && this.parent !== null) {
			return this.parent.has(arguments.name, arguments.recursive);
		}

		return false;
	}

	/**
	 * Returns metadata about the object registered under the name or alias.
	 */
	public Struct function info(required String name) {
		var slot = arguments.name
		if (!this.registry.keyExists(arguments.name) && this.aliases.keyExists(arguments.name)) {
			slot = this.aliases[arguments.name]
		}
		if (this.registry.keyExists(slot)) {
			return this.registry[slot];
		} else if (this.parent !== null) {
			return this.parent.info(arguments.name);
		}

		Throw("Info for object '#arguments.name#' not found", "NotBoundException");
	}

	public Boolean function isSingleton(required String name) {
		return this.info(arguments.name).singleton;
	}

	/**
	 * Returns whether the instantiation of the object registered under the name or alias is managed by this `ObjectProvider` or its parent.
	 */
	public Boolean function isManaged(required String name) {
		var slot = arguments.name
		if (!this.registry.keyExists(arguments.name) && this.aliases.keyExists(arguments.name)) {
			slot = this.aliases[arguments.name]
		}

		if (this.registry.keyExists(slot)) {
			return true;
		} else if (this.parent !== null) {
			return this.parent.isManaged(arguments.name);
		}

		return false;
	}

	/**
	 * Returns the object registered under the given name. If necessary, the object is instantiated and, if it's a singleton, cached.
	 */
	public Any function instance(required String name, Any properties = null) {
		if (!this.cache.keyExists(arguments.name)) {
			if (this.has(arguments.name, false)) {
				// First check if the name is actually an alias. An alias can refer to anything, so no info may be available for it.
				if (this.aliases.keyExists(arguments.name)) {
					return this.instance(this.aliases[arguments.name], arguments.properties);
				}
				// The name should be registered for some class.
				if (this.registry.keyExists(arguments.name)) {
					var info = this.info(arguments.name)
					var instance = this.instantiate(info, arguments.properties)
					if (info.singleton) {
						this.cache[arguments.name] = instance
					}

					return instance;
				}
			} else if (this.parent !== null) {
				return this.parent.instance(arguments.name, arguments.properties);
			}

			Throw("Object '#arguments.name#' is not registered", "NotBoundException");
		}

		return this.cache[arguments.name];
	}

	/**
	 * Returns a new instance of the class registered under the given name.
	 */
	public Component function newInstance(required String name, Any properties = null) {
		if (this.has(arguments.name, false)) {
			if (this.aliases.keyExists(arguments.name)) {
				return this.newInstance(this.aliases[arguments.name], arguments.properties);
			}
			return this.instantiate(this.info(arguments.name), arguments.properties);
		} else if (this.parent !== null) {
			return this.parent.newInstance(arguments.name, arguments.properties);
		}

		Throw("Object '#arguments.name#' is not registered", "NotBoundException");
	}

	/**
	 * Returns an instance defined by the given info, and injects dependencies.
	 * Any property in the properties struct takes precedence over a registered object.
	 */
	private Component function instantiate(required Struct info, Any properties) {

		var instance = CreateObject(arguments.info.class)

		if (arguments.info.constructor !== null) {
			var collection = {}
			// The info contains the parameters array from the original function metadata.
			for (var parameter in arguments.info.constructor) {
				var name = parameter.name
				if (arguments.properties !== null && arguments.properties.keyExists(name)) {
					collection[name] = arguments.properties[name]
				} else if (this.has(name & "@" & arguments.info.name, true)) {
					name &= "@" & arguments.info.name
					// If multiple classes have properties or constructor arguments by the same name, allow the client to differentiate
					// by registering an alias of the form <property>@<class>.
					// If the object is a transient, only inject it if the parameter is required.
					if (parameter.required || !this.isManaged(name) || this.isSingleton(name)) {
						collection[name] = this.instance(name)
					}
				} else if (this.has(name, true)) {
					// The parent has the object. Apply the same reasoning regarding transient objects.
					if (parameter.required || !this.isManaged(name) || this.isSingleton(name)) {
						collection[name] = this.instance(name)
					}
				} else {
					if (parameter.required) {
						Throw("Cannot find object for required constructor argument '#name#'", "MissingArgumentException");
					}
				}
			}

			instance.init(argumentCollection: collection)
		}

		if (arguments.info.setters !== null) {
			for (var name in arguments.info.setters) {
				// We need implicit accessors enabled.
				if (arguments.properties !== null && arguments.properties.keyExists(name)) {
					instance[name] = arguments.properties[name]
				} else if (this.has(name & "@" & arguments.info.name, true)) {
					instance[name] = this.instance(name & "@" & arguments.info.name)
				} else if (this.has(name, true)) {
					instance[name] = this.instance(name)
				} else {
					if (arguments.info.setters[name].required) {
						Throw("Cannot find object for required property '#name#'", "MissingArgumentException");
					}
				}
			}
		}

		if (arguments.info.configure) {
			instance.configure()
		}

		return instance;
	}

	public ObjectProvider function spawn() {
		return new ObjectProvider(this);
	}

}