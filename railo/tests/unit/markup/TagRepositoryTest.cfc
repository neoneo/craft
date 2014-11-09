import craft.markup.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.elementFactory = mock(CreateObject("stubs.ElementFactoryMock"))
		this.repository = new TagRepository(this.elementFactory)
		this.mapping = "/tests/unit/markup/stubs"
		this.dotMapping = this.mapping.listChangeDelims(".", "/")
	}

	public void function RegisterWithNoSettings_ShouldNot_RegisterAnything() {
		this.repository.register(this.mapping & "/nosettings")
		assertTrue(this.repository.tagNames.isEmpty())
	}

	public void function RegisterWithNoCraftSection_Should_ThrowNoSuchElementException() {
		try {
			this.repository.register(this.mapping & "/nocraftsection")
			fail("if there is no section named 'craft' in craft.ini, an exception should be thrown")
		} catch (NoSuchElementException e) {}
	}

	public void function RegisterWithNoNamespace_Should_ThrowNoSuchElementException() {
		try {
			this.repository.register(this.mapping & "/nonamespace")
			fail("if no namespace is defined in craft.ini, an exception should be thrown")
		} catch (NoSuchElementException e) {}
	}

	public void function RegisterWithSimpleSettings_Should_RegisterOnlyNonAbstractElements() {
		this.repository.register(this.mapping & "/recursive/dir2/sub")

		var tags = this.repository.tagNames

		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir2"), "there should be a key for the namespace as defined in craft.ini")
		tagNames = tags["http://neoneo.nl/craft/dir2"]

		assertFalse(tagNames.find("noelement") > 0, "if a component does not extend Element, it should not be registered")
		assertFalse(tagNames.find("abstractelement") > 0, "if a component has the 'abstract' annotation, it should not be registered")
		assertTrue(sameContents(["some", "extendssome", "extendsextendssome"], tagNames), "found tag names '#tagNames.toList()#'")

	}

	public void function Register_Should_LookInSubdirectories() {
		this.repository.register(this.mapping & "/recursive/dir1")

		var tags = this.repository.tagNames

		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir1"))
		tagNames = tags["http://neoneo.nl/craft/dir1"]

		// There are 2 directories, with 1 element each.
		assertEquals(2, tagNames.len())
		// SomeElement has no tag annotation, so the fully qualified name should be returned.
		assertTrue(sameContents([this.dotMapping & ".recursive.dir1.SomeElement", "dir1sub"], tagNames), "found tag names '#tagNames.toList()#'")
	}

	public void function Register_Should_RegisterMultipleNamespaces() {
		// This test combines the previous two tests by registering the parent directory.
		this.repository.register(this.mapping & "/recursive")

		var tags = this.repository.tagNames
		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir1"))
		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir2"))
	}

	public void function Register_Should_FollowDirectoriesDirective() {
		this.repository.register(this.mapping & "/directory")

		var tags = this.repository.tagNames
		assertTrue(tags.keyExists("http://neoneo.nl/craft/directory"))
		tagNames = tags["http://neoneo.nl/craft/directory"]

		// There are 3 directories that should be inspected, with 1 element each.
		assertTrue(sameContents(["yes", "yessub", "subyes"], tagNames), "found tag names '#tagNames.toList()#'")
	}

	private Boolean function sameContents(required Array array1, required Array array2) {
		return arguments.array1.containsAll(arguments.array2) && arguments.array2.containsAll(arguments.array1);
	}

	public void function Register_Should_ThrowAlreadyBoundException_When_ExistingTag() {
		try {
			this.repository.register(this.mapping & "/multiple/tagnames")
			fail("exception should have been thrown")
		} catch (AlreadyBoundException e) {
			assertTrue(e.message.startsWith("Tag"))
		}
	}

	public void function Register_Should_ThrowAlreadyBoundException_When_ExistingNamespace() {
		try {
			this.repository.register(this.mapping & "/multiple/namespaces")
			fail("exception should have been thrown")
		} catch (AlreadyBoundException e) {
			assertTrue(e.message.startsWith("Namespace"))
		}
	}

	public void function ElementFactory_Should_ReturnDefaultFactory_When_NoFactoryDirective() {
		this.repository.register(this.mapping & "/factory/nodirective")

		assertSame(this.elementFactory, this.repository.elementFactory("http://neoneo.nl/craft/factory/nodirective"))
	}

	public void function SetElementFactory_Should_SetFactoryForNamespace() {
		this.repository.register(this.mapping & "/factory/nodirective")
		// Set some element factory for the namespace just registered.
		var elementFactory = CreateObject("stubs.factory.directive.ElementFactoryStub")
		this.repository.setElementFactory("http://neoneo.nl/craft/factory/nodirective", elementFactory)

		assertSame(elementFactory, this.repository.elementFactory("http://neoneo.nl/craft/factory/nodirective"))
	}

	public void function SetElementFactory_Should_ThrowNoSuchElementException_When_NonExistingNamespace() {
		var elementFactory = CreateObject("stubs.factory.directive.ElementFactoryStub")
		try {
			this.repository.setElementFactory("http://neoneo.nl/craft/", elementFactory)
			fail("exception should have been thrown")
		} catch (NoSuchElementException e) {}

		this.repository.register(this.mapping & "/factory/nodirective")
		try {
			this.repository.setElementFactory("http://neoneo.nl/craft/nonexisting", elementFactory)
			fail("exception should have been thrown")
		} catch (NoSuchElementException e) {}
	}

	public void function Register_Should_ReturnCorrectFactory_When_FactoryDirective() {
		this.repository.register(this.mapping & "/factory/directive")

		var elementFactory = this.repository.elementFactory("http://neoneo.nl/craft/factory/directive")
		assertTrue(IsInstanceOf(elementFactory, this.dotMapping & ".factory.directive.ElementFactoryStub"),
			"element factory should be an instance of ElementFactoryStub")
	}

	// The following tests are integration tests, strictly speaking.

	public void function Deregister_Should_RemoveNamespace() {
		// First register some namespaces.
		this.repository.register(this.mapping & "/recursive")

		// Deregister one of the mappings.
		this.repository.deregister(this.mapping & "/recursive/dir2")

		// Test.
		var tags = this.repository.tagNames
		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir1"))
		assertFalse(tags.keyExists("http://neoneo.nl/craft/dir2"))
	}

	public void function DeregisterNamespace_Should_RemoveNamespace() {
		this.repository.register(this.mapping & "/recursive")

		this.repository.deregisterNamespace("http://neoneo.nl/craft/dir2")

		// Test.
		var tags = this.repository.tagNames
		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir1"))
		assertFalse(tags.keyExists("http://neoneo.nl/craft/dir2"))
	}

	public void function Get_Should_ThrowException_When_NonExistentNamespace() {
		this.repository.register(this.mapping & "/create")

		try {
			var metadata = this.repository.get("http://doesnotexist", "tagelement")
			fail("get should have thrown an exception")
		} catch (NoSuchElementException e) {}
	}

	public void function Get_Should_ThrowException_When_NonExistentTag() {
		this.repository.register(this.mapping & "/create")

		try {
			var metadata = this.repository.get("http://neoneo.nl/craft", "doesnotexist")
			fail("get should have thrown an exception")
		} catch (NoSuchElementException e) {}
	}

	public void function Get_Should_ReturnTagMetadata_When_TagName() {
		this.repository.register(this.mapping & "/create")

		var metadata = this.repository.get("http://neoneo.nl/craft", "tagelement")

		assertEquals(this.dotMapping & ".create.TagElement", metadata.class)
	}

	public void function Get_Should_ReturnTagMetadata_When_NoTagName() {
		this.repository.register(this.mapping & "/create")

		var metadata = this.repository.get("http://neoneo.nl/craft", this.dotMapping & ".create.NoTagElement")

		assertEquals(this.dotMapping & ".create.NoTagElement", metadata.class)
	}

}