component extends="mxunit.framework.TestCase" {

	public void function ObjectCache() {
		test(new craft.util.ObjectCache())
	}

	public void function ScopeCache() {
		test(new craft.util.ScopeCache())
	}

	private void function test(required craft.util.Cache cache) {

		var object1 = {"id" = "object1"}
		var object2 = {"id" = "object2"}

		arguments.cache.put("key1", object1)
		arguments.cache.put("key2", object2)

		assertTrue(arguments.cache.has("key1"), "cache should have 'key1'")
		assertTrue(arguments.cache.has("key2"), "cache should have 'key2'")
		assertFalse(arguments.cache.has("key3"), "cache should not have 'key3'")

		assertEquals(2, arguments.cache.keys().len(), "cache should have 2 keys")

		assertEquals(object1, arguments.cache.get("key1"), "object at 'key1' should equal object1")
		assertEquals(object2, arguments.cache.get("key2"), "object at 'key2' should equal object2")

		arguments.cache.remove("key1")
		assertFalse(arguments.cache.has("key1"), "'key1' should have been removed")

		arguments.cache.clear()
		assertFalse(arguments.cache.has("key2"), "'key2' should have been removed")
		assertEquals(0, arguments.cache.keys().len(), "cache should be cleared")

	}

}