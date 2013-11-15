component extends="ContentType" {

	public String function name() {
		return "json"
	}

	public String function mimeType() {
		return "application/json"
	}

	public String function convert(required Array strings) {

		var result = ""
		for (var string in arguments.strings) {
			// Make anything that doesn't look like JSON, safe for JSON.
			if (!isValidJSON("[" & string & "]")) {
				// Although a string shouldn't be serialized by itself, this effectively makes the string safe for JSON.
				string = SerializeJSON(string)
			}

			result = ListAppend(result, string)
		}

		return result
	}

	public String function write(required String content) {

		var content = Trim(arguments.content)
		if (!isValidJSON(content)) {
			Throw("Content is not valid JSON", "IllegalContentException")
		}

		return content
	}

	private Boolean function isValidJSON(required String content) {
		// Workaround for https://issues.jboss.org/browse/RAILO-2373
		return IsJSON(arguments.content) && FindOneOf("[{", arguments.content) == 1
	}

}