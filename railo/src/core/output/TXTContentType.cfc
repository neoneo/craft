component implements="ContentType" {

	public String function name() {
		return "txt"
	}

	public String function mimeType() {
		return "text/plain"
	}

	public String function merge(required Array strings) {
		return arguments.strings.toList("")
	}

	public String function write(required String content) {
		return arguments.content
	}

}