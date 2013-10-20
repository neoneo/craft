component extends="Extension" {

	public String function getName() {
		return "xml"
	}

	public String function getMimeType() {
		return "application/xml"
	}

	public String function convert(required Array strings) {

		var result = ""
		for (var string in arguments.strings) {
			if (!IsXML("<root>" & string & "</root>") && !string.startsWith("<![CDATA[")) {
				string = "<![CDATA[" & string & "]]>"
			}

			result &= string
		}

		return result
	}

	public String function write(required String content) {

		if (!IsXML(arguments.content)) {
			Throw("Content is not valid XML", "IllegalContentException")
		}

		return arguments.content
	}

}