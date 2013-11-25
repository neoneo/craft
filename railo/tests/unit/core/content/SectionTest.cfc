import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.section = new Section()
	}

	public void function Nodes_Should_ReturnNodes() {
		// Adding a mocked method makes the object unique for equals().
		var node1 = mock(CreateObject("Leaf")).unique()
		var node2 = mock(CreateObject("Leaf")).unique()

		variables.section.addNode(node1)
		variables.section.addNode(node2)

		// Test.
		var nodes = section.nodes()

		// Assert.
		assertEquals(2, nodes.len())
		assertSame(nodes[1], node1)
		assertSame(nodes[2], node2)
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitSection(variables.section)

		// Actual test.
		variables.section.accept(visitor)

		// Verify.
		visitor.verify().visitSection(variables.section)
	}

	public void function Traverse_Should_CallAcceptOnAllChildren() {
		var visitor = mock(new VisitorStub())

		var node1 = mock(CreateObject("Leaf")).accept(visitor)
		var node2 = mock(CreateObject("Leaf")).accept(visitor)
		var node3 = mock(CreateObject("Leaf")).accept(visitor)

		variables.section.addNode(node1)
		variables.section.addNode(node2)
		variables.section.addNode(node3)

		variables.section.traverse(visitor)

		node1.verify().accept(visitor)
		node2.verify().accept(visitor)
		node3.verify().accept(visitor)
	}

	public void function Placeholders_Should_ReturnPlaceholderDescendants() {

		// Build a tree with placeholders at several levels.
		// TODO: use mock objects.
		variables.section.addNode(new Placeholder("p1"))
		variables.section.addNode(new Composite())

		var level1 = new Composite()
		level1.addChild(new Leaf())
		variables.section.addNode(level1)

		var level2 = new Composite()
		level2.addChild(new Placeholder("p3"))
		level2.addChild(new Leaf())

		level1.addChild(level2)
		level1.addChild(new Placeholder("p2"))

		// Test.
		var placeholders = section.placeholders()

		// Assert.
		assertEquals(3, placeholders.len())

		// The order of the placeholders is not important.
		(["p1", "p2", "p3"]).each(function (ref) {
			var ref = arguments.ref
			assertTrue(placeholders.find(function (placeholder) {
				return arguments.placeholder.ref() == ref
			}) > 0)
		})

	}

}