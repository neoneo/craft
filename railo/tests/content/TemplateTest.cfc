component extends="mxunit.framework.TestCase" {

	public void function Render_Should_ReturnTemplateComponentContent() {
		var templateComponent = new craft.core.content.Section()
		var leaf1 = new LeafWithViewStub("leaf1")
		var leaf2 = new LeafWithViewStub("leaf2")

		templateComponent.addChild(leaf1)
		templateComponent.addChild(leaf2)

		var template = new craft.core.content.Template(templateComponent)

		var context = new ContextStub()
		assertEquals(templateComponent.render(context), template.render(context))
	}

}