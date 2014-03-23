component implements="LayoutContent" {

	public void function init(required Section section) {
		variables._section = arguments.section
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitLayout(this)
	}

	public Section function section() {
		return variables._section
	}

	public Placeholder[] function placeholders() {
		return variables._section.placeholders()
	}

}