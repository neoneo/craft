import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.placeholder1 = mock(CreateObject("Placeholder")).ref().returns("p1")
		variables.placeholder2 = mock(CreateObject("Placeholder")).ref().returns("p2")
		variables.placeholder3 = mock(CreateObject("Placeholder")).ref().returns("p3")
		variables.placeholder4 = mock(CreateObject("Placeholder")).ref().returns("p4")
		variables.placeholder5 = mock(CreateObject("Placeholder")).ref().returns("p5")
		variables.placeholder6 = mock(CreateObject("Placeholder")).ref().returns("p6")

		var layout = mock(CreateObject("Layout")).placeholders().returns([placeholder1, placeholder2])
		variables.document = new DocumentLayout(layout)
	}

	public void function Placeholders_Should_ReturnLayoutPlaceholders() {
		var placeholders = variables.document.placeholders()
		assertEquals(2, placeholders.len(), "since no placeholders are filled, the placeholders of the layout should be returned")

		// Fill one of the placeholders.
		var section2 = mock(CreateObject("Section")).placeholders().returns([placeholder3, placeholder4])
		variables.document.addSection(section2, variables.placeholder2.ref())

		var placeholders = variables.document.placeholders()
		assertEquals(3, placeholders.len(), "p2 should be replaced by p3 and p4, so there should be 3 placeholders")
		assertHasPlaceholders(["p1", "p3", "p4"], placeholders)
	}

	public void function Placeholders_Should_ReturnPlaceholdersRecursively() {
		// Fill placeholder2.
		var section2 = mock(CreateObject("Section")).placeholders().returns([variables.placeholder3])
		variables.document.addSection(section2, variables.placeholder2.ref()) // This now contains p1 (from the parent layout) and p3.

		var document2 = new DocumentLayout(variables.document)
		var placeholders = document2.placeholders()
		assertEquals(2, placeholders.len(), "the number of placeholders should equal that of variables.document")
		assertHasPlaceholders(["p1", "p3"], placeholders)

		// Placeholder p1 belongs to the layout.
		var section1 = mock(CreateObject("Section")).placeholders().returns([])
		document2.addSection(section1, variables.placeholder1.ref())
		var placeholders = document2.placeholders()
		assertEquals(1, placeholders.len(), "p1 is replaced by nil, so the same number of placeholders should be reduced by 1")
		assertHasPlaceholders(["p3"], placeholders)

		// Placeholder p3 belongs to the parent document layout.
		var section3 = mock(CreateObject("Section")).placeholders().returns([variables.placeholder4])
		document2.addSection(section3, variables.placeholder3.ref())
		var placeholders = document2.placeholders()
		assertEquals(1, placeholders.len(), "p3 is replaced by p4, so there should be 1 placeholder")
		assertHasPlaceholders(["p4"], placeholders)

		// Just to be sure, go one level deeper.
		var document3 = new DocumentLayout(document2)
		var placeholders = document3.placeholders()
		assertEquals(1, placeholders.len(), "the number of placeholders should equal that of document2")
		assertHasPlaceholders(["p4"], placeholders)

		// Placeholder p4 belongs to document2.
		var section4 = mock(CreateObject("Section")).placeholders().returns([variables.placeholder5, variables.placeholder6])
		document3.addSection(section4, variables.placeholder4.ref())
		var placeholders = document3.placeholders()
		assertEquals(2, placeholders.len(), "p4 is replaced by p5 and p6, so there should be 2 placeholders")
		assertHasPlaceholders(["p5", "p6"], placeholders)

		// The parent documents should not be affected.
		var placeholders = document2.placeholders()
		assertEquals(1, placeholders.len())
		assertHasPlaceholders(["p4"], placeholders)

		var placeholders = variables.document.placeholders()
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
				return arguments.placeholder.ref() == ref
			}) > 0, message)
		})
	}

}