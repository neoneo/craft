component implements="TemplateContent" accessors="true" {

	public void function init(required Section section) {
		variables._section = arguments.section
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitTemplate(this)
	}

	public Section function section() {
		return variables._section
	}

	public Array function placeholders() {
		return variables._section.placeholders()
	}

}