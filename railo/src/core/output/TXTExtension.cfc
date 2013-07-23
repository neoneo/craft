component extends="Extension" {

	public String function getName() {
		return "txt"
	}

	public String function getMimeType() {
		return "text/plain"
	}

	public String function concatenate(required Array strings) {
		return arguments.strings.toList("")
	}

	public String function write(required String content) {
		return arguments.content
	}

}