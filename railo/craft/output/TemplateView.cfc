import craft.request.Context;

component extends = View {

	public void function init(required TemplateRenderer templateRenderer, required String template) {
		super.init(arguments.templateRenderer)
		this.template = arguments.template
	}

	/**
	 * Renders the view by delegating to the `TemplateRenderer`.
	 */
	public String function render(required Struct model, required Context context) {
		return this.templateRenderer.render(this.template, arguments.model);
	}

}