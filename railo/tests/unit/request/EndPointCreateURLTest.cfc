import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.root = mock(CreateObject("PathSegment"))
		this.endPoint = new EndPointStub()
	}

	public void function CreateURLAbsolutePath() {
		this.endPoint.setTestPath("/test")
		var result = this.endPoint.createURL("/request.html")
		assertEquals("/request.html", result)
	}

	public void function CreateURLRelativePathDotSlash() {
		this.endPoint.setTestPath("/test")
		var result = this.endPoint.createURL("./request.html")
		assertEquals("/test/request.html", result)
	}

	public void function CreateURLRelativePathDotDotSlash() {
		this.endPoint.setTestPath("/test")
		var result = this.endPoint.createURL("../request.html")
		assertEquals("/request.html", result)
	}

	public void function CreateURLRelativePathDotDotSlashTwice() {
		this.endPoint.setTestPath("/test/test")
		var result = this.endPoint.createURL("../../request.html")
		assertEquals("/request.html", result)
	}

	public void function CreateURLDotSlashHalfway() {
		this.endPoint.setTestPath("/test/test")
		var result = this.endPoint.createURL("/request/one/./two.html")
		assertEquals("/request/one/two.html", result)
	}

	public void function CreateURLDotDotSlashHalfway() {
		this.endPoint.setTestPath("/test/test")
		var result = this.endPoint.createURL("/request/one/../two.html")
		assertEquals("/request/two.html", result)
	}

	public void function CreateURLComplexRelativePath() {
		this.endPoint.setTestPath("/test/test")
		var result = this.endPoint.createURL("../../request/./one/two/../three.html")
		assertEquals("/request/one/three.html", result)
	}

	public void function CreateURLComplexRelativePathHalfway() {
		this.endPoint.setTestPath("/test/test")
		var result = this.endPoint.createURL("/request/./one/two/../three.html")
		assertEquals("/request/one/three.html", result)
	}

	public void function CreateURLWithParameters() {
		this.endPoint.setTestPath("/test")
		var result = this.endPoint.createURL("/request.html", {"a": 1, "b": 2});
		// We don't know the order of the parameters. Split the result into an array.
		var parts = result.listToArray("?&")
		assertTrue(parts.find("a=1") > 0 && parts.find("b=2") > 0, "the created url should contain the parameters in the query string")
	}

	public void function CreateURLWithRootPath() {
		var endPoint = new EndPointStub()
		endPoint.setRootPath("/index.cfm")
		var result = endPoint.createURL("/request.html")
		assertEquals("/index.cfm/request.html", result)
	}

}