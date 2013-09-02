component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.node = new NodeStub()
		variables.context = new ContextStub()
	}

	public void function HasParent_Should_ReturnParent_IfExists() {
		var node = variables.node
		assertFalse(node.hasParent())

		var composite = new CompositeStub()
		node.setParent(composite)
		assertTrue(node.hasParent())
		assertEquals(composite, node.getParent())
	}

	public void function Render_Should_ReturnEmptyStruct() {
		var result = DeserializeJSON(variables.node.render(variables.context))
		assertTrue(result.keyExists("view"))
		assertEquals("node", result.view)
		assertTrue(result.keyExists("model"))
		assertEquals({}, result.model)
	}

	public void function Render_WithParentModel_Should_ReturnParentModel() {

		var parentModel = {parent: true}
		var result = DeserializeJSON(node.render(context, parentModel))
		assertTrue(result.keyExists("model"))
		assertEquals(parentModel, result.model)
	}

}