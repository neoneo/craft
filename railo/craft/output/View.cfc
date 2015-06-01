/**
 * The `View` is responsible for rendering the model in any form required. Unlike templates, views can return
 * any datatype so that serialization for the client can be deferred until the last moment. This makes it possible
 * to construct, for example, complex JSON or XML structures without string manipulation.
 */
import craft.request.Context;

/**
 * @singleton
 * @abstract
 */
component {

	property TemplateRenderer templateRenderer;

	public void function init(required TemplateRenderer templateRenderer) {
		this.templateRenderer = arguments.templateRenderer
	}

	public Any function render(required Any model, required Context context) {
		abort showerror="Not implemented";
	}

}