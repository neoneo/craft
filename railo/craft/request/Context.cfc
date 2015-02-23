/**
 * The `Context` is passed to `Component`s and `View`s to provide access to items and parameters pertaining to the request, as well
 * as some convenience methods.
 */
component accessors="true" {

	property String characterSet default="UTF-8";
	property String contentType;
	property Boolean deleteFile;
	property String downloadAs;
	property String downloadFile;
	property Numeric statusCode default="200";

	property String extension setter="false";
	property Struct parameters setter="false";
	property String path setter="false";
	property String requestMethod setter="false";

	public void function init(required Endpoint endpoint, required PathSegment root) {

		this.endpoint = arguments.endpoint
		this.root = arguments.root

		this.parameters = arguments.endpoint.requestParameters
		this.path = arguments.endpoint.path
		this.requestMethod = arguments.endpoint.requestMethod

		this.extension = arguments.endpoint.extension(this.path)
		this.contentType = arguments.endpoint.contentType(this.extension)

		this.dependencies = []

	}

	public String function createURL(required String path, Struct parameters) {
		// Note: the endpoint method must have exactly the same signature, including names.
		// It seems a waste to convert the arguments to something else to decouple.
		return this.endpoint.createURL(argumentCollection: arguments);
	}

	public void function require(required String dependency) {
		if (this.dependencies.find(arguments.dependency) == 0) {
			this.dependencies.append(arguments.dependency)
		}
	}

	package Any function handleRequest() {

		var segments = this.path.listToArray("/")

		// Remove the extension from the last segment.
		if (!segments.isEmpty() && !this.extension.isEmpty()) {
			segments[segments.len()] = segments.last().reReplace("\.#this.extension#$", "")
		}

		// Walk the path to get the path segment that applies to this request.
		var result = this.root.walk(segments)
		if (result.target === null) {
			Throw("Not found", "NotFoundException");
		}

		// The result contains the target path segment and the parameters introduced by the intermediate path segments.
		var target = result.target
		this.parameters.append(result.parameters)

		if (target.hasCommand(this.requestMethod)) {
			var command = target.command(this.requestMethod)
			var output = command.execute(this)

			if (this.contentType == "text/html") {
				for (var dependency in this.dependencies) {
					htmlhead text="#this.get(dependency)#";
				}
			}

			return output;
		} else {
			Throw("Method not allowed", "MethodNotAllowedException");
		}

	}

	/**
	 * Processes an internal request. Such a request is handled the same way as a regular request.
	 */
	private Any function request(required String requestMethod, required String path, required Struct parameters) {

		// Overwrite some of the state to mimick a new request.
		var contentType = this.contentType
		var extension = this.extension
		var parameters = this.parameters
		var path = this.path
		var requestMethod = this.requestMethod

		this.parameters = arguments.parameters
		this.path = arguments.path
		this.requestMethod = arguments.requestMethod

		this.extension = this.endpoint.extension(arguments.path)
		this.contentType = this.endpoint.contentType(this.extension)

		var output = this.handleRequest()

		// Revert the state and return the output.
		this.contentType = contentType
		this.extension = extension
		this.parameters = parameters
		this.path = path
		this.requestMethod = requestMethod

		return output;
	}

	public Any function get(required String path, Struct parameters = {}) {
		return this.request("GET", arguments.path, arguments.parameters);
	}

	public Any function post(required String path, Struct parameters = {}) {
		return this.request("POST", arguments.path, arguments.parameters);
	}

	public Any function put(required String path, Struct parameters = {}) {
		return this.request("PUT", arguments.path, arguments.parameters);
	}

	public Any function delete(required String path, Struct parameters = {}) {
		return this.request("DELETE", arguments.path, arguments.parameters);
	}

}