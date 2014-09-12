import craft.util.ScopeCache;

component extends="TemplateFinder" {

	public void function init() {
		super.init("cfc")

		this.viewMappings = {}
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