import craft.core.util.ScopeCache;

component {

	public void function init(required String extension) {
		variables._extension = arguments.extension
		variables._cache = new ScopeCache()
		clear()
	}

	public void function clear() {
		variables._cache.clear()
		variables._mappings = StructNew("linked") // The order of the mappings is important.
	}

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
			variables._cache.keys().each(function (key) {
				if (arguments.key.startsWith(prefix)) {
					variables._cache.remove(arguments.key)
				}
			})
		}
	}

	/**
	 * Returns the path including the mapping for the given template.
	 * The template should be passed in without the extension.
	 */
	public String function get(required String template) {

		if (!variables._cache.has(arguments.template)) {
			var fileName = locate(arguments.template)
			if (IsNull(fileName)) {
				Throw("Template '#arguments.template#' not found", "FileNotFoundException")
			}
			variables._cache.put(arguments.template, fileName)
		}

		return variables._cache.get(arguments.template)
	}

	private Any function locate(required String template) {

		var filename = arguments.template & "." & variables._extension
		var templatePath = NullValue()

		variables._mappings.some(function (mapping, directory) {
			// TODO: find out how to check for existence in Railo archives.
			if (FileExists(arguments.directory & "/" & filename)) {
				templatePath = arguments.mapping & "/" & filename
				return true
			}

			return false
		});

		return templatePath ?: NullValue()
	}

	public Boolean function exists(required String template) {
		return !IsNull(locate(arguments.template))
	}

}