import craft.core.request.*;

component extends="mxunit.framework.TestCase" {

	public void function Match_Should_InvokePathMatcher() {
		var path = ["dir1", "dir2"]
		var pathMatcher = mock(CreateObject("PathMatcherStub")).match(path).returns(1)

		var pathSegment = new PathSegment(pathMatcher)

		// Actual test.
		pathSegment.match(path)

		pathMatcher.verify().match(path)
	}

	public void function Content_Should_ReturnCorrespondingContent() {
		var content1 = new ContentStub(type: "test1")
		var content2 = new ContentStub(type: "test2")

		var pathSegment = new PathSegment(mock(CreateObject("PathMatcherStub")))
		pathSegment.setContent("test1", content1)
		pathSegment.setContent("test2", content2)

		assertEquals(content1, pathSegment.content("test1"))
		assertEquals(content2, pathSegment.content("test2"))

		try {
			pathSegment.content("test3") // not existing type
			fail("path segment should throw NoSuchElementException when content type does not exist")
		} catch (NoSuchElementException e) {
			// OK
		}
	}

	public void function Content_Should_OverwriteExistingContent() {
		var content1 = new ContentStub(type: "test")
		var content2 = new ContentStub(type: "test")

		var pathSegment = new PathSegment(mock(CreateObject("PathMatcherStub")))
		pathSegment.setContent("test", content1)
		assertEquals(content1, pathSegment.content("test"))

		pathSegment.setContent("test", content2)
		assertEquals(content2, pathSegment.content("test"))
	}

}