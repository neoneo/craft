component implements="LayoutContent" accessors="true" {

	property Section section setter="false";
	property Array placeholders setter="false"; // Placeholder[]

	public void function init(required Section section) {
		this.section = arguments.section
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitLayout(this)
	}

	public Placeholder[] function getPlaceholders() {
		return this.section.getPlaceholders();
	}

}