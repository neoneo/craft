import craft.markup.*;

component extends="mxunit.framework.TestCase" {

	public void function Has_Should_ReturnFalse_When_RefDoesNotExist() {
		var scope = new Scope()
		assertFalse(scope.has("ref"))
	}

	public void function HasSlashGet_Should_ReturnTrueSlashElement_When_RefExists() {
		var scope = new Scope()
		var element = mock(CreateObject("Element"))
		element.ref = "ref"

		scope.put(element)

		assertTrue(scope.has("ref"))
		assertSame(element, scope.get("ref"))
		assertFalse(scope.has("ref2"))
	}

	public void function Methods_Should_SearchParentScope() {
		var scope1 = new Scope()
		var element1 = mock(CreateObject("Element"))
		element1.ref = "ref1"
		scope1.put(element1)

		var scope2 = new Scope(scope1)
		var element2 = mock(CreateObject("Element"))
		element2.ref = "ref2"
		scope2.put(element2)

		var scope3 = new Scope(scope2)
		var element3 = mock(CreateObject("Element"))
		element3.ref = "ref3"
		scope3.put(element3)

		assertTrue(scope3.has("ref3"))
		assertSame(element3, scope3.get("ref3"))

		assertTrue(scope3.has("ref2"))
		assertSame(element2, scope3.get("ref2"))

		assertTrue(scope3.has("ref1"))
		assertSame(element1, scope3.get("ref1"))
	}

}