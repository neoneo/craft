component extends="Extension" {

	public String function getName() {
		return "pdf"
	}

	public String function getMimeType() {
		return "application/pdf"
	}

	public String function concatenate(required Array strings) {
		return arguments.strings.toList("")
	}

	public String function write(required String content) {

		document format="pdf" name="local.result" {
			Echo(arguments.content)
		}

		return result
	}

}