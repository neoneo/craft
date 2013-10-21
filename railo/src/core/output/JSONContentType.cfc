component extends="ContentType" {

	public String function getName() {
		return "json"
	}

	public String function getMimeType() {
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

		if (!isValidJSON(arguments.content)) {
			Throw("Content is not valid JSON", "IllegalContentException")
		}

		return arguments.content
	}

	private Boolean function isValidJSON(required String content) {
		// Workaround for https://issues.jboss.org/browse/RAILO-2373
		return IsJSON(arguments.content) && FindOneOf("[{", arguments.content) == 1
	}

}