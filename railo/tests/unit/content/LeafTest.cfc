import craft.content.*;

import craft.output.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.viewFactory = mock(CreateObject("ViewFactory"))
		this.leaf = new Leaf(this.viewFactory)
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new stubs.VisitorStub()).visitLeaf(this.leaf)
		this.leaf.accept(visitor)
		visitor.verify().visitLeaf(this.leaf)
	}

	public void function HasChildren_Should_ReturnFalse() {
		assertFalse(this.leaf.hasChildren)
	}

}