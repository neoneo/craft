import craft.util.ScopeCollection;

/**
 * A `Composite` is a `Component` that contains other `Component`s.
 *
 * @abstract
 */
component extends="Component" {

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
	 * Returns whether the `Component` contains `Component`s.
	 */
	public Boolean function hasChildren() {
		return !variables._children.isEmpty()
	}

	public Component[] function children() {
		return variables._children.toArray()
	}

	/**
	 * Adds a `Component` to this `Composite`.
	 * The optional `beforeChild` argument specifies where to move the `Component`. If `beforeChild` is null, the `Component` is moved to the end.
	 */
	public void function addChild(required Component child, Component beforeChild) {
		var success = variables._children.add(argumentCollection: ArrayToStruct(arguments))
		if (success) {
			arguments.child.setParent(this)
		}
	}

	/**
	 * Removes the `Component` from this `Composite`.
	 */
	public void function removeChild(required Component child) {
		var success = variables._children.remove(arguments.child)
		if (success) {
			arguments.child.setParent(null)
		}
	}

	/**
	 * Moves the `Component` to another position among its siblings.
	 * The optional `beforeChild` argument specifies where to move the `Component`. If `beforeChild` is null, the `Component` is moved to the end.
	 */
	public void function moveChild(required Component child, Component beforeChild) {
		variables._children.move(argumentCollection: ArrayToStruct(arguments))
	}

}