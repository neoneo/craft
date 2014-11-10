/**
 * The `Context` is passed to `Component`s to provide access to items and parameters pertaining to the request, as well
 * as some convenience methods.
 */
component accessors="true" {

	property String characterSet default="UTF-8";
	property String contentType;
	property Boolean deleteFile;
	property String downloadAs;
	property String downloadFile;
	property Numeric statusCode default="200";

	property Array dependencies setter="false"; // String[]
	property String extension setter="false";
	property Struct parameters setter="false";
	property String path setter="false";
	property PathSegment pathSegment setter="false";
	property String requestMethod setter="false";

	public void function init(required Endpoint endpoint, required PathSegment root) {

		this.endpoint = arguments.endpoint
		this.root = arguments.root

		this.extension = arguments.endpoint.extension
		this.requestMethod = arguments.endpoint.requestMethod
		this.parameters = arguments.endpoint.requestParameters

		this.contentType = arguments.endpoint.contentType
		this.path = arguments.endpoint.path

		// Parse the path. If path segments define parameters, they are appended on the parameters struct.
		this.pathSegment = null
		var segments = this.path.listToArray("/")

		if (!segments.isEmpty()) {
			var lastSegment = segments.last()
			var extension = lastSegment.listLast(".")

			// The extension cannot be the whole last segment.
			if (extension != lastSegment && arguments.endpoint.extensions.find(extension) > 0) {
				// Remove the extension from the last segment.
				segments[segments.len()] = lastSegment.reReplace("\.[a-z0-9]{3,4}$", "")
			}
		}

		// Walk the path to get the path segment that applies to this request.
		this.walk(segments, arguments.root)
		if (this.pathSegment === null) {
			Throw("Path segment not found", "FileNotFoundException");
		}

		this.dependencies = []

	}

	public String function createURL(required String path, Struct parameters) {
		// Note: the endpoint method must have exactly the same signature, including names.
		// It seems a waste to convert the arguments to something else to decouple.
		return this.endpoint.createURL(argumentCollection: arguments);
	}

	public void function addDependency(required String dependency) {
		this.dependencies.append(arguments.dependency)
	}

	/**
	 * Traverses the path to find the applicable `PathSegment`. When the `PathSegment` is found, any parameters defined by `PathSegment`s
	 * on the path are available in the parameters.
	 */
	private void function walk(required String[] path, required PathSegment start) {

		if (arguments.path.isEmpty()) {
			this.pathSegment = arguments.start
		} else {
			var children = arguments.start.children
			var count = children.len()
			var i = 1
			while (this.pathSegment === null && i <= count) {
				var child = children[i]
				var segmentCount = child.match(arguments.path)
				if (segmentCount > 0) {
					// Remove the number of segments that were matched and walk the remaining path, starting at the child.
					var remainingPath = segmentCount == arguments.path.len() ? [] : arguments.path.slice(segmentCount + 1)
					this.walk(remainingPath, child)

					if (this.pathSegment !== null) {
						// The complete path is traversed so the current path segment is part of the tree.
						var parameterName = child.parameterName
						if (parameterName !== null) {
							// Get the part of the path that was actually matched by the current path segment.
							this.parameters[parameterName] = arguments.path.slice(1, segmentCount).toList("/")
						}
					}
				}

				i += 1
			}
		}

	}

}