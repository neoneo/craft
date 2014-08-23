/**
 * The `Context` is passed to `Component`s to provide access to items and parameters pertaining to the request, as well
 * as some convenience methods.
 *
 * @transient
 */
component accessors="true" {

	property String characterSet default="UTF-8";
	property Boolean deleteFile;
	property String downloadAs;
	property String downloadFile;
	property String contentType;
	property Numeric statusCode default="200";

	public void function init(required EndPoint endPoint, required PathSegment root) {

		variables._endPoint = arguments.endPoint
		variables._root = arguments.root

		variables._extension = arguments.endPoint.extension()
		variables._requestMethod = arguments.endPoint.requestMethod()
		variables._parameters = arguments.endPoint.requestParameters()

		setContentType(arguments.endPoint.contentType())

		// Parse the path. If path segments define parameters, they are appended on the parameters struct.
		variables._pathSegment = null
		var segments = path().listToArray("/")

		if (!segments.isEmpty()) {
			var lastSegment = segments.last()
			var extension = lastSegment.listLast(".")

			// The extension cannot be the whole last segment.
			if (extension != lastSegment && arguments.endPoint.extensions().find(extension) > 0) {
				// Remove the extension from the last segment.
				segments[segments.len()] = lastSegment.reReplace("\.[a-z0-9]{3,4}$", "")
			}
		}

		// Walk the path to get the path segment that applies to this request.
		walk(segments, arguments.root)
		if (variables._pathSegment === null) {
			Throw("Path segment not found", "FileNotFoundException");
		}

		variables._dependencies = []

	}

	public PathSegment function pathSegment() {
		return variables._pathSegment;
	}

	public Struct function parameters() {
		return variables._parameters;
	}

	public String function path() {
		return variables._endPoint.path();
	}

	public String function extension() {
		return variables._extension;
	}

	public String function requestMethod() {
		// TODO: implement tunnelling
		return variables._requestMethod;
	}

	public String function createURL(required String path, Struct parameters) {
		return variables._endPoint.createURL(argumentCollection: ArrayToStruct(arguments));
	}

	public void function addDependency(required String dependency) {
		variables._dependencies.append(arguments.dependency)
	}

	public String[] function dependencies() {
		return variables._dependencies;
	}

	/**
	 * Traverses the path to find the applicable `PathSegment`. When the `PathSegment` is found, any parameters defined by `PathSegment`s
	 * on the path are available in the parameters.
	 */
	private void function walk(required String[] path, required PathSegment start) {

		if (arguments.path.isEmpty()) {
			variables._pathSegment = arguments.start
		} else {
			var children = arguments.start.children()
			var count = children.len()
			var i = 1
			while (variables._pathSegment === null && i <= count) {
				var child = children[i]
				var segmentCount = child.match(arguments.path)
				if (segmentCount > 0) {
					// Remove the number of segments that were matched and walk the remaining path, starting at the child.
					var remainingPath = segmentCount == arguments.path.len() ? [] : arguments.path.slice(segmentCount + 1)
					walk(remainingPath, child)

					if (variables._pathSegment !== null) {
						// The complete path is traversed so the current path segment is part of the tree.
						var parameterName = child.parameterName()
						if (parameterName !== null) {
							// Get the part of the path that was actually matched by the current path segment.
							variables._parameters[parameterName] = arguments.path.slice(1, segmentCount).toList("/")
						}
					}
				}

				i += 1
			}
		}

	}

}