import craft.core.output.*;

import craft.core.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.root = mock(CreateObject("PathSegment"))
		variables.endPoint = new EndPoint(variables.root)
	}

	public void function RequestParameters_Should_ReturnMergedUrlAndFormScopes() {
		// When merge url and form is enabled in the administrator, this test is not useful.
		// We have to set the url variables first, so that the test doesn't fail in that case.
		url.a = 2
		url.x = 2
		url.y = "string 2"
		form.a = 1
		form.b = "string 1"

		// We need a new end point because the merge takes place in the constructor.
		var endPoint = new EndPoint(variables.root)

		var parameters = endPoint.requestParameters()
		var merged = {a: 1, b: "string 1", x: 2, y: "string 2"}

		var result = true
		for (var key in merged) {
			result = parameters.keyExists(key) && parameters[key] == merged[key]
		}

		assertTrue(result, "requestParameters should merge form and url scopes, with form parameters taking precedence")
	}

}