import craft.util.*;

component extends="testbox.system.BaseSpec" {

	function run() {

		describe("ObjectCache", function () {
			it("should work", function () {
				test(new ObjectCache())
			})
		})

		describe("ScopeCache", function () {
			it("should work", function () {
				test(new ScopeCache())
			})
		})

	}

	function test(required Cache cache) {

		var object1 = {"id" = "object1"}
		var object2 = {"id" = "object2"}

		arguments.cache.put("key1", object1)
		arguments.cache.put("key2", object2)

		expect(arguments.cache.has("key1")).toBeTrue("cache should have 'key1'")
		expect(arguments.cache.has("key2")).toBeTrue("cache should have 'key2'")
		expect(arguments.cache.has("key3")).toBeFalse("cache should not have 'key3'")

		expect(arguments.cache.keys().len()).toBe(2, "cache should have 2 keys")

		expect(arguments.cache.get("key1")).toBe(object1, "object at 'key1' should be object1")
		expect(arguments.cache.get("key2")).toBe(object2, "object at 'key2' should be object2")

		arguments.cache.remove("key1")
		expect(arguments.cache.has("key1")).toBeFalse("'key1' should have been removed")

		arguments.cache.clear()
		expect(arguments.cache.has("key2")).toBeFalse("'key2' should have been removed")
		expect(arguments.cache.keys().len()).toBe(0, "cache should be cleared")

	}

}