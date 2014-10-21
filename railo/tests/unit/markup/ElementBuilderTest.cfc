import craft.markup.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		var elementFactory = new stubs.ElementFactoryMock()

		this.tagRepository = mock(CreateObject("TagRepository"))
			.get("http://neoneo.nl/craft", "node").returns({
				class: "node",
				attributes: [{name: "ref", type: "String", required: true}]
			})
			.elementFactory("{string}").returns(elementFactory)

		// Create a builder mock. Its instantiate() method is the only thing that is stubbed, so that it doesn't stand in the way.
		this.builder = new stubs.ElementBuilderMock(this.tagRepository, new Scope())

		// Create a fake xml document for the call to build().
		this.document = XMLNew()
		this.document.xmlRoot = XMLElemNew(this.document, "http://neoneo.nl/craft", "node")
	}

	public void function BuildSingleElement() {
		var element = createElement("ref")
		this.builder.element = element

		var result = this.builder.build(this.document)

		// The result should be the element created earlier.
		assertSame(element, result)
		// The most important test: the building process should be complete.
		assertTrue(result.ready)
	}

	public void function BuildElementTree() {
		var root = createElementTree()
		this.builder.element = root

		var result = this.builder.build(this.document)

		assertSame(root, result)
		// Test whether all elements are ready.
		assertTrue(allReady(root))
	}

	public void function BuildDeferredTree() {
		var root = createElementTree()
		this.builder.element = root

		var children = root.children
		var until = children[2].children[3] // The last element to be traversed.
		var deferred1 = new stubs.build.DeferredElementMock(ref: "deferred1", until: until)
		var deferred2 = new stubs.build.DeferredElementMock(ref: "deferred2", until: deferred1)
		// Add deferred1 to the first child. The build process should pass through here first.
		// Add deferred2 to the last child. In case the algorithm changes, we still have an element whose construction is deferred.
		children[1].add(deferred1)
		children[3].add(deferred2)

		var result = this.builder.build(this.document)

		assertSame(root, result)
		assertTrue(allReady(root))
	}

	public void function BuildCircularTree_Should_ThrowConstructionException() {
		var root = createElementTree()
		this.builder.element = root

		var until = root.children[2].children[3] // The last element to be traversed.
		var deferred1 = new stubs.build.DeferredElementMock(ref: "deferred1", until: until)
		var deferred2 = new stubs.build.DeferredElementMock(ref: "deferred2", until: deferred1)

		root.children[1].add(deferred1)
		until.add(deferred2)

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

	public void function Instantiate_Should_ThrowIllegalArgumentException_When_MissingAttributes() {
		// The repository already has a mock get method, which returns something unsuitable for this test.
		this.tagRepository.get("http://neoneo.nl/craft/test", "node").returns({
			class: "node",
			attributes: [
				{name: "ref", type: "String", required: true},
				{name: "attribute1", type: "String"},
				{name: "attribute2", type: "String", required: true}
			]
		})

		builder = new ElementBuilder(this.tagRepository, new Scope())
		makePublic(builder, "instantiate")

		var document = XMLNew()
		var node = XMLElemNew(document, "http://neoneo.nl/craft/test", "node")
		node.xmlAttributes.ref = "ref"

		try {
			builder.instantiate(node)
			fail("exception should have been thrown")
		} catch (IllegalArgumentException e) {
			assertTrue(e.message.startsWith("Attribute"))
			assertTrue(e.message contains "attribute2")
		}

	}

	public void function Instantiate_Should_ThrowIllegalArgumentException_When_InvalidNumeric() {
		this.testAttributeDatatype("Numeric", "a", "42")
	}

	public void function Instantiate_Should_ThrowIllegalArgumentException_When_InvalidDate() {
		this.testAttributeDatatype("Date", "b", "2000-01-01")
	}

	public void function Instantiate_Should_ThrowIllegalArgumentException_When_InvalidBoolean() {
		this.testAttributeDatatype("Boolean", "c", "false")
	}

	private void function testAttributeDatatype(required String datatype, required String falseValue, required String trueValue) {
		this.tagRepository.get("http://neoneo.nl/craft/test", "node").returns({
			class: "node",
			attributes: [
				{name: "ref", type: "String"},
				{name: arguments.datatype, type: arguments.datatype}
			]
		})

		builder = new ElementBuilder(this.tagRepository, new Scope())
		makePublic(builder, "instantiate")

		var document = XMLNew()
		var node = XMLElemNew(document, "http://neoneo.nl/craft/test", "node")
		node.xmlAttributes.ref = "ref"
		node.xmlAttributes[arguments.datatype] = arguments.falseValue

		try {
			builder.instantiate(node)
			fail("exception should have been thrown")
		} catch (IllegalArgumentException e) {
			assertTrue(e.message.startsWith("Invalid"))
		}

		node.xmlAttributes[arguments.datatype] = arguments.trueValue
		builder.instantiate(node)

	}

	public void function Instantiate_Should_UseDefault_When_NoValue() {
		this.tagRepository.get("http://neoneo.nl/craft/test", "node").returns({
			class: "node",
			attributes: [
				{name: "ref", type: "String"},
				{name: "attribute1", type: "String", default: "somevalue"},
				{name: "attribute2", type: "String"},
			]
		})

		builder = new ElementBuilder(this.tagRepository, new Scope())
		makePublic(builder, "instantiate")

		var document = XMLNew()
		var node = XMLElemNew(document, "http://neoneo.nl/craft/test", "node")
		node.xmlAttributes.ref = "ref"
		node.xmlAttributes.attribute2 = "othervalue"

		var element = builder.instantiate(node)

		assertEquals("somevalue", element.attribute1)
		assertEquals("othervalue", element.attribute2)
	}

	public void function Instantiate_Should_ReturnElementTree() {
		builder = new ElementBuilder(this.tagRepository, new Scope())
		makePublic(builder, "instantiate")

		var document = XMLNew()

		var createNode = function (required String ref) {
			var node = XMLElemNew(document, "http://neoneo.nl/craft", "node")
			node.xmlAttributes.ref = arguments.ref
			return node;
		}

		var rootNode = createNode("root")
		var childNode1 = createNode("child1")
		var childNode2 = createNode("child2")
		var childNode3 = createNode("child3")
		var grandchildNode1 = createNode("grandchild1")
		var grandchildNode2 = createNode("grandchild2")
		var grandchildNode3 = createNode("grandchild3")

		childNode2.xmlChildren = [grandchildNode1, grandchildNode2, grandchildNode3]
		rootNode.xmlChildren = [childNode1, childNode2, childNode3]

		// Test.
		var root = builder.instantiate(rootNode)
		assertEquals(rootNode.xmlAttributes.ref, root.ref)
		// assertEquals(rootNode.xmlName, root.name)

		var children = root.children
		var child1 = children[1]
		assertEquals(childNode1.xmlAttributes.ref, child1.ref)
		// assertEquals(rootNode.xmlName, root.name)

		var child2 = children[2]
		assertEquals(childNode2.xmlAttributes.ref, child2.ref)
		// assertEquals(childNode2.xmlName, child2.name)

		var child3 = children[3]
		assertEquals(childNode3.xmlAttributes.ref, child3.ref)
		// assertEquals(childNode3.xmlName, child3.name)

		var grandchildren = child2.children

		var grandchild1 = grandchildren[1]
		assertEquals(grandchildNode1.xmlAttributes.ref, grandchild1.ref)
		// assertEquals(grandchildNode1.xmlName, grandchild1.name)
		var grandchild2 = grandchildren[2]
		assertEquals(grandchildNode2.xmlAttributes.ref, grandchild2.ref)
		// assertEquals(grandchildNode2.xmlName, grandchild2.name)
		var grandchild3 = grandchildren[3]
		assertEquals(grandchildNode3.xmlAttributes.ref, grandchild3.ref)
		// assertEquals(grandchildNode3.xmlName, grandchild3.name)

	}

	public void function Instantiate_Should_HandleMultipleNamespaces() {
		this.tagRepository.get("http://neoneo.nl/craft/test", "t:composite").returns({
			class: "node",
			attributes: [{name: "ref", type: "String", required: true}]
		})

		var builder = new ElementBuilder(this.tagRepository, new Scope())
		makePublic(builder, "instantiate")

		var document = XMLNew()
		var rootNode = XMLElemNew(document, "http://neoneo.nl/craft/test", "t:composite")
		rootNode.xmlAttributes.ref = "root"
		var childNode = XMLElemNew(document, "http://neoneo.nl/craft", "node")
		childNode.xmlAttributes.ref = "child"

		rootNode.xmlChildren = [childNode]

		var root = builder.instantiate(rootNode)
		assertEquals(rootNode.xmlAttributes.ref, root.ref)

		var child = root.children[1]
		assertEquals(childNode.xmlAttributes.ref, child.ref)

	}

}