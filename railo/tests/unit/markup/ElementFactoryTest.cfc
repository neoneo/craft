import craft.markup.ElementFactory;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.factory = new ElementFactory()
		variables.mapping = "/crafttests/unit/markup/stubs"
	}

	public void function RegisterWithNoSettings_ShouldNot_RegisterAnything() {
		variables.factory.register(variables.mapping & "/nosettings")
		assertTrue(variables.factory.tags().isEmpty())
	}

	public void function RegisterWithNoCraftSection_Should_ThrowNoSuchElementException() {
		try {
			variables.factory.register(variables.mapping & "/nocraftsection")
			fail("if there is no section named 'craft' in settings.ini, an exception should be thrown")
		} catch (NoSuchElementException e) {}
	}

	public void function RegisterWithNoNamespace_Should_ThrowNoSuchElementException() {
		try {
			variables.factory.register(variables.mapping & "/nonamespace")
			fail("if no namespace is defined in settings.ini, an exception should be thrown")
		} catch (NoSuchElementException e) {}
	}

	public void function RegisterWithSimpleSettings_Should_RegisterOnlyNonAbstractElements() {
		variables.factory.register(variables.mapping & "/recursive/dir2/sub")

		var tags = variables.factory.tags()

		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir2"), "there should be a key for the namespace as defined in settings.ini")
		tagNames = tags["http://neoneo.nl/craft/dir2"]

		assertFalse(tagNames.find("noelement") > 0, "if a component does not extend Element, it should not be registered")
		assertFalse(tagNames.find("abstractelement") > 0, "if a component has the 'abstract' annotation, it should not be registered")
		assertTrue(sameContents(["some", "extendssome", "extendsextendssome"], tagNames), "found tag names '#tagNames.toList()#'")

	}

	public void function Register_Should_LookInSubdirectories() {
		variables.factory.register(variables.mapping & "/recursive/dir1")

		var tags = variables.factory.tags()

		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir1"))
		tagNames = tags["http://neoneo.nl/craft/dir1"]

		// There are 2 directories, with 1 element each.
		assertEquals(2, tagNames.len())
		// SomeElement has no tag annotation, so the fully qualified name should be returned.
		assertTrue(sameContents(["crafttests.unit.markup.stubs.recursive.dir1.SomeElement", "dir1sub"], tagNames), "found tag names '#tagNames.toList()#'")
	}

	public void function Register_Should_RegisterMultipleNamespaces() {
		// This test combines the previous two tests by registering the parent directory.
		variables.factory.register(variables.mapping & "/recursive")

		var tags = variables.factory.tags()
		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir1"))
		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir2"))
	}

	public void function RegisterWithDirectory_Should_OnlyRegisterWhereIndicated() {
		variables.factory.register(variables.mapping & "/directory")

		var tags = variables.factory.tags()
		assertTrue(tags.keyExists("http://neoneo.nl/craft/directory"))
		tagNames = tags["http://neoneo.nl/craft/directory"]

		// There are 3 directories that should be inspected, with 1 element each.
		assertTrue(sameContents(["yes", "yessub", "subyes"], tagNames), "found tag names '#tagNames.toList()#'")
	}

	private Boolean function sameContents(required Array array1, required Array array2) {
		return arguments.array1.containsAll(arguments.array2) && arguments.array2.containsAll(arguments.array1)
	}

	// The following tests are integration tests, strictly speaking.

	public void function Deregister_Should_RemoveNamespace() {
		// First register some namespaces.
		variables.factory.register(variables.mapping & "/recursive")

		// Deregister one of the mappings.
		variables.factory.deregister(variables.mapping & "/recursive/dir2")

		// Test.
		var tags = variables.factory.tags()
		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir1"))
		assertFalse(tags.keyExists("http://neoneo.nl/craft/dir2"))
	}

	public void function DeregisterNamespace_Should_RemoveNamespace() {
		variables.factory.register(variables.mapping & "/recursive")

		variables.factory.deregisterNamespace("http://neoneo.nl/craft/dir2")

		// Test.
		var tags = variables.factory.tags()
		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir1"))
		assertFalse(tags.keyExists("http://neoneo.nl/craft/dir2"))
	}

	public void function Create_Should_ThrowException_When_NonExistentNamespace() {
		variables.factory.register(variables.mapping & "/create")

		try {
			var element = variables.factory.create("http://doesnotexist", "tagelement")
			fail("create should have thrown an exception")
		} catch (NoSuchElementException e) {}
	}

	public void function Create_Should_ThrowException_When_NonExistentTag() {
		variables.factory.register(variables.mapping & "/create")

		try {
			var element = variables.factory.create("http://neoneo.nl/craft", "doesnotexist")
			fail("create should have thrown an exception")
		} catch (NoSuchElementException e) {}
	}

	public void function Create_Should_ReturnElement_When_Tag() {
		variables.factory.register(variables.mapping & "/create")

		var element = variables.factory.create("http://neoneo.nl/craft", "tagelement")

		assertTrue(IsInstanceOf(element, "TagElement"))
	}

	public void function Create_Should_ReturnElementWithAttributes_When_TagAndAttributes() {
		variables.factory.register(variables.mapping & "/create")

		var attributes = {
			ref: CreateUniqueId(),
			name: CreateGUID()
		}
		var element = variables.factory.create("http://neoneo.nl/craft", "tagelement", attributes)

		assertTrue(IsInstanceOf(element, "TagElement"))
		assertEquals(attributes.ref, element.getRef())
		assertEquals(attributes.name, element.getName())
	}

	public void function Create_Should_ReturnElement_When_Component() {
		variables.factory.register(variables.mapping & "/create")

		var element = variables.factory.create("http://neoneo.nl/craft", "crafttests.unit.markup.stubs.create.NoTagElement")

		assertTrue(IsInstanceOf(element, "NoTagElement"))
	}

	public void function Create_Should_ReturnElementWithAttributes_When_ComponentAndAttributes() {
		variables.factory.register(variables.mapping & "/create")

		var attributes = {
			ref: CreateUniqueId(),
			name: CreateGUID()
		}
		var element = variables.factory.create("http://neoneo.nl/craft", "crafttests.unit.markup.stubs.create.NoTagElement", attributes)

		assertTrue(IsInstanceOf(element, "NoTagElement"))
		assertEquals(attributes.ref, element.getRef())
		assertEquals(attributes.name, element.getName())
	}

	public void function Create_Should_ReturnElementWithoutAttributes_When_TagAndUndefinedAttributes() {
		variables.factory.register(variables.mapping & "/create")

		var attributes = {
			foo: CreateUniqueId(),
			bar: CreateGUID(),
			ref: CreateUniqueId()
		}
		var element = variables.factory.create("http://neoneo.nl/craft", "tagelement", attributes)

		assertTrue(IsInstanceOf(element, "TagElement"))
		assertEquals(attributes.ref, element.getRef())
		assertTrue(element.getName() === null)
	}

	public void function Convert_Should_ReturnElementTree() {
		variables.factory = new ElementFactoryMock()

		var document = XMLNew()

		var createNode = function (required String ref) {
			var node = XMLElemNew(document, "http://neoneo.nl/craft", "node")
			node.xmlAttributes.ref = arguments.ref
			return node
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
		var root = factory.convert(rootNode)
		assertEquals(rootNode.xmlAttributes.ref, root.getRef())
		assertEquals(rootNode.xmlName, root.getName())

		var children = root.children()
		var child1 = children[1]
		assertEquals(childNode1.xmlAttributes.ref, child1.getRef())
		assertEquals(rootNode.xmlName, root.getName())

		var child2 = children[2]
		assertEquals(childNode2.xmlAttributes.ref, child2.getRef())
		assertEquals(childNode2.xmlName, child2.getName())

		var child3 = children[3]
		assertEquals(childNode3.xmlAttributes.ref, child3.getRef())
		assertEquals(childNode3.xmlName, child3.getName())

		var grandchildren = child2.children()

		var grandchild1 = grandchildren[1]
		assertEquals(grandchildNode1.xmlAttributes.ref, grandchild1.getRef())
		assertEquals(grandchildNode1.xmlName, grandchild1.getName())
		var grandchild2 = grandchildren[2]
		assertEquals(grandchildNode2.xmlAttributes.ref, grandchild2.getRef())
		assertEquals(grandchildNode2.xmlName, grandchild2.getName())
		var grandchild3 = grandchildren[3]
		assertEquals(grandchildNode3.xmlAttributes.ref, grandchild3.getRef())
		assertEquals(grandchildNode3.xmlName, grandchild3.getName())

	}

	public void function Convert_Should_HandleMultipleNamespaces() {
		variables.factory = new ElementFactoryMock()

		var document = XMLNew()
		var rootNode = XMLElemNew(document, "http://neoneo.nl/craft/test", "t:composite")
		rootNode.xmlAttributes.ref = "root"
		var childNode = XMLElemNew(document, "http://neoneo.nl/craft", "node")
		childNode.xmlAttributes.ref = "child"

		rootNode.xmlChildren = [childNode]

		var root = factory.convert(rootNode)
		assertEquals(rootNode.xmlAttributes.ref, root.getRef())
		// getName() returns the tag name without the namespace prefix.
		assertEquals(rootNode.xmlName, "t:" & root.getName())

		var child = root.children()[1]
		assertEquals(childNode.xmlAttributes.ref, child.getRef())
		assertEquals(childNode.xmlName, child.getName())

	}

}