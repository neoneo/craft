component extends="ContentType" {

	public String function getName() {
		return "pdf"
	}

	public String function getMimeType() {
		return "application/pdf"
	}

	public String function convert(required Array strings) {
		return arguments.strings.toList("")
	}

	public String function write(required String content) {

		document format="pdf" name="local.result" {
			Echo(arguments.content)
		}

		return result
	}

}