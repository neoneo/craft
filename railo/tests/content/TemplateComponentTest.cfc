import craft.core.content.Placeholder;

component extends="mxunit.framework.TestCase" {

	public void function GetPlaceholders_Should_ReturnPlaceholdersArray() {

		var component = new TemplateComponentStub()
		// build a tree with placeholders at several levels
		component.addChild(new Placeholder("p1"))
		component.addChild(new ComponentStub())

		var level1 = new ComponentStub()
		level1.addChild(new LeafStub())
		component.addChild(level1)

		var level2 = new ComponentStub()
		level2.addChild(new Placeholder("p3"))
		level2.addChild(new LeafStub())

		level1.addChild(level2)
		level1.addChild(new Placeholder("p2"))

		var placeholders = component.getPlaceholders()
		assertEquals(3, placeholders.len())

		// the order of the placeholders is not important
		(["p1", "p2", "p3"]).each(function (ref) {
			var ref = arguments.ref
			assertTrue(placeholders.find(function (placeholder) {
				return arguments.placeholder.getRef() == ref
			}) > 0)
		})

	}

}