component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {
		variables.viewFinder = new craft.core.output.ViewFinder("cfm")
		variables.viewFinder.addMapping("/craft/../tests/output/viewstubs")
		variables.json = new ExtensionStub("json")
	}

	public void function setUp() {
		variables.renderer = new craft.core.output.DefaultRenderer(variables.viewFinder)
	}

	public void function Render_Should_ReturnStructWithOutputAndExtensionKeys() {
		var result = variables.renderer.render("renderer", {}, "get", variables.json)
		assertTrue(StructKeyExists(result, "output"), "result should contain key 'output'")
		assertTrue(IsSimpleValue(result.output), "output should be a string")
		assertTrue(StructKeyExists(result, "extension"), "result should contain key 'extension'")
		assertEquals(variables.json, result.extension, "extension should equal the extension used")
	}

	public void function Render_Should_ReturnOutputContainingSerializedModel() {
		var model = {
			number: 1,
			string: "string",
			boolean: true,
			date: Now()
		}
		var result = variables.renderer.render("renderer", model, "get", variables.json)
		assertTrue(IsJSON(result.output), "the output should be a valid JSON string")
		var output = DeserializeJSON(result.output)
		for (var key in model) {
			assertTrue(StructKeyExists(output, key), "key '#key#' should exist in the returned JSON string")
			assertTrue(output[key] == model[key], "key '#key#' should be the same in the model and the returned JSON string")
		}
	}

}