import craft.core.output.*;

component extends="mxunit.framework.TestCase" {

	public void function Get_Should_ReturnView_When_ComponentExists() {
		var viewFinder = new ViewFinder()

		var viewName = "crafttest.unit.core.output.ViewStub"
		var view = viewFinder.get(viewName)

		assertTrue(IsInstanceOf(view, "View"))
		assertTrue(IsInstanceOf(view, viewName))
	}

	public void function Get_Should_ThrowFileNotFoundException_When_ViewComponentNotFound() {
		var viewFinder = new ViewFinder()
		var viewName = "crafttest.unit.core.output.NoViewStub"

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

		assertTrue(IsInstanceOf(view, "TemplateView"))

		// Just for completeness, repeat the test for the view component.
		var viewName = "crafttest.unit.core.output.ViewStub"
		var view = viewFinder.get(viewName)

		assertTrue(IsInstanceOf(view, "View"))
		assertTrue(IsInstanceOf(view, viewName))
	}

	public void function Get_Should_ThrowFileNotFoundException_When_ViewTemplateNotFound() {
		var templateFinder = mock(CreateObject("TemplateFinder"))
			.get("viewtemplate").returns(null) // no template
		var templateRenderer = mock(CreateObject("templateRendererStub"))

		try {
			var view = viewFinder.get("viewtemplate")
			fail("exception should have been thrown")
		} catch (Any e) {
			assertEquals("FileNotFoundException", e.type)
		}
	}
}