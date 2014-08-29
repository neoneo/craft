import craft.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		for (var i = 1; i <= 6; i += 1) {
			var placeholder = this["placeholder" & i] = mock(CreateObject("Placeholder"))
			placeholder.ref = "p" & i
		}

		// We have to mock both the getter and the implicit getter.
		var layout = mock(CreateObject("Layout")).getPlaceholders().returns([placeholder1, placeholder2])
		layout.placeholders = [this.placeholder1, this.placeholder2]
		this.document = new DocumentLayout(layout)
	}

	public void function Placeholders_Should_ReturnLayoutPlaceholders() {
		var placeholders = this.document.placeholders
		assertEquals(2, placeholders.len(), "since no placeholders are filled, the placeholders of the layout should be returned")

		// Fill one of the placeholders.
		var section2 = mock(CreateObject("Section")).getPlaceholders().returns([this.placeholder3, this.placeholder4])
		section2.placeholders = [this.placeholder3, this.placeholder4]
		this.document.addSection(section2, this.placeholder2.ref)

		var placeholders = this.document.placeholders
		assertEquals(3, placeholders.len(), "p2 should be replaced by p3 and p4, so there should be 3 placeholders")
		assertHasPlaceholders(["p1", "p3", "p4"], placeholders)
	}

	public void function Placeholders_Should_ReturnPlaceholdersRecursively() {
		// Fill placeholder2.
		var section2 = mock(CreateObject("Section")).getPlaceholders().returns([this.placeholder3])
		section2.placeholders = [this.placeholder3]
		this.document.addSection(section2, this.placeholder2.ref) // This now contains p1 (from the parent layout) and p3.

		var document2 = new DocumentLayout(this.document)
		var placeholders = document2.placeholders
		assertEquals(2, placeholders.len(), "the number of placeholders should equal that of this.document")
		assertHasPlaceholders(["p1", "p3"], placeholders)

		// Placeholder p1 belongs to the layout.
		var section1 = mock(CreateObject("Section")).getPlaceholders().returns([])
		section1.placeholders = []
		document2.addSection(section1, this.placeholder1.ref)
		var placeholders = document2.getPlaceholders()
		assertEquals(1, placeholders.len(), "p1 is replaced by nil, so the same number of placeholders should be reduced by 1")
		assertHasPlaceholders(["p3"], placeholders)

		// Placeholder p3 belongs to the parent document layout.
		var section3 = mock(CreateObject("Section")).getPlaceholders().returns([this.placeholder4])
		section3.placeholders = [this.placeholder4]
		document2.addSection(section3, this.placeholder3.ref)
		var placeholders = document2.getPlaceholders()
		assertEquals(1, placeholders.len(), "p3 is replaced by p4, so there should be 1 placeholder")
		assertHasPlaceholders(["p4"], placeholders)

		// Just to be sure, go one level deeper.
		var document3 = new DocumentLayout(document2)
		var placeholders = document3.getPlaceholders()
		assertEquals(1, placeholders.len(), "the number of placeholders should equal that of document2")
		assertHasPlaceholders(["p4"], placeholders)

		// Placeholder p4 belongs to document2.
		var section4 = mock(CreateObject("Section")).getPlaceholders().returns([this.placeholder5, this.placeholder6])
		document3.addSection(section4, this.placeholder4.ref)
		var placeholders = document3.getPlaceholders()
		assertEquals(2, placeholders.len(), "p4 is replaced by p5 and p6, so there should be 2 placeholders")
		assertHasPlaceholders(["p5", "p6"], placeholders)

		// The parent documents should not be affected.
		var placeholders = document2.getPlaceholders()
		assertEquals(1, placeholders.len())
		assertHasPlaceholders(["p4"], placeholders)

		var placeholders = this.document.getPlaceholders()
		assertEquals(2, placeholders.len())
		assertHasPlaceholders(["p1", "p3"], placeholders)

	}

	private void function assertHasPlaceholders(required Array expected, required Array actual, String message = "") {
		var message = arguments.message
		var placeholders = arguments.actual
		// The order of the placeholders is not important.
		arguments.expected.each(function (ref) {
			var ref = arguments.ref
			assertTrue(placeholders.find(function (placeholder) {
				return arguments.placeholder.ref == ref
			}) > 0, message)
		})
	}

}