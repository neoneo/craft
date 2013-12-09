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
		viewFinder.addMapping("/crafttests/integration/core/views")
		var renderer = new CFMLRenderer(viewFinder)

		variables.visitor = new RenderVisitor(renderer, context)
	}

	public void function RenderLeaf() {
		var leaf = new stubs.Leaf("leaf")

		variables.visitor.visitLeaf(leaf)

		var content = variables.visitor.content()
		var output = DeserializeJSON(variables.contentType.write(content))
		var expected = {"component": "leaf"}

		assertEquals(expected, output)
	}

	public void function RenderComposite() {
		variables.visitor.visitComposite(simpleComposite())

		var content = variables.visitor.content()
		var output = DeserializeJSON(variables.contentType.write(content))
		var expected = {
			"component": "composite",
			"content": [
				{"component": "leaf1"},
				{"component": "leaf2"},
				{"component": "leaf3"}
			]
		}

		assertEquals(expected, output)
	}

	public void function RenderNestedComposite() {
		var composite = nestedComposite()

		variables.visitor.visitComposite(composite)

		var content = variables.visitor.content()
		var output = DeserializeJSON(variables.contentType.write(content))
		var expected = {
			"component": "composite1",
			"content": [
				{"component": "leaf1"},
				{
					"component": "composite2",
					"content": [
						{"component": "leaf2"},
						{"component": "leaf3"}
					]
				},
				{"component": "leaf4"}
			]
		}

		assertEquals(expected, output)
	}

	public void function RenderDocument() {
		var composite = nestedComposite()
		var section = new Section()
		section.addComponent(composite)
		var template = new Template(section)
		var document = new Document(template)

		variables.visitor.visitDocument(document)

		var content = variables.visitor.content()
		var output = DeserializeJSON(variables.contentType.write(content))

		var expected = {
			"component": "composite1",
			"content": [
				{"component": "leaf1"},
				{
					"component": "composite2",
					"content": [
						{"component": "leaf2"},
						{"component": "leaf3"}
					]
				},
				{"component": "leaf4"}
			]
		}

		assertEquals(expected, output)
	}

	public void function RenderDocumentWithPlaceholders() {
		var section = new Section() // With placeholders.
		section.addComponent(nestedComposite(true))
		var template = new Template(section)
		var document = new Document(template)

		var p1Section = new Section()
		p1Section.addComponent(simpleComposite())
		document.addSection(p1Section, "p1")

		var p3Section = new Section()
		p3Section.addComponent(simpleComposite())
		document.addSection(p3Section, "p3")

		variables.visitor.visitDocument(document)

		var content = variables.visitor.content()
		var output = DeserializeJSON(variables.contentType.write(content))

		var expected = {
			"component": "composite1",
			"content": [
				{"component": "leaf1"},
				// p1Section:
				{
					"component": "composite",
					"content": [
						{"component": "leaf1"},
						{"component": "leaf2"},
						{"component": "leaf3"}
					]
				},
				{
					"component": "composite2",
					"content": [
						// p2Section: not filled.
						{"component": "leaf2"},
						{"component": "leaf3"}
					]
				},
				{"component": "leaf4"},
				// p3Section:
				{
					"component": "composite",
					"content": [
						{"component": "leaf1"},
						{"component": "leaf2"},
						{"component": "leaf3"}
					]
				}
			]
		}

		assertEquals(expected, output)
	}

	public void function RenderNestedDocument() {

		var section = new Section()
		section.addComponent(nestedComposite(true))
		var template = new Template(section)

		var documentTemplate1 = new DocumentTemplate(template)
		var p1Section = new Section()
		p1Section.addComponent(simpleComposite(true))
		documentTemplate1.addSection(p1Section, "p1")

		// The available placeholders in the document template should now be: p, p2, p3.

		var documentTemplate2 = new DocumentTemplate(documentTemplate1)
		var pSection = new Section()
		pSection.addComponent(new stubs.Leaf("p"))
		documentTemplate2.addSection(pSection, "p")

		var p2Section = new Section()
		p2Section.addComponent(new stubs.Leaf("p2"))
		documentTemplate2.addSection(p2Section, "p2")

		// Now remains only placeholder p3.

		var documentTemplate3 = new DocumentTemplate(documentTemplate2)
		var p3Section = new Section()
		p3Section.addComponent(new stubs.Leaf("p3"))
		documentTemplate3.addSection(p3Section, "p3")

		var document = new Document(documentTemplate3)

		// Start the actual test.
		variables.visitor.visitDocument(document)

		var content = variables.visitor.content()
		var output = DeserializeJSON(variables.contentType.write(content))

		var expected = {
			"component": "composite1",
			"content": [
				{"component": "leaf1"},
				// Placeholder p1:
				{
					"component": "composite",
					"content": [
						{"component": "leaf1"},
						// Placeholder p:
						{"component": "p"},
						{"component": "leaf2"},
						{"component": "leaf3"}
					]
				},
				{
					"component": "composite2",
					"content": [
						// Placeholder p2:
						{"component": "p2"},
						{"component": "leaf2"},
						{"component": "leaf3"}
					]
				},
				{"component": "leaf4"},
				// Placeholder p3:
				{"component": "p3"}
			]
		}

		assertEquals(expected, output)
	}

	public void function UseTemplate_Should_KeepMatchingContent() {
		var section1 = new Section()
		section1.addComponent(nestedComposite(true))
		var template1 = new Template(section1)

		// For this test, only include p1 en p2 in the second template.
		var composite = new stubs.Composite("composite")
		composite.addChild(new Placeholder("p1"))
		composite.addChild(new Placeholder("p2"))
		var section2 = new Section()
		section2.addComponent(composite)
		var template2 = new Template(section2)

		// Create a document based on template 1.
		var document = new Document(template1)
		// Fill all placeholders p1, p2 and p3.
		var p1Section = new Section()
		p1Section.addComponent(new stubs.Leaf("p1"))
		document.addSection(p1Section, "p1")

		var p2Section = new Section()
		p2Section.addComponent(new stubs.Leaf("p2"))
		document.addSection(p2Section, "p2")

		var p3Section = new Section()
		p3Section.addComponent(new stubs.Leaf("p3"))
		document.addSection(p3Section, "p3")

		// Actual test.
		document.useTemplate(template2)

		variables.visitor.visitDocument(document)

		var content = variables.visitor.content()
		var output = DeserializeJSON(variables.contentType.write(content))

		var expected = {
			"component": "composite",
			"content": [
				{"component": "p1"},
				{"component": "p2"}
			]
		}

		assertEquals(expected, output)

		// Replace the old template back. The content of p3 should have been removed earlier, and should therefore not be rendered.
		document.useTemplate(template1)
		variables.visitor.visitDocument(document)

		var content = variables.visitor.content()
		var output = DeserializeJSON(variables.contentType.write(content))

		var expected = {
			"component": "composite1",
			"content": [
				{"component": "leaf1"},
				{"component": "p1"},
				{
					"component": "composite2",
					"content": [
						{"component": "p2"},
						{"component": "leaf2"},
						{"component": "leaf3"}
					]
				},
				{"component": "leaf4"}
				// No p3.
			]
		}

		assertEquals(expected, output)
	}

	public void function ParentModel_Should_Propagate() {
		var root = new stubs.RootComposite()
		// Create a non-predictable constant that should be passed down the hierarchy of components unchanged.
		var constant = CreateGUID()
		root.setConstant(constant)

		// Create siblings on each level. The depth variable should remain constant within a level.
		root.addChild(new stubs.ModelLeaf("before1"))

		var composite1 = new stubs.ModelComposite("composite1")
		composite1.addChild(new stubs.ModelLeaf("before2"))
		var composite2 = new stubs.ModelComposite("composite2")
		composite2.addChild(new stubs.ModelLeaf("bottom"))
		composite1.addChild(composite2)
		composite1.addChild(new stubs.ModelLeaf("after2"))
		root.addChild(composite1)

		root.addChild(new stubs.ModelLeaf("after1"))

		// Actual test.
		variables.visitor.visitComposite(root)

		var content = variables.visitor.content()
		var output = DeserializeJSON(variables.contentType.write(content))

		var expected = {
			"component": "root",
			"depth": 1,
			"constant": constant,
			"content": [
				{
					"component": "before1",
					"depth": 2,
					"constant": constant
				},
				{
					"component": "composite1",
					"depth": 2,
					"constant": constant,
					"content": [
						{
							"component": "before2",
							"depth": 3,
							"constant": constant
						},
						{
							"component": "composite2",
							"depth": 3,
							"constant": constant,
							"content": [
								{
									"component": "bottom",
									"depth": 4,
									"constant": constant
								}
							]
						},
						{
							"component": "after2",
							"depth": 3,
							"constant": constant
						}
					]
				},
				{
					"component": "after1",
					"depth": 2,
					"constant": constant
				}
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

}