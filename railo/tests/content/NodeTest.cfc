component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.node = new NodeStub()
		variables.context = new ContextStub()
	}

	public void function Model_Should_ReturnEmptyStruct() {
		makePublic(variables.node, "model")
		var model = variables.node.model(variables.context)
		assertEquals({}, model)
	}

	public void function Render_WithParentModel_Should_ReturnParentModel() {
		makePublic(variables.node, "model")
		var parentModel = {parent: true}
		var model = variables.node.model(variables.context, parentModel)
		assertEquals(parentModel, model)
	}

}