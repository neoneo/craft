import craft.util.ClassFinder;

component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		mapping = "/tests/unit/util/classFinder"
		dotMapping = mapping.listChangeDelims(".", "/")
	}

	function run() {

		describe("ClassFinder", function () {

			beforeEach(function () {
				classFinder = new ClassFinder()
			})

			describe(".get", function () {

				it("should return the dot delimited mapping to the class", function () {
					classFinder.addMapping(mapping & "/package")

					var class = classFinder.get("Class")

					expect(class).toBe(dotMapping & ".package.Class")
				})

				it("should return the class when requested using a dot delimited mapping", function () {
					classFinder.addMapping(mapping)

					var class = classFinder.get("package.Class")

					expect(class).toBe(dotMapping & ".package.Class")
				})

				it("should return the class when requested using a slash delimited mapping", function () {
					classFinder.addMapping(mapping)

					var class = classFinder.get("/package/Class")

					expect(class).toBe(dotMapping & ".package.Class")
				})

			})

		})

	}

}