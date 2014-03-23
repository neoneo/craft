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
		var layout = variables.viewFinder.get("view1", variables.ext1) // OK
		assertTrue(layout.endsWith("/dir1/view1.ext1.cfm"), "layout view1.ext1.cfm should be found in dir1")
	}

	public void function GetView_Should_ThrowFileNotFound_When_FileDoesNotExist() {
		try {
			var layout = variables.viewFinder.get("view3", variables.ext2) // error: file does not exist
			fail("view3.ext2.cfm should not be found")
		} catch (any e) {
			assertEquals("FileNotFoundException", e.type, "when a view is not found, exception 'FileNotFoundException' should be thrown")
		}
	}

	public void function GetView_Should_LocateMostSpecificView_When_MultipleMappings() {
		variables.viewFinder.addMapping(variables.mapping & "/dir2")
		variables.viewFinder.addMapping(variables.mapping & "/dir3")

		var layout = variables.viewFinder.get("view1", variables.ext1) // OK: from dir1
		assertTrue(layout.endsWith("/dir1/view1.ext1.cfm"), "layout view1.ext1.cfm should be found in dir1")

		var layout = variables.viewFinder.get("view2", variables.ext2) // OK: from dir1 (also exists in dir2)
		assertTrue(layout.endsWith("/dir1/view2.ext2.cfm"), "layout view2.ext2.cfm should be found in dir1")

		var layout = variables.viewFinder.get("view2", variables.ext1) // OK: from dir2
		assertTrue(layout.endsWith("/dir2/view2.ext1.cfm"), "layout view2.ext1.cfm should be found in dir2")

		var layout = variables.viewFinder.get("view3", variables.ext1) // OK: from dir2 (also exists in dir3)
		assertTrue(layout.endsWith("/dir2/view3.ext1.cfm"), "layout view3.ext1.cfm should be found in dir2")

		var layout = variables.viewFinder.get("view3", variables.ext2) // OK: from dir3
		assertTrue(layout.endsWith("/dir3/view3.ext2.cfm"), "layout view3.ext2.cfm should be found in dir3")

		var layout = variables.viewFinder.get("view4", variables.ext1) // OK: from dir3
		assertTrue(layout.endsWith("/dir3/view4.ext1.cfm"), "layout view4.ext1.cfm should be found in dir3")
	}

}