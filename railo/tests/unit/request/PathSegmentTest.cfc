import craft.core.request.PathMatcher;
import craft.core.request.PathSegment;

component extends="mxunit.framework.TestCase" {

	public void function Match_Should_InvokePathMatcher() {
		var path = ["dir1", "dir2"]
		var pathSegment = new PathSegment(new PathMatcherStub(true))
		assertTrue(pathSegment.match(path) == 1)
		var pathSegment = new PathSegment(new PathMatcherStub(false))
		assertTrue(pathSegment.match(path) == 0)
	}

	public void function GetContent_Should_ReturnAppropriateContent() {
		var content1 = new ContentStub(type = "test1")
		var content2 = new ContentStub(type = "test2")

		var pathSegment = new PathSegment(new PathMatcherStub(true))
		pathSegment.setContent("test1", content1)
		pathSegment.setContent("test2", content2)

		assertEquals(content1, pathSegment.getContent("test1"))
		assertEquals(content2, pathSegment.getContent("test2"))

		try {
			pathSegment.getContent("test3") // not existing type
			fail("path segment should throw ContentNotFoundException when content type does not exist")
		} catch (ContentNotFoundException e) {
			// OK
		}
	}

	public void function GetContent_Should_OverwriteExistingContent() {
		var content1 = new ContentStub(type = "test")
		var content2 = new ContentStub(type = "test")

		var pathSegment = new PathSegment(new PathMatcherStub(true))
		pathSegment.setContent("test", content1)
		assertEquals(content1, pathSegment.getContent("test"))

		pathSegment.setContent("test", content2)
		assertEquals(content2, pathSegment.getContent("test"))
	}

}