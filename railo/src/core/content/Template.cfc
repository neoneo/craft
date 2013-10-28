component implements="TemplateContent" accessors="true" {

	property Section section setter="false";

	public void function init(required Section section) {
		variables.section = arguments.section
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitTemplate(this)
	}

	public Array function getPlaceholders() {
		return getSection().getPlaceholders()
	}

}