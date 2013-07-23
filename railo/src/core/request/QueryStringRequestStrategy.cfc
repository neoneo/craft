component extends="RequestStrategy" {

	public String function createUrl(required String path, Struct parameters, String extensionName) {

		var path = arguments.path
		if (!path.startsWith("/")) {
			// not an absolute path
			// get the current path (without the file name if present)
			var currentPath = REReplace(getPath(), "/([^/.]+\.[^/.]+)?$", "")
			if (path.startsWith("./") == 1) {
				path = currentPath & "/" & ListRest(path, "/")
			} else {
				while (path.startsWith("../")) {
					// remove the last list item from the current path and the first from the path
					path = ListRest(path, "/")
					currentPath = REReplace(currentPath, "/[^/]+$", "")
				}
				path = currentPath & "/" & path
			}
		}

		var extensionName = arguments.extensionName ?: getExtension().getName()
		var queryString = "path=" & UrlEncodedFormat(path & "." & extensionName)

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