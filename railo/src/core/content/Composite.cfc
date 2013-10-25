import craft.core.util.ScopeBranchList;

/**
 * A `Composite` is a `Node` that contains other `Node`s.
 *
 * @abstract
 */
component extends="Node" {

	public void function init() {
		super.init()
		variables.children = new ScopeBranchList(this)
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitComposite(this)
	}

	public void function traverse(required Visitor visitor) {

		for (var child in getChildren()) {
			child.accept(arguments.visitor)
		}

	}

	/**
	 * Returns whether the `Component` contains `Node`s.
	 **/
	public Boolean function hasChildren() {
		return !variables.children.isEmpty()
	}

	public Array function getChildren() {
		return variables.children.toArray()
	}

	/**
	 * Adds a `Node` to this `Composite`.
	 **/
	public void function addChild(required Node child, Node beforeChild) {
		variables.children.add(argumentCollection: ArrayToStruct(arguments))
	}

	/**
	 * Removes the `Node` from this `Composite`.
	 **/
	public void function removeChild(required Node child) {
		variables.children.remove(arguments.child)
	}

	/**
	 * Moves the `Node` to another position among its siblings.
	 * The optional `beforeNode` argument specifies where to move the `Node`. If `beforeNode` is null, the `Node` is moved to the end.
	 **/
	public void function moveChild(required Node child, Node beforeChild) {
		variables.children.move(argumentCollection: ArrayToStruct(arguments))
	}

}