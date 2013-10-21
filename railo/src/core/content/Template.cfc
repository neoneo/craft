import craft.core.output.Renderer;

component implements="TemplateContent" {

	property Section section setter="false";

	public void function init(required Section section) {
		variables.section = arguments.section
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitTemplate(this)
	}

	public Array function getPlaceholders() {
		return variables.section.getPlaceholders()
	}

}