component accessors = true {

	property String indexFile default = ""; // The index file used in the url. If set, the value should start with a /.

	property String contextRoot setter = false;
	property String extension setter = false;
	property Array extensions setter = false; // String[]
	property String path setter = false;
	property String requestMethod setter = false;
	property Struct requestParameters setter = false;

	this.contentTypes = {
		html: "text/html",
		json: "application/json",
		xml: "application/xml",
		pdf: "application/pdf",
		txt: "text/plain"
	}
	this.contextRoot = GetContextRoot()
	this.extensions = this.contentTypes.keyArray()

	public String function extension(required String path) {
		var lastSegment = arguments.path.listLast("/")
		var extension = lastSegment.listLast(".")

		if (extension != lastSegment && this.contentTypes.keyExists(extension)) {
			return extension;
		}

		return "";
	}

	public String function contentType(required String extension) {
		return this.contentTypes[arguments.extension] ?: this.contentTypes.html;
	}

	public String function getPath() {
		// Remove the context root from the beginning.
		return cgi.path_info.removeChars(1, this.contextRoot.len());
	}

	public String function getRequestMethod() {
		return cgi.request_method;
	}

	public Struct function getRequestParameters() {
		// Merge the parameters from the form and url scopes.
		var parameters = Duplicate(form, false)
		parameters.append(url, false)

		return parameters;
	}

	public String function createURL(required String path, Struct parameters) {

		var path = arguments.path

		if (path contains "./") {
			// Part of the path is relative, but this could be somewhere in the middle.
			if (!path.startsWith("/")) {
				// Prepend the current path (without the file name if present).
				path = this.getPath().reReplace("/([^/.]+\.[a-z0-9]{3,4})?$", "") & "/" & path
			}
			do {
				var position = path.find("../")
				if (position > 0) {
					// Split the path where the ../ is found.
					var absolutePath = position > 1 ? path.left(position - 1) : "/"
					var relativePath = path.mid(position)
					// Remove the last list item from the current path and the first from the relative path.
					path = absolutePath.listDeleteAt(absolutePath.listLen("/"), "/") & "/" & relativePath.listRest("/")
				}
			} while (position > 0);
			// Any './' still in the path does nothing.
			path = path.replace("./", "", "all")
		}

		var queryString = ""
		var parameters = arguments.parameters ?: null
		if (parameters !== null && !parameters.isEmpty()) {
			// Put the parameters on the query string.
			queryString = "?" & parameters.reduce(function (queryString, name, value) {
				return arguments.queryString.listAppend(arguments.name & "=" & URLEncode(value), "&");
			}, queryString)
		}

		return this.contextRoot & this.indexFile & path & queryString;
	}

}