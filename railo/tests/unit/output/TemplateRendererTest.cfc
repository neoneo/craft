import craft.output.TemplateRenderer;

component extends="tests.MocktorySpec" {

	function run() {

		describe("TemplateRenderer", function () {

			beforeEach(function () {
				templateFinder = mock("FileFinder")
				templateRenderer = mock(new TemplateRenderer("cfm"))
					.$property("templateFinder", "this", templateFinder)

				mapping = "mapping"
			})

			describe(".addMapping", function () {

				it("should add the mapping", function () {
					mock({
						$object: templateFinder,
						addMapping: {
							$args: [mapping],
							$returns: null,
							$times: 1
						}
					})

					templateRenderer.addMapping(mapping)

					verify(templateFinder)
				})

			})

			describe(".removeMapping", function () {

				it("should remove the mapping", function () {
					mock({
						$object: templateFinder,
						removeMapping: {
							$args: [mapping],
							$returns: null,
							$times: 1
						}
					})

					templateRenderer.removeMapping(mapping)

					verify(templateFinder)
				})

			})

			describe(".clearMappings", function () {

				it("should clear the mappings", function () {
					mock({
						$object: templateFinder,
						clear: {
							$returns: null,
							$times: 1
						}
					})

					templateRenderer.clearMappings(mapping)

					verify(templateFinder)
				})

			})

		})

	}

}