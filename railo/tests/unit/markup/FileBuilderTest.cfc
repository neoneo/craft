import craft.markup.ElementBuilder;

component extends="tests.MocktorySpec" {

	function run() {

		describe("FileBuilder", function () {

			beforeEach(function () {
				elementBuilder = mock("ElementBuilder")
				element = mock("Element")
				scope = mock({
					$class: "Scope",
					put: null
				})

				fileBuilder = mock("FileBuilder")
				fileBuilder.$property("elementBuilder", "this", elementBuilder)
				fileBuilder.$property("scope", "this", scope)
			})

			it("should build the element described by the xml file", function () {
				mock({
					$object: elementBuilder,
					build: {
						$object: element,
						ready: true
					}
				})

				var result = fileBuilder.build(ExpandPath("/tests/unit/markup/filebuilder/file.xml"))

				$assert.isSameInstance(element, result)
				verify(elementBuilder, {
					build: {
						$args: ["{xml}"],
						$times: 1
					}
				})
				verify(scope, {
					put: {
						$args: [element],
						$times: 1
					}
				})
			})

			it("should throw InstantiationException if the element is not ready afterwards", function () {
				mock({
					$object: elementBuilder,
					build: {
						$object: element,
						ready: false
					}
				})

				expect(function () {
					fileBuilder.build(ExpandPath("/tests/unit/markup/filebuilder/file.xml"))
				}).toThrow("InstantiationException")
			})

		})

	}

}