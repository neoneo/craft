import craft.core.request.Context;

component implements="Content" accessors="true" {

	property TemplateContent template setter="false";
	property Struct sections setter="false";

	public void function init(required TemplateContent template) {
		setTemplate(arguments.template)
		variables.sections = {}
	}

	public String function render(required Renderer renderer) {
		return arguments.renderer.document(this)
	}

	public void function addSection(required Section section, required Placeholder placeholder) {

		var sections = getSections()
		var ref = arguments.placeholder.getRef()
		if (!sections.keyExists(ref)) {
			sections[ref] = arguments.section
		}

	}

	/**
	 * Removes the nodes for the given section.
	 **/
	public void function removeSection(required Placeholder placeholder) {
		getSections().delete(arguments.placeholder.getRef())
	}

	private void function setTemplate(required TemplateContent template) {
		variables.template = arguments.template
	}

}