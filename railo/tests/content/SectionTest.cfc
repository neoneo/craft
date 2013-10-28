import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.section = new Section()
	}

	public void function SetParent_Should_ThrowNotSupportedException() {
		var composite = new Composite()
		try {
			variables.section.setParent(composite)
			fail("calling setParent should have thrown NotSupportedException")
		} catch (Any e) {
			assertEquals("NotSupportedException", e.type)
		}
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitSection(variables.section)
		variables.section.accept(visitor)

		visitor.verify().visitSection(variables.section)
	}

	public void function GetPlaceholders_Should_ReturnPlaceholderDescendants() {

		// Build a tree with placeholders at several levels.
		// TODO: use mock objects.
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

		var placeholders = variables.section.getPlaceholders()
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