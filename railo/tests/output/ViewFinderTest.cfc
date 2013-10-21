component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {
	  	variables.ext1 = new ContentTypeStub("ext1")
		variables.ext2 = new ContentTypeStub("ext2")
		variables.ext3 = new ContentTypeStub("ext3")

		variables.ext1.addFallback(ext2)
		variables.ext1.addFallback(ext3)
	}

	public void function setUp(){
	  variables.viewFinder = new craft.core.output.ViewFinder("cfm")
	  variables.viewFinder.addMapping("/craft/../tests/output/viewstubs/dir1")
	}

	public void function GetView_Should_ReturnFileName_When_FileExists() {
		var result = variables.viewFinder.get("view1", "get", ext1) // OK
		assertTrue(result.template.endsWith("/dir1/view1.ext1.cfm"), "template view1.ext1.cfm should be found in dir1");
		var result = variables.viewFinder.get("view1", "post", ext1) // OK
		assertTrue(result.template.endsWith("/dir1/view1.ext1.cfm"), "template view1.ext1.cfm should be found in dir1");
		var result = variables.viewFinder.get("view2", "post", ext2) // OK
		assertTrue(result.template.endsWith("/dir1/view2.post.ext2.cfm"), "template view2.post.ext2.cfm should be found in dir1");
	}

	public void function GetView_Should_UseFallbacks_When_FileDoesNotExist() {
		var result = variables.viewFinder.get("view2", "get", ext1) // OK: fallback to view2.ext2
		assertTrue(result.template.endsWith("/dir1/view2.ext2.cfm"), "template view2.ext1.cfm should fall back to view2.ext2.cfm in dir1");

		var result = variables.viewFinder.get("view3", "get", ext1) // OK: fallback to view3.ext3
		assertTrue(result.template.endsWith("/dir1/view3.ext3.cfm"), "template view3.ext1.cfm should fall back to view3.ext3.cfm in dir1");
		var result = variables.viewFinder.get("view3", "post", ext1) // OK: fallback to view3.ext3
		assertTrue(result.template.endsWith("/dir1/view3.post.ext3.cfm"), "template view3.post.ext1.cfm should fall back to view3.post.ext3.cfm in dir1");
	}

	public void function GetView_Should_ThrowViewNotFound_When_FileDoesNotExist() {
		try {
			var result = variables.viewFinder.get("view3", "get", ext2) // error: ext2 has no fallbacks
			fail("view3.ext2.cfm should not be found")
		} catch (any e) {
			assertEquals("ViewNotFoundException", e.type, "when a view is not found, exception 'ViewNotFoundException' should be thrown")
		}
	}

	public void function GetView_Should_LocateMostSpecificView_When_MultipleMappingsAreUsed() {
		variables.viewFinder.addMapping("/craft/../tests/output/viewstubs/dir2")

		var result = variables.viewFinder.get("view2", "get", ext2) // OK: from dir1
		assertTrue(result.template.endsWith("/dir1/view2.ext2.cfm"), "template view2.ext2.cfm should be found in dir1");

		var result = variables.viewFinder.get("view3", "get", ext2) // OK: from dir2
		assertTrue(result.template.endsWith("/dir2/view3.ext2.cfm"), "template view3.ext2.cfm should be found in dir2");

		var result = variables.viewFinder.get("view1", "put", ext1) // OK: from dir2
		assertTrue(result.template.endsWith("/dir2/view1.put.ext1.cfm"), "template view1.put.ext1.cfm should be found in dir2");
	}


}