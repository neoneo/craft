component extends="Collection" {

	variables._items = []

	public Boolean function remove(required Any item) {
		return variables._items.delete(arguments.item)
	}

	public Boolean function contains(required Any item) {
		return variables._items.find(arguments.item) > 0
	}

	public Boolean function isEmpty() {
		return variables._items.isEmpty()
	}

	public Any function select(required Function predicate) {
		var index = variables._items.find(arguments.predicate)
		return index > 0 ? variables._items[index] : null
	}

	public Numeric function size() {
		return variables._items.len()
	}

	public Array function toArray() {
		return variables._items
	}

	private void function append(required Any item) {
		remove(arguments.item)
		variables._items.append(arguments.item)
	}

	private void function insertAt(required Numeric index, required Any item) {
		variables._items.insertAt(arguments.index, arguments.item)
	}

	private void function deleteAt(required Numeric index) {
		variables._items.deleteAt(arguments.index)
	}

	private Numeric function indexOf(required Any item) {
		return variables._items.find(arguments.item)
	}

}