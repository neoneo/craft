import craft.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.section = mock(CreateObject("Section"))
		this.layout = new Layout(this.section)
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