import craft.output.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.template = "template"
		this.model = {key: 1}

		this.viewRenderer = mock(CreateObject("ViewRenderer"))
			.render(this.template, this.model).returns(this.template)

	}

	public void function Render_Should_CallRenderer() {

		var view = new TemplateView(this.viewRenderer, {template: this.template})

		var output = view.render(this.model)
		assertEquals(this.template, output)

		this.viewRenderer.verify().render(this.template, this.model)
	}

	public void function Render_Should_PassPropertiesToTemplate() {
		var properties = {
			property1: "one",
			property2: "two",
			property3: "three"
		}
		var view = new TemplateView(this.viewRenderer, {template: this.template, properties: properties})

		// The model being rendered is the model and the properties combined.
		var renderedModel = Duplicate(this.model, false).append(properties)
		this.viewRenderer.render(this.template, renderedModel).returns(this.template & "augmented")
		// The view uses the model without the properties, as that is what the component would produce.
		var output = view.render(this.model)
		assertEquals(this.template & "augmented", output)

		this.viewRenderer.verify().render(this.template, renderedModel)
	}

}