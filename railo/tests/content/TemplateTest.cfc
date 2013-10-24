import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.section = new Section()
		variables.template = new Template(variables.section)
	}

	public void function GetSection_Should_ReturnSection() {
		var section = variables.template.getSection()
		assertEquals(variables.section, section)
	}

	public void function GetPlaceholders_Should_ReturnSectionPlaceholders() {
		var placeholder = new Placeholder("ref")
		variables.section.addChild(placeholder)

		var placeholders = variables.template.getPlaceholders()
		assertEquals(1, placeholders.len())
		assertEquals(placeholder.getRef(), placeholders[1].getRef())
	}

	public void function Accept_Should_InvokeVistor() {
		var visitor = mock(new VisitorStub()).visitTemplate(variables.template)
		variables.template.accept(visitor)

		visitor.verify().visitTemplate(variables.template)
	}


}