component extends="mxunit.framework.TestCase" {

	public void function Render_Should_ReturnLeafView() {
		var leaf = new LeafStub()
		var result = leaf.render(new ContextStub())
		assertEquals("leaf", result)
	}

	// TODO: add test for passing through the parent model passed to ContextStub.render()

}