import craft.core.output.*;

component extends="mxunit.framework.TestCase" {

	public void function Get_Should_ReturnView_When_ComponentExists() {
		var viewFinder = new ViewFinder()
		viewFinder.addMapping("/crafttest/unit/core/output")

		var viewName = "ViewStub"
		var view = viewFinder.get(viewName)

		assertTrue(IsInstanceOf(view, "View"))
		assertTrue(IsInstanceOf(view, viewName))
	}

	public void function Get_Should_ReturnView_When_ComponentExistsDotDelimited() {
		var viewFinder = new ViewFinder()
		viewFinder.addMapping("/crafttest/unit")

		var viewName = "core.output.ViewStub"
		var view = viewFinder.get(viewName)

		assertTrue(IsInstanceOf(view, "View"))
		assertTrue(IsInstanceOf(view, "crafttest.unit.core.output.ViewStub"))
	}

	public void function Get_Should_ReturnView_When_ComponentExistsSlashDelimited() {
		var viewFinder = new ViewFinder()
		viewFinder.addMapping("/crafttest/unit")

		var viewName = "/core/output/ViewStub"
		var view = viewFinder.get(viewName)

		assertTrue(IsInstanceOf(view, "View"))
		assertTrue(IsInstanceOf(view, "crafttest.unit.core.output.ViewStub"))
	}

	public void function Get_Should_ThrowFileNotFoundException_When_ViewComponentNotFound() {
		var viewFinder = new ViewFinder()
		viewFinder.addMapping("/crafttest/unit/core/output")
		var viewName = "NoViewStub"

		try {
			var view = viewFinder.get(viewName)
			fail("exception should have been thrown")
		} catch (Any e) {
			assertEquals("FileNotFoundException", e.type)
		}
	}

	public void function Init_Should_ThrowIllegalArgumentException_When_RendererAbsent() {
		var templateFinder = mock(CreateObject("TemplateFinder"))

		try {
			var viewFinder = new ViewFinder(templateFinder)
			fail("exception should have been thrown")
		} catch (Any e) {
			assertEquals("IllegalArgumentException", e.type)
		}
	}

	public void function Get_Should_ReturnTemplateView_When_ViewIsTemplate() {
		var templateFinder = mock(CreateObject("TemplateFinder"))
			.get("viewtemplate").returns("viewtemplate")
		var templateRenderer = mock(CreateObject("templateRendererStub"))

		var viewFinder = new ViewFinder(templateFinder, templateRenderer)

		var view = viewFinder.get("viewtemplate")
		viewFinder.addMapping("/crafttest/unit")

		assertTrue(IsInstanceOf(view, "TemplateView"))

		// Just for completeness, repeat the test for the view component.
		var viewName = "core.output.ViewStub"
		var view = viewFinder.get(viewName)

		assertTrue(IsInstanceOf(view, "View"))
		assertTrue(IsInstanceOf(view, "crafttest.unit.core.output.ViewStub"))
	}

	public void function Get_Should_ThrowFileNotFoundException_When_ViewTemplateNotFound() {
		var templateFinder = mock(CreateObject("TemplateFinder"))
			.get("viewtemplate").throws("FileNotFoundException")
		var templateRenderer = mock(CreateObject("TemplateRendererStub"))

		var viewFinder = new ViewFinder(templateFinder, templateRenderer)
		viewFinder.addMapping("/crafttest/unit/core/output")

		try {
			var view = viewFinder.get("viewtemplate")
			fail("exception should have been thrown")
		} catch (Any e) {
			assertEquals("FileNotFoundException", e.type)
		}

		templateFinder.verify().get("viewtemplate")

	}
}