import craft.output.*;

component extends="mxunit.framework.TestCase" {

	this.mapping = "/tests/unit/output/templates"

	public void function setUp() {
		this.renderer = new CFMLRenderer()
		this.renderer.addMapping(this.mapping)
		this.template = "renderer"
	}

	public void function Render_Should_ReturnOutputString() {
		var output = this.renderer.render(this.template, {})
		assertTrue(IsSimpleValue(output), "output should be a string")
	}

	public void function Render_Should_ReturnOutputContainingSerializedModel() {
		var model = {
			number: 1,
			string: "string",
			boolean: true,
			date: Now()
		}
		var output = this.renderer.render(this.template, model)
		assertTrue(IsJSON(output), "the output should be a valid JSON string")
		var deserialized = DeserializeJSON(output)
		for (var key in model) {
			assertTrue(deserialized.keyExists(key), "key '#key#' should exist in the returned JSON string")
			assertTrue(deserialized[key] == model[key], "key '#key#' should be the same in the model and the returned JSON string")
		}
	}

}