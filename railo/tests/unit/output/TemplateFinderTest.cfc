import craft.output.*;

component extends="mxunit.framework.TestCase" {

	this.mapping = "/crafttests/unit/output/templates"

	public void function setUp(){
		this.templateFinder = new TemplateFinder("cfm")
		this.templateFinder.addMapping(this.mapping & "/dir1")
	}

	public void function Get_Should_ReturnFileName_When_FileExists() {
		var layout = this.templateFinder.get("view1") // OK
		assertTrue(layout.endsWith("/dir1/view1.cfm"), "layout view1.cfm should be found in dir1")
	}

	public void function Get_Should_ThrowFileNotFound_When_FileDoesNotExist() {
		try {
			var layout = this.templateFinder.get("view3") // error: file does not exist
			fail("view3.cfm should not be found")
		} catch (FileNotFoundException e) {}
	}

	public void function Get_Should_SearchMappingsInOrder() {
		this.templateFinder.addMapping(this.mapping & "/dir2")
		this.templateFinder.addMapping(this.mapping & "/dir3")

		var layout = this.templateFinder.get("view1") // OK: from dir1
		assertTrue(layout.endsWith("/dir1/view1.cfm"), "layout view1.cfm should be found in dir1")

		var layout = this.templateFinder.get("view2") // OK: from dir1 (also exists in dir2)
		assertTrue(layout.endsWith("/dir1/view2.cfm"), "layout view2.cfm should be found in dir1")

		var layout = this.templateFinder.get("view3") // OK: from dir2 (also exists in dir3)
		assertTrue(layout.endsWith("/dir2/view3.cfm"), "layout view3.cfm should be found in dir2")

		var layout = this.templateFinder.get("view4") // OK: from dir3
		assertTrue(layout.endsWith("/dir3/view4.cfm"), "layout view4.cfm should be found in dir3")
	}

}