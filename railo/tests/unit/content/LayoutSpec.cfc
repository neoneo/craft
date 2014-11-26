import craft.content.Layout;
import craft.content.Placeholder;

component extends="tests.MocktorySpec" {

	function run() {

		describe("Layout", function () {

			beforeEach(function () {
				section = mock("Section")
				layout = new Layout(section)
			})

			describe(".section", function () {

				it("should return the section", function () {
					$assert.isSameInstance(section, layout.section)
				})

			})

			describe(".accept", function () {

				it("should invoke the visitor", function () {
					var visitor = mock({
						$interface: "Visitor",
						visitLayout: {
							$args: [layout],
							$returns: null,
							$times: 1
						}
					})

					layout.accept(visitor)

					verify(visitor)
				})

			})

			describe(".placeholders", function () {

				it("should return the placeholders from the section", function () {
					mock({
						$object: section,
						placeholders: {
							$returns: [
								// If we return mocks here, the test fails due to a type error.
								new Placeholder("p1"),
								new Placeholder("p2")
							],
							$times: 1
						}
					})

					var placeholders = layout.placeholders

					expect(placeholders.len()).toBe(2)
					verify(section)
				})

			})

		})
	}

}