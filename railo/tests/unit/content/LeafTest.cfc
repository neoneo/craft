import craft.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.leaf = new Leaf()
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitLeaf(this.leaf)
		this.leaf.accept(visitor)
		visitor.verify().visitLeaf(this.leaf)
	}

	public void function HasChildren_Should_ReturnFalse() {
		assertFalse(this.leaf.hasChildren)
	}

}