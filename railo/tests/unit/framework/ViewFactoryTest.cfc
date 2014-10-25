import craft.output.*;

import craft.util.*;

component extends="mxunit.framework.TestCase" {

	this.mapping = "/crafttests/unit/framework/stubs"
	this.dotMapping = this.mapping.listChangeDelims(".", "/")

	public void function setUp() {
		this.templateRenderer = mock(CreateObject("TemplateRenderer"))
		this.viewFactory = new stubs.ViewFactoryMock(this.templateRenderer)
		var viewFinder = mock(CreateObject("ClassFinder"))
			.exists("does").returns(true).get("does").returns(this.dotMapping & ".SomeView")
			.exists("doesnot").returns(false).get("doesnot")

		this.viewFactory.viewFinder = viewFinder

		var objectHelper = mock(CreateObject("ObjectHelper")).initialize("{object}", "{struct}")
	}

	public void function Create_Should_ReturnView_When_Exists() {

		var view = this.viewFactory.create("does")

		assertTrue(IsInstanceOf(view, this.dotMapping & ".SomeView"))
	}

	public void function Create_Should_ReturnTemplateView_When_NotExists() {

		var view = this.viewFactory.create("doesnot")

		assertTrue(IsInstanceOf(view, "TemplateView"))
	}

}