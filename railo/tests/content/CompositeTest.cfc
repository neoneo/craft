component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.component = new CompositeStub()
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = new VisitorStub()
		variables.component.accept(visitor)
		var result = visitor.getResult()
		assertEquals("composite", result)
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