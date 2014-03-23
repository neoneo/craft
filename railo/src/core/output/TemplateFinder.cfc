component {

	public void function init(required String extension) {
		variables._extension = arguments.extension
		clear()
	}

	public void function clear() {
		variables._cache = {}
		variables._locations = StructNew("linked") // The order of the locations is important.
	}

	public void function addMapping(required String mapping) {
		if (variables._locations.keyExists(arguments.mapping)) {
			Throw("Mapping '#arguments.mapping# already exists", "AlreadyBoundException")
		}
		variables._locations[arguments.mapping] = ExpandPath(arguments.mapping)
	}

	public void function removeMapping(required String mapping) {
		if (variables._locations.keyExists(arguments.mapping)) {
			variables._locations.delete(arguments.mapping)
			// The mapping serves as the prefix for all keys to be removed from the cache.
			var prefix = arguments.mapping
			// Get a key array first and then delete from the cache.
			variables._cache.keyArray().each(function (key) {
				if (Left(arguments.key, Len(prefix)) == prefix) {
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

		var template = null

		for (var path in variables._locations) {
			var directory = variables._locations[path]
			var filename = arguments.template & "." & variables._extension
			if (FileExists(directory & "/" & filename)) {
				template = path & "/" & filename
				break;
			}
		}

		return template
	}

	public Boolean function exists(required String template) {
		return !IsNull(locate(arguments.template))
	}

}