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
		variables.endPoint = new EndPointStub()
	}

	public void function ParsePath_indexhtml_Should_ReturnIndexPathSegment() {
		variables.endPoint.setTestPath("/index.html")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.index, context.pathSegment())
	}

	public void function ParsePath_indexjson_Should_ReturnIndexPathSegment() {
		variables.endPoint.setTestPath("/index.json")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.index, context.pathSegment())
	}

	public void function ParsePath_index_Should_ReturnIndexPathSegment() {
		variables.endPoint.setTestPath("/index")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.index, context.pathSegment())
	}

	public void function ParsePath_indexslash_Should_ReturnIndexPathSegment() {
		variables.endPoint.setTestPath("/index/")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.index, context.pathSegment())
	}

	public void function ParsePath_indexhtmlslash_Should_ReturnIndexPathSegment() {
		variables.endPoint.setTestPath("/index.html/")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.index, context.pathSegment())
	}

	public void function ParsePath_slash_Should_ReturnRootPathSegment() {
		variables.endPoint.setTestPath("/")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.root, context.pathSegment())
	}

	public void function ParsePath_html_Should_ReturnHTMLPathSegment() {
		variables.endPoint.setTestPath("/html")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.html, context.pathSegment(), "parsing /html should return the html path segment")
		var parameters = context.parameters()
		assertTrue(parameters.keyExists("html"), "the html request parameter should exist")
		assertEquals("html", parameters.html, "the html request parameter should equal 'html'")
	}

	public void function ParsePath_test1_Should_ReturnTest1PathSegment() {
		variables.endPoint.setTestPath("/test1")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.test1, context.pathSegment(), "parsing /test1 should return the test1 path segment")
		var parameters = context.parameters()
		assertTrue(parameters.keyExists("test1"), "the test1 request parameter should exist")
		assertEquals("test1", parameters.test1, "the test1 request parameter should equal 'test1'")
	}

	public void function ParsePath_test1test2_Should_ReturnTest2PathSegment() {
		variables.endPoint.setTestPath("/test1/test2")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.test2, context.pathSegment(), "parsing /test1/test2 should return the test2 path segment")
		var parameters = context.parameters()
		assertTrue(parameters.keyExists("test1"), "the test1 request parameter should exist")
		assertEquals("test1", parameters.test1, "the test1 request parameter should equal 'test1'")
		assertTrue(parameters.keyExists("test2"), "the test2 request parameter should exist")
		assertEquals("test2", parameters.test2, "the test2 request parameter should equal 'test2'")
	}

	public void function ParsePath_test1test2test3_Should_ReturnTest5PathSegment() {
		variables.endPoint.setTestPath("/test1/test2/test3")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.test3, context.pathSegment(), "parsing /test1/test2/test3 should return the test3 path segment")
		var parameters = context.parameters()
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
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.testABCD, context.pathSegment(), "parsing /test1/test2/test3/test4 should return the testABCD path segment")
		var parameters = context.parameters()
		assertTrue(parameters.keyExists("testABCD"), "the testABCD request parameter should exist")
		assertEquals("test1/test2/test3/test4", parameters.testABCD, "the testABCD request parameter should equal 'test1/test2/test3/test4'")
	}

	public void function ParsePath_testABCD_Should_ReturnTestABCD() {
		variables.endPoint.setTestPath("/testA/testB/testC/testD")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.testABCD, context.pathSegment(), "parsing /testA/testB/testC/testD should return the testABCD path segment")
		var parameters = context.parameters()
		assertTrue(parameters.keyExists("testABCD"), "the testABCD request parameter should exist")
		assertEquals("testa/testb/testc/testd", parameters.testABCD, "the testABCD request parameter should equal 'testa/testb/testc/testd'")
	}

	public void function ParsePath_Should_NotCareAboutNumberOfSlashes() {
		variables.endPoint.setTestPath("index")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.index, context.pathSegment())

		variables.endPoint.setTestPath("//index")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.index, context.pathSegment())

		variables.endPoint.setTestPath("///index")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.index, context.pathSegment())

		variables.endPoint.setTestPath("test1//test2")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.test2, context.pathSegment())

		variables.endPoint.setTestPath("//test1//test2//")
		var context = new Context(variables.endPoint, variables.root)
		assertSame(variables.test2, context.pathSegment())
	}

}