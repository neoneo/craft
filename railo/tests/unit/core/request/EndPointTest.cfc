import craft.core.output.*;

import craft.core.request.*;

component extends="mxunit.framework.TestCase" {

	public void function beforeTests(){
		// create a path structure that contains segments using all types of path matchers
		variables.root = new RootPathSegment()
		variables.index = new StaticPathSegment("index")
		variables.root.addChild(variables.index)

		variables.html = new StaticPathSegment("html", "html")
		variables.test1 = new StaticPathSegment("test1", "test1")
		variables.test2 = new DynamicPathSegment("test[0-9]", "test2")
		variables.test3 = new StaticPathSegment("test3", "test3")
		variables.testABCD = new EntirePathSegment("testABCD")

		variables.root.addChild(variables.html) // /html
		variables.root.addChild(variables.test1) // /test1
		variables.root.addChild(variables.testABCD) // /testA/testB/testC/testD
		variables.test1.addChild(variables.test2) // /test1/test2
		variables.test2.addChild(variables.test3) // /test1/test2/test3

	}

	public void function setUp() {
		variables.endPoint = new EndPointStub(variables.root)
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

	public void function ParsePath_indexhtml_Should_ReturnIndexPathSegment() {
		variables.endPoint.setTestPath("/index.html")
		var result = variables.endPoint.parsePath()
		assertSame(variables.index, result)
		assertEquals("html", variables.endPoint.extension())
	}

	public void function ParsePath_indexjson_Should_ReturnIndexPathSegment() {
		variables.endPoint.setTestPath("/index.json")
		var result = variables.endPoint.parsePath()
		assertSame(variables.index, result)
		assertEquals("json", variables.endPoint.extension())
	}

	public void function ParsePath_index_Should_ReturnIndexPathSegment() {
		variables.endPoint.setTestPath("/index")
		var result = variables.endPoint.parsePath()
		assertSame(variables.index, result, "parsing /index should return the index path segment")
		assertEquals("html", variables.endPoint.extension())
	}

	public void function ParsePath_indexslash_Should_ReturnIndexPathSegment() {
		variables.endPoint.setTestPath("/index/")
		var result = variables.endPoint.parsePath()
		assertSame(variables.index, result)
		assertEquals("html", variables.endPoint.extension())
	}

	public void function ParsePath_indexhtmlslash_Should_ReturnIndexPathSegment() {
		variables.endPoint.setTestPath("/index.html/")
		var result = variables.endPoint.parsePath()
		assertSame(variables.index, result)
		assertEquals("html", variables.endPoint.extension())
	}

	public void function ParsePath_slash_Should_ReturnRootPathSegment() {
		variables.endPoint.setTestPath("/")
		var result = variables.endPoint.parsePath()
		assertSame(variables.root, result)
	}

	public void function ParsePath_html_Should_ReturnHTMLPathSegment() {
		variables.endPoint.setTestPath("/html")
		var result = variables.endPoint.parsePath()
		assertSame(variables.html, result, "parsing /html should return the html path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("html"), "the html request parameter should exist")
		assertEquals("html", parameters.html, "the html request parameter should equal 'html'")
	}

	public void function ParsePath_test1_Should_ReturnTest1PathSegment() {
		variables.endPoint.setTestPath("/test1")
		var result = variables.endPoint.parsePath()
		assertSame(variables.test1, result, "parsing /test1 should return the test1 path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("test1"), "the test1 request parameter should exist")
		assertEquals("test1", parameters.test1, "the test1 request parameter should equal 'test1'")
	}

	public void function ParsePath_test1test2_Should_ReturnTest2PathSegment() {
		variables.endPoint.setTestPath("/test1/test2")
		var result = variables.endPoint.parsePath()
		assertSame(variables.test2, result, "parsing /test1/test2 should return the test2 path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("test1"), "the test1 request parameter should exist")
		assertEquals("test1", parameters.test1, "the test1 request parameter should equal 'test1'")
		assertTrue(parameters.keyExists("test2"), "the test2 request parameter should exist")
		assertEquals("test2", parameters.test2, "the test2 request parameter should equal 'test2'")
	}

	public void function ParsePath_test1test2test3_Should_ReturnTest5PathSegment() {
		variables.endPoint.setTestPath("/test1/test2/test3")
		var result = variables.endPoint.parsePath()
		assertSame(variables.test3, result, "parsing /test1/test2/test3 should return the test3 path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("test1"), "the test1 request parameter should exist")
		assertEquals("test1", parameters.test1, "the test1 request parameter should equal 'test1'")
		assertTrue(parameters.keyExists("test2"), "the test2 request parameter should exist")
		assertEquals("test2", parameters.test2, "the test2 request parameter should equal 'test2'")
		assertTrue(parameters.keyExists("test3"), "the test3 request parameter should exist")
		assertEquals("test3", parameters.test3, "the test3 request parameter should equal 'test5'")
	}

	public void function ParsePath_test1test2test3test4_Should_ReturnTestABCD() {
		// the test4 segment is not mapped, so the search should revert to the entire path matcher
		variables.endPoint.setTestPath("/test1/test2/test3/test4")
		var result = variables.endPoint.parsePath()
		assertSame(variables.testABCD, result, "parsing /test1/test2/test3/test4 should return the testABCD path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("testABCD"), "the testABCD request parameter should exist")
		assertEquals("test1/test2/test3/test4", parameters.testABCD, "the testABCD request parameter should equal 'test1/test2/test3/test4'")
	}

	public void function ParsePath_testABCD_Should_ReturnTestABCD() {
		variables.endPoint.setTestPath("/testA/testB/testC/testD")
		var result = variables.endPoint.parsePath()
		assertSame(variables.testABCD, result, "parsing /testA/testB/testC/testD should return the testABCD path segment")
		var parameters = variables.endPoint.requestParameters()
		assertTrue(parameters.keyExists("testABCD"), "the testABCD request parameter should exist")
		assertEquals("testa/testb/testc/testd", parameters.testABCD, "the testABCD request parameter should equal 'testa/testb/testc/testd'")
	}

	public void function ParsePath_Should_NotCareAboutNumberOfSlashes() {
		variables.endPoint.setTestPath("index")
		var result = variables.endPoint.parsePath()
		assertSame(variables.index, result)

		variables.endPoint.setTestPath("//index")
		var result = variables.endPoint.parsePath()
		assertSame(variables.index, result)

		variables.endPoint.setTestPath("///index")
		var result = variables.endPoint.parsePath()
		assertSame(variables.index, result)

		variables.endPoint.setTestPath("test1//test2")
		var result = variables.endPoint.parsePath()
		assertSame(variables.test2, result)

		variables.endPoint.setTestPath("//test1//test2//")
		var result = variables.endPoint.parsePath()
		assertSame(variables.test2, result)
	}

}