import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.endPoint = new EndPointStub()
		this.root = mock(CreateObject("PathSegment"))
		this.contextRoot = GetContextRoot()
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

	public void function CreateURLAbsolutePath() {
		this.endPoint.setTestPath("/test")
		var result = this.endPoint.createURL("/request.html")
		assertEquals(this.contextRoot & "/request.html", result)
	}

	public void function CreateURLRelativePathDotSlash() {
		this.endPoint.setTestPath("/test")
		var result = this.endPoint.createURL("./request.html")
		assertEquals(this.contextRoot & "/test/request.html", result)
	}

	public void function CreateURLRelativePathDotDotSlash() {
		this.endPoint.setTestPath("/test")
		var result = this.endPoint.createURL("../request.html")
		assertEquals(this.contextRoot & "/request.html", result)
	}

	public void function CreateURLRelativePathDotDotSlashTwice() {
		this.endPoint.setTestPath("/test/test")
		var result = this.endPoint.createURL("../../request.html")
		assertEquals(this.contextRoot & "/request.html", result)
	}

	public void function CreateURLDotSlashHalfway() {
		this.endPoint.setTestPath("/test/test")
		var result = this.endPoint.createURL("/request/one/./two.html")
		assertEquals(this.contextRoot & "/request/one/two.html", result)
	}

	public void function CreateURLDotDotSlashHalfway() {
		this.endPoint.setTestPath("/test/test")
		var result = this.endPoint.createURL("/request/one/../two.html")
		assertEquals(this.contextRoot & "/request/two.html", result)
	}

	public void function CreateURLComplexRelativePath() {
		this.endPoint.setTestPath("/test/test")
		var result = this.endPoint.createURL("../../request/./one/two/../three.html")
		assertEquals(this.contextRoot & "/request/one/three.html", result)
	}

	public void function CreateURLComplexRelativePathHalfway() {
		this.endPoint.setTestPath("/test/test")
		var result = this.endPoint.createURL("/request/./one/two/../three.html")
		assertEquals(this.contextRoot & "/request/one/three.html", result)
	}

	public void function CreateURLWithParameters() {
		this.endPoint.setTestPath("/test")
		var result = this.endPoint.createURL("/request.html", {"a": 1, "b": 2});
		// We don't know the order of the parameters. Split the result into an array.
		var parts = result.listToArray("?&")
		assertTrue(parts.find("a=1") > 0 && parts.find("b=2") > 0, "the created url should contain the parameters in the query string")
	}

	public void function CreateURLWithIndexFile() {
		var endPoint = new EndPointStub()
		endPoint.setIndexFile("/index.cfm")
		var result = endPoint.createURL("/request.html")
		assertEquals(this.contextRoot & "/index.cfm/request.html", result)
	}

}