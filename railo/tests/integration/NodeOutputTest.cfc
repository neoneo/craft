import craft.core.content.*;
import craft.core.output.*;
import craft.core.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.contentType = new JSONContentType()
		var context = mock(CreateObject("Context"))
			.getRequestMethod().returns("get")
			.getContentType().returns(variables.contentType)
		var viewFinder = new ViewFinder("cfm")
		viewFinder.addMapping("/craft/../tests/integration/views")
		var renderer = new CFMLRenderer(viewFinder)

		variables.visitor = new RenderVisitor(renderer, context)
	}

	public void function LeafTest() {
		var leaf = new stubs.Leaf("leaf")

		variables.visitor.visitLeaf(leaf)

		var content = variables.visitor.getContent()
		var output = DeserializeJSON(variables.contentType.write(content))
		var expected = {"node": "leaf"}

		assertEquals(expected, output)
	}

	public void function CompositeTest() {
		variables.visitor.visitComposite(simpleComposite())

		var content = variables.visitor.getContent()
		var output = DeserializeJSON(variables.contentType.write(content))
		var expected = {
			"node": "composite",
			"content": [
				{"node": "leaf1"},
				{"node": "leaf2"},
				{"node": "leaf3"}
			]
		}

		assertEquals(expected, output)
	}

	public void function NestedCompositeTest() {
		var composite = nestedComposite()

		variables.visitor.visitComposite(composite)

		var content = variables.visitor.getContent()
		var output = DeserializeJSON(variables.contentType.write(content))
		var expected = {
			"node": "composite1",
			"content": [
				{"node": "leaf1"},
				{
					"node": "composite2",
					"content": [
						{"node": "leaf2"},
						{"node": "leaf3"}
					]
				},
				{"node": "leaf4"}
			]
		}

		assertEquals(expected, output)
	}

	public void function DocumentTest() {
		var composite = nestedComposite()
		var section = new Section(composite)
		var template = new Template(section)
		var document = new Document(template)

		variables.visitor.visitDocument(document)

		var content = variables.visitor.getContent()
		var output = DeserializeJSON(variables.contentType.write(content))

		var expected = {
			"node": "composite1",
			"content": [
				{"node": "leaf1"},
				{
					"node": "composite2",
					"content": [
						{"node": "leaf2"},
						{"node": "leaf3"}
					]
				},
				{"node": "leaf4"}
			]
		}

		assertEquals(expected, output)
	}

	public void function DocumentWithPlaceholdersTest() {
		var section = new Section(nestedComposite(true)) // With placeholders.
		var template = new Template(section)
		var document = new Document(template)

		var p1Section = new Section(simpleComposite())
		document.addSection(p1Section, new Placeholder("p1"))

		var p3Section = new Section(simpleComposite())
		document.addSection(p3Section, new Placeholder("p3"))

		variables.visitor.visitDocument(document)

		var content = variables.visitor.getContent()
		var output = DeserializeJSON(variables.contentType.write(content))

		var expected = {
			"node": "composite1",
			"content": [
				{"node": "leaf1"},
				// p1Section:
				{
					"node": "composite",
					"content": [
						{"node": "leaf1"},
						{"node": "leaf2"},
						{"node": "leaf3"}
					]
				},
				{
					"node": "composite2",
					"content": [
						// p2Section: not filled.
						{"node": "leaf2"},
						{"node": "leaf3"}
					]
				},
				{"node": "leaf4"},
				// p3Section:
				{
					"node": "composite",
					"content": [
						{"node": "leaf1"},
						{"node": "leaf2"},
						{"node": "leaf3"}
					]
				}
			]
		}

		assertEquals(expected, output)
	}

	public void function NestedDocumentTest() {

		var section = new Section(nestedComposite(true))
		var template = new Template(section)

		var documentTemplate1 = new DocumentTemplate(template)
		var p1Section = new Section(simpleComposite(true))
		documentTemplate1.addSection(p1Section, new Placeholder("p1"))

		// The available placeholders in the document template should now be: p, p2, p3.

		var documentTemplate2 = new DocumentTemplate(documentTemplate1)
		var pSection = new Section(new stubs.Leaf("p"))
		documentTemplate2.addSection(pSection, new Placeholder("p"))

		var p2Section = new Section(new stubs.Leaf("p2"))
		documentTemplate2.addSection(p2Section, new Placeholder("p2"))

		// Now remains only placeholder p3.

		var documentTemplate3 = new DocumentTemplate(documentTemplate2)
		var p3Section = new Section(new stubs.Leaf("p3"))
		documentTemplate3.addSection(p3Section, new Placeholder("p3"))

		var document = new Document(documentTemplate3)

		// Start the actual test.
		variables.visitor.visitDocument(document)

		var content = variables.visitor.getContent()
		var output = DeserializeJSON(variables.contentType.write(content))

		var expected = {
			"node": "composite1",
			"content": [
				{"node": "leaf1"},
				// Placeholder p1:
				{
					"node": "composite",
					"content": [
						{"node": "leaf1"},
						// Placeholder p:
						{"node": "p"},
						{"node": "leaf2"},
						{"node": "leaf3"}
					]
				},
				{
					"node": "composite2",
					"content": [
						// Placeholder p2:
						{"node": "p2"},
						{"node": "leaf2"},
						{"node": "leaf3"}
					]
				},
				{"node": "leaf4"},
				// Placeholder p3:
				{"node": "p3"}
			]
		}

		assertEquals(expected, output)
	}

	public void function ReplaceTemplateTest() {
		var section1 = new Section(nestedComposite(true))
		var template1 = new Template(section1)

		// For this test, only include p1 en p2 in the second template.
		var composite = new stubs.Composite("composite")
		composite.addChild(new Placeholder("p1"))
		composite.addChild(new Placeholder("p2"))
		var section2 = new Section(composite)
		var template2 = new Template(section2)

		// Create a document based on template 1.
		var document = new Document(template1)
		// Fill all placeholders p1, p2 and p3.
		var p1Section = new Section(new stubs.Leaf("p1"))
		document.addSection(p1Section, new Placeholder("p1"))
		var p2Section = new Section(new stubs.Leaf("p2"))
		document.addSection(p2Section, new Placeholder("p2"))
		var p3Section = new Section(new stubs.Leaf("p3"))
		document.addSection(p3Section, new Placeholder("p3"))

		// Actual test.
		document.useTemplate(template2)

		variables.visitor.visitDocument(document)

		var content = variables.visitor.getContent()
		var output = DeserializeJSON(variables.contentType.write(content))

		var expected = {
			"node": "composite",
			"content": [
				{"node": "p1"},
				{"node": "p2"}
			]
		}

		assertEquals(expected, output)

		// Replace the old template back. The content of p3 should have been removed earlier, and should therefore not be rendered.
		document.useTemplate(template1)
		variables.visitor.visitDocument(document)

		var content = variables.visitor.getContent()
		var output = DeserializeJSON(variables.contentType.write(content))

		var expected = {
			"node": "composite1",
			"content": [
				{"node": "leaf1"},
				{"node": "p1"},
				{
					"node": "composite2",
					"content": [
						{"node": "p2"},
						{"node": "leaf2"},
						{"node": "leaf3"}
					]
				},
				{"node": "leaf4"}
				// No p3.
			]
		}

		assertEquals(expected, output)
	}

	private stubs.Composite function simpleComposite(Boolean placeholder = true) {
		var composite = new stubs.Composite("composite")
		composite.addChild(new stubs.Leaf("leaf1"))
		if (arguments.placeholder) {
			composite.addChild(new Placeholder("p"))
		}
		composite.addChild(new stubs.Leaf("leaf2"))
		composite.addChild(new stubs.Leaf("leaf3"))

		return composite
	}

	private stubs.Composite function nestedComposite(Boolean placeholders = false) {
		var composite1 = new stubs.Composite("composite1")
		composite1.addChild(new stubs.Leaf("leaf1"))

		if (arguments.placeholders) {
			composite1.addChild(new Placeholder("p1"))
		}

		var composite2 = new stubs.Composite("composite2")
		if (arguments.placeholders) {
			composite2.addChild(new Placeholder("p2"))
		}
		composite2.addChild(new stubs.Leaf("leaf2"))
		composite2.addChild(new stubs.Leaf("leaf3"))

		composite1.addChild(composite2)
		composite1.addChild(new stubs.Leaf("leaf4"))
		if (arguments.placeholders) {
			composite1.addChild(new Placeholder("p3"))
		}

		return composite1
	}

	private Section function placeholderSection(required String ref) {
		var section = new Section()

	}

}