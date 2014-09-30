component extends="TemplateFinder" {

	public void function init() {
		super.init("cfc")

		this.viewMappings = {}
	}

	public void function removeMapping(required String mapping) {
		super.removeMapping(arguments.mapping)
		this.viewMappings = this.viewMappings.filter(function () {

		})
	}

	public String function get(required String view) {

		if (this.viewMappings.keyExists(arguments.view)) {
			return this.viewMappings[arguments.view];
		} else {
			// The superclass uses slash delimited paths.
			var name = arguments.view.listChangeDelims("/", ".")
			var path = super.get(name)

			// Convert the returned path to a dot delimited mapping and remove the cfc extension.
			var className = path.listChangeDelims(".", "/").reReplace("\.cfc$", "")

			this.viewMappings[arguments.view] = className

			return className;
		}
	}

}