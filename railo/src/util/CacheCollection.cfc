component extends="Collection" {

	public void function init(required Cache cache) {
		variables._cache = arguments.cache
		variables._key = generateKey()
		variables._cache.put(variables._key, [])
	}

	public Boolean function remove(required Any item) {

		var items = get()
		var removed = items.delete(arguments.item)

		put(items)

		return removed
	}

	public Boolean function contains(required Any item) {
		return get().find(arguments.item) > 0
	}

	public Boolean function isEmpty() {
		return get().isEmpty()
	}

	public Any function select(required Function predicate) {

		var items = get()
		var index = items.find(arguments.predicate)

		return index > 0 ? items[index] : null
	}

	public Numeric function size() {
		return get().len()
	}

	public Array function toArray() {
		return get()
	}

	private void function append(required Any item) {

		var items = get()
		items.delete(arguments.item)
		items.append(arguments.item)

		put(items)
	}

	private void function insertAt(required Numeric index, required Any item) {
		var items = get()
		items.insertAt(arguments.index, arguments.item)
		put(items)
	}

	private void function deleteAt(required Numeric index) {
		var items = get()
		items.deleteAt(arguments.index)
		put(items)
	}

	private Numeric function indexOf(required Any item) {
		return get().find(arguments.item)
	}

	private Array function get() {
		return variables._cache.get(variables._key)
	}

	private void function put(required Array items) {
		variables._cache.remove(variables._key)
		variables._cache.put(variables._key, arguments.items)
	}

	private String function generateKey() {
		return CreateGUID()
	}

}