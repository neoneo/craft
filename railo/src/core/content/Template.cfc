import craft.core.request.Context;

component implements="TemplateContent" {

	public void function init(required TemplateComponent templateComponent) {
		variables.templateComponent = arguments.templateComponent
	}

	public String function render(required Context context) {
		return variables.templateComponent.render(arguments.context)
	}

	public Array function getPlaceholders() {
		return variables.templateComponent.getPlaceholders()
	}

}