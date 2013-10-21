import craft.core.util.ScopeBranchList;

/**
 * @abstract
 **/
component extends="Node" {

	public void function init() {
		super.init()
		variables.children = new ScopeBranchList(this)
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitComposite(this)
	}

	/**
	 * Returns whether the component contains nodes.
	 **/
	public Boolean function hasChildren() {
		return !variables.children.isEmpty()
	}

	public Array function getChildren() {
		return variables.children.toArray()
	}

	/**
	 * Adds a node to this component.
	 **/
	public void function addChild(required Node child, Node beforeChild) {
		variables.children.add(argumentCollection = arguments.toStruct())
	}

	/**
	 * Removes the node from this component.
	 **/
	public void function removeChild(required Node child) {
		variables.children.remove(arguments.child)
	}

	/**
	 * Moves the node to another position among its siblings.
	 * The optional beforeNode argument specifies where to move the node. If beforeNode is null, the node is moved to the end.
	 **/
	public void function moveChild(required Node child, Node beforeChild) {
		variables.children.move(argumentCollection = arguments.toStruct())
	}

}