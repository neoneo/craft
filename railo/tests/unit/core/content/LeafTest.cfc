import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.leaf = new Leaf()
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitLeaf(variables.leaf)
		variables.leaf.accept(visitor)
		visitor.verify().visitLeaf(variables.leaf)
	}

	public void function HasChildren_Should_ReturnFalse() {
		assertFalse(variables.leaf.hasChildren())
	}

}