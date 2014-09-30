component {

	public void function init(required TemplateRenderer templateRenderer, required TemplateFinder templateFinder) {
		this.templateRenderer = arguments.templateRenderer
		this.templateFinder = arguments.templateFinder
	}

	public String function render(required String name, required Struct model) {
		var template = this.templateFinder.get(arguments.name)

		return this.templateRenderer.render(template, model);
	}

}