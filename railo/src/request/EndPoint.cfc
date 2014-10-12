component accessors="true" {

	property String rootPath;

	property String extension setter="false";
	property Array extensions setter="false"; // String[]
	property String path setter="false";
	property String requestMethod setter="false";
	property Struct requestParameters setter="false";

	this.contentTypes = {
		html: "text/html",
		json: "application/json",
		xml: "application/xml",
		pdf: "application/pdf",
		txt: "text/plain"
	}
	this.rootFile = "" // The file present in the url to direct traffic to Railo.
	this.rootDirectory = "" // The directory that is transparently added to and removed from every url.
	this.rootPath = "" // The concatenation of rootFile and rootDirectory.
	this.extensions = this.contentTypes.keyArray()

	public void function setRootPath(required String rootPath) {

		// If a file (usually index.cfm) is used in urls, keep it separate from the rest of the root path.
		// This way, we can transparently add and remove the root path, since the root file is not present in cgi.path_info.
		var firstSegment = arguments.rootPath.listFirst("/")
		if (firstSegment.reFind("\.cfml?") > 0) {
			this.rootFile = "/" & firstSegment
			this.rootDirectory = "/" & arguments.rootPath.listRest("/")
		} else {
			this.rootFile = ""
			// Keep the root directory empty unless it actually contains a segment. That is, '/' should revert to ''.
			if (arguments.rootPath.listLen("/") > 0) {
				this.rootDirectory = arguments.rootPath
			} else {
				this.rootDirectory = ""
			}
		}

		this.rootPath = this.rootFile & this.rootDirectory
	}

	public String function getExtension() {
		var extension = this.getPath().listLast(".")

		return this.contentTypes.keyExists(extension) ? extension : "html";
	}

	public String function getContentType() {
		return this.contentTypes[this.getExtension()];
	}

	public String function getPath() {
		// Remove the root directory from the beginning.
		return cgi.path_info.replace(this.rootDirectory, "");
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

		return this.rootPath & path & queryString;
	}

}