import craft.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.component = new Component()
	}

	public void function GetSetParent() {
		var composite = new Composite()
		this.component.parent = composite
		var parent = this.component.parent

		assertSame(composite, parent)
	}

	public void function HasParent_Should_ReturnFalse_When_NoParent() {
		assertFalse(this.component.hasParent)
	}

	public void function HasParent_Should_ReturnTrue_When_Parent() {
		var composite = new Composite()
		this.component.setParent(composite)
		assertTrue(this.component.hasParent)
	}

}