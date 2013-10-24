import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.placeholder = new Placeholder("ref")
	}

	public void function GetRef_Should_Return_Ref() {
		assertEquals("ref", variables.placeholder.getRef())
	}

	public void function Accept_Should_InvokeVistor() {
		var visitor = mock(new VisitorStub()).visitPlaceholder(variables.placeholder)
		variables.placeholder.accept(visitor)
		visitor.verify().visitPlaceholder(variables.placeholder)
	}

}