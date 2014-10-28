component extends="Collection" {

	public void function init(required Cache cache) {
		this.cache = arguments.cache
		this.key = CreateGUID()
		this.cache.put(this.key, [])
	}

	public Boolean function remove(required Any item) {

		var items = this.get()
		var removed = items.delete(arguments.item)

		this.put(items)

		return removed;
	}

	public Boolean function contains(required Any item) {
		return this.get().find(arguments.item) > 0;
	}

	public Boolean function isEmpty() {
		return this.get().isEmpty();
	}

	public Any function select(required Function predicate) {

		var items = this.get()
		var index = items.find(arguments.predicate)

		return index > 0 ? items[index] : null;
	}

	public Numeric function size() {
		return this.get().len();
	}

	public Array function toArray() {
		return this.get();
	}

	private void function append(required Any item) {

		var items = this.get()
		items.append(arguments.item)

		this.put(items)
	}

	private void function insertAt(required Numeric index, required Any item) {
		var items = this.get()
		items.insertAt(arguments.index, arguments.item)
		this.put(items)
	}

	private void function deleteAt(required Numeric index) {
		var items = this.get()
		items.deleteAt(arguments.index)
		this.put(items)
	}

	private Numeric function indexOf(required Any item) {
		return this.get().find(arguments.item);
	}

	private Array function get() {
		return this.cache.get(this.key);
	}

	private void function put(required Array items) {
		this.cache.remove(this.key)
		this.cache.put(this.key, arguments.items)
	}

}