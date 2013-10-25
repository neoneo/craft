import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.section = new Section()
	}

	public void function SetParent_Should_ThrowNotSupportedException() {
		var composite = new Composite()
		try {
			variables.section.setParent(composite)
			fail("calling setParent should have thrown NotSupportedException")
		} catch (Any e) {
			assertEquals("NotSupportedException", e.type)
		}
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitSection(variables.section)
		variables.section.accept(visitor)

		visitor.verify().visitSection(variables.section)
	}

}