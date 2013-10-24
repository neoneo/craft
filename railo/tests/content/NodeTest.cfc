component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.node = new NodeStub()
	}

	public void function GetParent_Should_ThrowNoSuchElementException_When_NoParent() {
		try {
			var parent = variables.node.getParent()
			fail("getParent should throw NoSuchElementException")
		} catch (Any e) {
			assertEquals("NoSuchElementException", e.type)
		}
	}

	public void function GetSetParent_Should_Work() {
		var composite = new CompositeStub()
		variables.node.setParent(composite)
		var parent = variables.node.getParent()

		assertEquals(composite, parent)
	}

	public void function HasParent_Should_ReturnFalse_When_NoParent() {
		assertFalse(variables.node.hasParent())
	}

	public void function HasParent_Should_ReturnTrue_When_Parent() {
		var composite = new CompositeStub()
		variables.node.setParent(composite)
		assertTrue(variables.node.hasParent())
	}

}