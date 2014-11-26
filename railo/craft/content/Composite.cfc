import craft.util.Collection;
import craft.util.ScopeCollection;

/**
 * A `Composite` is a `Component` that contains other `Component`s.
 *
 * @abstract
 */
component extends="Component" accessors="true" {

	property Array children setter="false"; // Component[]
	property Boolean hasChildren setter="false";

	this.childCollection = this.createCollection()

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitComposite(this)
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
	public Boolean function addChild(required Component child, Component beforeChild) {

		var success = this.childCollection.add(arguments.child, arguments.beforeChild ?: null)
		if (success) {
			arguments.child.parent = this
		}

		return success;
	}

	/**
	 * Removes the `Component` from this `Composite`.
	 */
	public Boolean function removeChild(required Component child) {

		var success = this.childCollection.remove(arguments.child)
		if (success) {
			arguments.child.parent = null
		}

		return success;
	}

	/**
	 * Moves the `Component` to another position among its siblings.
	 * The optional `beforeChild` argument specifies where to move the `Component`. If `beforeChild` is null, the `Component` is moved to the end.
	 */
	public Boolean function moveChild(required Component child, Component beforeChild) {
		return this.childCollection.move(arguments.child, arguments.beforeChild ?: null);
	}

	public void function traverse(required Visitor visitor) {
		for (var child in this.getChildren()) {
			child.accept(arguments.visitor)
		}
	}

	private Collection function createCollection() {
		return new ScopeCollection();
	}

}