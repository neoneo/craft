import craft.output.*;

import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.endPoint = new EndPointStub()
	}

	public void function RequestParameters_Should_ReturnMergedUrlAndFormScopes() {
		// When merge url and form is enabled in the administrator, this test is not useful.
		// We have to set the url variables first, so that the test doesn't fail in that case.
		url.a = 2
		url.x = 2
		url.y = "string 2"
		form.a = 1
		form.b = "string 1"

		var parameters = variables.endPoint.requestParameters()
		var merged = {a: 1, b: "string 1", x: 2, y: "string 2"}

		// The form contains fields introduced by Railo.
		var result = true
		for (var key in merged) {
			result = parameters.keyExists(key) && parameters[key] === merged[key]
		}

		assertTrue(result, "requestParameters should merge form and url scopes, with form parameters taking precedence")
	}

	public void function ExtensionMimeType_Should_ReturnValueOrDefault() {
		variables.endPoint.setTestPath("/path/to/request.json")
		assertEquals("json", variables.endPoint.extension())
		assertEquals("application/json", variables.endPoint.mimeType())

		variables.endPoint.setTestPath("/path/to/request.notexist")
		assertEquals("html", variables.endPoint.extension())
		assertEquals("text/html", variables.endPoint.mimeType())
	}

}