component extends="Extension" {

	public String function getName() {
		return "html"
	}

	public String function getMimeType() {
		return "text/html"
	}

	public String function concatenate(required Array strings) {
		return arguments.strings.toList("")
	}

	public String function write(required String content) {
		return arguments.content
	}

}