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

		var node1 = mock(CreateObject("Placeholder"))
		var node2 = mock(CreateObject("Placeholder"))
		var node3 = mock(CreateObject("Placeholder"))

		visitor.visitLeaf(node1)
			.visitLeaf(node2)
			.visitLeaf(node3)

		variables.composite.addChild(node1)
		variables.composite.addChild(node2)
		variables.composite.addChild(node3)

		variables.composite.traverse(visitor)

		visitor.verify().visitLeaf(node1)
		visitor.verify().visitLeaf(node2)
		visitor.verify().visitLeaf(node3)

	}

	// TODO: tests for addChild, removeChild, moveChild.

}