import craft.util.ObjectCache;
import craft.util.ScopeCache;


component extends="testbox.system.BaseSpec" {

	function run() {

		describe("ObjectCache", function () {
			it("should put, get and remove items", function () {
				test(new ObjectCache())
			})
		})

		describe("ScopeCache", function () {
			it("should put, get and remove items", function () {
				test(new ScopeCache())
			})
		})

	}

	function test(required Cache cache) {

		var object1 = {id: "object1"}
		var object2 = {id: "object2"}

		arguments.cache.put("key1", object1)
		arguments.cache.put("key2", object2)

		expect(arguments.cache.has("key1")).toBeTrue()
		expect(arguments.cache.has("key2")).toBeTrue()
		expect(arguments.cache.has("key3")).toBeFalse()

		expect(arguments.cache.keys().len()).toBe(2)

		expect(arguments.cache.get("key1")).toBe(object1)
		expect(arguments.cache.get("key2")).toBe(object2)

		arguments.cache.remove("key1")
		expect(arguments.cache.has("key1")).toBeFalse()

		arguments.cache.clear()
		expect(arguments.cache.has("key2")).toBeFalse()
		expect(arguments.cache.keys().len()).toBe(0)

	}

}