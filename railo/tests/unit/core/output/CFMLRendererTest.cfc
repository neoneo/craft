import craft.core.output.*;

component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {
		variables.json = mock(CreateObject("ContentTypeStub"))
			.name().returns("json")
		variables.viewFinder = mock(CreateObject("ViewFinder"))
			.get("renderer", variables.json).returns("/crafttests/unit/core/output/viewstubs/renderer.json.cfm")
	}

	public void function setUp() {
		variables.renderer = new CFMLRenderer(variables.viewFinder)
	}

	public void function Render_Should_ReturnOutputString() {
		var output = variables.renderer.render("renderer", {}, variables.json)
		variables.viewFinder.verify().get("renderer", variables.json)
		assertTrue(IsSimpleValue(output), "output should be a string")
	}

	public void function Render_Should_ReturnOutputContainingSerializedModel() {
		var model = {
			number: 1,
			string: "string",
			boolean: true,
			date: Now()
		}
		var output = variables.renderer.render("renderer", model, variables.json)
		assertTrue(IsJSON(output), "the output should be a valid JSON string")
		var deserialized = DeserializeJSON(output)
		for (var key in model) {
			assertTrue(deserialized.keyExists(key), "key '#key#' should exist in the returned JSON string")
			assertTrue(deserialized[key] == model[key], "key '#key#' should be the same in the model and the returned JSON string")
		}
	}

}