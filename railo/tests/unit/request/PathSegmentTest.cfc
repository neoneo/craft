import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.root = createPathSegment("root")
		this.path1 = ["dir1", "dir2", "dir3"]
		this.path2 = ["dirA"]
	}

	public void function PatternAndParameterName_Should_ReturnConstructorValues() {
		var segment = new PathSegment("pattern", "parameter")
		assertEquals("pattern", segment.pattern)
		assertEquals("parameter", segment.parameterName)
	}

	public void function Command_Should_ReturnCorrespondingCommand() {
		var command1 = new CommandStub()
		var command2 = new CommandStub()

		assertFalse(this.root.hasCommand())

		this.root.setCommand(command1, "GET")
		this.root.setCommand(command2, "POST")

		assertTrue(this.root.hasCommand())
		assertTrue(this.root.hasCommand("GET"))
		assertFalse(this.root.hasCommand("DELETE"))

		assertEquals(command1, this.root.command("GET"))
		assertEquals(command2, this.root.command("POST"))

		try {
			this.root.command("DELETE")
			fail("exception should have been thrown")
		} catch (NoSuchElementException e) {}

		this.root.removeCommand("GET")
		assertFalse(this.root.hasCommand("GET"))

		this.root.removeCommand("POST")
		assertFalse(this.root.hasCommand("POST"))
		assertFalse(this.root.hasCommand())
	}

	public void function Children_Should_BeEmptyArray() {
		assertTrue(this.root.children.isEmpty())
		assertFalse(this.root.hasChildren)
	}

	public void function AddChild_Should_AppendChildAndSetParent() {
		var child1 = createPathSegment("test1")
		var child2 = createPathSegment("test2")
		this.root.addChild(child1)
		this.root.addChild(child2)

		assertTrue(this.root.hasChildren)

		var children = this.root.children
		assertEquals(2, children.len())
		assertSame(child1, children[1])
		assertSame(child2, children[2])

		assertSame(this.root, child1.parent)
		assertSame(this.root, child2.parent)
	}

	public void function AddChildBefore_Should_InsertChild() {
		var test1 = createPathSegment("test1")
		var test2 = createPathSegment("test2")
		var test3 = createPathSegment("test3")
		this.root.addChild(test1)
		this.root.addChild(test3)

		// actual test
		this.root.addChild(test2, test3)
		var children = this.root.children
		assertEquals(3, children.len())
		assertSame(test2, children[2])
	}

	public void function RemoveChild_Should_RemoveIfChildAndSetParentNull() {
		var test1 = createPathSegment("test1")
		var test2 = createPathSegment("test2")
		this.root.addChild(test1)
		this.root.addChild(test2)

		var test3 = createPathSegment("test3")
		test2.addChild(test3)

		var removed = this.root.removeChild(test1)
		assertTrue(removed)
		assertFalse(test1.hasParent)
		// Try again:
		var removed = this.root.removeChild(test1)
		assertFalse(removed)

		var children = this.root.children
		assertEquals(1, children.len())
		assertSame(test2, children[1])

		// Try to remove test3 from the root, while it's a child of test2.
		var removed = this.root.removeChild(test3)
		assertFalse(removed)
		assertSame(test2, test3.parent)
	}

	public void function Parent_Should_ReturnParent_IfExists() {
		var test = createPathSegment("test")
		assertFalse(test.hasParent)

		test.setParent(this.root)
		assertTrue(test.hasParent)
		assertSame(this.root, test.parent)
	}

	private PathSegment function createPathSegment(required String name) {
		return new PathSegment(arguments.name)
	}

	public void function EntirePathSegmentMatch() {
		var segment = new EntirePathSegment()
		assertEquals(this.path1.len(), segment.match(this.path1))
		assertEquals(this.path2.len(), segment.match(this.path2))
	}

	public void function StaticPathSegmentMatch() {
		var segment = new StaticPathSegment("dir1")

		assertEquals(1, segment.match(this.path1))
		assertEquals(0, segment.match(this.path2))
	}

	public void function DynamicPathSegmentMatch() {
		var segment = new DynamicPathSegment("dir[0-9]")
		assertEquals(1, segment.match(this.path1))
		assertEquals(0, segment.match(this.path2))
		var path = ["dir10"]
		assertEquals(0, segment.match(path), "pattern path matcher should match against the complete segment")
	}


}