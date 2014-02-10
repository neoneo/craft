component implements="ContentType" {

	public String function name() {
		return "html"
	}

	public String function mimeType() {
		return "text/html"
	}

	public String function merge(required Array strings) {
		return arguments.strings.toList("")
	}

	public String function write(required String content) {
		return arguments.content
	}

}