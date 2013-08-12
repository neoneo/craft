component {

	public void function init(required PathSegment root, required Array extensions) {

		variables.root = arguments.root
		variables.extensions = arguments.extensions

		variables.extensionNames = {}
		for (var extension in variables.extensions) {
			variables.extensionNames[extension.getName()] = extension
		}

		// merge the parameters from the form and url scopes
		variables.parameters = StructCopy(form)
		variables.parameters.append(url, false)

	}

	public Struct function parsePath() {

		var path = getPath()
		var segments = ListToArray(path, "/")
		var extension = variables.extensions.first() // the default extension

		if (!segments.isEmpty()) {
			var lastSegment = segments.last()
			var extensionName = ListLast(lastSegment, ".")

			// the extension cannot be the whole last segment
			if (extensionName != lastSegment && variables.extensionNames.keyExists(extensionName)) {
				extension = variables.extensionNames[extensionName]
				// remove the extension from the last segment
				segments[segments.len()] = Left(lastSegment, Len(lastSegment) - Len(extensionName) - 1)
			}
		}

		// traverse the path to get the path segment that applies to this request
		var pathSegment = variables.root.match(segments) ? variables.root : traverse(segments, variables.root)
		if (IsNull(pathSegment)) {
			Throw("Path segment not found", "PathSegmentNotFoundException")
		}

		return {
			pathSegment = pathSegment,
			extension = extension
		}
	}

	public Struct function getRequestParameters() {
		return variables.parameters
	}

	public String function getRequestMethod() {
		return cgi.request_method
	}

	public String function getPath() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public String function createURL(required String path, Struct parameters, String extensionName) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	// PRIVATE ====================================================================================

	/**
	 * Traverses the path to find the applicable path segment. If no path segment is found, returns null.
	 **/
	private any function traverse(required Array path, required PathSegment pathSegment) {

		var result = arguments.pathSegment
		if (!arguments.path.isEmpty()) {
			result = NullValue()

			var children = arguments.pathSegment.getChildren()
			var count = children.len()
			var i = 1
			while (IsNull(result) && i <= count) {
				var child = children[i]
				var segmentCount = child.match(arguments.path)
				if (segmentCount > 0) {
					// remove the number of segments that were matched and traverse the remaining path
					result = traverse(arguments.path.mid(segmentCount + 1), child)

					if (!IsNull(result)) {
						// the complete path is traversed so the current path segment is part of the tree
						var parameterName = child.getParameterName()
						if (!IsNull(parameterName)) {
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