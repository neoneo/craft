import craft.framework.ContentFactory;

component extends="tests.MocktorySpec" {

	mapping = "/tests/unit/framework/stubs"
	dotMapping = mapping.listChangeDelims(".", "/")

	function run() {

		describe("ContentFactory", function () {

			beforeEach(function () {
				viewFactory = mock("ViewFactory")
				componentFinder = mock("ClassFinder")
				objectHelper = mock({
					$class: "ObjectHelper",
					initialize: null
				})

				contentFactory = mock(new ContentFactory(viewFactory))
					.$property("componentFinder", "this", componentFinder)
					.$property("objectHelper", "this", objectHelper)
			})

			describe(".create", function () {

				beforeEach(function () {
					mock({
						$object: componentFinder,
						get: dotMapping & ".SomeContent"
					})
				})

				it("should create the content object", function () {
					var result = contentFactory.create("SomeContent")

					expect(result).toBeInstanceOf(dotMapping & ".SomeContent")
					verify(objectHelper, {
						initialize: {
							$args: [result, {}],
							$times: 1
						}
					})
				})

				it("should inject the view factory in the content object", function () {
					var result = contentFactory.create("SomeContent")

					$assert.isSameInstance(viewFactory, result.getViewFactory())
				})

				it("should inject the given properties into the content object", function () {
					var properties = {
						property1: "property1",
						property2: "property2"
					}

					var result = contentFactory.create("SomeContent", properties)

					verify(objectHelper, {
						initialize: {
							$args: [result, properties],
							$times: 1
						}
					})
				})

			})

			describe(".addMapping", function () {

				it("should add the mapping", function () {
					mock({
						$object: componentFinder,
						addMapping: null
					})

					contentFactory.addMapping("/some/mapping")

					verify(componentFinder, {
						addMapping: {
							$args: ["/some/mapping"],
							$times: 1
						}
					})
				})

			})

			describe(".removeMapping", function () {

				it("should remove the mapping", function () {
					mock({
						$object: componentFinder,
						removeMapping: null
					})

					contentFactory.removeMapping("/some/mapping")

					verify(componentFinder, {
						removeMapping: {
							$args: ["/some/mapping"],
							$times: 1
						}
					})
				})

			})

		})

	}

}