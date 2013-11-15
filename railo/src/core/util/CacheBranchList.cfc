component extends="BranchList" {

	public void function init(required Branch parent, required Cache cache) {

		variables._cache = arguments.cache
		variables._keys = []
		variables._parentKey = obtainKey(arguments.parent)
		variables._cache.put(variables._parentKey, arguments.parent)

	}

	public Branch function parent() {
		return variables._cache.get(variables._parentKey)
	}

	public Boolean function remove(required Branch child) {

		var key = obtainKey(arguments.child)
		var exists = variables._keys.delete(key)
		if (exists) {
			variables._cache.remove(key)
		}

		return exists
	}

	public Boolean function contains(required Branch child) {
		return variables._cache.has(obtainKey(arguments.child))
	}

	public Boolean function isEmpty() {
		return variables._keys.isEmpty()
	}

	public any function select(required Function predicate) {
		// The predicate wants to handle children directly, so first get the children from the cache and then apply the predicate.
		var branches = toArray()
		var index = branches.find(arguments.predicate)
		if (index > 0) {
			return branches[index]
		}
	}

	public Numeric function size() {
		return variables._keys.len()
	}

	public Array function toArray() {

		var branches = []
		variables._keys.each(function (key) {
			branches.append(variables._cache.get(arguments.key))
		})

		return branches
	}

	private void function append(required Branch child) {

		var key = obtainKey(arguments.child)
		variables._keys.delete(key)
		variables._keys.append(key)
		variables._cache.put(key, arguments.child)

	}

	private void function insertAt(required Numeric index, required Branch child) {
		variables._keys.insertAt(arguments.index, obtainKey(arguments.child))
	}

	private void function deleteAt(required Numeric index) {
		variables._keys.deleteAt(arguments.index)
	}

	private Numeric function indexOf(required Branch child) {
		return variables._keys.find(obtainKey(arguments.child))
	}

	private String function obtainKey(required Branch child) {

		if (!StructKeyExists(arguments.child, "_cacheKey")) {
			arguments.child._cacheKey = generateKey()
		}

		return arguments.child._cacheKey
	}

	private String function generateKey() {
		return CreateGUID()
	}

}