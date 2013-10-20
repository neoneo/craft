component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.placeholder = new craft.core.content.Placeholder("ref")
	}

	public void function getTag_Should_Return_Ref() {
		assertEquals("[[ref]]", variables.placeholder.getTag())
	}

	public void function Render_Should_Return_Insert() {
		var context = new ContextStub()
		assertEquals(variables.placeholder.getTag(), variables.placeholder.render(context))
	}

}