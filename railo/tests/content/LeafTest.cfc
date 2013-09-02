component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.leaf = new LeafStub()
		variables.context = new ContextStub()
	}

	public void function Render_Should_ReturnStructWithModelAndView() {

		var result = DeserializeJSON(variables.leaf.render(variables.context))
		assertTrue(result.keyExists("view"))
		assertEquals("leaf", result.view)
		assertTrue(result.keyExists("model"))
		assertTrue(result.model.keyExists("leaf"))
		assertTrue(result.model.keyExists("parent"))
		assertTrue(result.model.parent.isEmpty())

	}

	public void function Render_WithParentModel_Should_ReturnParentModel() {

		var parentModel = {parent: true}
		var result = DeserializeJSON(variables.leaf.render(context, parentModel))

		assertTrue(result.keyExists("model"))
		assertTrue(result.model.keyExists("parent"))
		assertEquals(parentModel, result.model.parent)

	}

}