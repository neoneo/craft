import craft.markup.*;

component extends="mxunit.framework.TestCase" {

	public void function Has_Should_ReturnFalse_When_RefDoesNotExist() {
		var scope = new Scope()
		assertFalse(scope.has("ref"))
	}

	public void function HasSlashGet_Should_ReturnTrueSlashElement_When_RefExists() {
		var scope = new Scope()
		var element = mock(CreateObject("Element")).getRef().returns("ref")

		scope.store(element)

		assertTrue(scope.has("ref"))
		assertSame(element, scope.get("ref"))
		assertFalse(scope.has("ref2"))
	}

	public void function Methods_Should_SearchParentScope() {
		var scope1 = new Scope()
		var element1 = mock(CreateObject("Element")).getRef().returns("ref1")
		scope1.store(element1)

		var scope2 = new Scope(scope1)
		var element2 = mock(CreateObject("Element")).getRef().returns("ref2")
		scope2.store(element2)

		var scope3 = new Scope(scope2)
		var element3 = mock(CreateObject("Element")).getRef().returns("ref3")
		scope3.store(element3)

		assertTrue(scope3.has("ref3"))
		assertSame(element3, scope3.get("ref3"))

		assertTrue(scope3.has("ref2"))
		assertSame(element2, scope3.get("ref2"))

		assertTrue(scope3.has("ref1"))
		assertSame(element1, scope3.get("ref1"))
	}

}