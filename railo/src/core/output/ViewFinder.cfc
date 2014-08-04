import craft.util.ScopeCache;

component {

	public void function init(TemplateFinder templateFinder, TemplateRenderer templateRenderer) {

		variables._templateFinder = arguments.templateFinder ?: null
		variables._templateRenderer = arguments.templateRenderer ?: null
		if (variables._templateFinder !== null) {
			// The template renderer is now required for creating template views.
			if (variables._templateRenderer === null) {
				Throw("TemplateRenderer is required", "IllegalArgumentException")
			}
		}

		/*
			The functionality needed for locating view components can be reused from TemplateFinder.
			We need to map some public methods, and keep a cache of View instances, as the template finder returns paths.
		*/
		variables._finder = new TemplateFinder("cfc")

		variables._cache = new ScopeCache()

	}

	public void function clear() {
		variables._finder.clear()
		variables._cache.clear()
	}

	public void function addMapping(required String mapping) {
		variables._finder.addMapping(arguments.mapping)
	}

	public void function removeMapping(required String mapping) {
		variables._finder.removeMapping(arguments.mapping)
	}

	/**
	 * Returns the `View` with the given name.
	 * The name is a dot delimited or slash delimited mapping, relative to one of the registered mappings.
	 * If a `View` component is not found, a template is searched if there is a `TemplateFinder`.
	 */
	public View function get(required String viewName) {

		if (!variables._cache.has(arguments.viewName)) {
			var view = null
			try {
				// The finder uses slash delimited paths.
				var path = variables._finder.get(arguments.viewName.listChangeDelims("/", "."))
				// Convert the returned path to a dot delimited mapping and remove the cfc extension.
				var mapping = path.listChangeDelims(".", "/").reReplace("\.cfc$", "")
				view = new "#mapping#"()

			} catch (FileNotFoundException e) {
				// No view component was found.
				if (variables._templateFinder !== null) {
					try {
						var template = variables._templateFinder.get(arguments.viewName)
						view = new TemplateView(template, variables._templateRenderer)
					} catch (FileNotFoundException e) {
						// Swallow the exception, we will throw a new one below.
					}
				}
			}

			if (view === null) {
				Throw("View '#arguments.viewName#' not found", "FileNotFoundException")
			}
			variables._cache.put(arguments.viewName, view)
		}

		return variables._cache.get(arguments.viewName)
	}

}