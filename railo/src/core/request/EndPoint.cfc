component {

	public void function init(required PathSegment root, required Array supportedExtensions) {

		variables.root = arguments.root
		variables.extensions = arguments.extensions

		variables.extensionNames = {}
		for (var extension in variables.extensions) {
			variables.extensionNames[extension.getName()] = extension
		}

	}

	public Struct function parsePath() {

		var path = getPath()
		var extensionName = ListLast(path, ".")
		// get the extension from the set; it returns the default one if the extension does not exist
		var extension = variables.extensionNames[extensionName] ?: variables.extensions.first()
		// if the extension exists, remove it from the path (including the preceding dot)
		if (variables.extensionNames.keyExists(extensionName)) {
			path = Left(path, Len(path) - Len(extensionName) - 1)
		}

		// traverse the path to get the path segment that applies to this request
		var pathSegment = traverse(ListToArray(path, "/"), variables.root)
		if (pathSegment == null) {
			Throw("Path segment not found", "PathSegmentNotFoundException")
		}

		return {
			pathSegment = pathSegment,
			extension = extension
		}
	}

	public Struct function getRequestParameters() {
		// merge the parameters from the form and url scopes
		var parameters = form.copy()
		var parameters.append(url, false)

		return parameters
	}

	public String function getRequestMethod() {
		return cgi.request_method
	}

	public String function getPath() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public String function createUrl(required String path, Struct parameters, String extensionName) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	// PRIVATE ====================================================================================

	/**
	 * Traverses the path to find the applicable path segment. If no path segment is found, returns null.
	 **/
	private any function traverse(required Array path, required PathSegment pathSegment) {

		var result = arguments.pathSegment
		if (!arguments.path.isEmpty()) {
			result = null

			var children = arguments.pathSegment.getChildren()
			var count = children.len()
			var i = 1
			while (result == null && i <= count) {
				var child = children[i]
				var segmentCount = child.match(arguments.path)
				if (segmentCount > 0) {
					// remove the number of segments that were matched and traverse the remaining path
					result = traverse(arguments.path.mid(segmentCount + 1), child)

					if (result != null) {
						// the complete path is traversed so the current path segment is part of the tree
						var parameterName = child.getParameterName()
						if (parameterName != null) {
							// get the part of the path that was actually matched by the current path segment
							variables.parameters[parameterName] = arguments.path.mid(1, segmentCount).toList("/")
						}
					}
				}

				i += 1
			}
		}

		return result
	}

}