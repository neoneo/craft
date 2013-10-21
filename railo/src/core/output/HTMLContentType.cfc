component extends="ContentType" {

	public String function getName() {
		return "html"
	}

	public String function getMimeType() {
		return "text/html"
	}

	public String function convert(required Array strings) {
		return arguments.strings.toList("")
	}

	public String function write(required String content) {
		return arguments.content
	}

}