import craft.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.section = new Section()
	}

	public void function Components_Should_ReturnComponents() {
		// Adding a mocked method makes the object unique for equals().
		var component1 = mock(CreateObject("Leaf")).unique()
		var component2 = mock(CreateObject("Leaf")).unique()

		this.section.addComponent(component1)
		this.section.addComponent(component2)

		// Test.
		var components = section.components

		// Assert.
		assertEquals(2, components.len())
		assertSame(components[1], component1)
		assertSame(components[2], component2)
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitSection(this.section)

		// Actual test.
		this.section.accept(visitor)

		// Verify.
		visitor.verify().visitSection(this.section)
	}

	public void function Traverse_Should_CallAcceptOnAllChildren() {
		var visitor = mock(new VisitorStub())

		var component1 = mock(CreateObject("Leaf")).accept(visitor)
		var component2 = mock(CreateObject("Leaf")).accept(visitor)
		var component3 = mock(CreateObject("Leaf")).accept(visitor)

		this.section.addComponent(component1)
		this.section.addComponent(component2)
		this.section.addComponent(component3)

		this.section.traverse(visitor)

		component1.verify().accept(visitor)
		component2.verify().accept(visitor)
		component3.verify().accept(visitor)
	}

	public void function Placeholders_Should_ReturnPlaceholderDescendants() {

		// Build a tree with placeholders at several levels.
		// TODO: use mock objects.
		this.section.addComponent(new Placeholder("p1"))
		this.section.addComponent(new Composite())

		var level1 = new Composite()
		level1.addChild(new Leaf())
		this.section.addComponent(level1)

		var level2 = new Composite()
		level2.addChild(new Placeholder("p3"))
		level2.addChild(new Leaf())

		level1.addChild(level2)
		level1.addChild(new Placeholder("p2"))

		// Test.
		var placeholders = section.placeholders

		// Assert.
		assertEquals(3, placeholders.len())

		// The order of the placeholders is not important.
		(["p1", "p2", "p3"]).each(function (ref) {
			var ref = arguments.ref
			assertTrue(placeholders.find(function (placeholder) {
				return arguments.placeholder.ref == ref
			}) > 0)
		})

	}

}