import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function Create() {
		var factory = new PathSegmentFactory()

		var root = factory.create("/")
		assertTrue(IsInstanceOf(root, "RootPathSegment"))

		var entire = factory.create("*", "par1")
		assertTrue(IsInstanceOf(entire, "EntirePathSegment"))
		assertEquals("par1", entire.parameterName)

		var static = factory.create("static", "par2")
		assertTrue(IsInstanceOf(static, "StaticPathSegment"))
		assertEquals("static", static.pattern)
		assertEquals("par2", static.parameterName)

		var dynamic = factory.create("[0-9]+", "par3")
		assertTrue(IsInstanceOf(dynamic, "DynamicPathSegment"))
		assertEquals("[0-9]+", dynamic.pattern)
		assertEquals("par3", dynamic.parameterName)
	}

}