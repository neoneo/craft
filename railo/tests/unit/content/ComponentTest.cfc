import craft.content.*;

import craft.output.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.viewFactory = mock(CreateObject("ViewFactory"))
		this.component = new ComponentStub(this.viewFactory)
	}

	public void function GetSetParent_Should_Work() {
		var composite = new Composite(this.viewFactory)
		this.component.parent = composite
		var parent = this.component.parent

		assertSame(composite, parent)
	}

	public void function HasParent_Should_ReturnFalse_When_NoParent() {
		assertFalse(this.component.hasParent)
	}

	public void function HasParent_Should_ReturnTrue_When_Parent() {
		var composite = new Composite(this.viewFactory)
		this.component.setParent(composite)
		assertTrue(this.component.hasParent)
	}

	public void function GetViewFactory() {
		assertSame(this.viewFactory, this.component.viewFactory)
	}

	public void function Properties() {
		var component = new ComponentStub(this.viewFactory, {
			property1: "first",
			property2: "second"
		})

		assertEquals("first", component.property1)
		assertEquals("second", component.property2)
	}

}