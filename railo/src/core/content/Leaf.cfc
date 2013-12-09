/**
 * A `Leaf` is a `Component` that does not contain other `Component`s.
 *
 * @abstract
 */
component extends="Component" {

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitLeaf(this)
	}

	public Boolean function hasChildren() {
		return false
	}


}