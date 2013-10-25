/**
 * A `Leaf` is a `Node` that does not contain other `Node`s.
 *
 * @abstract
 */
component extends="Node" {

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitLeaf(this)
	}

	public Boolean function hasChildren() {
		return false
	}


}