component {

	public void function init(required PathSegment root, required Array extensions) {

		variables.root = arguments.root
		variables.extensions = arguments.extensions

		variables.extensionNames = {}
		for (var contentType in variables.extensions) {
			variables.extensionNames[contentType.name()] = contentType
		}

		// Merge the parameters from the form and url scopes.
		variables.parameters = Duplicate(form, false)
		variables.parameters.append(url, false)

	}

	public Struct function parsePath() {

		var path = getPath()
		var segments = ListToArray(path, "/")
		var contentType = variables.extensions.first() // The default content type.

		if (!segments.isEmpty()) {
			var lastSegment = segments.last()
			var extensionName = ListLast(lastSegment, ".")

			// The content type cannot be the whole last segment.
			if (extensionName != lastSegment && variables.extensionNames.keyExists(extensionName)) {
				contentType = variables.extensionNames[extensionName]
				// Remove the content type from the last segment.
				segments[segments.len()] = Left(lastSegment, Len(lastSegment) - Len(extensionName) - 1)
			}
		}

		// Traverse the path to get the path segment that applies to this request.
		var pathSegment = variables.root.match(segments) ? variables.root : traverse(segments, variables.root)
		if (IsNull(pathSegment)) {
			Throw("Path segment not found", "PathSegmentNotFoundException")
		}

		return {
			pathSegment = pathSegment,
			contentType = contentType
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
					// Remove the number of segments that were matched and traverse the remaining path.
					result = traverse(arguments.path.mid(segmentCount + 1), child)

					if (!IsNull(result)) {
						// The complete path is traversed so the current path segment is part of the tree.
						var parameterName = child.getParameterName()
						if (!IsNull(parameterName)) {
							// Get the part of the path that was actually matched by the current path segment.
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