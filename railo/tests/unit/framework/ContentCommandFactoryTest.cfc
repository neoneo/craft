import craft.framework.ContentCommand;
import craft.framework.ContentCommandFactory;

component extends="tests.MocktorySpec" {

	function run() {

		describe("ContentCommandFactory", function () {

			beforeEach(function () {
				tagRegistry = mock("TagRegistry")
				scope = mock("Scope")
				fileBuilder = mock("FileBuilder")
				commandFactory = mock(new ContentCommandFactory(tagRegistry, scope))
					.$property("fileBuilder", "this", fileBuilder)
					.setPath("/path")
			})

			describe(".create", function () {

				it("should create the content command for the given content", function () {
					var result = commandFactory.create("/some/content.xml")

					expect(result).toBeInstanceOf("ContentCommand")
					$assert.isSameInstance(fileBuilder, result.fileBuilder)
					expect(result.path).toBe("/path/some/content.xml")
				})

			})

		})

	}

}