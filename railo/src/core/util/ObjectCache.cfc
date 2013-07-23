component implements="Cache" {

	public any function get(required String key) {
		return CacheGet(arguments.key)
	}

	public void function put(required String key, required any object) {
		CachePut(arguments.key, arguments.object)
	}

	public void function remove(required String key) {
		CacheRemove(arguments.key)
	}

	public Boolean function has(required String key) {
		return CacheIdExists(arguments.key)
	}

	public void function clear() {
		CacheClear()
	}

	public Array function keys() {
		return CacheGetAllIds()
	}

}