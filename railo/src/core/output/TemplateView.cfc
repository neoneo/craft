component extends="View" {

	public void function init(required String template, required TemplateRenderer renderer) {
		variables._template = arguments.template
		variables._renderer = arguments.renderer
	}

	public String function render(required Struct model, required String method) {
		return variables._renderer.render(variables._template, arguments.model)
	}

}