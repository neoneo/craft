component implements="TemplateContent" accessors="true" {

	property Section section setter="false";

	public void function init(required Section section) {
		variables.section = arguments.section
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitTemplate(this)
	}

	public Array function getPlaceholders() {
		return getPlaceholdersFromNode(getSection())
	}

	private Array function getPlaceholdersFromNode(required Node node) {

		var placeholders = []
		if (arguments.node.hasChildren()) {
			arguments.node.getChildren().each(function (child) {
				if (IsInstanceOf(arguments.child, "Placeholder")) {
					placeholders.append(arguments.child)
				} else {
					placeholders.append(getPlaceholdersFromNode(arguments.child), true)
				}
			})
		}

		return placeholders
	}

}