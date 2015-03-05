component extends = FileFinder {

	public void function init() {
		super.init("cfc")

		this.classNames = {} // Map between names and class names.
	}

	public void function removeMapping(required String mapping) {
		super.removeMapping(arguments.mapping)

		var prefix = arguments.mapping.listChangeDelims(".", "/")
		this.classNames = this.classNames.filter(function (name, className) {
			return !arguments.className.startsWith(prefix)
		})
	}

	public String function get(required String name) {

		if (this.classNames.keyExists(arguments.name)) {
			return this.classNames[arguments.name];
		} else {
			// The superclass uses slash delimited paths.
			var mapping = super.get(arguments.name.listChangeDelims("/", "."))

			// Convert the returned mapping to a dot delimited mapping and remove the cfc extension.
			var className = mapping.listChangeDelims(".", "/").reReplace("\.cfc$", "")

			this.classNames[arguments.name] = className

			return className;
		}
	}

}