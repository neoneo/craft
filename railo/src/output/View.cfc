/**
 * The `View` is responsible for rendering the model in any form required. Unlike templates, views can return
 * any datatype so that serialization for the client can be deferred until the last moment. This makes it possible
 * to construct, for example, complex JSON or XML structures without string manipulation.
 */
component {

	property TemplateRenderer templateRenderer;

	public void function init(required TemplateRenderer templateRenderer, Struct properties) {
		this.templateRenderer = arguments.templateRenderer

		this.configure(argumentCollection: arguments.properties)
	}

	/**
	 * 'Semi-constructor'. Implement this method instead of `init()`.
	 */
	private void function configure() {}

	public Any function render(required Any model) {
		abort showerror="Not implemented";
	}

}