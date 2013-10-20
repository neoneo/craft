import craft.core.content.Placeholder;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.templateComponent = new craft.core.content.Section()
	}

	public void function GetPlaceholders_Should_ReturnPlaceholdersArray() {

		// build a tree with placeholders at several levels
		variables.templateComponent.addChild(new Placeholder("p1"))
		variables.templateComponent.addChild(new ComponentStub())

		var level1 = new ComponentStub()
		level1.addChild(new LeafStub())
		variables.templateComponent.addChild(level1)

		var level2 = new ComponentStub()
		level2.addChild(new Placeholder("p3"))
		level2.addChild(new LeafStub())

		level1.addChild(level2)
		level1.addChild(new Placeholder("p2"))

		var placeholders = variables.templateComponent.getPlaceholders()
		assertEquals(3, placeholders.len())

		// the order of the placeholders is not important
		(["p1", "p2", "p3"]).each(function (ref) {
			var ref = arguments.ref
			assertTrue(placeholders.find(function (placeholder) {
				return arguments.placeholder.getRef() == ref
			}) > 0)
		})

	}

	public void function SetParent_Should_ThrowNotSupportedException() {
		var component = new craft.core.content.Composite()
		try {
			variables.templateComponent.setParent(component)
			fail("calling setParent should have thrown NotSupportedException")
		} catch (Any e) {
			assertEquals("NotSupportedException", e.type)
		}
	}

	public void function Render_Should_ReturnChildContent() {
		var leaf1 = new LeafWithViewStub("leaf1")
		var leaf2 = new LeafWithViewStub("leaf2")

		variables.templateComponent.addChild(leaf1)
		variables.templateComponent.addChild(leaf2)

		var context = new ContextStub()
		var result = variables.templateComponent.render(context)
		assertEquals("leaf1leaf2", result)
	}

}