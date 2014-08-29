import craft.markup.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.factory = mock(CreateObject("ElementFactory"))

		this.builder = new ElementBuilder(this.factory, new Scope())

		// Create a fake xml document for the call to build().
		this.document = XMLNew()
		this.document.xmlRoot = XMLElemNew(this.document, "http://neoneo.nl/craft", "node")
	}

	public void function BuildSingleElement() {
		var element = createElement("ref")

		// Mock the convert() method, which is called by the builder.
		// The {xml} datatype expects xml strings, not nodes, so we use struct.
		this.factory.convert("{struct}").returns(element)

		var result = this.builder.build(this.document)

		// The result should be the element created earlier.
		assertSame(element, result)
		// The most important test: the building process should be complete.
		assertTrue(result.ready)
	}

	public void function BuildElementTree() {
		var root = createElementTree()

		this.factory.convert("{struct}").returns(root)

		var result = this.builder.build(this.document)

		assertSame(root, result)
		// Test whether all elements are ready.
		assertTrue(allReady(root))
	}

	public void function BuildDeferredTree() {
		var root = createElementTree()

		var children = root.children
		var until = children[2].children[3] // The last element to be traversed.
		var deferred1 = new stubs.build.DeferredElementMock(ref: "deferred1", until: until)
		var deferred2 = new stubs.build.DeferredElementMock(ref: "deferred2", until: deferred1)
		// Add deferred1 to the first child. The build process should pass through here first.
		// Add deferred2 to the last child. In case the algorithm changes, we still have an element whose construction is deferred.
		children[1].add(deferred1)
		children[3].add(deferred2)

		this.factory.convert("{struct}").returns(root)

		var result = this.builder.build(this.document)

		assertSame(root, result)
		assertTrue(allReady(root))
	}

	public void function BuildCircularTree_Should_ThrowConstructionException() {
		var root = createElementTree()
		var until = root.children[2].children[3] // The last element to be traversed.
		var deferred1 = new stubs.build.DeferredElementMock(ref: "deferred1", until: until)
		var deferred2 = new stubs.build.DeferredElementMock(ref: "deferred2", until: deferred1)

		root.children[1].add(deferred1)
		until.add(deferred2)

		this.factory.convert("{struct}").returns(root)

		// Deferred2 waits for deferred1. Deferred1 waits for until. Until waits for deferred2.
		try {
			var result = this.builder.build(this.document)
			dump(result)
			abort;
			fail("building an element tree with a circular structure should throw an exception")
		} catch (InstantiationException e) {}
	}

	private Boolean function allReady(required Element element) {
		return arguments.element.ready && arguments.element.children.every(function (element) {
			return allReady(arguments.element);
		});
	}

	private Element function createElement(required String ref) {
		return new stubs.build.ElementMock(ref: arguments.ref);
	}

	private Element function createElementTree() {
		// Create a tree of elements.
		var root = createElement("root")
		([1, 2, 3]).each(function (index) {
			root.add(createElement("child" & arguments.index))
		})

		var child2 = root.children[2]; // Semicolon needed for parser exception.
		([1, 2, 3]).each(function (index) {
			child2.add(createElement("grandchild" & arguments.index))
		})

		return root;
	}

}