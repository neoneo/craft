/**
 * The `View` is responsible for rendering the model in any form required. Unlike templates, views can return
 * any datatype so that serialization for the client can be deferred until the last moment. This makes it possible
 * to construct, for example, complex JSON or XML structures without string manipulation.
 */
component accessors="true" {

	property ViewRenderer viewRenderer setter="false";

	public void function init(required ViewRenderer viewRenderer, Struct properties) {
		this.viewRenderer = arguments.viewRenderer

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