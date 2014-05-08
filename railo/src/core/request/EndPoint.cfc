component {

	public void function init(required PathSegment root) {

		variables._root = arguments.root

		// Merge the parameters from the form and url scopes.
		variables._parameters = Duplicate(form, false)
		variables._parameters.append(url, false)

		variables._mimeTypes = {
			html: "text/html",
			json: "application/json",
			xml: "application/xml",
			pdf: "application/pdf",
			txt: "text/plain"
		}

	}

	public PathSegment function parsePath() {

		var segments = ListToArray(path(), "/")

		if (!segments.isEmpty()) {
			var lastSegment = segments.last()
			var extension = ListLast(lastSegment, ".")

			// The extension cannot be the whole last segment.
			if (extension != lastSegment) {
				// Remove the extension from the last segment.
				segments[segments.len()] = lastSegment.left(lastSegment.len() - extension.len() - 1)
			}
		}

		// Traverse the path to get the path segment that applies to this request.
		var pathSegment = variables._root.match(segments) ? variables._root : traverse(segments, variables._root)
		if (IsNull(pathSegment)) {
			Throw("Path segment not found", "FileNotFoundException")
		}

		return pathSegment
	}

	public String function extension() {
		var extension = ListLast(path(), ".")

		return variables._mimeTypes.keyExists(extension) ? extension : "html"
	}

	public Struct function requestParameters() {
		return variables._parameters
	}

	public String function requestMethod() {
		return cgi.request_method
	}

	public String function path() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NoSuchMethodException")
	}

	public String function createURL(required String path, Struct parameters, String extension) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NoSuchMethodException")
	}

	// PRIVATE ====================================================================================

	/**
	 * Traverses the path to find the applicable path segment. If no path segment is found, returns null.
	 */
	private Any function traverse(required Array path, required PathSegment pathSegment) {

		if (arguments.path.isEmpty()) {
			return arguments.pathSegment
		} else {
			var result = null

			var children = arguments.pathSegment.children()
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
						var parameterName = child.parameterName()
						if (!IsNull(parameterName)) {
							// Get the part of the path that was actually matched by the current path segment.
							variables._parameters[parameterName] = arguments.path.mid(1, segmentCount).toList("/")
						}
					}
				}

				i += 1
			}

			return result
		}

	}

}