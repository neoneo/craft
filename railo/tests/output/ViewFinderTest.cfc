import craft.core.output.*;

component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {
	  	variables.ext1 = mock(CreateObject("ContentType"))
	  		.getName().returns("ext1")
		variables.ext2 = mock(CreateObject("ContentType"))
			.getName().returns("ext2")
			.getFallbacks().returns([])
		variables.ext3 = mock(CreateObject("ContentType"))
			.getName().returns("ext3")
			.getFallbacks().returns([])

		variables.ext1.getFallbacks().returns([ext2, ext3])
	}

	public void function setUp(){
	  variables.viewFinder = new ViewFinder("cfm")
	  variables.viewFinder.addMapping("/craft/../tests/output/viewstubs/dir1")
	}

	public void function GetView_Should_ReturnFileName_When_FileExists() {
		var template = variables.viewFinder.template("view1", "get", variables.ext1) // OK
		assertTrue(template.endsWith("/dir1/view1.ext1.cfm"), "template view1.ext1.cfm should be found in dir1")

		var template = variables.viewFinder.template("view1", "post", variables.ext1) // OK
		assertTrue(template.endsWith("/dir1/view1.ext1.cfm"), "template view1.ext1.cfm should be found in dir1")

		var template = variables.viewFinder.template("view2", "post", variables.ext2) // OK
		assertTrue(template.endsWith("/dir1/view2.post.ext2.cfm"), "template view2.post.ext2.cfm should be found in dir1")

		var contentType = variables.viewFinder.contentType("view1", "get", variables.ext1) // OK
		assertSame(variables.ext1, contentType)
	}

	public void function GetView_Should_UseFallbacks_When_FileDoesNotExist() {
		var template = variables.viewFinder.template("view2", "get", variables.ext1) // OK: fallback to view2.ext2
		assertTrue(template.endsWith("/dir1/view2.ext2.cfm"), "template view2.ext1.cfm should fall back to view2.ext2.cfm in dir1")

		var template = variables.viewFinder.template("view3", "get", variables.ext1) // OK: fallback to view3.ext3
		assertTrue(template.endsWith("/dir1/view3.ext3.cfm"), "template view3.ext1.cfm should fall back to view3.ext3.cfm in dir1")

		var template = variables.viewFinder.template("view3", "post", variables.ext1) // OK: fallback to view3.ext3
		assertTrue(template.endsWith("/dir1/view3.post.ext3.cfm"), "template view3.post.ext1.cfm should fall back to view3.post.ext3.cfm in dir1")

		// Repeat this for the content types.
		var contentType = variables.viewFinder.contentType("view2", "get", variables.ext1) // OK: fallback to view2.ext2
		assertSame(variables.ext2, contentType)

		var contentType = variables.viewFinder.contentType("view3", "get", variables.ext1) // OK: fallback to view3.ext3
		assertSame(variables.ext3, contentType)

		var contentType = variables.viewFinder.contentType("view3", "post", variables.ext1) // OK: fallback to view3.ext3
		assertSame(variables.ext3, contentType)
	}

	public void function GetView_Should_ThrowViewNotFound_When_FileDoesNotExist() {
		try {
			var template = variables.viewFinder.template("view3", "get", ext2) // error: ext2 has no fallbacks
			fail("view3.ext2.cfm should not be found")
		} catch (any e) {
			assertEquals("ViewNotFoundException", e.type, "when a view is not found, exception 'ViewNotFoundException' should be thrown")
		}
	}

	public void function GetView_Should_LocateMostSpecificView_When_MultipleMappingsAreUsed() {
		variables.viewFinder.addMapping("/craft/../tests/output/viewstubs/dir2")

		var template = variables.viewFinder.template("view2", "get", ext2) // OK: from dir1
		assertTrue(template.endsWith("/dir1/view2.ext2.cfm"), "template view2.ext2.cfm should be found in dir1")

		var template = variables.viewFinder.template("view3", "get", ext2) // OK: from dir2
		assertTrue(template.endsWith("/dir2/view3.ext2.cfm"), "template view3.ext2.cfm should be found in dir2")

		var template = variables.viewFinder.template("view1", "put", ext1) // OK: from dir2
		assertTrue(template.endsWith("/dir2/view1.put.ext1.cfm"), "template view1.put.ext1.cfm should be found in dir2")
	}


}