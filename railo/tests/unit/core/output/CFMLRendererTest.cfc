import craft.core.output.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.renderer = new CFMLRenderer()
		variables.template = "/crafttest/unit/core/output/templates/renderer.cfm"
	}

	public void function Render_Should_ReturnOutputString() {
		var output = variables.renderer.render(variables.template, {})
		assertTrue(IsSimpleValue(output), "output should be a string")
	}

	public void function Render_Should_ReturnOutputContainingSerializedModel() {
		var model = {
			number: 1,
			string: "string",
			boolean: true,
			date: Now()
		}
		var output = variables.renderer.render(variables.template, model)
		assertTrue(IsJSON(output), "the output should be a valid JSON string")
		var deserialized = DeserializeJSON(output)
		for (var key in model) {
			assertTrue(deserialized.keyExists(key), "key '#key#' should exist in the returned JSON string")
			assertTrue(deserialized[key] == model[key], "key '#key#' should be the same in the model and the returned JSON string")
		}
	}

}