component {

	public void function init(required String extension) {
		variables._extension = arguments.extension
		clear()
	}

	public void function clear() {
		variables._cache = {}
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
			variables._cache.keyArray().each(function (key) {
				if (arguments.key.left(prefix.len()) == prefix) {
					variables._cache.delete(arguments.key)
				}
			})
		}
	}

	public String function get(required String template) {

		if (!variables._cache.keyExists(arguments.template)) {
			var template = locate(arguments.template)
			if (IsNull(template)) {
				Throw("Template '#arguments.template#' not found", "FileNotFoundException")
			}
			variables._cache[arguments.template] = template
		}

		return variables._cache[arguments.template]
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

	public Boolean function exists(required String template) {
		return !IsNull(locate(arguments.template))
	}

}