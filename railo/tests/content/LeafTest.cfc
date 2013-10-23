component extends="mxunit.framework.TestCase" {

	public void function init() {
		variables.leaf = new LeafStub()
	}

	public void function Accept_Should_InvokeVistor() {
		var visitor = new RenderVistorStub()
		variables.leaf.accept(visitor)
		var result = visitor.getContent()
		assertEquals("leaf", result)
	}

	public void function HasChildren_Should_ReturnFalse() {
		assertFalse(variables.leaf.hasChildren())
	}

}