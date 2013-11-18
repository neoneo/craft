import craft.core.util.ScopeCollection;

/**
 * A `Composite` is a `Node` that contains other `Node`s.
 *
 * @abstract
 */
component extends="Node" {

	variables._children = new ScopeCollection()

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitComposite(this)
	}

	public void function traverse(required Visitor visitor) {

		for (var child in children()) {
			child.accept(arguments.visitor)
		}

	}

	/**
	 * Returns whether the `Component` contains `Node`s.
	 **/
	public Boolean function hasChildren() {
		return !variables._children.isEmpty()
	}

	public Array function children() {
		return variables._children.toArray()
	}

	/**
	 * Adds a `Node` to this `Composite`.
	 **/
	public void function addChild(required Node child, Node beforeChild) {
		var added = variables._children.add(argumentCollection: ArrayToStruct(arguments))
		if (added) {
			arguments.child.setParent(this)
		}
	}

	/**
	 * Removes the `Node` from this `Composite`.
	 **/
	public void function removeChild(required Node child) {
		variables._children.remove(arguments.child)
	}

	/**
	 * Moves the `Node` to another position among its siblings.
	 * The optional `beforeNode` argument specifies where to move the `Node`. If `beforeNode` is null, the `Node` is moved to the end.
	 **/
	public void function moveChild(required Node child, Node beforeChild) {
		variables._children.move(argumentCollection: ArrayToStruct(arguments))
	}

}