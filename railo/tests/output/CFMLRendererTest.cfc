import craft.core.output.*;

component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {
		variables.json = mock(CreateObject("ContentType"))
			.getName().returns("json")
		variables.viewFinder = mock(CreateObject("ViewFinder"))
			.template("renderer", "get", variables.json).returns("/craft/../tests/output/viewstubs/renderer.json.cfm")
			.contentType("renderer", "get", variables.json).returns(variables.json)
	}

	public void function setUp() {
		variables.renderer = new CFMLRenderer(variables.viewFinder)
	}

	public void function Render_Should_ReturnOutputString() {
		var output = variables.renderer.render("renderer", {}, "get", variables.json)
		variables.viewFinder.verify().template("renderer", "get", variables.json)
		assertTrue(IsSimpleValue(output), "output should be a string")
	}

	public void function ContentType_Should_ReturnUsedContentType() {
		var contentType = variables.renderer.contentType("renderer", "get", variables.json)
		assertSame(variables.json, contentType)
	}

	public void function Render_Should_ReturnOutputContainingSerializedModel() {
		var model = {
			number: 1,
			string: "string",
			boolean: true,
			date: Now()
		}
		var output = variables.renderer.render("renderer", model, "get", variables.json)
		assertTrue(IsJSON(output), "the output should be a valid JSON string")
		var deserialized = DeserializeJSON(output)
		for (var key in model) {
			assertTrue(StructKeyExists(deserialized, key), "key '#key#' should exist in the returned JSON string")
			assertTrue(deserialized[key] == model[key], "key '#key#' should be the same in the model and the returned JSON string")
		}
	}

}