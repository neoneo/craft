import craft.core.output.*;

component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {
	  	variables.ext1 = mock(new ContentTypeStub())
	  		.name().returns("ext1")
		variables.ext2 = mock(new ContentTypeStub())
			.name().returns("ext2")

		variables.mapping = "/crafttests/unit/core/output/viewstubs"
	}

	public void function setUp(){
	  variables.viewFinder = new ViewFinder("cfm")
	  variables.viewFinder.addMapping(variables.mapping & "/dir1")
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

	public void function GetView_Should_ThrowViewNotFound_When_FileDoesNotExist() {
		try {
			var template = variables.viewFinder.template("view3", "get", variables.ext2) // error: file does not exist
			fail("view3.ext2.cfm should not be found")
		} catch (any e) {
			assertEquals("ViewNotFoundException", e.type, "when a view is not found, exception 'ViewNotFoundException' should be thrown")
		}
	}

	public void function GetView_Should_LocateMostSpecificView_When_MultipleMappings() {
		variables.viewFinder.addMapping(variables.mapping & "/dir2")

		var template = variables.viewFinder.template("view2", "get", variables.ext2) // OK: from dir1
		assertTrue(template.endsWith("/dir1/view2.ext2.cfm"), "template view2.ext2.cfm should be found in dir1")

		var template = variables.viewFinder.template("view1", "post", variables.ext1) // OK: from dir2
		assertTrue(template.endsWith("/dir2/view1.post.ext1.cfm"), "template view1.post.ext1.cfm should be found in dir2")

		var template = variables.viewFinder.template("view2", "post", variables.ext2) // OK: from dir1
		assertTrue(template.endsWith("/dir1/view2.post.ext2.cfm"), "template view2.post.ext2.cfm should be found in dir1")

		var template = variables.viewFinder.template("view2", "put", variables.ext2) // OK: from dir1
		assertTrue(template.endsWith("/dir1/view2.ext2.cfm"), "template view2.ext2.cfm should be found in dir1")
	}

}