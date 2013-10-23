component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.node = new NodeStub()
	}

	public void function Get_Should_ThrowNoSuchElementException_WhenNoParent() {
		try {
			var parent = variables.node.getParent()
			fail("getParent should throw NoSuchElementException")
		} catch (Any e) {
			assertEquals("NoSuchElementException", e.type)
		}
	}

	public void function GetSet_Should_Work() {
		var composite = new CompositeStub()
		variables.node.setParent(composite)
		var parent = variables.node.getParent()

		assertEquals(composite, parent)
	}

	public void function HasParent_Should_ReturnFalse_WhenNoParent() {
		assertFalse(variables.node.hasParent())
	}

	public void function HasParent_Should_ReturnTrue_WhenParent() {
		var composite = new CompositeStub()
		variables.node.setParent(composite)
		assertTrue(variables.node.hasParent())
	}

}