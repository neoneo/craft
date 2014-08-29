import craft.output.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.template = "template"
		this.model = {key: 1}

		this.renderer = mock(CreateObject("TemplateRendererStub"))
			.render(this.template, this.model).returns("done")

		this.view = new TemplateView(this.template, this.renderer)
	}

	public void function Render_Should_CallRenderer() {
		var result = this.view.render(this.model, "get")
		assertEquals("done", result)

		this.renderer.verify().render(this.template, this.model)
	}

}