component extends="View" {

	public void function configure(required String template, Struct properties = {}) {
		this.template = arguments.template
		this.properties = arguments.properties
	}

	/**
	 * Renders the view by delegating to the `TemplateRenderer`.
	 */
	public String function render(required Any model) {

		var model = IsStruct(arguments.model) ? arguments.model.append(this.properties) : this.properties

		return this.templateRenderer.render(this.template, model);
	}

}