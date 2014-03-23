component extends="View" {

	public void function init(required Renderer renderer, required String template) {
		variables._renderer = arguments.renderer
		variables._template = arguments.template
	}

	public Any function render(required Struct model, required Context context) {
		return variables._renderer.render(variables._template, arguments.model)
	}

}