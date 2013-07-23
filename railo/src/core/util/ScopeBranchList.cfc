component extends="BranchList" {

	public void function init(required Branch parent) {
		super.init(arguments.parent)
		variables.children = []
	}

	public Boolean function remove(required Branch child) {
		return variables.children.delete(arguments.child)
	}

	public Boolean function contains(required Branch child) {
		return variables.children.find(arguments.child) > 0
	}

	public Boolean function isEmpty() {
		return variables.children.isEmpty()
	}

	public any function select(required Function predicate) {
		var index = variables.children.find(arguments.predicate)
		if (index > 0) {
			return variables.children[index]
		}
	}

	public Numeric function size() {
		return variables.children.len()
	}

	public Array function toArray() {
		return ([]).merge(variables.children)
	}

	private void function append(required Branch child) {
		variables.children.append(arguments.child)
	}

	private void function insertAt(required Numeric index, required Branch child) {
		variables.children.insertAt(arguments.index, arguments.child)
	}

	private void function deleteAt(required Numeric index) {
		variables.children.deleteAt(arguments.index)
	}

	private Numeric function indexOf(required Branch child) {
		return variables.children.find(arguments.child)
	}

}