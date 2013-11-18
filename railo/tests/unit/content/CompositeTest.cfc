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

	public void function Traverse_Should_CallAcceptOnAllChildren() {
		var visitor = mock(new VisitorStub())

		var node1 = mock(CreateObject("Leaf")).accept(visitor)
		var node2 = mock(CreateObject("Leaf")).accept(visitor)
		var node3 = mock(CreateObject("Leaf")).accept(visitor)

		variables.composite.addChild(node1)
		variables.composite.addChild(node2)
		variables.composite.addChild(node3)

		variables.composite.traverse(visitor)

		node1.verify().accept(visitor)
		node2.verify().accept(visitor)
		node3.verify().accept(visitor)
	}

	// TODO: tests for addChild, removeChild, moveChild.

}