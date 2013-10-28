import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.container = new Container("collection", "item")
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitContainer(variables.container)
		variables.container.accept(visitor)
		visitor.verify().visitContainer(variables.container)
	}

	public void function GetCollectionName_Should_Work() {
		assertEquals("collection", variables.container.getCollectionName())
	}

	public void function GetItemName_Should_Work() {
		assertEquals("item", variables.container.getItemName())
	}

}