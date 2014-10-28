component extends="Collection" {

	this.items = []

	public Boolean function remove(required Any item) {
		return this.items.delete(arguments.item);
	}

	public Boolean function contains(required Any item) {
		return this.items.find(arguments.item) > 0;
	}

	public Boolean function isEmpty() {
		return this.items.isEmpty();
	}

	public Any function select(required Function predicate) {
		var index = this.items.find(arguments.predicate)
		return index > 0 ? this.items[index] : null;
	}

	public Numeric function size() {
		return this.items.len();
	}

	public Array function toArray() {
		return this.items;
	}

	private void function append(required Any item) {
		this.items.append(arguments.item)
	}

	private void function insertAt(required Numeric index, required Any item) {
		this.items.insertAt(arguments.index, arguments.item)
	}

	private void function deleteAt(required Numeric index) {
		this.items.deleteAt(arguments.index)
	}

	private Numeric function indexOf(required Any item) {
		return this.items.find(arguments.item);
	}

}