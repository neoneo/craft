component extends="EndPoint" {

	public String function createURL(required String path, Struct parameters) {

		var path = arguments.path

		if (path contains "./") {
			// Part of the path is relative, but this could be somewhere in the middle.
			// Get the current path (without the file name if present).
			if (!path.startsWith("/")) {
				path = REReplace(this.path(), "/([^/.]+\.[^/.]+)?$", "") & "/" & path
			}
			do {
				var position = Find("../", path)
				if (position > 0) {
					// Split the path where the ../ is found.
					var absolutePath = position > 1 ? Left(path, position - 1) : "/"
					var relativePath = Mid(path, position)
					// Remove the last list item from the current path and the first from the relative path.
					path = ListDeleteAt(absolutePath, ListLen(absolutePath, "/"), "/") & "/" & ListRest(relativePath, "/")
				}
			} while (position > 0)
			path = Replace(path, "./", "", "all")
		}

		var queryString = "path=" & UrlEncodedFormat(path)

		if (StructKeyExists(arguments, "parameters")) {
			// Put the parameters on the query string.
			for (var name in arguments.parameters) {
				queryString = ListAppend(queryString, name & "=" & UrlEncodedFormat(arguments.parameters[name]), "&")
			}
		}

		return "index.cfm?" & queryString
	}

	public String function path() {
		return url.path ?: "/"
	}

}