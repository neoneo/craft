import craft.framework.DefaultElementFactory;

component extends="tests.MocktorySpec" {

	mapping = "/tests/unit/framework/stubs"
	dotMapping = mapping.listChangeDelims(".", "/")

	function run() {

		describe("DefaultElementFactory", function () {

			beforeEach(function () {
				contentFactory = mock("ContentFactory")
				objectHelper = mock({
					$class: "ObjectHelper",
					initialize: null
				})
				elementFactory = mock(new DefaultElementFactory(contentFactory))
					.$property("objectHelper", "this", objectHelper)
			})

			describe(".create", function () {

				it("should create the element", function () {
					var result = elementFactory.create(dotMapping & ".SomeElement", {})

					expect(result).toBeInstanceOf(dotMapping & ".SomeElement")
					verify(objectHelper, {
						initialize: {
							$args: [result, {}],
							$times: 1
						}
					})
				})

				it("should inject the content factory into the element", function () {
					var result = elementFactory.create(dotMapping & ".SomeElement", {})

					$assert.isSameInstance(contentFactory, result.getContentFactory())
				})

				it("should inject the given attributes into the element", function () {
					var attributes = {
						ref: "ref",
						attribute: "attribute"
					}

					var result = elementFactory.create(dotMapping & ".SomeElement", attributes)

					verify(objectHelper, {
						initialize: {
							$args: [result, attributes],
							$times: 1
						}
					})
				})

			})

		})

	}

}