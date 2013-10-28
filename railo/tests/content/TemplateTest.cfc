import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.section = mock(CreateObject("Section"))
		variables.template = new Template(variables.section)
	}

	public void function GetSection_Should_Work() {
		var section = variables.template.getSection()
		assertSame(variables.section, section)
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitTemplate(variables.template)
		variables.template.accept(visitor)

		visitor.verify().visitTemplate(variables.template)
	}

	public void function GetPlaceholders_Should_ReturnSectionPlaceholders() {
		var placeholder1 = mock(CreateObject("Placeholder")).getRef().returns("p1")
		var placeholder2 = mock(CreateObject("Placeholder")).getRef().returns("p2")
		variables.section.getPlaceholders().returns([placeholder1, placeholder2])

		var placeholders = variables.template.getPlaceholders()
		assertEquals(2, placeholders.len())
		(["p1", "p2"]).each(function (ref) {
			var ref = arguments.ref
			assertTrue(placeholders.find(function (placeholder) {
				return arguments.placeholder.getRef() == ref
			}) > 0)
		})

	}

}