component {

	public void function init() {

		variables._rootPath = ""

		variables._mimeTypes = {
			html: "text/html",
			json: "application/json",
			xml: "application/xml",
			pdf: "application/pdf",
			txt: "text/plain"
		}
		variables._extensions = variables._mimeTypes.keyArray()

	}

	public void function setRootPath(required String rootPath) {
		variables._rootPath = arguments.rootPath
	}

	public String function extension() {
		var extension = path().listLast(".")

		return variables._mimeTypes.keyExists(extension) ? extension : "html"
	}

	public String[] function extensions() {
		return variables._extensions
	}

	public Struct function requestParameters() {
		// Merge the parameters from the form and url scopes.
		var parameters = Duplicate(form, false)
		parameters.append(url, false)

		return parameters
	}

	public String function requestMethod() {
		return cgi.request_method
	}

	public String function createURL(required String path, Struct parameters) {

		var path = arguments.path

		if (path contains "./") {
			// Part of the path is relative, but this could be somewhere in the middle.
			if (!path.startsWith("/")) {
				// Prepend the current path (without the file name if present).
				path = this.path().reReplace("/([^/.]+\.[a-z0-9]{3,4})?$", "") & "/" & path
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
			} while (position > 0)
			path = path.replace("./", "", "all")
		}

		var queryString = ""
		var parameters = arguments.parameters ?: null
		if (parameters !== null && !parameters.isEmpty()) {
			// Put the parameters on the query string.
			queryString = "?" & parameters.reduce(function (queryString, name, value) {
				return arguments.queryString.listAppend(arguments.name & "=" & URLEncode(value), "&")
			}, queryString)
		}

		return variables._rootPath & path & queryString
	}

	public String function path() {
		return cgi.path_info
	}

}