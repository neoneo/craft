import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.section = new Section() // We're not mocking the section because of getPlaceholders(). Maybe later.
		variables.template = new Template(variables.section)
	}

	public void function GetSection_Should_ReturnSection() {
		var section = variables.template.getSection()
		assertSame(variables.section, section)
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitTemplate(variables.template)
		variables.template.accept(visitor)

		visitor.verify().visitTemplate(variables.template)
	}

	public void function GetPlaceholders_Should_ReturnPlaceholdersArray() {

		// Build a tree with placeholders at several levels.
		variables.section.addChild(new Placeholder("p1"))
		variables.section.addChild(new Composite())

		var level1 = new Composite()
		level1.addChild(new Leaf())
		variables.section.addChild(level1)

		var level2 = new Composite()
		level2.addChild(new Placeholder("p3"))
		level2.addChild(new Leaf())

		level1.addChild(level2)
		level1.addChild(new Placeholder("p2"))

		var placeholders = variables.template.getPlaceholders()
		assertEquals(3, placeholders.len())

		// The order of the placeholders is not important.
		(["p1", "p2", "p3"]).each(function (ref) {
			var ref = arguments.ref
			assertTrue(placeholders.find(function (placeholder) {
				return arguments.placeholder.getRef() == ref
			}) > 0)
		})

	}

}