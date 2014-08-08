import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.root = createPathSegment("root")
		variables.path1 = ["dir1", "dir2", "dir3"]
		variables.path2 = ["dirA"]
	}

	public void function PatternAndParameterName_Should_ReturnConstructorValues() {
		var segment = new PathSegment("pattern", "parameter")
		assertEquals("pattern", segment.pattern())
		assertEquals("parameter", segment.parameterName())
	}

	public void function Command_Should_ReturnCorrespondingCommand() {
		var command1 = new CommandStub()
		var command2 = new CommandStub()

		assertFalse(variables.root.hasCommand())

		variables.root.setCommand(command1, "GET")
		variables.root.setCommand(command2, "POST")

		assertTrue(variables.root.hasCommand())
		assertTrue(variables.root.hasCommand("GET"))
		assertFalse(variables.root.hasCommand("DELETE"))

		assertEquals(command1, variables.root.command("GET"))
		assertEquals(command2, variables.root.command("POST"))

		try {
			variables.root.command("DELETE")
			fail("exception should have been thrown")
		} catch (NoSuchElementException e) {}

		variables.root.removeCommand("GET")
		assertFalse(variables.root.hasCommand("GET"))

		variables.root.removeCommand("POST")
		assertFalse(variables.root.hasCommand("POST"))
		assertFalse(variables.root.hasCommand())
	}

	public void function Children_Should_BeEmptyArray() {
		assertTrue(variables.root.children().isEmpty())
		assertFalse(variables.root.hasChildren())
	}

	public void function AddChild_Should_AppendChildAndSetParent() {
		var child1 = createPathSegment("test1")
		var child2 = createPathSegment("test2")
		variables.root.addChild(child1)
		variables.root.addChild(child2)

		assertTrue(variables.root.hasChildren())

		var children = variables.root.children()
		assertEquals(2, children.len())
		assertSame(child1, children[1])
		assertSame(child2, children[2])

		assertSame(variables.root, child1.parent())
		assertSame(variables.root, child2.parent())
	}

	public void function AddChildBefore_Should_InsertChild() {
		var test1 = createPathSegment("test1")
		var test2 = createPathSegment("test2")
		var test3 = createPathSegment("test3")
		variables.root.addChild(test1)
		variables.root.addChild(test3)

		// actual test
		variables.root.addChild(test2, test3)
		var children = variables.root.children()
		assertEquals(3, children.len())
		assertSame(test2, children[2])
	}

	public void function RemoveChild_Should_RemoveIfChildAndSetParentNull() {
		var test1 = createPathSegment("test1")
		var test2 = createPathSegment("test2")
		variables.root.addChild(test1)
		variables.root.addChild(test2)

		var test3 = createPathSegment("test3")
		test2.addChild(test3)

		var removed = variables.root.removeChild(test1)
		assertTrue(removed)
		assertFalse(test1.hasParent())
		// Try again:
		var removed = variables.root.removeChild(test1)
		assertFalse(removed)

		var children = variables.root.children()
		assertEquals(1, children.len())
		assertSame(test2, children[1])

		// Try to remove test3 from the root, while it's a child of test2.
		var removed = variables.root.removeChild(test3)
		assertFalse(removed)
		assertSame(test2, test3.parent())
	}

	public void function Parent_Should_ReturnParent_IfExists() {
		var test = createPathSegment("test")
		assertFalse(test.hasParent())

		test.setParent(variables.root)
		assertTrue(test.hasParent())
		assertSame(variables.root, test.parent())
	}

	private PathSegment function createPathSegment(required String name) {
		return new PathSegment(arguments.name)
	}

	public void function EntirePathSegmentMatch() {
		var segment = new EntirePathSegment()
		assertEquals(variables.path1.len(), segment.match(variables.path1))
		assertEquals(variables.path2.len(), segment.match(variables.path2))
	}

	public void function StaticPathSegmentMatch() {
		var segment = new StaticPathSegment("dir1")

		assertEquals(1, segment.match(variables.path1))
		assertEquals(0, segment.match(variables.path2))
	}

	public void function DynamicPathSegmentMatch() {
		var segment = new DynamicPathSegment("dir[0-9]")
		assertEquals(1, segment.match(variables.path1))
		assertEquals(0, segment.match(variables.path2))
		var path = ["dir10"]
		assertEquals(0, segment.match(path), "pattern path matcher should match against the complete segment")
	}


}