component {

	public void function init(required String fileExtension) {
		variables.fileExtension = "." & arguments.fileExtension
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
			// the mappingPath serves as the prefix for all keys to be removed from the cache
			removeByPrefix(mappingPath)
		}
	}

	public Struct function get(required String view, required Extension extension) {

		var key = arguments.view & "." & arguments.extension.getName()
		if (!variables.cache.keyExists(key)) {
			var extensions = ([arguments.extension]).merge(arguments.extension.getFallbacks()) // first look for the most specific template
			var found = false
			search:for (var extension in extensions) {
				var name = arguments.view & "." & extension.getName() & variables.fileExtension
				for (var mapping in variables.mappings) {
					if (FileExists(mapping.directory & "/" & name)) {
						variables.cache[key] = {
							template = mapping.path & "/" & name,
							extension = extension
						}
						found = true
						break search;
					}
				}
			}
			if (!found) {
				Throw("View '#arguments.view#.#arguments.extension.getName()#' not found", "ViewNotFoundException")
			}
		}

		return variables.cache[key]
	}

	public void function reset() {
		variables.cache = {}
		variables.mappings = []
	}

	public void function add(required String path) {
		var key = cacheKey(arguments.path)
		if (!IsNull(key)) {
			// the added file might have higher priority than similar files already cached
			// remove all similar keys; when requested the files will be put in the cache in priority order
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

	private Any function cacheKey(required String path) {

		// the file name must end with the proper file extenstion
		if (ListLast(arguments.path, ".") == variables.fileExtension) {
			var path = arguments.path
			var index = variables.mappings.find(function (mapping) {
				return path.startsWith(arguments.mapping.directory)
			})
			if (index > 0) {
				var mapping = variables.mappings[index]
				// the cache key starts with the mapping, followed by the relative path without the file extension
				var mappedPath = Replace(arguments.path, mapping.directory, mapping.path)
				// remove the file extension
				var key = ListDeleteAt(mappedPath, ListLen(mappedPath, "."), ".")

				return key
			}
		}

		return null
	}

	private void function removeByPrefix(required String prefix) {
		// just to be certain, get a key array first and then delete from the cache
		var prefix = arguments.prefix
		variables.cache.keyArray().each(function (key) {
			if (Left(arguments.key, Len(prefix)) == prefix) {
				variables.cache.delete(arguments.key)
			}
		})
	}

}