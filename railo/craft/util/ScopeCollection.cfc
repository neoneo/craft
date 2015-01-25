component extends="Collection" {

	// The CopyOnWriteArrayList allows concurrent reads without synchronization. It is much slower for writes, but these are expected to be limited.
	this.items = CreateObject("java", "java.util.concurrent.CopyOnWriteArrayList").init()

	public Boolean function remove(required Any item) {
		return ArrayDelete(this.items, arguments.item);
	}

	public Boolean function contains(required Any item) {
		return ArrayFind(this.items, arguments.item) > 0;
	}

	public Boolean function isEmpty() {
		return ArrayIsEmpty(this.items);
	}

	public Any function select(required Function predicate) {
		var index = ArrayFind(this.items, arguments.predicate)
		return index > 0 ? this.items[index] : null;
	}

	public Numeric function size() {
		return ArrayLen(this.items);
	}

	public Array function toArray() {
		return this.items;
	}

	private void function append(required Any item) {
		ArrayAppend(this.items, arguments.item)
	}

	private void function insertAt(required Numeric index, required Any item) {
		ArrayInsertAt(this.items, arguments.index, arguments.item)
	}

	private void function deleteAt(required Numeric index) {
		ArrayDeleteAt(this.items, arguments.index)
	}

	private Numeric function indexOf(required Any item) {
		return ArrayFind(this.items, arguments.item);
	}

}