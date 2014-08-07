component implements="Cache" {

	public void function init(TimeSpan timeToLive, TimeSpan idleTime, String cacheName) {

		variables._timeToLive = arguments.timeToLive ?: null
		variables._idleTime = arguments.idleTime ?: null
		variables._cacheName = arguments.cacheName ?: null

		// Create a 'bit mask' for the three arguments.
		// 1: time to live, 2: idle time, 4: cache name
		variables._mask = 0
		variables._mask += variables._timeToLive !== null ? 1 : 0
		variables._mask += variables._idleTime !== null ? 2 : 0
		variables._mask += variables._cacheName !== null ? 4 : 0

		// An argument can only be provided if the previous argument is provided as well.
		if (variables._mask == 2 || variables._mask > 3 && variables._mask < 7) {
			Throw("Illegal arguments", "IllegalArgumentException")
		}

		variables._key = CreateGUID() & "/"

	}

	public Any function get(required String key) {
		if (variables._mask < 7) {
			return CacheGet(variables._key & arguments.key)
		} else {
			return CacheGet(variables._key & arguments.key, variables._cacheName)
		}
	}

	public void function put(required String key, required Any value) {
		if (variables._mask == 0) {
			CachePut(variables._key & arguments.key, arguments.value)
		} else if (variables._mask == 1) {
			CachePut(variables._key & arguments.key, arguments.value, variables._timeToLive)
		} else if (variables._mask == 3) {
			CachePut(variables._key & arguments.key, arguments.value, variables._timeToLive, variables._idleTime)
		} else if (variables._mask == 7) {
			CachePut(variables._key & arguments.key, arguments.value, variables._timeToLive, variables._idleTime, variables._cacheName)
		}
	}

	public void function remove(required String key) {
		if (variables._mask < 7) {
			CacheRemove(variables._key & arguments.key)
		} else {
			CacheRemove(variables._key & arguments.key, variables._cacheName)
		}
	}

	public Boolean function has(required String key) {
		if (variables._mask < 7) {
			return CacheIdExists(variables._key & arguments.key)
		} else {
			return CacheIdExists(variables._key & arguments.key, variables._cacheName)
		}
	}

	public void function clear() {
		if (variables._mask < 7) {
			CacheClear(variables._key & "*")
		} else {
			CacheClear(variables._key & "*", variables._cacheName)
		}
	}

	public String[] function keys() {
		if (variables._mask < 7) {
			return CacheGetAllIds(variables._key & "*")
		} else {
			return CacheGetAllIds(variables._key & "*", variables._cacheName)
		}

	}

}