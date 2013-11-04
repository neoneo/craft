/**
 * Represents an isolated node tree.
 */
component accessors="true" {

	property Node node setter="false";

	public void function init(required Node node) {
		variables.node = arguments.node
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitSection(this)
	}

	public Array function getPlaceholders() {
		return getPlaceholdersFromNode(getNode())
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