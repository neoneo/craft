component implements="ContentType" {

	public String function name() {
		return "xml"
	}

	public String function mimeType() {
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
			Throw("Content is not valid XML", "IllegalContentException", arguments.content)
		}

		return arguments.content
	}

}