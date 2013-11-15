/**
 * Represents an isolated node tree.
 */
component accessors="true" {

	variables._nodes = []

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitSection(this)
	}

	public Array function placeholders() {
		return placeholdersFromNodes(variables._nodes)
	}

	public void function addNode(required Node node) {
		variables._nodes.append(arguments.node)
	}

	public Array function nodes() {
		return variables._nodes
	}

	private Array function placeholdersFromNodes(required Array nodes) {

		var placeholders = []
		arguments.nodes.each(function (node) {
			if (IsInstanceOf(arguments.node, "Placeholder")) {
				placeholders.append(arguments.node)
			} else if (arguments.node.hasChildren()) {
				placeholders.append(placeholdersFromNodes(arguments.node.children()), true)
			}
		})

		return placeholders
	}

}