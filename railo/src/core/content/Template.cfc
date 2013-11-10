component implements="TemplateContent" accessors="true" {

	property Section section;

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitTemplate(this)
	}

	public Array function getPlaceholders() {
		return getSection().getPlaceholders()
	}

}