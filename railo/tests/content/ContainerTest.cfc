import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.container = new Container()
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitContainer(variables.container)
		variables.container.accept(visitor)
		visitor.verify().visitContainer(variables.container)
	}

}