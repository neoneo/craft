component implements="Cache" {

	public void function init(TimeSpan timeToLive, TimeSpan idleTime, String cacheName) {

		this.timeToLive = arguments.timeToLive ?: null
		this.idleTime = arguments.idleTime ?: null
		this.cacheName = arguments.cacheName ?: null

		// Create a 'bit mask' for the three arguments.
		// 1: time to live, 2: idle time, 4: cache name
		this.mask = 0
		this.mask += this.timeToLive !== null ? 1 : 0
		this.mask += this.idleTime !== null ? 2 : 0
		this.mask += this.cacheName !== null ? 4 : 0

		// An argument can only be provided if the previous argument is provided as well.
		if (this.mask == 2 || this.mask > 3 && this.mask < 7) {
			Throw("Illegal arguments", "IllegalArgumentException");
		}

		this.key = CreateGUID() & "/"

	}

	public Any function get(required String key) {
		if (this.mask < 7) {
			return CacheGet(this.key & arguments.key);
		} else {
			return CacheGet(this.key & arguments.key, this.cacheName);
		}
	}

	public void function put(required String key, required Any value) {
		if (this.mask == 0) {
			CachePut(this.key & arguments.key, arguments.value)
		} else if (this.mask == 1) {
			CachePut(this.key & arguments.key, arguments.value, this.timeToLive)
		} else if (this.mask == 3) {
			CachePut(this.key & arguments.key, arguments.value, this.timeToLive, this.idleTime)
		} else if (this.mask == 7) {
			CachePut(this.key & arguments.key, arguments.value, this.timeToLive, this.idleTime, this.cacheName)
		}
	}

	public void function remove(required String key) {
		if (this.mask < 7) {
			CacheRemove(this.key & arguments.key)
		} else {
			CacheRemove(this.key & arguments.key, this.cacheName)
		}
	}

	public Boolean function has(required String key) {
		if (this.mask < 7) {
			return CacheIdExists(this.key & arguments.key);
		} else {
			return CacheIdExists(this.key & arguments.key, this.cacheName);
		}
	}

	public void function clear() {
		if (this.mask < 7) {
			CacheClear(this.key & "*")
		} else {
			CacheClear(this.key & "*", this.cacheName)
		}
	}

	public String[] function keys() {
		if (this.mask < 7) {
			return CacheGetAllIds(this.key & "*");
		} else {
			return CacheGetAllIds(this.key & "*", this.cacheName);
		}

	}

}