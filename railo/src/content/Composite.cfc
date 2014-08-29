import craft.util.ScopeCollection;

/**
 * A `Composite` is a `Component` that contains other `Component`s.
 *
 * @abstract
 */
component extends="Component" accessors="true" {

	property Array children setter="false"; /* Component[] */

	this.childCollection = new ScopeCollection()

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitComposite(this)
	}

	public void function traverse(required Visitor visitor) {

		for (var child in this.getChildren()) {
			child.accept(arguments.visitor)
		}

	}

	/**
	 * Returns whether the `Component` contains `Component`s.
	 */
	public Boolean function getHasChildren() {
		return !this.childCollection.isEmpty();
	}

	public Component[] function getChildren() {
		return this.childCollection.toArray();
	}

	/**
	 * Adds a `Component` to this `Composite`.
	 * The optional `beforeChild` argument specifies where to move the `Component`. If `beforeChild` is null, the `Component` is moved to the end.
	 */
	public void function addChild(required Component child, Component beforeChild) {
		var success = this.childCollection.add(argumentCollection: ArrayToStruct(arguments))
		if (success) {
			arguments.child.parent = this
		}
	}

	/**
	 * Removes the `Component` from this `Composite`.
	 */
	public void function removeChild(required Component child) {
		var success = this.childCollection.remove(arguments.child)
		if (success) {
			arguments.child.parent = null
		}
	}

	/**
	 * Moves the `Component` to another position among its siblings.
	 * The optional `beforeChild` argument specifies where to move the `Component`. If `beforeChild` is null, the `Component` is moved to the end.
	 */
	public void function moveChild(required Component child, Component beforeChild) {
		this.childCollection.move(argumentCollection: ArrayToStruct(arguments))
	}

}