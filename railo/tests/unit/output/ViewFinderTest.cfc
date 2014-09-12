import craft.output.*;

component extends="mxunit.framework.TestCase" {

	public void function Get_Should_ReturnView_When_ComponentExists() {
		var viewFinder = new ViewFinder()
		viewFinder.addMapping("/crafttests/unit/output")

		var view = viewFinder.get("ViewStub")

		assertEquals("crafttests.unit.output.ViewStub", view)
	}

	public void function Get_Should_ReturnView_When_ComponentExistsDotDelimited() {
		var viewFinder = new ViewFinder()
		viewFinder.addMapping("/crafttests/unit")

		var view = viewFinder.get("output.ViewStub")

		assertEquals("crafttests.unit.output.ViewStub", view)
	}

	public void function Get_Should_ReturnView_When_ComponentExistsSlashDelimited() {
		var viewFinder = new ViewFinder()
		viewFinder.addMapping("/crafttests/unit")

		var viewName = "/output/ViewStub"
		var view = viewFinder.get(viewName)

		assertEquals("crafttests.unit.output.ViewStub", view)
	}

	public void function Get_Should_ThrowFileNotFoundException_When_ViewComponentNotFound() {
		var viewFinder = new ViewFinder()
		viewFinder.addMapping("/crafttests/unit/output")
		var viewName = "NoViewStub"

		try {
			var view = viewFinder.get(viewName)
			fail("exception should have been thrown")
		} catch (FileNotFoundException e) {}
	}

}