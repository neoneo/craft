import craft.core.request.Context;

component {

	public void function init(required TemplateComponent templateComponent) {
		variables.templateComponent = arguments.templateComponent
	}

	public String function render(required Context context) {
		return variables.templateComponent.render(arguments.context)
	}

}