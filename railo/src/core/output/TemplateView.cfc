component extends="View" {

	public void function init(required TemplateRenderer renderer, required String template) {
		variables._renderer = arguments.renderer
		variables._template = arguments.template
	}

	public Any function render(required Struct model, required String method) {
		return variables._renderer.render(variables._template, arguments.model)
	}

}