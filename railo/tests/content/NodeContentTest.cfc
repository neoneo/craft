component extends="mxunit.framework.TestCase" {

	public void function Render_Should_ReturnLeafContent() {
		var leaf = new LeafWithViewStub("leaf")
		var nodeContent = new craft.core.content.NodeContent(leaf)

		var context = new ContextStub()
		assertEquals(leaf.render(context), nodeContent.render(context))
	}

}