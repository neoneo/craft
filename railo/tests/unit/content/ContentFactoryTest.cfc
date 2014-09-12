import craft.content.*;

import craft.output.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.viewFactory = mock(CreateObject("ViewFactory"))
		this.contentFactory = new ContentFactory(this.viewFactory)
	}

	public void function Create_Should_InjectViewFactory() {
		var component = this.contentFactory.create("crafttests.unit.content.ComponentStub")

		assertTrue(component.injectedFactory, "factory should have been injected")
	}

	public void function Create_Should_InjectParameters() {
		var component = this.contentFactory.create("crafttests.unit.content.ComponentStub", {
			property: "property"
		})

		assertTrue(component.injectedParameters, "parameters should have been injected")
	}

	public void function CreatePackageComponent_Should_WorkWithClassNameOnly() {
		// Create a placeholder, using only 'Placeholder' as the component name.
		this.contentFactory.create("Placeholder", {ref: "ref"})
	}

}