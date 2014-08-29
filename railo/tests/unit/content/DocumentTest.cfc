import craft.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		var placeholder1 = mock(CreateObject("Placeholder"))
		placeholder1.ref = "p1"
		var placeholder2 = mock(CreateObject("Placeholder"))
		placeholder2.ref = "p2"

		this.layout = mock(CreateObject("Layout")).getPlaceholders().returns([placeholder1, placeholder2])
		this.layout.placeholders = [placeholder1, placeholder2]
		this.document = new Document(this.layout)
	}

	public void function Accept_Should_InvokeVisitor() {
		var visitor = mock(new VisitorStub()).visitDocument(this.document)
		this.document.accept(visitor)

		visitor.verify().visitDocument(this.document)
	}

	public void function AddRemoveSection_Should_Work() {
		assertTrue(this.document.sections.isEmpty(), "before a section is added, sections should return an empty struct")

		var section1 = mock(CreateObject("Section"))
		var placeholder1 = mock(CreateObject("Placeholder"))
		placeholder1.ref = "p1"
		this.document.addSection(section1, placeholder1.ref)

		var sections = this.document.sections
		assertFalse(sections.isEmpty())
		assertEquals(1, StructCount(sections)) // https://issues.jboss.org/browse/RAILO-2692
		assertTrue(sections.keyExists("p1"))
		assertSame(sections.p1, section1)

		var section2 = mock(CreateObject("Section"))
		var placeholder2 = mock(CreateObject("Placeholder"))
		placeholder2.ref = "p2"
		this.document.addSection(section2, placeholder2.ref)

		var sections = this.document.sections
		assertEquals(2, StructCount(sections))
		assertTrue(sections.keyExists("p2"))
		assertSame(sections.p2, section2)

		this.document.removeSection(placeholder1.ref)

		var sections = this.document.sections
		assertFalse(sections.keyExists("p1"))
		assertTrue(sections.keyExists("p2"))

	}

	public void function AddSection_Should_HaveNoEffect_When_PlaceholderFilled() {
		var section1 = mock(CreateObject("Section"))
		var placeholder1 = mock(CreateObject("Placeholder"))
		placeholder1.ref = "p1"
		this.document.addSection(section1, placeholder1.ref)

		var sections = this.document.sections
		assertSame(sections.p1, section1)

		var section2 = mock(CreateObject("Section"))
		assertNotSame(section1, section2)
		this.document.addSection(section2, placeholder1.ref)

		var sections = this.document.sections
		assertSame(sections.p1, section1)
	}

	public void function AddSection_Should_ThrowNoSuchElementException_When_NotExists() {
		var section1 = mock(CreateObject("Section"))
		var placeholder1 = mock(CreateObject("Placeholder"))
		placeholder1.ref = "p3"

		try {
			this.document.addSection(section1, placeholder1.ref)
			fail("exception should have been thrown")
		} catch (NoSuchElementException e) {}
	}

	public void function UseLayout_Should_KeepSimilarContentAndRemoveRest() {
		var layout1 = this.document.layout

		var placeholder1 = mock(CreateObject("Placeholder"))
		placeholder1.ref = "p1"
		var placeholder2 = mock(CreateObject("Placeholder"))
		placeholder2.ref = "p2"
		var placeholder3 = mock(CreateObject("Placeholder"))
		placeholder3.ref = "p3"

		var layout2 = mock(CreateObject("Layout")).getPlaceholders().returns([placeholder1, placeholder3])

		// Add some content to the placeholders p1 and p2.
		var section1 = mock(CreateObject("Section"))
		var section2 = mock(CreateObject("Section"))
		this.document.addSection(section1, placeholder1.ref)
		this.document.addSection(section2, placeholder2.ref)

		// Now replace by layout 2.
		this.document.useLayout(layout2)

		var sections = this.document.sections
		assertEquals(1, StructCount(sections), "the old and new layout have one placeholder in common, so there should be one key")
		assertTrue(sections.keyExists("p1"))
		assertSame(sections.p1, section1, "the content in the old layout should now be in the new layout")

		try {
			this.document.addSection(section2, placeholder2.ref)
			fail("exception should have been thrown")
		} catch (Any e) {
			// Don't check for the type here, that's another test. We just want to be sure that we can't add to p2 anymore.
		}
		this.document.addSection(section2, placeholder3.ref) // This should not throw.

		var sections = this.document.sections
		assertTrue(sections.keyExists("p3"))

		// Put the old layout back in.
		this.document.useLayout(layout1)
		var sections = this.document.sections
		assertEquals(1, sections.len(), "the old and new layout have one placeholder in common, so there should be one key")
		assertTrue(sections.keyExists("p1"))
		assertSame(sections.p1, section1, "the content in the old layout should now be in the new layout")
		// Test again that we can't add to placeholders of the previous layout, and that adding to placeholders of the new layout is possible.
		try {
			this.document.addSection(section2, placeholder3.ref)
			fail("exception should have been thrown")
		} catch (Any e) {}
		this.document.addSection(section2, placeholder2.ref)

	}

}