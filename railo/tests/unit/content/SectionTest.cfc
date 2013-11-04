import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function GetNode_Should_Work() {
		var node1 = mock(CreateObject("Node"))
		var section = new Section(node1)

		// Test.
		var node2 = section.getNode()

		// Assert.
		assertSame(node1, node2)
	}

	public void function Accept_Should_InvokeVisitor() {
		var node = mock(CreateObject("Node"))
		var section = new Section(node)
		var visitor = mock(new VisitorStub()).visitSection(section)

		// Actual test.
		section.accept(visitor)

		// Verify.
		visitor.verify().visitSection(section)
	}

	public void function GetPlaceholders_Should_ReturnPlaceholderDescendants() {

		// Build a tree with placeholders at several levels.
		// TODO: use mock objects.
		var root = new Composite()

		root.addChild(new Placeholder("p1"))
		root.addChild(new Composite())

		var level1 = new Composite()
		level1.addChild(new Leaf())
		root.addChild(level1)

		var level2 = new Composite()
		level2.addChild(new Placeholder("p3"))
		level2.addChild(new Leaf())

		level1.addChild(level2)
		level1.addChild(new Placeholder("p2"))

		var section = new Section(root)

		// Test.
		var placeholders = section.getPlaceholders()

		// Assert.
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