component {

	this.accessLevels = {
		private: 1,
		package: 2
		public: 3,
		remote: 4
	}

	/**
	 * Returns whether the method exists in the object and can be invoked given the minimum access level.
	 */
	public Boolean function methodExists(required Any object, required String methodName, String access = "private") {

		var metadata = GetMetaData(arguments.object)

		var methodName = arguments.methodName
		var accessLevel = this.accessLevels[arguments.access]
		var index = metadata.functions.find(function (metadata) {
			return arguments.metadata.name == methodName && this.accessLevels[arguments.metadata.access] >= accessLevel;
		})

		return index > 0;
	}

	/**
	 * Initializes the object. Applicable if the object is not created using `new`.
	 */
	public void function initialize(required Any object, Struct parameters = {}) {

		// If the instance has a public init method, invoke it. Otherwise, run setters for each item in the argument collection.
		if (this.methodExists(arguments.object, "init", "public")) {
			arguments.object.init(argumentCollection: arguments.parameters)
		} else {
			var object = arguments.object
			arguments.parameters.each(function (name, value) {
				var setter = "set" & arguments.name
				if (this.methodExists(object, setter, "public")) {
					Invoke(object, setter, [arguments.value])
				}
			})
		}

	}

}