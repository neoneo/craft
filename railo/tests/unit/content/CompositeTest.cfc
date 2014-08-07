import craft.content.*;

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

		var component1 = mock(CreateObject("Leaf")).accept(visitor)
		var component2 = mock(CreateObject("Leaf")).accept(visitor)
		var component3 = mock(CreateObject("Leaf")).accept(visitor)

		variables.composite.addChild(component1)
		variables.composite.addChild(component2)
		variables.composite.addChild(component3)

		variables.composite.traverse(visitor)

		component1.verify().accept(visitor)
		component2.verify().accept(visitor)
		component3.verify().accept(visitor)
	}

	// TODO: tests for addChild, removeChild, moveChild.

}