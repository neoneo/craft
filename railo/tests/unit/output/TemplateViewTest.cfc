import craft.output.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.template = "template"
		variables.model = {key: 1}

		variables.renderer = mock(CreateObject("TemplateRendererStub"))
			.render(variables.template, variables.model).returns("done")

		variables.view = new TemplateView(variables.template, variables.renderer)
	}

	public void function Render_Should_CallRenderer() {
		var result = variables.view.render(variables.model, "get")
		assertEquals("done", result)

		variables.renderer.verify().render(variables.template, variables.model)
	}

}