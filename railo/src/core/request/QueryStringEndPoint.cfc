component extends="EndPoint" {

	public String function createURL(required String path, Struct parameters) {

		var path = arguments.path

		if (path contains "./") {
			// part of the path is relative, but this could be somewhere in the middle
			// get the current path (without the file name if present)
			if (!path.startsWith("/")) {
				path = REReplace(getPath(), "/([^/.]+\.[^/.]+)?$", "") & "/" & path
			}
			var position = 1
			while (position > 0) {
				position = Find("../", path)
				if (position > 0) {
					// split the path where the ../ is found
					var absolutePath = position > 1 ? Left(path, position - 1) : "/"
					var relativePath = Mid(path, position)
					// remove the last list item from the current path and the first from the relative path
					path = REReplace(absolutePath, "/[^/]+/$", "") & "/" & ListRest(relativePath, "/")
				}
			}
			path = Replace(path, "./", "", "all")
		}

		var queryString = "path=" & UrlEncodedFormat(path)

		if (StructKeyExists(arguments, "parameters")) {
			// put the parameters on the query string
			for (var name in arguments.parameters) {
				queryString = ListAppend(queryString, name & "=" & UrlEncodedFormat(arguments.parameters[name]), "&")
			}
		}

		return "index.cfm?" & queryString
	}

	public String function getPath() {
		return url.path ?: "/"
	}

}