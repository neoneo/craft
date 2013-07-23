component extends="BranchList" {

	public void function init(required Branch parent, required Cache cache) {

		variables.cache = arguments.cache
		variables.keys = []
		variables.parentKey = obtainKey(arguments.parent)
		variables.cache.put(variables.parentKey, arguments.parent)

	}

	public Branch function getParent() {
		return variables.cache.get(variables.parentKey)
	}

	public Boolean function remove(required Branch child) {

		var key = obtainKey(arguments.child)
		var exists = variables.keys.delete(key)
		if (exists) {
			variables.cache.remove(key)
		}

		return exists
	}

	public Boolean function contains(required Branch child) {
		return variables.cache.has(obtainKey(arguments.child))
	}

	public Boolean function isEmpty() {
		return variables.keys.isEmpty()
	}

	public any function select(required Function predicate) {
		// the predicate wants to handle children directly, so first get the children from the cache and then apply the predicate
		var branches = toArray()
		var index = branches.find(arguments.predicate)
		if (index > 0) {
			return branches[index]
		}
	}

	public Numeric function size() {
		return variables.keys.len()
	}

	public Array function toArray() {

		var branches = []
		variables.keys.each(function (key) {
			branches.append(variables.cache.get(arguments.key))
		})

		return branches
	}

	private void function append(required Branch child) {

		var key = obtainKey(arguments.child)
		variables.keys.append(key)
		variables.cache.put(key, arguments.child)

	}

	private void function insertAt(required Numeric index, required Branch child) {
		variables.keys.insertAt(arguments.index, obtainKey(arguments.child))
		dump(variables.keys)
	}

	private void function deleteAt(required Numeric index) {
		variables.keys.deleteAt(arguments.index)
		dump(variables.keys)
	}

	private Numeric function indexOf(required Branch child) {
		return variables.keys.find(obtainKey(arguments.child))
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