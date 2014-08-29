import craft.util.ScopeCache;

component {

	public void function init(TemplateFinder templateFinder, TemplateRenderer templateRenderer) {

		this.templateFinder = arguments.templateFinder ?: null
		this.templateRenderer = arguments.templateRenderer ?: null
		if (this.templateFinder !== null) {
			// The template renderer is now required for creating template views.
			if (this.templateRenderer === null) {
				Throw("TemplateRenderer is required", "IllegalArgumentException")
			}
		}

		/*
			The functionality needed for locating view components can be reused from TemplateFinder.
			We need to map some public methods, and keep a cache of View instances, as the template finder returns paths.
		*/
		this.finder = new TemplateFinder("cfc")

		this.views = {}

	}

	public void function clear() {
		this.finder.clear()
		this.views.clear()
	}

	public void function addMapping(required String mapping) {
		this.finder.addMapping(arguments.mapping)
	}

	public void function removeMapping(required String mapping) {
		this.finder.removeMapping(arguments.mapping)
	}

	/**
	 * Returns the `View` with the given name.
	 * The name is a dot delimited or slash delimited mapping, relative to one of the registered mappings.
	 * If a `View` component is not found, a template is searched if there is a `TemplateFinder`.
	 */
	public View function get(required String viewName) {

		if (!this.views.keyExists(arguments.viewName)) {
			var view = null
			try {
				// The finder uses slash delimited paths.
				var path = this.finder.get(arguments.viewName.listChangeDelims("/", "."))
				// Convert the returned path to a dot delimited mapping and remove the cfc extension.
				var mapping = path.listChangeDelims(".", "/").reReplace("\.cfc$", "")
				view = new "#mapping#"()

			} catch (FileNotFoundException e) {
				// No view component was found.
				if (this.templateFinder !== null) {
					try {
						var template = this.templateFinder.get(arguments.viewName)
						view = new TemplateView(template, this.templateRenderer)
					} catch (FileNotFoundException e) {
						// Swallow the exception, we will throw a new one below.
					}
				}
			}

			if (view === null) {
				Throw("View '#arguments.viewName#' not found", "FileNotFoundException");
			}
			this.views[arguments.viewName] = view
		}

		return this.views[arguments.viewName];
	}

}