component {

	public void function init(required String extension) {
		variables._extension = "." & arguments.extension
		clear()
	}

	public void function clear() {
		variables._cache = {}
		variables._mappings = []
	}

	public void function addMapping(required String mappingPath) {
		variables._mappings.append({
			path: arguments.mappingPath,
			directory: ExpandPath(arguments.mappingPath)
		})
	}

	public void function removeMapping(required String mappingPath) {
		var mappingPath = arguments.mappingPath
		var index = variables._mappings.find(function (mapping) {
			return arguments.mapping.path = mappingPath
		})
		if (index > 0) {
			variables._mappings.deleteAt(index)
			// The mapping path serves as the prefix for all keys to be removed from the cache.
			removeByPrefix(mappingPath)
		}
	}

	public String function template(required String view, required String requestMethod, required ContentType contentType) {
		return get(arguments.view, arguments.requestMethod, arguments.contentType).template
	}

	public ContentType function contentType(required String view, required String requestMethod, required ContentType contentType) {
		return get(arguments.view, arguments.requestMethod, arguments.contentType).contentType
	}

	private Struct function get(required String view, required String requestMethod, required ContentType contentType) {

		var key = arguments.view & "." & arguments.requestMethod & "." & arguments.contentType.name()
		if (!variables._cache.keyExists(key)) {
			var result = locate(arguments.view, arguments.requestMethod, arguments.contentType)
			if (IsNull(result)) {
				Throw("View '#arguments.view#' for contentType '#arguments.contentType.name()#' not found", "ViewNotFoundException")
			}
			variables._cache[key] = result
		}

		return variables._cache[key]
	}

	private Any function locate(required String view, required String requestMethod, required ContentType contentType) {

		var result = null
		// Search for files with or without the request method (in that order).
		var names = [
			arguments.view & "." & arguments.requestMethod,
			arguments.view
		]
		var found = false
		search: for (var name in names) {
			for (var mapping in variables._mappings) {
				var filename = name & "." & arguments.contentType.name() & variables._extension
				if (FileExists(mapping.directory & "/" & filename)) {
					result = {
						template = mapping.path & "/" & filename,
						contentType = contentType
					}
					found = true
					break search;
				}
			}
		}

		return result
	}

	public Boolean function exists(required String view, required String requestMethod, required ContentType contentType) {
		return !IsNull(locate(arguments.view, arguments.requestMethod, arguments.contentType))
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
			variables._cache.delete(key)
		}
	}

	private Any function cacheKey(required String path) {

		// The file name must end with the proper file extension.
		if (ListLast(arguments.path, ".") == variables._extension) {
			var path = arguments.path
			var index = variables._mappings.find(function (mapping) {
				return Left(path, Len(arguments.mapping.directory)) == arguments.mapping.directory
			})
			if (index > 0) {
				var mapping = variables._mappings[index]
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
		variables._cache.keyArray().each(function (key) {
			if (Left(arguments.key, Len(prefix)) == prefix) {
				variables._cache.delete(arguments.key)
			}
		})
	}

}