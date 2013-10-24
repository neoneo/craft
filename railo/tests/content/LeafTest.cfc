component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.leaf = new LeafStub()
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = new VisitorStub()
		variables.leaf.accept(visitor)
		var result = visitor.getResult()
		assertEquals("leaf", result)
	}

	public void function HasChildren_Should_ReturnFalse() {
		assertFalse(variables.leaf.hasChildren())
	}

}