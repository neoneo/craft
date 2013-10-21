component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {
		variables.viewFinder = new craft.core.output.ViewFinder("cfm")
		variables.viewFinder.addMapping("/craft/../tests/output/viewstubs")
		variables.json = new ContentTypeStub("json")
	}

	public void function setUp() {
		variables.renderer = new craft.core.output.CFMLRenderer(variables.viewFinder)
	}

	public void function Render_Should_ReturnOutputString() {
		var output = variables.renderer.render("renderer", {}, "get", variables.json)
		assertTrue(IsSimpleValue(output), "output should be a string")
	}

	public void function ContentType_Should_ReturnUsedContentType() {
		var contentType = variables.renderer.contentType("renderer", "get", variables.json)
		assertEquals(variables.json, contentType)
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