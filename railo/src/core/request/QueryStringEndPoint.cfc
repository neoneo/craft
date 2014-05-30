component extends="EndPoint" {

	public String function createURL(required String path, Struct parameters) {

		var path = arguments.path

		if (path contains "./") {
			// Part of the path is relative, but this could be somewhere in the middle.
			// Get the current path (without the file name if present).
			if (!path.startsWith("/")) {
				path = this.path().reReplace("/([^/.]+\.[^/.]+)?$", "") & "/" & path
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

		var queryString = "path=" & URLEncode(path)

		if (!IsNull(arguments.parameters)) {
			// Put the parameters on the query string.
			queryString = arguments.parameters.reduce(function (queryString, name, value) {
				return ListAppend(arguments.queryString, arguments.name & "=" & URLEncode(value), "&")
			}, queryString)
		}

		return "index.cfm?" & queryString
	}

	public String function path() {
		return url.path ?: "/"
	}

}