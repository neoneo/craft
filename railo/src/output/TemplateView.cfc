component implements="View" {

	public void function init(required String template, required TemplateRenderer renderer) {
		this.template = arguments.template
		this.renderer = arguments.renderer
	}

	/**
	* Renders the view by delegating to the `TemplateRenderer`.
	*/
	public Any function render(required Any model) {
		return this.renderer.render(this.template, arguments.model ?: {});
	}

}