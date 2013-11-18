import craft.core.util.ScopeCollection;

/**
 * Represents an isolated node tree.
 */
component accessors="true" {

	/*
		A section has functional overlap with a composite, but it is not the same thing.
		There is no model or view, and a section can't have a parent. Still, we could think about
		letting section extend composite.
	*/

	variables._nodes = new ScopeCollection()

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitSection(this)
	}

	public void function traverse(required Visitor visitor) {

		for (var node in nodes()) {
			node.accept(arguments.visitor)
		}

	}

	public Array function placeholders() {
		return placeholdersFromNodes(nodes())
	}

	public Array function nodes() {
		return variables._nodes.toArray()
	}

	public void function addNode(required Node node, Node node) {
		variables._nodes.add(argumentCollection: ArrayToStruct(arguments))
	}

	public void function removeNode(required Node node) {
		variables._nodes.remove(arguments.node)
	}

	public void function moveNode(required Node node, Node beforeNode) {
		variables._nodes.move(argumentCollection: ArrayToStruct(arguments))
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