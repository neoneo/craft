import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.section = mock(CreateObject("Section"))
		variables.template = new Template(variables.section)
	}

	public void function Section_Should_Work() {
		var section = variables.template.section()
		assertSame(variables.section, section)
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitTemplate(variables.template)
		variables.template.accept(visitor)

		visitor.verify().visitTemplate(variables.template)
	}

	public void function Placeholders_Should_ReturnSectionPlaceholders() {
		var placeholder1 = mock(CreateObject("Placeholder")).ref().returns("p1")
		var placeholder2 = mock(CreateObject("Placeholder")).ref().returns("p2")
		variables.section.placeholders().returns([placeholder1, placeholder2])

		var placeholders = variables.template.placeholders()
		assertEquals(2, placeholders.len())
		(["p1", "p2"]).each(function (ref) {
			var ref = arguments.ref
			assertTrue(placeholders.find(function (placeholder) {
				return arguments.placeholder.ref() == ref
			}) > 0)
		})

	}

}