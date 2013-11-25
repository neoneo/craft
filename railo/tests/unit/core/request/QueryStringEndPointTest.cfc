import craft.core.output.*;

import craft.core.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		var root = mock(CreateObject("PathSegment"))
		var contentType = mock(CreateObject("ContentType")).name().returns("test")
		variables.endPoint = new QueryStringEndPoint(root, [contentType])
	}

	public void function CreateURLAbsolutePath() {
		url.path = "/test"
		var result = variables.endPoint.createURL("/request.html")
		assertEquals("index.cfm?path=%2frequest%2ehtml", result, "the created url should contain the requested path as is")
	}

	public void function CreateURLRelativePathDotSlash() {
		url.path = "/test"
		var result = variables.endPoint.createURL("./request.html")
		assertEquals("index.cfm?path=%2ftest%2frequest%2ehtml", result, "the created url should contain the requested path appended to the current path")
	}

	public void function CreateURLRelativePathDotDotSlash() {
		url.path = "/test"
		var result = variables.endPoint.createURL("../request.html")
		assertEquals("index.cfm?path=%2frequest%2ehtml", result, "the created url should contain the requested path one level higher")
	}

	public void function CreateURLRelativePathDotDotSlashTwice() {
		url.path = "/test/test"
		var result = variables.endPoint.createURL("../../request.html")
		assertEquals("index.cfm?path=%2frequest%2ehtml", result, "the created url should contain the requested path two levels higher")
	}

	public void function CreateURLDotSlashHalfway() {
		url.path = "/test/test"
		var result = variables.endPoint.createURL("/request/one/./two.html")
		assertEquals("index.cfm?path=%2frequest%2fone%2ftwo%2ehtml", result, "the created url should contain the requested path with ./ removed")
	}

	public void function CreateURLDotDotSlashHalfway() {
		url.path = "/test/test"
		var result = variables.endPoint.createURL("/request/one/../two.html")
		assertEquals("index.cfm?path=%2frequest%2ftwo%2ehtml", result, "the created url should contain the requested path with ../ applied")
	}

	public void function CreateURLComplexRelativePath() {
		url.path = "/test/test"
		var result = variables.endPoint.createURL("../../request/./one/two/../three.html")
		assertEquals("index.cfm?path=%2frequest%2fone%2fthree%2ehtml", result, "the created url should contain the requested path with all modifiers applied")
	}

	public void function CreateURLComplexRelativePathHalfway() {
		url.path = "/test/test"
		var result = variables.endPoint.createURL("/request/./one/two/../three.html")
		assertEquals("index.cfm?path=%2frequest%2fone%2fthree%2ehtml", result, "the created url should contain the requested path with all modifiers applied")
	}

	public void function CreateURLWithParameters() {
		url.path = "/test"
		var result = variables.endPoint.createURL("/request.html", {"a": 1, "b": 2});
		assertTrue(result contains "&a=1" && result contains "&b=2", "the created url should contain the parameters in the query string")
	}

}