import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.composite = new Composite()
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitComposite(variables.composite)
		variables.composite.accept(visitor)

		visitor.verify().visitComposite(variables.composite)
	}

	public void function Traverse_Should_InvokeVisitorForAllChildren() {
		var visitor = mock(new VisitorStub())

		// Could not mock nodes due to NPE in Mighty Mock.
		// Use placeholders, because they have a property that makes them unique.
		var node1 = new Placeholder("ref1")
		var node2 = new Placeholder("ref2")
		var node3 = new Placeholder("ref3")

		visitor
			.visitPlaceholder(node1)
			.visitPlaceholder(node2)
			.visitPlaceholder(node3)


		variables.composite.addChild(node1)
		variables.composite.addChild(node2)
		variables.composite.addChild(node3)

		variables.composite.traverse(visitor)

		visitor.verify().visitPlaceholder(node1)
		visitor.verify().visitPlaceholder(node2)
		visitor.verify().visitPlaceholder(node3)

	}

	// TODO: tests for addChild, removeChild, moveChild.

}