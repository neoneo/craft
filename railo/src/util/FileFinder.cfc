import craft.util.ScopeCache;

component {

	public void function init(required String extension) {
		this.extension = arguments.extension
		this.fileMappings = {} // Map between names and mappings to files.
		this.paths = StructNew("linked") // Map between registered mappings and paths. The order is important.
	}

	public void function clear() {
		this.fileMappings.clear()
		this.paths.clear()
	}

	public void function addMapping(required String mapping) {
		this.paths[arguments.mapping] = ExpandPath(arguments.mapping)
	}

	public void function removeMapping(required String mapping) {
		if (this.paths.keyExists(arguments.mapping)) {
			this.paths.delete(arguments.mapping)
			// The mapping serves as the prefix for all keys to be removed from the cache.
			var prefix = arguments.mapping
			this.fileMappings = this.fileMappings.filter(function (name, mapping) {
				return !arguments.mapping.startsWith(prefix);
			})
		}
	}

	/**
	 * Returns the path including the mapping for the given file.
	 * The file name should be passed in without the extension.
	 */
	public String function get(required String name) {

		if (!this.fileMappings.keyExists(arguments.name)) {
			var fileMapping = this.locate(arguments.name)
			if (fileMapping === null) {
				Throw("File '#arguments.name#' not found", "FileNotFoundException");
			}
			this.fileMappings[arguments.name] = fileMapping
		}

		return this.fileMappings[arguments.name];
	}

	private Any function locate(required String name) {

		var filename = arguments.name & "." & this.extension
		var fileMapping = null

		this.paths.some(function (mapping, path) {
			// TODO: find out how to check for existence in Railo archives.
			if (FileExists(arguments.path & "/" & filename)) {
				fileMapping = arguments.mapping & "/" & filename
				return true;
			}

			return false;
		});

		return fileMapping;
	}

	public Boolean function exists(required String name) {
		return this.fileMappings.keyExists(arguments.name) || this.locate(arguments.name) !== null;
	}

}