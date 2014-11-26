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


	public void function Section_Should_Work() {
		var section = this.layout.section
		assertSame(this.section, section)
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new stubs.VisitorStub()).visitLayout(this.layout)
		this.layout.accept(visitor)

		visitor.verify().visitLayout(this.layout)
	}

	public void function Placeholders_Should_ReturnSectionPlaceholders() {
		var placeholder1 = mock(CreateObject("Placeholder"))
		placeholder1.ref = "p1"
		var placeholder2 = mock(CreateObject("Placeholder"))
		placeholder2.ref = "p2"
		this.section.getPlaceholders().returns([placeholder1, placeholder2])

		var placeholders = this.layout.placeholders
		assertEquals(2, placeholders.len())
		(["p1", "p2"]).each(function (ref) {
			var ref = arguments.ref
			assertTrue(placeholders.find(function (placeholder) {
				return arguments.placeholder.ref == ref;
			}) > 0)
		})

	}

}