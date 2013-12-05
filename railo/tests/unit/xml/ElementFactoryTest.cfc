import craft.xml.ElementFactory;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.factory = new ElementFactory()
		variables.mapping = "/crafttest/unit/xml/stubs"
	}

	public void function RegisterWithNoSettings_ShouldNot_RegisterAnything() {
		variables.factory.register(variables.mapping & "/nosettings")
		assertTrue(variables.factory.tags().isEmpty())
	}

	public void function RegisterWithNoCraftSection_Should_ThrowNoSuchElementException() {
		try {
			variables.factory.register(variables.mapping & "/nocraftsection")
			fail("if there is no section named 'craft' in settings.ini, an exception should be thrown")
		} catch (any e) {
			assertEquals("NoSuchElementException", e.type)
		}
	}

	public void function RegisterWithNoNamespace_Should_ThrowNoSuchElementException() {
		try {
			variables.factory.register(variables.mapping & "/nonamespace")
			fail("if no namespace is defined in settings.ini, an exception should be thrown")
		} catch (any e) {
			assertEquals("NoSuchElementException", e.type)
		}
	}

	public void function RegisterWithSimpleSettings_Should_RegisterNonAbstractElements() {
		variables.factory.register(variables.mapping & "/recursive/dir2/sub")

		var tags = variables.factory.tags()

		assertTrue(tags.keyExists("http://neoneo.nl/craft/dir2"), "there should be a key for the namespace as defined in settings.ini")
		tagNames = tags["http://neoneo.nl/craft/dir2"]

		// There are precisely 3 elements that are not abstract.
		assertEquals(3, tagNames.len())
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
		assertTrue(sameContents(["crafttest.unit.xml.recursive.dir1.SomeElement", "dir1sub"], tagNames), "found tag names '#tagNames.toList()#'")
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
		tagNames = tags["http://neoneo.nl/craft/dir1"]

		// There are 3 directories that should be inspected, with 1 element each.
		assertEquals(3, tagNames.len())
		assertTrue(sameContents(["yes", "yessub", "subyes"], tagNames), "found tag names '#tagNames.toList()#'")
	}

	private Boolean function sameContents(required Array array1, required Array array2) {
		return arguments.array1.containsAll(arguments.array2) && arguments.array2.containsAll(arguments.array1)
	}

}