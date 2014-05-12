component {

	public void function init(TemplateFinder templateFinder, TemplateRenderer templateRenderer) {
		variables._templateFinder = arguments.templateFinder ?: null
		if (!IsNull(variables._templateFinder)) {
			if (IsNull(arguments.templateRenderer)) {
				Throw("TemplateRenderer is required", "IllegalArgumentException")
			}
			variables._templateRenderer = arguments.templateRenderer
		}
		clear()
	}

	public void function clear() {
		variables._cache = {}
		variables._mappings = StructNew("linked")
	}

	// TODO: addMapping and removeMapping duplicate code in TemplateFinder.
	public void function addMapping(required String mapping) {
		if (variables._mappings.keyExists(arguments.mapping)) {
			Throw("Mapping '#arguments.mapping# already exists", "AlreadyBoundException")
		}
		variables._mappings[arguments.mapping] = ExpandPath(arguments.mapping)
	}

	public void function removeMapping(required String mapping) {
		if (variables._mappings.keyExists(arguments.mapping)) {
			variables._mappings.delete(arguments.mapping)
			// The mapping serves as the prefix for all keys to be removed from the cache.
			var prefix = arguments.mapping
			// Get a key array first and then delete from the cache.
			variables._cache.keyArray().each(function (key) {
				if (arguments.key.left(prefix.len()) == prefix) {
					variables._cache.delete(arguments.key)
				}
			})
		}
	}

	public View function get(required String viewName) {

		if (!variables._cache.keyExists(arguments.viewName)) {
			var view = null
			// TODO: find out how to check for existence in Railo archives.
			var componentPath = ExpandPath("/" & ListChangeDelims(arguments.viewName, "/", ".") & ".cfc"
			if (FileExists(componentPath)) {
				view = new "#arguments.viewName#"()
			} else {
				// Check if it's a template.
				if (!IsNull(variables._templateFinder)) {
					var template = variables._templateFinder.get(arguments.viewName)
					if (!IsNull(template)) {
						view = new TemplateView(template, variables._templateRenderer)
					}
				}
			}
			if (IsNull(view)) {
				Throw("View '#arguments.viewName#' not found", "FileNotFoundException")
			}
			variables._cache[arguments.viewName] = view
		}

		return variables._cache[arguments.viewName]
	}

	private Any function locate(required String template) {

		var filename = arguments.template & "." & variables._extension
		var template = null

		variables._mappings.some(function (mapping, directory) {
			if (FileExists(arguments.directory & "/" & filename)) {
				template = arguments.mapping & "/" & filename
				return true
			}

			return false
		});

		return template
	}

}