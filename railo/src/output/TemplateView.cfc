component implements="View" {

	public void function init(required String template, required TemplateRenderer renderer) {
		variables._template = arguments.template
		variables._renderer = arguments.renderer
	}

	/**
	* Renders the view by delegating to the `TemplateRenderer`.
	*/
	public Any function render(required Any model) {
		return variables._renderer.render(variables._template, arguments.model ?: {})
	}

}