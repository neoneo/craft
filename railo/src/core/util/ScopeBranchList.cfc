component extends="BranchList" {

	public void function init(required Branch parent) {
		variables._parent = arguments.parent
		variables._children = []
	}

	public Branch function parent() {
		return variables._parent
	}

	public Boolean function remove(required Branch child) {
		return variables._children.delete(arguments.child)
	}

	public Boolean function contains(required Branch child) {
		return variables._children.find(arguments.child) > 0
	}

	public Boolean function isEmpty() {
		return variables._children.isEmpty()
	}

	public any function select(required Function predicate) {
		var index = variables._children.find(arguments.predicate)
		if (index > 0) {
			return variables._children[index]
		}
	}

	public Numeric function size() {
		return variables._children.len()
	}

	public Array function toArray() {
		return variables._children
	}

	private void function append(required Branch child) {
		remove(arguments.child)
		variables._children.append(arguments.child)
	}

	private void function insertAt(required Numeric index, required Branch child) {
		variables._children.insertAt(arguments.index, arguments.child)
	}

	private void function deleteAt(required Numeric index) {
		variables._children.deleteAt(arguments.index)
	}

	private Numeric function indexOf(required Branch child) {
		return variables._children.find(arguments.child)
	}

}