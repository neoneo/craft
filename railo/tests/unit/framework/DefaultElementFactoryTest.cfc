import craft.framework.DefaultElementFactory;

component extends="tests.MocktorySpec" {

	mapping = "/tests/unit/framework/stubs"
	dotMapping = mapping.listChangeDelims(".", "/")

	function run() {

		describe("DefaultElementFactory", function () {

			beforeEach(function () {
				elementFactory = new DefaultElementFactory()
			})

			describe(".create", function () {

				it("should create the element", function () {
					var result = elementFactory.create(dotMapping & ".SomeElement", {})

					expect(result).toBeInstanceOf(dotMapping & ".SomeElement")
				})

				it("should inject the given attributes into the element", function () {
					var attributes = {
						ref: "ref",
						attribute: "attribute"
					}

					var result = elementFactory.create(dotMapping & ".SomeElement", attributes)

					expect(result).toBeInstanceOf(dotMapping & ".SomeElement")
					expect(result.ref).toBe(attributes.ref)
					expect(result.attribute).toBe(attributes.attribute)
				})

			})

		})

	}

}