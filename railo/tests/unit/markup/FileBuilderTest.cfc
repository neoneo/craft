import craft.markup.FileBuilder;

component extends="tests.MocktorySpec" {

	function run() {

		describe("FileBuilder", function () {

			beforeEach(function () {
				elementBuilder = mock("ElementBuilder")
				element = mock("Element")

				fileBuilder = new FileBuilder(elementBuilder)
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