import craft.core.content.*;
import craft.core.output.*;
import craft.core.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		var context = mock(CreateObject("Context"))
			.requestMethod().returns("get")
		var templateFinder = new TemplateFinder("cfm")
		templateFinder.addMapping("/crafttest/integration/core/templates")
		var renderer = new CFMLRenderer()

		var viewFinder = new ViewFinder(templateFinder, renderer)
		// We don't add a mapping yet, so that we get template views only.
		// Put the view finder in the variables scope to be able to change that later.
		variables.viewFinder = viewFinder

		variables.visitor = new RenderVisitor(context, viewFinder)
	}

	public void function RenderLeafTemplate() {
		var leaf = new components.Leaf("leaf")

		variables.visitor.visitLeaf(leaf)

		var content = variables.visitor.content().trim()
		var expected = "leaf"

		assertEquals(expected, content)
	}

	public void function RenderCompositeTemplate() {
		variables.visitor.visitComposite(simpleComposite())

		var content = variables.visitor.content().trim()
		var expected = "composite,leaf1,leaf2,leaf3,composite"

		assertEquals(expected, content)
	}

	public void function RenderNestedCompositeTemplate() {
		var composite = nestedComposite()

		variables.visitor.visitComposite(composite)

		var content = variables.visitor.content().trim()
		var expected = "composite1,leaf1,composite2,leaf2,leaf3,composite2,leaf4,composite1"

		assertEquals(expected, content)
	}

	public void function RenderDocumentTemplate() {
		var composite = nestedComposite()
		var section = new Section()
		section.addComponent(composite)
		var layout = new Layout(section)
		var document = new Document(layout)

		variables.visitor.visitDocument(document)

		var content = variables.visitor.content()

		var expected = "composite1,leaf1,composite2,leaf2,leaf3,composite2,leaf4,composite1"

		assertEquals(expected, content)
	}

	public void function RenderDocumentWithPlaceholdersTemplate() {
		var section = new Section()
		section.addComponent(nestedComposite(true)) // With placeholders.
		var layout = new Layout(section)
		var document = new Document(layout)

		var p1Section = new Section()
		p1Section.addComponent(simpleComposite())
		document.addSection(p1Section, "p1")

		var p3Section = new Section()
		p3Section.addComponent(simpleComposite())
		document.addSection(p3Section, "p3")

		variables.visitor.visitDocument(document)

		var content = variables.visitor.content()

		var expected = "composite1,leaf1,p1,composite2,leaf2,leaf3,composite2,leaf4,p3,composite1"
		var placeholder = "composite,leaf1,leaf2,leaf3,composite"
		// p1 and p3 are filled with the composite placeholder, p2 is left empty
		expected = expected.reReplace("(p1|p3)", placeholder, "all")

		assertEquals(expected, content)
	}

	public void function RenderNestedDocumentTemplate() {

		var section = new Section()
		section.addComponent(nestedComposite(true))
		var layout = new Layout(section)

		var documentLayout1 = new DocumentLayout(layout)
		var p1Section = new Section()
		p1Section.addComponent(simpleComposite(true))
		documentLayout1.addSection(p1Section, "p1")

		// The available placeholders in the document layout should now be: p, p2, p3.

		var documentLayout2 = new DocumentLayout(documentLayout1)
		var pSection = new Section()
		pSection.addComponent(new components.Leaf("p"))
		documentLayout2.addSection(pSection, "p")

		var p2Section = new Section()
		p2Section.addComponent(new components.Leaf("p2"))
		documentLayout2.addSection(p2Section, "p2")

		// Now remains only placeholder p3.

		var documentLayout3 = new DocumentLayout(documentLayout2)
		var p3Section = new Section()
		p3Section.addComponent(new components.Leaf("p3"))
		documentLayout3.addSection(p3Section, "p3")

		var document = new Document(documentLayout3)

		// Start the actual test.
		variables.visitor.visitDocument(document)

		var content = variables.visitor.content()

		var expected = "composite1,leaf1,p1,composite2,p2,leaf2,leaf3,composite2,leaf4,p3,composite1"
		// p1 is filled with the simple composite (with a placeholder p)
		expected = expected.replace("p1", "composite,leaf1,p,leaf2,leaf3,composite")
		// All placeholders are filled with leaves of the same name.

		assertEquals(expected, content)
	}

	public void function RenderNestedCompositeViewWithPlaceholders() {
		// The main functionality has been tested in the tests above. The purpose of this test is to test the view component functionality.
		variables.viewFinder.addMapping("/crafttest/integration/core/views")

		var section = new Section()
		section.addComponent(nestedComposite(true))
		var layout = new Layout(section)

		var documentLayout = new DocumentLayout(layout)
		var p1Section = new Section()
		p1Section.addComponent(simpleComposite(true)) // This will include a p placeholder.
		documentLayout.addSection(p1Section, "p1")

		var p2Section = new Section()
		p2Section.addComponent(new components.Leaf("p2"))
		documentLayout.addSection(p2Section, "p2")

		var p3Section = new Section()
		p3Section.addComponent(new components.Leaf("p3"))
		documentLayout.addSection(p3Section, "p3")

		var document = new Document(documentLayout)

		// Fill the p placeholder, included by the simple composite.
		var pSection = new Section()
		pSection.addComponent(new components.Leaf("p"))
		document.addSection(pSection, "p")

		// Start the actual test.
		variables.visitor.visitDocument(document)

		var content = variables.visitor.content()

		var expected = {
			component: "composite1",
			__content__: [
				{component: "leaf1"},
				{
					component: "composite",
					__content__: [
						{component: "leaf1"},
						{component: "p"},
						{component: "leaf2"},
						{component: "leaf3"}
					]
				},
				{
					component: "composite2",
					__content__: [
						{component: "p2"},
						{component: "leaf2"},
						{component: "leaf3"}
					]
				},
				{component: "leaf4"},
				{component: "p3"}
			]
		}

		assertEquals(expected, content)
	}

	public void function UseLayout_Should_KeepMatchingContent() {
		var section1 = new Section()
		section1.addComponent(nestedComposite(true))
		var layout1 = new Layout(section1)

		// The layout contains placeholders p1, p2 and p3.
		// Create a 2nd layout that only includes placeholders p1 en p2.
		var composite = new components.Composite("composite")
		composite.addChild(new Placeholder("p1"))
		composite.addChild(new Placeholder("p2"))
		var section2 = new Section()
		section2.addComponent(composite)
		var layout2 = new Layout(section2)

		// Create a document based on layout 1.
		var document = new Document(layout1)
		// Fill all placeholders p1, p2 and p3.
		var p1Section = new Section()
		p1Section.addComponent(new components.Leaf("p1"))
		document.addSection(p1Section, "p1")

		var p2Section = new Section()
		p2Section.addComponent(new components.Leaf("p2"))
		document.addSection(p2Section, "p2")

		var p3Section = new Section()
		p3Section.addComponent(new components.Leaf("p3"))
		document.addSection(p3Section, "p3")

		// Actual test.
		document.useLayout(layout2)

		variables.visitor.visitDocument(document)

		var content = variables.visitor.content()

		var expected = "composite,p1,p2,composite"

		assertEquals(expected, content)

		// Put the previous layout back. The content of p3 should have been removed earlier, and should therefore not be rendered.
		document.useLayout(layout1)
		variables.visitor.visitDocument(document)

		var content = variables.visitor.content()

		var expected = "composite1,leaf1,p1,composite2,p2,leaf2,leaf3,composite2,leaf4,composite1"

		assertEquals(expected, expected)
	}

	private components.Composite function simpleComposite(Boolean placeholder = true) {
		var composite = new components.Composite("composite")
		composite.addChild(new components.Leaf("leaf1"))
		if (arguments.placeholder) {
			composite.addChild(new Placeholder("p"))
		}
		composite.addChild(new components.Leaf("leaf2"))
		composite.addChild(new components.Leaf("leaf3"))

		return composite
	}

	private components.Composite function nestedComposite(Boolean placeholders = false) {
		var composite1 = new components.Composite("composite1")
		composite1.addChild(new components.Leaf("leaf1"))

		if (arguments.placeholders) {
			composite1.addChild(new Placeholder("p1"))
		}

		var composite2 = new components.Composite("composite2")
		if (arguments.placeholders) {
			composite2.addChild(new Placeholder("p2"))
		}
		composite2.addChild(new components.Leaf("leaf2"))
		composite2.addChild(new components.Leaf("leaf3"))

		composite1.addChild(composite2)
		composite1.addChild(new components.Leaf("leaf4"))
		if (arguments.placeholders) {
			composite1.addChild(new Placeholder("p3"))
		}

		return composite1
	}

}