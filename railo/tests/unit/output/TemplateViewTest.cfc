import craft.output.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.template = "template"
		this.model = {key: 1}

		this.templateFinder = mock(CreateObject("TemplateFinder"))
			.get(this.template).returns(this.template)

		this.renderer = mock(CreateObject("TemplateRendererStub"))
			.render(this.template, this.model).returns("done")

	}

	public void function Render_Should_CallRenderer() {

		var view = new TemplateView(this.templateFinder, this.renderer, {template: this.template})

		var result = view.render(model)
		assertEquals("done", result)

		this.renderer.verify().render(this.template, this.model)
	}

	public void function Render_Should_PassPropertiesToTemplate() {
		var properties = {
			property1: "one",
			property2: "two",
			property3: "three"
		}
		var view = new TemplateView(this.templateFinder, this.renderer, {template: this.template, properties: properties})

		// The model being rendered is the model and the properties combined.
		var renderedModel = Duplicate(this.model, false).append(properties)
		this.renderer.render(this.template, renderedModel).returns("done")
		// The view uses the model without the properties, as that is what the component would produce.
		var result = view.render(this.model)
		assertEquals("done", result)

		this.renderer.verify().render(this.template, renderedModel)
	}

}