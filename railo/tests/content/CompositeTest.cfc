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

	// public void function Render_WithChildren_Should_ReturnCompositeContent() {
	// 	var leaf1 = new LeafWithViewStub("leaf1")
	// 	var leaf2 = new LeafWithViewStub("leaf2")
	// 	var leaf3 = new LeafWithViewStub("leaf3")

	// 	variables.component.addChild(leaf1)
	// 	variables.component.addChild(leaf2)
	// 	variables.component.addChild(leaf3, leaf2) // insert before leaf2 as an additional test

	// 	var result = variables.component.render(variables.context)
	// 	assertEquals("before leaf1leaf3leaf2 after", result)
	// }

}