import craft.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.placeholder = new Placeholder("ref")
	}

	public void function Ref_Should_Return_Ref() {
		assertEquals("ref", this.placeholder.ref)
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new stubs.VisitorStub()).visitPlaceholder(this.placeholder)
		this.placeholder.accept(visitor)
		visitor.verify().visitPlaceholder(this.placeholder)
	}

}