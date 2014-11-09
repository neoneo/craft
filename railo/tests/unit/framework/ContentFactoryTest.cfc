import craft.content.*;

import craft.framework.*;

import craft.util.*;

component extends="mxunit.framework.TestCase" {

	this.mapping = "/tests/unit/framework/stubs"
	this.dotMapping = this.mapping.listChangeDelims(".", "/")

	public void function setUp() {
		this.viewFactory = mock(CreateObject("ViewFactory"))
		this.contentFactory = new stubs.ContentFactoryMock(this.viewFactory)

		var componentFinder = mock(CreateObject("ClassFinder")).get("{string}").returns(this.dotMapping & ".SomeContent")
		this.contentFactory.componentFinder = componentFinder

		this.objectHelper = mock(CreateObject("ObjectHelper")).initialize("{object}", "{struct}")
		this.contentFactory.objectHelper = this.objectHelper
	}

	public void function Create_Should_ReturnContentInstance() {

		var component = this.contentFactory.create("SomeContent")

		assertTrue(IsInstanceOf(component, this.dotMapping & ".SomeContent"))
		this.objectHelper.verify().initialize("{object}", "{struct}")
	}

	public void function Create_Should_InjectViewFactory() {
		var component = this.contentFactory.create("SomeContent")

		assertSame(this.viewFactory, component.getViewFactory())
	}

	public void function Create_Should_InjectParameters() {
		var parameters = {
			parameter1: "par1",
			parameter2: "par2"
		}
		// might mock lets the test fail if we mock using the real parameters.
		// so test using a real object helper..
		this.contentFactory.objectHelper = new ObjectHelper()

		var component = this.contentFactory.create("SomeContent", parameters)

		assertTrue(IsInstanceOf(component, this.dotMapping & ".SomeContent"))
		assertEquals(parameters, component.parameters)
	}

	// TODO: add tests for addMapping, removeMapping and the other create* methods.

}