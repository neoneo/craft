component implements="Cache" {

	variables._cache = {}

	public Any function get(required String key) {
		return variables._cache[arguments.key]
	}

	public void function put(required String key, required Any value) {
		variables._cache[arguments.key] = arguments.value
	}

	public void function remove(required String key) {
		variables._cache.delete(arguments.key)
	}

	public Boolean function has(required String key) {
		return variables._cache.keyExists(arguments.key)
	}

	public void function clear() {
		variables._cache.clear()
	}

	public String[] function keys() {
		return variables._cache.keyArray()
	}

}