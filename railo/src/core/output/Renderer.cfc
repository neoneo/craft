interface {

	public String function render(required String view, required Struct model, required String requestMethod, required ContentType contentType);

	public ContentType function contentType(required String view, required String requestMethod, required ContentType contentType);

}