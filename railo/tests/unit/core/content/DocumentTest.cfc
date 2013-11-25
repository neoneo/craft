import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		var placeholder1 = mock(CreateObject("Placeholder")).ref().returns("p1")
		var placeholder2 = mock(CreateObject("Placeholder")).ref().returns("p2")

		variables.template = mock(CreateObject("Template")).placeholders().returns([placeholder1, placeholder2])
		variables.document = new Document(variables.template)
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitDocument(variables.document)
		variables.document.accept(visitor)

		visitor.verify().visitDocument(variables.document)
	}

	public void function AddRemoveSection_Should_Work() {
		assertTrue(variables.document.sections().isEmpty(), "before a section is added, sections() should return an empty struct")

		var section1 = mock(CreateObject("Section"))
		var placeholder1 = mock(CreateObject("Placeholder")).ref().returns("p1")
		variables.document.addSection(section1, placeholder1.ref())

		var sections = variables.document.sections()
		assertFalse(sections.isEmpty())
		assertEquals(1, StructCount(sections)) // https://issues.jboss.org/browse/RAILO-2692
		assertTrue(sections.keyExists("p1"))
		assertSame(sections.p1, section1)

		var section2 = mock(CreateObject("Section"))
		var placeholder2 = mock(CreateObject("Placeholder")).ref().returns("p2")
		variables.document.addSection(section2, placeholder2.ref())

		var sections = variables.document.sections()
		assertEquals(2, StructCount(sections))
		assertTrue(sections.keyExists("p2"))
		assertSame(sections.p2, section2)

		variables.document.removeSection(placeholder1.ref())

		var sections = variables.document.sections()
		assertFalse(sections.keyExists("p1"))
		assertTrue(sections.keyExists("p2"))

	}

	public void function AddSection_Should_HaveNoEffect_When_PlaceholderFilled() {
		var section1 = mock(CreateObject("Section"))
		var placeholder1 = mock(CreateObject("Placeholder")).ref().returns("p1")
		variables.document.addSection(section1, placeholder1.ref())

		var sections = variables.document.sections()
		assertSame(sections.p1, section1)

		var section2 = mock(CreateObject("Section"))
		assertNotSame(section1, section2)
		variables.document.addSection(section2, placeholder1.ref())

		var sections = variables.document.sections()
		assertSame(sections.p1, section1)
	}

	public void function AddSection_Should_ThrowNoSuchElementException_When_NotExists() {
		var section1 = mock(CreateObject("Section"))
		var placeholder1 = mock(CreateObject("Placeholder")).ref().returns("p3")

		try {
			variables.document.addSection(section1, placeholder1.ref())
			fail("exception should have been thrown")
		} catch (Any e) {
			assertEquals(e.type, "NoSuchElementException")
		}
	}

	public void function UseTemplate_Should_KeepSimilarContentAndRemoveRest() {
		var template1 = variables.document.template()

		var placeholder1 = mock(CreateObject("Placeholder")).ref().returns("p1")
		var placeholder2 = mock(CreateObject("Placeholder")).ref().returns("p2")
		var placeholder3 = mock(CreateObject("Placeholder")).ref().returns("p3")

		var template2 = mock(CreateObject("Template")).placeholders().returns([placeholder1, placeholder3])

		// Add some content to the placeholders p1 and p2.
		var section1 = mock(CreateObject("Section"))
		var section2 = mock(CreateObject("Section"))
		variables.document.addSection(section1, placeholder1.ref())
		variables.document.addSection(section2, placeholder2.ref())

		// Now replace by template 2.
		variables.document.useTemplate(template2)

		var sections = variables.document.sections()
		assertEquals(1, StructCount(sections), "the old and new template have one placeholder in common, so there should be one key")
		assertTrue(sections.keyExists("p1"))
		assertSame(sections.p1, section1, "the content in the old template should now be in the new template")

		try {
			variables.document.addSection(section2, placeholder2.ref())
			fail("exception should have been thrown")
		} catch (Any e) {
			// Don't check for the type here, that's another test. We just want to be sure that we can't add to p2 anymore.
		}
		variables.document.addSection(section2, placeholder3.ref()) // This should not throw.

		var sections = variables.document.sections()
		assertTrue(sections.keyExists("p3"))

		// Put the old template back in.
		variables.document.useTemplate(template1)
		var sections = variables.document.sections()
		assertEquals(1, StructCount(sections), "the old and new template have one placeholder in common, so there should be one key")
		assertTrue(sections.keyExists("p1"))
		assertSame(sections.p1, section1, "the content in the old template should now be in the new template")
		// Test again that we can't add to placeholders of the previous template, and that adding to placeholders of the new template is possible.
		try {
			variables.document.addSection(section2, placeholder3.ref())
			fail("exception should have been thrown")
		} catch (Any e) {}
		variables.document.addSection(section2, placeholder2.ref())

	}

}