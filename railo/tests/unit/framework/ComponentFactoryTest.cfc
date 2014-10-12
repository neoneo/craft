import craft.content.*;

import craft.output.*;

component extends="mxunit.framework.TestCase" {

	this.mapping = "/crafttests/unit/content/stubs"
	this.dotMapping = "crafttests.unit.content.stubs"

	public void function setUp() {
		this.viewFactory = mock(CreateObject("ViewFactory"))
		this.contentFactory = new ContentFactory(this.viewFactory)
	}

	public void function Create_Should_ReturnContentInstance() {
		this.contentFactory.addMapping(this.mapping)
		var component = this.contentFactory.create("ComponentStub")

		assertTrue(IsInstanceOf(component, this.dotMapping & ".ComponentStub"))
	}

	public void function Create_Should_InjectViewFactory() {
		this.contentFactory.addMapping(this.mapping)
		var component = this.contentFactory.create("ComponentStub")

		assertTrue(component.injectedFactory, "factory should have been injected")
	}

	public void function Create_Should_InjectParameters() {
		this.contentFactory.addMapping(this.mapping)
		var component = this.contentFactory.create("ComponentStub", {
			property1: "property1",
			property2: "property2"
		})

		assertTrue(component.injectedParameters, "parameters should have been injected")
		assertEquals("property1", component.property1)
		assertEquals("property2", component.property2)
	}

	// TODO: add tests for addMapping, removeMapping.

}