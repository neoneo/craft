import craft.markup.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.factory = mock(CreateObject("ElementFactory"))
		variables.scope = new Scope() // We should mock this, but it's a simple object. Mocking would be too complicated.

		variables.builder = new DocumentBuilder(variables.factory, variables.scope)
	}

	public void function BuildSingleNode_Should_ReturnElement() {

		var element = new stubs.build.RootElement(ref: "ref")

		// Mock the convert() method, which is called by the builder.
		// The {xml} datatype expects xml strings, not nodes, so we use struct.
		variables.factory.convert("{struct}").returns(element)

		var document = XMLNew()
		var root = XMLElemNew(document, "http://neoneo.nl/craft", "node")
		document.xmlRoot = root

		var result = variables.builder.build(document)

		// The result should be the element created earlier.
		assertSame(element, result)
		assertTrue(variables.scope.has("ref"))
		assertTrue(element.ready())
	}

	public void function ParseNodeTree_Should_ReturnElementWithChildren() {
		var root = createNode("root")
		var child1 = createNode("child1")
		var child2 = createNode("child2")
		var child3 = createNode("child3")
		var grandchild1 = createNode("grandchild1")
		var grandchild2 = createNode("grandchild2")
		var grandchild3 = createNode("grandchild3")

		child2.xmlChildren = [grandchild1, grandchild2, grandchild3]
		root.xmlChildren = [child1, child2, child3]

		var element = variables.reader.parse(root)

		assertEquals("root", element.getRef())
		assertTrue(element.hasChildren())

		var children = element.children()
		assertEquals(3, children.len())
		assertEquals("child1", children[1].getRef())
		assertEquals("child2", children[2].getRef())
		assertEquals("child3", children[3].getRef())

		assertFalse(children[1].hasChildren())
		assertTrue(children[2].hasChildren())
		assertFalse(children[3].hasChildren())

		var grandchildren = children[2].children()
		assertEquals(3, grandchildren.len())
		assertEquals("grandchild1", grandchildren[1].getRef())
		assertEquals("grandchild2", grandchildren[2].getRef())
		assertEquals("grandchild3", grandchildren[3].getRef())
	}

	private XML function createNode(required String ref) {
		var node = XMLElemNew(variables.document, "http://neoneo.nl/craft", "node")
		node.xmlAttributes.ref = arguments.ref

		return node
	}

	public void function BuildSimpleTree() {
		var root = createElementTree()

		var content = variables.reader.build(root)

		assertTrue(IsInstanceOf(content, "Root"), "content should be an instance of stubs.build.Root")
		assertTrue(content.hasChildren(), "content should have children")

		var children = content.children()
		assertEquals(3, children.len())
		assertEquals("child1", children[1].getRef())
		assertEquals("child2", children[2].getRef())
		assertEquals("child3", children[3].getRef())

		assertFalse(children[1].hasChildren())
		assertTrue(children[2].hasChildren())
		assertFalse(children[3].hasChildren())

		var grandchildren = children[2].children()
		assertEquals(3, grandchildren.len())
		assertEquals("grandchild1", grandchildren[1].getRef())
		assertEquals("grandchild2", grandchildren[2].getRef())
		assertEquals("grandchild3", grandchildren[3].getRef())
	}

	public void function BuildDeferredTree() {
		var root = createElementTree()
		var until = root.children()[2].children()[3] // The last element to be traversed.
		var deferred1 = new stubs.build.DeferredElement(ref: "deferred1", until: until)
		var deferred2 = new stubs.build.DeferredElement(ref: "deferred2", until: deferred1)
		// Add deferred1 to the first child. The build process should pass through here first.
		// Add deferred2 to the last child. In case the algorithm changes, we still have an element whose construction is deferred.
		root.children()[1].add(deferred1)
		root.children()[3].add(deferred2)

		var content = variables.reader.build(root)

		var children = content.children()
		assertEquals(3, children.len())
		assertEquals("child1", children[1].getRef())
		assertTrue(children[1].hasChildren(), "child1 should have children")
		assertTrue(children[3].hasChildren(), "child3 should have children")

		var grandchildren1 = children[1].children()
		assertEquals(1, grandchildren1.len())
		assertEquals("deferred1", grandchildren1[1].getRef())

		var grandchildren3 = children[3].children()
		assertEquals(1, grandchildren3.len())
		assertEquals("deferred2", grandchildren3[1].getRef())
	}

	public void function BuildCircularTree_Should_ThrowConstructionException() {
		var root = createElementTree()
		var until = root.children()[2].children()[3] // The last element to be traversed.
		var deferred1 = new stubs.build.DeferredElement(ref: "deferred1", until: until)
		var deferred2 = new stubs.build.DeferredElement(ref: "deferred2", until: deferred1)

		root.children()[1].add(deferred1)
		until.add(deferred2)

		// Deferred2 waits for deferred1. Deferred1 waits for until. Until waits for deferred2.
		try {
			var content = variables.reader.build(root)
			fail("building an element tree with a circular structure should throw an exception")
		} catch (any e) {
			assertEquals("ConstructionException", e.type)
		}
	}

	private Element function createElement(required String ref) {
		return new stubs.build.ChildElement(ref: arguments.ref)
	}

	private Element function createElementTree() {
		// Create a tree of elements.
		var root = new stubs.build.RootElement()
		var child1 = createElement("child1")
		var child2 = createElement("child2")
		var child3 = createElement("child3")
		var grandchild1 = createElement("grandchild1")
		var grandchild2 = createElement("grandchild2")
		var grandchild3 = createElement("grandchild3")

		root.add(child1)
		root.add(child2)
		root.add(child3)
		child2.add(grandchild1)
		child2.add(grandchild2)
		child2.add(grandchild3)

		return root
	}

}