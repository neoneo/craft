import craft.framework.ViewFactory;

component extends="tests.MocktorySpec" {

	mapping = "/tests/unit/framework/stubs"
	dotMapping = mapping.listChangeDelims(".", "/")

	function run() {

		describe("ViewFactory", function () {

			beforeEach(function () {
				templateRenderer = mock("TemplateRenderer")
				viewFinder = mock("ClassFinder")

				viewFactory = mock(new ViewFactory(templateRenderer))
					.$property("viewFinder", "this", viewFinder)
			})

			describe(".create", function () {

				describe("if the view exists", function () {

					beforeEach(function () {
						mock({
							$object: viewFinder,
							exists: {
								$args: ["SomeView"],
								$returns: true
							},
							get: {
								$args: ["SomeView"],
								$returns: dotMapping & ".SomeView"
							}
						})
						objectHelper = mock({
							$class: "ObjectHelper",
							initialize: null
						})
						viewFactory.$property("objectHelper", "this", objectHelper)
					})

					it("should create the given view", function () {
						var result = viewFactory.create("SomeView")

						expect(result).toBeInstanceOf(dotMapping & ".SomeView")
					})

					it("should inject the template renderer into the view", function () {
						var result = viewFactory.create("SomeView")

						$assert.isSameInstance(templateRenderer, result.templateRenderer)
					})

					it("should inject the given properties into the view", function () {
						var properties = {
							property1: "property1",
							property2: "property2"
						}

						var result = viewFactory.create("SomeView", properties)

						verify(objectHelper, {
							initialize: {
								$args: [result, properties],
								$times: 1
							}
						})

					})

				})

				describe("if the view does not exist", function () {

					beforeEach(function () {
						mock({
							$object: viewFinder,
							exists: {
								$args: ["SomeView"],
								$returns: false
							}
						})
					})

					it("should create a template view", function () {
						var result = viewFactory.create("SomeView")

						expect(result).toBeInstanceOf("craft.output.TemplateView")
					})

					it("should inject the template renderer into the template view", function () {
						var result = viewFactory.create("SomeView")

						$assert.isSameInstance(templateRenderer, result.templateRenderer)
					})

					it("should inject the given properties into the template view", function () {
						var properties = {
							property1: "property1",
							property2: "property2"
						}

						var result = viewFactory.create("SomeView", properties)

						expect(result.properties).toBe(properties)
					})

				})

			})

			describe(".addMapping", function () {

				it("should add the mapping", function () {
					mock({
						$object: viewFinder,
						addMapping: null
					})

					viewFactory.addMapping("/some/mapping")

					verify(viewFinder, {
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
						$object: viewFinder,
						removeMapping: null
					})

					viewFactory.removeMapping("/some/mapping")

					verify(viewFinder, {
						removeMapping: {
							$args: ["/some/mapping"],
							$times: 1
						}
					})
				})

			})

			describe(".clearMappings", function () {

				it("should clear the mapping", function () {
					mock({
						$object: viewFinder,
						clear: null
					})

					viewFactory.clearMappings()

					verify(viewFinder, {
						clear: {
							$times: 1
						}
					})
				})

			})

		})

	}

}