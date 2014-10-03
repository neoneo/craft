import craft.output.*;

component extends="mxunit.framework.TestCase" {

	public void function CallConfigureWithProperties() {
		var properties = {
			a: 1,
			b: true,
			c: "x"
		}
		var view = new stubs.ViewStub(mock(CreateObject("TemplateRenderer")), properties)

		assertTrue(view.configureCalled, "configure should have been called")
		assertEquals(view.properties, properties)
	}

}