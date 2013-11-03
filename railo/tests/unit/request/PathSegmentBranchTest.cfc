import craft.core.request.PathSegment;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.pathMatcher = new PathMatcherStub(true)
		variables.root = createPathSegment("root")
	}

	public void function Children_Should_BeEmptyArray() {
		assertTrue(variables.root.getChildren().isEmpty())
	}

	public void function AddChild_Should_AppendChild() {
		variables.root.addChild(createPathSegment("test1"))
		variables.root.addChild(createPathSegment("test2"))

		var children = variables.root.getChildren()
		assertEquals(2, children.len())
		assertEquals("test1", children[1].getParameterName())
		assertEquals("test2", children[2].getParameterName())
	}

	public void function AddChildBefore_Should_InsertChild() {
		var test1 = createPathSegment("test1")
		var test2 = createPathSegment("test2")
		var test3 = createPathSegment("test3")
		variables.root.addChild(test1)
		variables.root.addChild(test3)

		// actual test
		variables.root.addChild(test2, test3)
		var children = variables.root.getChildren()
		assertEquals(3, children.len())
		assertEquals("test2", children[2].getParameterName())
	}

	public void function RemoveChild_Should_ReturnRemovedChild() {
		var test1 = createPathSegment("test1")
		var test2 = createPathSegment("test2")
		variables.root.addChild(test1)
		variables.root.addChild(test2)

		var removed = variables.root.removeChild(test2)
		assertTrue(removed);
		// try again
		var removed = variables.root.removeChild(test2)
		assertFalse(removed);

		var children = variables.root.getChildren()
		assertEquals(1, children.len())
		assertEquals("test1", children[1].getParameterName())
	}

	public void function GetParent_Should_ReturnParentIfExists() {
		var test = createPathSegment("test")
		assertFalse(test.hasParent())

		test.setParent(variables.root)
		assertTrue(test.hasParent())
		assertEquals(variables.root, test.getParent())
	}

	private PathSegment function createPathSegment(required String name) {
		return new PathSegment(variables.pathMatcher, arguments.name)
	}

}