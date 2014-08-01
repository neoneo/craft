import craft.core.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.root = mock(CreateObject("PathSegment"))
		variables.endPoint = new EndPointStub()
	}

	public void function CreateURLAbsolutePath() {
		variables.endPoint.setTestPath("/test")
		var result = variables.endPoint.createURL("/request.html")
		assertEquals("/request.html", result)
	}

	public void function CreateURLRelativePathDotSlash() {
		variables.endPoint.setTestPath("/test")
		var result = variables.endPoint.createURL("./request.html")
		assertEquals("/test/request.html", result)
	}

	public void function CreateURLRelativePathDotDotSlash() {
		variables.endPoint.setTestPath("/test")
		var result = variables.endPoint.createURL("../request.html")
		assertEquals("/request.html", result)
	}

	public void function CreateURLRelativePathDotDotSlashTwice() {
		variables.endPoint.setTestPath("/test/test")
		var result = variables.endPoint.createURL("../../request.html")
		assertEquals("/request.html", result)
	}

	public void function CreateURLDotSlashHalfway() {
		variables.endPoint.setTestPath("/test/test")
		var result = variables.endPoint.createURL("/request/one/./two.html")
		assertEquals("/request/one/two.html", result)
	}

	public void function CreateURLDotDotSlashHalfway() {
		variables.endPoint.setTestPath("/test/test")
		var result = variables.endPoint.createURL("/request/one/../two.html")
		assertEquals("/request/two.html", result)
	}

	public void function CreateURLComplexRelativePath() {
		variables.endPoint.setTestPath("/test/test")
		var result = variables.endPoint.createURL("../../request/./one/two/../three.html")
		assertEquals("/request/one/three.html", result)
	}

	public void function CreateURLComplexRelativePathHalfway() {
		variables.endPoint.setTestPath("/test/test")
		var result = variables.endPoint.createURL("/request/./one/two/../three.html")
		assertEquals("/request/one/three.html", result)
	}

	public void function CreateURLWithParameters() {
		variables.endPoint.setTestPath("/test")
		var result = variables.endPoint.createURL("/request.html", {"a": 1, "b": 2});
		// We don't know the order of the parameters. Split the result into an array.
		var parts = result.listToArray("?&")
		assertTrue(parts.find("a=1") > 0 && parts.find("b=2") > 0, "the created url should contain the parameters in the query string")
	}

	public void function CreateURLWithDefaultDocument() {
		var endPoint = new EndPointStub("/index.cfm")
		var result = endPoint.createURL("/request.html")
		assertEquals("/index.cfm/request.html", result)
	}

}