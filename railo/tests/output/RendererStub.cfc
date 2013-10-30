import craft.core.output.*;

component implements="Renderer" {

	public String function render(required String view, required Struct model, required String requestMethod, required ContentType contentType) {
		return ""
	}

	public ContentType function contentType(required String view, required String requestMethod, required ContentType contentType) {
		return arguments.contentType
	}


}