import craft.core.output.*;

import craft.core.request.*;

component extends="mxunit.framework.TestCase" {

	public void function beforeTests(){
		// create a path structure that contains segments using all types of path matchers
		variables.root = new PathSegment(new RootPathMatcher("index"))

		var html = new PathSegment(new FixedPathMatcher("html"), "html")
		var test1 = new PathSegment(new FixedPathMatcher("test1"), "test1")
		var test2 = new PathSegment(new PatternPathMatcher("test[0-9]"), "test2")
		var test3matcher = new FixedPathMatcher("test3")
		// the remaining path matcher matches everything that remains if the decorated matcher matches something
		var test3test4 = new PathSegment(new RemainingPathMatcher(test3matcher), "test3")
		var test5 = new PathSegment(new FixedPathMatcher("test5"), "test5")
		var testABCD = new PathSegment(new EntirePathMatcher(), "testABCD")

		variables.root.addChild(html) // /html
		variables.root.addChild(test1) // /test1
		variables.root.addChild(testABCD) // /testA/testB/testC/testD
		test1.addChild(test2) // /test1/test2
		test2.addChild(test5) // /test1/test2/test5
		test2.addChild(test3test4) // /test1/test2/test3/test4

	}

	public void function setUp() {
		variables.endPoint = new QueryStringEndPoint(variables.root)
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
		var endPoint = new QueryStringEndPoint(variables.root)

		var parameters = endPoint.requestParameters()
		var merged = {a: 1, b: "string 1", x: 2, y: "string 2"}

		var result = true
		for (var key in merged) {
			result = parameters.keyExists(key) && parameters[key] == merged[key]
		}

		assertTrue(result, "requestParameters should merge form and url scopes, with form parameters taking precedence")
	}

	public void function ParsePath_indexhtml_Should_ReturnRootPathSegment() {
		url.path = "/index.html"
		var result = variables.endPoint.parsePath()
		assertSame(variables.root, result)
	}

	public void function ParsePath_indexjson_Should_ReturnRootPathSegment() {
		url.path = "/index.json"
		var result = variables.endPoint.parsePath()
		assertSame(variables.root, result)
	}

	public void function ParsePath_index_Should_ReturnRootPathSegment() {
		url.path = "/index"
		var result = variables.endPoint.parsePath()
		assertSame(variables.root, result, "parsing /index should return the root path segment")
	}

	public void function ParsePath_indexslash_Should_ReturnRootPathSegment() {
		url.path = "/index/"
		var result = variables.endPoint.parsePath()
		assertSame(variables.root, result)
	}

	public void function ParsePath_indexhtmlslash_Should_ReturnRootPathSegment() {
		url.path = "/index.html/"
		var result = variables.endPoint.parsePath()
		assertSame(variables.root, result)
	}

	public void function ParsePath_slash_Should_ReturnRootPathSegment() {
		url.path = "/"
		var result = variables.endPoint.parsePath()
		assertSame(variables.root, result)
	}

	public void function ParsePath_html_Should_ReturnHTMLPathSegment() {
		url.path = "/html"
		var result = variables.endPoint.parsePath()
		assertEquals("html", result.parameterName(), "parsing /html should return the html path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("html"), "the html request parameter should exist")
		assertEquals("html", parameters.html, "the html request parameter should equal 'html'")
	}

	public void function ParsePath_test1_Should_ReturnTest1PathSegment() {
		url.path = "/test1"
		var result = variables.endPoint.parsePath()
		assertEquals("test1", result.parameterName(), "parsing /test1 should return the test1 path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("test1"), "the test1 request parameter should exist")
		assertEquals("test1", parameters.test1, "the test1 request parameter should equal 'test1'")
	}

	public void function ParsePath_test1test2_Should_ReturnTest2PathSegment() {
		url.path = "/test1/test2"
		var result = variables.endPoint.parsePath()
		assertEquals("test2", result.parameterName(), "parsing /test1/test2 should return the test2 path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("test1"), "the test1 request parameter should exist")
		assertEquals("test1", parameters.test1, "the test1 request parameter should equal 'test1'")
		assertTrue(parameters.keyExists("test2"), "the test2 request parameter should exist")
		assertEquals("test2", parameters.test2, "the test2 request parameter should equal 'test2'")
	}

	public void function ParsePath_test1test2test3test4_Should_ReturnTest3PathSegment() {
		// test3 should match the remaining segments after test1 and test2
		url.path = "/test1/test2/test3/test4"
		var result = variables.endPoint.parsePath()
		assertEquals("test3", result.parameterName(), "parsing /test1/test2/test3/test4 should return the test3 path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("test1"), "the test1 request parameter should exist")
		assertEquals("test1", parameters.test1, "the test1 request parameter should equal 'test1'")
		assertTrue(parameters.keyExists("test2"), "the test2 request parameter should exist")
		assertEquals("test2", parameters.test2, "the test2 request parameter should equal 'test2'")
		assertTrue(parameters.keyExists("test3"), "the test3 request parameter should exist")
		assertEquals("test3/test4", parameters.test3, "the test3 request parameter should equal 'test3/test4'")
	}

	public void function ParsePath_test1test2test5_Should_ReturnTest5PathSegment() {
		url.path = "/test1/test2/test5"
		var result = variables.endPoint.parsePath()
		assertEquals("test5", result.parameterName(), "parsing /test1/test2/test5 should return the test5 path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("test1"), "the test1 request parameter should exist")
		assertEquals("test1", parameters.test1, "the test1 request parameter should equal 'test1'")
		assertTrue(parameters.keyExists("test2"), "the test2 request parameter should exist")
		assertEquals("test2", parameters.test2, "the test2 request parameter should equal 'test2'")
		assertTrue(parameters.keyExists("test5"), "the test5 request parameter should exist")
		assertEquals("test5", parameters.test5, "the test5 request parameter should equal 'test5'")
	}

	public void function ParsePath_test1test2test5test6_Should_ReturnTestABCD() {
		// the test6 segment is not mapped, so the search should revert to the entire path matcher
		url.path = "/test1/test2/test5/test6"
		var result = variables.endPoint.parsePath()
		assertEquals("testABCD", result.parameterName(), "parsing /test1/test2/test5/test6 should return the testABCD path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("testABCD"), "the testABCD request parameter should exist")
		assertEquals("test1/test2/test5/test6", parameters.testABCD, "the testABCD request parameter should equal 'test1/test2/test5/test6'")
	}

	public void function ParsePath_testABCD_Should_ReturnTestABCD() {
		url.path = "/testA/testB/testC/testD"
		var result = variables.endPoint.parsePath()
		assertEquals("testABCD", result.parameterName(), "parsing /testA/testB/testC/testD should return the testABCD path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("testABCD"), "the testABCD request parameter should exist")
		assertEquals("testa/testb/testc/testd", parameters.testABCD, "the testABCD request parameter should equal 'testa/testb/testc/testd'")
	}

}