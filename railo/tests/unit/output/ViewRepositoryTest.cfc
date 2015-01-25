import craft.output.ViewRepository;

component extends="tests.MocktorySpec" {

	mapping = "/tests/unit/output/stubs"
	dotMapping = mapping.listChangeDelims(".", "/")

	function run() {

		describe("ViewRepository", function () {

			beforeEach(function () {
				templateRenderer = mock("TemplateRenderer")
				viewFinder = mock("ClassFinder")

				viewRepository = mock(new ViewRepository(templateRenderer))
					.$property("viewFinder", "this", viewFinder)
			})

			describe(".get", function () {

				describe("creating views", function () {

					describe("if the view exists", function () {

						beforeEach(function () {
							mock({
								$object: viewFinder,
								exists: {
									$args: ["ViewStub"],
									$returns: true
								},
								get: {
									$args: ["ViewStub"],
									$returns: dotMapping & ".ViewStub"
								}
							})
						})

						it("should create the given view", function () {
							var result = viewRepository.get("ViewStub")

							expect(result).toBeInstanceOf(dotMapping & ".ViewStub")
						})

						it("should inject the template renderer into the view", function () {
							var result = viewRepository.get("ViewStub")

							$assert.isSameInstance(templateRenderer, result.templateRenderer)
						})

						// it("should inject the given properties into the view", function () {
						// 	var properties = {
						// 		property1: "property1",
						// 		property2: "property2"
						// 	}

						// 	var result = viewRepository.get("ViewStub", properties)
						// })

					})

					describe("if the view does not exist", function () {

						beforeEach(function () {
							mock({
								$object: viewFinder,
								exists: {
									$args: ["ViewStub"],
									$returns: false
								}
							})
						})

						it("should create a template view", function () {
							var result = viewRepository.get("ViewStub")

							expect(result).toBeInstanceOf("craft.output.TemplateView")
						})

						it("should inject the template renderer into the template view", function () {
							var result = viewRepository.get("ViewStub")

							$assert.isSameInstance(templateRenderer, result.templateRenderer)
						})

						// it("should inject the given properties into the template view", function () {
						// 	var properties = {
						// 		property1: "property1",
						// 		property2: "property2"
						// 	}

						// 	var result = viewRepository.get("ViewStub", properties)

						// 	expect(result.properties).toBe(properties)
						// })

					})

				})

			})

			describe(".addMapping", function () {

				it("should add the mapping", function () {
					mock({
						$object: viewFinder,
						addMapping: null
					})

					viewRepository.addMapping("/some/mapping")

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

					viewRepository.removeMapping("/some/mapping")

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

					viewRepository.clearMappings()

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