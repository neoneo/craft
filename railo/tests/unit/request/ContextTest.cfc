import craft.output.*;

import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function beforeTests(){
		// create a path structure that contains segments using all types of path matchers
		this.root = new RootPathSegment()
		this.index = new StaticPathSegment("index")
		this.root.addChild(this.index)

		this.html = new StaticPathSegment("html", "html")
		this.test1 = new StaticPathSegment("test1", "test1")
		this.test2 = new DynamicPathSegment("test[0-9]", "test2")
		this.test3 = new StaticPathSegment("test3", "test3")
		this.testABCD = new EntirePathSegment("testABCD")

		this.root.addChild(this.html) // /html
		this.root.addChild(this.test1) // /test1
		this.root.addChild(this.testABCD) // /testA/testB/testC/testD
		this.test1.addChild(this.test2) // /test1/test2
		this.test2.addChild(this.test3) // /test1/test2/test3

	}

	public void function setUp() {
		this.endPoint = new EndPointStub()
	}

	public void function ParsePath_indexhtml_Should_ReturnIndexPathSegment() {
		this.endPoint.setTestPath("/index.html")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.index, context.pathSegment)
	}

	public void function ParsePath_indexjson_Should_ReturnIndexPathSegment() {
		this.endPoint.setTestPath("/index.json")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.index, context.pathSegment)
	}

	public void function ParsePath_index_Should_ReturnIndexPathSegment() {
		this.endPoint.setTestPath("/index")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.index, context.pathSegment)
	}

	public void function ParsePath_indexslash_Should_ReturnIndexPathSegment() {
		this.endPoint.setTestPath("/index/")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.index, context.pathSegment)
	}

	public void function ParsePath_indexhtmlslash_Should_ReturnIndexPathSegment() {
		this.endPoint.setTestPath("/index.html/")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.index, context.pathSegment)
	}

	public void function ParsePath_slash_Should_ReturnRootPathSegment() {
		this.endPoint.setTestPath("/")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.root, context.pathSegment)
	}

	public void function ParsePath_html_Should_ReturnHTMLPathSegment() {
		this.endPoint.setTestPath("/html")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.html, context.pathSegment, "parsing /html should return the html path segment")
		var parameters = context.parameters
		assertTrue(parameters.keyExists("html"), "the html request parameter should exist")
		assertEquals("html", parameters.html, "the html request parameter should equal 'html'")
	}

	public void function ParsePath_test1_Should_ReturnTest1PathSegment() {
		this.endPoint.setTestPath("/test1")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.test1, context.pathSegment, "parsing /test1 should return the test1 path segment")
		var parameters = context.parameters
		assertTrue(parameters.keyExists("test1"), "the test1 request parameter should exist")
		assertEquals("test1", parameters.test1, "the test1 request parameter should equal 'test1'")
	}

	public void function ParsePath_test1test2_Should_ReturnTest2PathSegment() {
		this.endPoint.setTestPath("/test1/test2")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.test2, context.pathSegment, "parsing /test1/test2 should return the test2 path segment")
		var parameters = context.parameters
		assertTrue(parameters.keyExists("test1"), "the test1 request parameter should exist")
		assertEquals("test1", parameters.test1, "the test1 request parameter should equal 'test1'")
		assertTrue(parameters.keyExists("test2"), "the test2 request parameter should exist")
		assertEquals("test2", parameters.test2, "the test2 request parameter should equal 'test2'")
	}

	public void function ParsePath_test1test2test3_Should_ReturnTest5PathSegment() {
		this.endPoint.setTestPath("/test1/test2/test3")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.test3, context.pathSegment, "parsing /test1/test2/test3 should return the test3 path segment")
		var parameters = context.parameters
		assertTrue(parameters.keyExists("test1"), "the test1 request parameter should exist")
		assertEquals("test1", parameters.test1, "the test1 request parameter should equal 'test1'")
		assertTrue(parameters.keyExists("test2"), "the test2 request parameter should exist")
		assertEquals("test2", parameters.test2, "the test2 request parameter should equal 'test2'")
		assertTrue(parameters.keyExists("test3"), "the test3 request parameter should exist")
		assertEquals("test3", parameters.test3, "the test3 request parameter should equal 'test5'")
	}

	public void function ParsePath_test1test2test3test4_Should_ReturnTestABCD() {
		// the test4 segment is not mapped, so the search should revert to the entire path matcher
		this.endPoint.setTestPath("/test1/test2/test3/test4")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.testABCD, context.pathSegment, "parsing /test1/test2/test3/test4 should return the testABCD path segment")
		var parameters = context.parameters
		assertTrue(parameters.keyExists("testABCD"), "the testABCD request parameter should exist")
		assertEquals("test1/test2/test3/test4", parameters.testABCD, "the testABCD request parameter should equal 'test1/test2/test3/test4'")
	}

	public void function ParsePath_testABCD_Should_ReturnTestABCD() {
		this.endPoint.setTestPath("/testA/testB/testC/testD")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.testABCD, context.pathSegment, "parsing /testA/testB/testC/testD should return the testABCD path segment")
		var parameters = context.parameters
		assertTrue(parameters.keyExists("testABCD"), "the testABCD request parameter should exist")
		assertEquals("testa/testb/testc/testd", parameters.testABCD, "the testABCD request parameter should equal 'testa/testb/testc/testd'")
	}

	public void function ParsePath_Should_NotCareAboutNumberOfSlashes() {
		this.endPoint.setTestPath("index")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.index, context.pathSegment)

		this.endPoint.setTestPath("//index")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.index, context.pathSegment)

		this.endPoint.setTestPath("///index")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.index, context.pathSegment)

		this.endPoint.setTestPath("test1//test2")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.test2, context.pathSegment)

		this.endPoint.setTestPath("//test1//test2//")
		var context = new Context(this.endPoint, this.root)
		assertSame(this.test2, context.pathSegment)
	}

}