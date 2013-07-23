component implements="Cache" {

	public void function init() {
		variables.cache = {}
	}

	public any function get(required String key) {
		return variables.cache[arguments.key]
	}

	public void function put(required String key, required any object) {
		variables.cache[arguments.key] = arguments.object
	}

	public void function remove(required String key) {
		variables.cache.delete(arguments.key)
	}

	public Boolean function has(required String key) {
		return variables.cache.keyExists(arguments.key)
	}

	public void function clear() {
		variables.cache.clear()
	}

	public Array function keys() {
		return variables.cache.keyArray()
	}

}