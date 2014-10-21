component extends="mxunit.framework.TestCase" {

	public void function implement() {
		Throw("implement");
	}

	public void function Get_Should_ReturnElementWithAttributes_When_TagAndAttributes() {
		this.repository.register(this.mapping & "/create")

		var attributes = {
			ref: CreateUniqueId(),
			name: CreateGUID()
		}
		var element = this.repository.get("http://neoneo.nl/craft", "tagelement", attributes)

		assertTrue(IsInstanceOf(element, "TagElement"))
		assertEquals(attributes.ref, element.ref)
		assertEquals(attributes.name, element.name)
	}

	public void function Get_Should_ReturnElementWithAttributes_When_ComponentAndAttributes() {
		this.repository.register(this.mapping & "/create")

		var attributes = {
			ref: CreateUniqueId(),
			name: CreateGUID()
		}
		var element = this.repository.get("http://neoneo.nl/craft", this.dotMapping & ".create.NoTagElement", attributes)

		assertTrue(IsInstanceOf(element, "NoTagElement"))
		assertEquals(attributes.ref, element.ref)
		assertEquals(attributes.name, element.name)
	}

	public void function Get_Should_ReturnElementWithoutAttributes_When_TagAndUndefinedAttributes() {
		this.repository.register(this.mapping & "/create")

		var attributes = {
			foo: CreateUniqueId(),
			bar: CreateGUID(),
			ref: CreateUniqueId()
		}
		var element = this.repository.get("http://neoneo.nl/craft", "tagelement", attributes)

		assertTrue(IsInstanceOf(element, "TagElement"))
		assertEquals(attributes.ref, element.ref)
		assertTrue(element.name === null)
	}

}