component implements="Cache" {

	this.cache = {}

	public Any function get(required String key) {
		return this.cache[arguments.key];
	}

	public void function put(required String key, required Any value) {
		this.cache[arguments.key] = arguments.value
	}

	public void function remove(required String key) {
		this.cache.delete(arguments.key)
	}

	public Boolean function has(required String key) {
		return this.cache.keyExists(arguments.key);
	}

	public void function clear() {
		this.cache.clear()
	}

	public String[] function keys() {
		return this.cache.keyArray();
	}

}