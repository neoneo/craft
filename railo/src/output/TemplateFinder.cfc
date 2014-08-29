import craft.util.ScopeCache;

component {

	public void function init(required String extension) {
		this.extension = arguments.extension
		this.templatePaths = {}
		this.mappingPaths = StructNew("linked") // The order of the mappings is important.
	}

	public void function clear() {
		this.templatePaths.clear()
		this.mappingPaths.clear()
	}

	public void function addMapping(required String mapping) {
		this.mappingPaths[arguments.mapping] = ExpandPath(arguments.mapping)
	}

	public void function removeMapping(required String mapping) {
		if (this.mappingPaths.keyExists(arguments.mapping)) {
			this.mappingPaths.delete(arguments.mapping)
			// The mapping serves as the prefix for all keys to be removed from the cache.
			var prefix = arguments.mapping
			// Get a key array first and then delete from the cache.
			this.templatePaths.keyArray().each(function (key) {
				if (arguments.key.startsWith(prefix)) {
					this.templatePaths.delete(arguments.key)
				}
			})
		}
	}

	/**
	 * Returns the path including the mapping for the given template.
	 * The template should be passed in without the extension.
	 */
	public String function get(required String template) {

		if (!this.templatePaths.keyExists(arguments.template)) {
			var fileName = locate(arguments.template)
			if (fileName === null) {
				Throw("Template '#arguments.template#' not found", "FileNotFoundException");
			}
			this.templatePaths[arguments.template] = fileName
		}

		return this.templatePaths[arguments.template];
	}

	private Any function locate(required String template) {

		var filename = arguments.template & "." & this.extension
		var templatePath = null

		this.mappingPaths.some(function (mapping, directory) {
			// TODO: find out how to check for existence in Railo archives.
			if (FileExists(arguments.directory & "/" & filename)) {
				templatePath = arguments.mapping & "/" & filename
				return true;
			}

			return false;
		});

		return templatePath;
	}

	public Boolean function exists(required String template) {
		return locate(arguments.template) !== null;
	}

}