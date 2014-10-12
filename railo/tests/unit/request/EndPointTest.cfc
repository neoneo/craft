import craft.output.*;

import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.endPoint = new EndPointStub()
	}

	public void function RequestParameters_Should_ReturnMergedUrlAndFormScopes() {
		// When merge url and form is enabled in the administrator, this test is not useful.
		// We have to set the url variables first, so that the test doesn't fail in that case.
		url.a = 2
		url.x = 2
		url.y = "string 2"
		form.a = 1
		form.b = "string 1"

		var parameters = this.endPoint.requestParameters
		var merged = {a: 1, b: "string 1", x: 2, y: "string 2"}

		// The form contains fields introduced by Railo.
		var result = true
		for (var key in merged) {
			result = parameters.keyExists(key) && parameters[key] === merged[key]
		}

		assertTrue(result, "requestParameters should merge form and url scopes, with form parameters taking precedence")
	}

	public void function ExtensionContentType_Should_ReturnValueOrDefault() {
		this.endPoint.setTestPath("/path/to/request.json")
		assertEquals("json", this.endPoint.extension)
		assertEquals("application/json", this.endPoint.contentType)

		this.endPoint.setTestPath("/path/to/request.notexist")
		assertEquals("html", this.endPoint.extension)
		assertEquals("text/html", this.endPoint.contentType)
	}

	public void function SetRootPath_Should_SplitIndexFromRest() {
		Throw("implement");
	}

	public void function CreateURL_Should_AppendPathToRootPath() {
		Throw("implement");
	}

	public void function CreateURL_Should_AppendParametersInQueryString() {
		Throw("implement");
	}

	public void function CreateURL_Should_HandleRelativePaths() {
		Throw("implement");

		// Paths starting with ./
		// Paths containing ./ in the middle
		// Paths starting with ../
		// Paths containing ./ in the middle
	}

}