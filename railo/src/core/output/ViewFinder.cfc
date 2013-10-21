component {

	public void function init(required String fileContentType) {
		variables.fileContentType = "." & arguments.fileContentType
		reset()
	}

	public void function addMapping(required String mappingPath) {
		variables.mappings.append({path = arguments.mappingPath, directory = ExpandPath(arguments.mappingPath)})
	}

	public void function removeMapping(required String mappingPath) {
		var mappingPath = arguments.mappingPath
		var index = variables.mappings.find(function (mapping) {
			return arguments.mapping.path = mappingPath
		})
		if (index > 0) {
			variables.mappings.deleteAt(index)
			// The mappingPath serves as the prefix for all keys to be removed from the cache.
			removeByPrefix(mappingPath)
		}
	}

	public String function getTemplate(required String view, required String requestMethod, required ContentType contentType) {
		return get(arguments.view, arguments.requestMethod, arguments.contentType).template
	}

	public ContentType function getContentType(required String view, required String requestMethod, required ContentType contentType) {
		return get(arguments.view, arguments.requestMethod, arguments.contentType).contentType
	}

	public void function reset() {
		variables.cache = {}
		variables.mappings = []
	}

	public void function add(required String path) {
		var key = cacheKey(arguments.path)
		if (!IsNull(key)) {
			// The added file might have higher priority than similar files already cached.
			// Remove all similar keys. When requested the files will be put in the cache in priority order.
			var prefix = ListDeleteAt(key, ListLen(key, "."), ".")
			removeByPrefix(prefix)
		}
	}

	public void function remove(required String path) {
		var key = cacheKey(arguments.path)
		if (!IsNull(key)) {
			variables.cache.delete(key)
		}
	}

	private Struct function get(required String view, required String requestMethod, required ContentType contentType) {

		var key = arguments.view & "." & arguments.requestMethod & "." & arguments.contentType.getName()
		if (!variables.cache.keyExists(key)) {
			var extensions = ([arguments.contentType]).merge(arguments.contentType.getFallbacks()) // First look for the most specific template.
			// Search for files with or without the request method (in that order).
			var names = [
				arguments.view & "." & arguments.requestMethod,
				arguments.view
			]
			var found = false
			search:for (var contentType in extensions) {
				for (var name in names) {
					for (var mapping in variables.mappings) {
						var filename = name & "." & contentType.getName() & variables.fileContentType
						if (FileExists(mapping.directory & "/" & filename)) {
							variables.cache[key] = {
								template = mapping.path & "/" & filename,
								contentType = contentType
							}
							found = true
							break search;
						}
					}
				}
			}
			if (!found) {
				Throw("View '#arguments.view# for contentType #arguments.contentType.getName()#' not found", "ViewNotFoundException")
			}
		}

		return variables.cache[key]
	}

	private Any function cacheKey(required String path) {

		// The file name must end with the proper file extenstion.
		if (ListLast(arguments.path, ".") == variables.fileContentType) {
			var path = arguments.path
			var index = variables.mappings.find(function (mapping) {
				return path.startsWith(arguments.mapping.directory)
			})
			if (index > 0) {
				var mapping = variables.mappings[index]
				// The cache key starts with the mapping, followed by the relative path without the file contentType.
				var mappedPath = Replace(arguments.path, mapping.directory, mapping.path)
				// Remove the file contentType.
				var key = ListDeleteAt(mappedPath, ListLen(mappedPath, "."), ".")

				return key
			}
		}

		return null
	}

	private void function removeByPrefix(required String prefix) {
		// Just to be certain, get a key array first and then delete from the cache.
		var prefix = arguments.prefix
		variables.cache.keyArray().each(function (key) {
			if (Left(arguments.key, Len(prefix)) == prefix) {
				variables.cache.delete(arguments.key)
			}
		})
	}

}