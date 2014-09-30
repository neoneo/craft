import craft.output.ViewFactory;

component {

	public void function init(required ViewFactory viewFactory) {
		this.viewFactory = arguments.viewFactory

		this.dotMappings = StructNew("linked") // Map between mappings and dot mappings.
		this.qualifiedNames = {} // Cache that maps names to fully qualified names.
	}

	public Component function create(required String name, Struct properties = {}) {

		if (this.qualifiedNames.keyExists(arguments.name)) {
			return new "#this.qualifiedNames[arguments.name]#"(this.viewFactory, arguments.properties);
		} else {
			for (var mapping in dotMappings) {
				if (FileExists(ExpandPath(mapping) & "/"))
			}
		}
	}

	public void function addMapping(required String mapping) {
		var dotMapping = arguments.mapping.listChangeDelims(".", "/")
		if (!dotMapping.isEmpty()) {
			this.dotMappings[arguments.mapping] = dotMapping & "."
		}
	}

	public void function removeMapping(required String mapping) {
		this.dotMappings.delete(arguments.mapping)

		var dotMapping = arguments.mapping.listChangeDelims(".", "/")
		this.qualifiedNames = this.qualifiedNames.filter(function (name, componentName) {
			return !arguments.componentName.startsWith(dotMapping);
		})
	}

}