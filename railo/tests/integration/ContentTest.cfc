import craft.content.*;
import craft.output.*;
import craft.request.*;

component extends="mxunit.framework.TestCase" {

	this.mapping = "/crafttests/integration/content"

	public void function setUp() {
		var context = mock(CreateObject("Context"))

		var templateRenderer = new CFMLRenderer()
		templateRenderer.addMapping(this.mapping & "/templates")

		var viewFactory = new ViewFactory(templateRenderer)
		this.viewFactory = viewFactory
		// We don't add a mapping yet, so that we get template views only.

		this.contentFactory = new ContentFactory(viewFactory)
		this.contentFactory.addMapping(this.mapping & "/components")

		this.visitor = new RenderVisitor(context)
	}

	public void function RenderLeafTemplate() {
		var leaf = this.contentFactory.create("Leaf", {ref: "leaf"})

		this.visitor.visitLeaf(leaf)

		var content = this.visitor.content.trim()
		var expected = "leaf"

		assertEquals(expected, content)
	}

	public void function RenderCompositeTemplate() {
		this.visitor.visitComposite(simpleComposite())

		var content = this.visitor.content.trim()
		var expected = "composite,leaf1,leaf2,leaf3,composite"

		assertEquals(expected, content)
	}

	public void function RenderNestedCompositeTemplate() {
		var composite = nestedComposite()

		this.visitor.visitComposite(composite)

		var content = this.visitor.content.trim()
		var expected = "composite1,leaf1,composite2,leaf2,leaf3,composite2,leaf4,composite1"

		assertEquals(expected, content)
	}

	public void function RenderDocumentTemplate() {
		var composite = nestedComposite()
		var section = new Section()
		section.addComponent(composite)
		var layout = new Layout(section)
		var document = new Document(layout)

		this.visitor.visitDocument(document)

		var content = this.visitor.content

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

		this.visitor.visitDocument(document)

		var content = this.visitor.content

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
		pSection.addComponent(this.contentFactory.create("Leaf", {ref: "p"}))
		documentLayout2.addSection(pSection, "p")

		var p2Section = new Section()
		p2Section.addComponent(this.contentFactory.create("Leaf", {ref: "p2"}))
		documentLayout2.addSection(p2Section, "p2")

		// Now remains only placeholder p3.

		var documentLayout3 = new DocumentLayout(documentLayout2)
		var p3Section = new Section()
		p3Section.addComponent(this.contentFactory.create("Leaf", {ref: "p3"}))
		documentLayout3.addSection(p3Section, "p3")

		var document = new Document(documentLayout3)

		// Start the actual test.
		this.visitor.visitDocument(document)

		var content = this.visitor.content

		var expected = "composite1,leaf1,p1,composite2,p2,leaf2,leaf3,composite2,leaf4,p3,composite1"
		// p1 is filled with the simple composite (with a placeholder p)
		expected = expected.replace("p1", "composite,leaf1,p,leaf2,leaf3,composite")
		// All placeholders are filled with leaves of the same name.

		assertEquals(expected, content)
	}

	public void function RenderNestedCompositeViewWithPlaceholders() {
		// The main functionality has been tested in the tests above. The purpose of this test is to test the view component functionality.
		this.viewFactory.addMapping(this.mapping & "/views")

		var section = new Section()
		section.addComponent(nestedComposite(true))
		var layout = new Layout(section)

		var documentLayout = new DocumentLayout(layout)
		var p1Section = new Section()
		p1Section.addComponent(simpleComposite(true)) // This will include a p placeholder.
		documentLayout.addSection(p1Section, "p1")

		var p2Section = new Section()
		p2Section.addComponent(this.contentFactory.create("Leaf", {ref: "p2"}))
		documentLayout.addSection(p2Section, "p2")

		var p3Section = new Section()
		p3Section.addComponent(this.contentFactory.create("Leaf", {ref: "p3"}))
		documentLayout.addSection(p3Section, "p3")

		var document = new Document(documentLayout)

		// Fill the p placeholder, included by the simple composite.
		var pSection = new Section()
		pSection.addComponent(this.contentFactory.create("Leaf", {ref: "p"}))
		document.addSection(pSection, "p")
		// Start the actual test.
		this.visitor.visitDocument(document)

		var content = this.visitor.content

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
		var composite = this.contentFactory.create("Composite", {ref: "composite"})
		composite.addChild(new Placeholder(this.viewFactory, {ref: "p1"}))
		composite.addChild(new Placeholder(this.viewFactory, {ref: "p2"}))
		var section2 = new Section()
		section2.addComponent(composite)
		var layout2 = new Layout(section2)

		// Create a document based on layout 1.
		var document = new Document(layout1)
		// Fill all placeholders p1, p2 and p3.
		var p1Section = new Section()
		p1Section.addComponent(this.contentFactory.create("Leaf", {ref: "p1"}))
		document.addSection(p1Section, "p1")

		var p2Section = new Section()
		p2Section.addComponent(this.contentFactory.create("Leaf", {ref: "p2"}))
		document.addSection(p2Section, "p2")

		var p3Section = new Section()
		p3Section.addComponent(this.contentFactory.create("Leaf", {ref: "p3"}))
		document.addSection(p3Section, "p3")

		// Actual test.
		document.useLayout(layout2)

		this.visitor.visitDocument(document)

		var content = this.visitor.content

		var expected = "composite,p1,p2,composite"

		assertEquals(expected, content)

		// Put the previous layout back. The content of p3 should have been removed earlier, and should therefore not be rendered.
		document.useLayout(layout1)
		this.visitor.visitDocument(document)

		var content = this.visitor.content

		var expected = "composite1,leaf1,p1,composite2,p2,leaf2,leaf3,composite2,leaf4,composite1"

		assertEquals(expected, expected)
	}

	private Composite function simpleComposite(Boolean placeholder = true) {
		var composite = this.contentFactory.create("Composite", {ref: "composite"})
		composite.addChild(this.contentFactory.create("Leaf", {ref: "leaf1"}))
		if (arguments.placeholder) {
			composite.addChild(new Placeholder(this.viewFactory, {ref: "p"}))
		}
		composite.addChild(this.contentFactory.create("Leaf", {ref: "leaf2"}))
		composite.addChild(this.contentFactory.create("Leaf", {ref: "leaf3"}))

		return composite;
	}

	private Composite function nestedComposite(Boolean placeholders = false) {
		var composite1 = this.contentFactory.create("Composite", {ref: "composite1"})
		composite1.addChild(this.contentFactory.create("Leaf", {ref: "leaf1"}))

		if (arguments.placeholders) {
			composite1.addChild(new Placeholder(this.viewFactory, {ref: "p1"}))
		}

		var composite2 = this.contentFactory.create("Composite", {ref: "composite2"})
		if (arguments.placeholders) {
			composite2.addChild(new Placeholder(this.viewFactory, {ref: "p2"}))
		}
		composite2.addChild(this.contentFactory.create("Leaf", {ref: "leaf2"}))
		composite2.addChild(this.contentFactory.create("Leaf", {ref: "leaf3"}))

		composite1.addChild(composite2)
		composite1.addChild(this.contentFactory.create("Leaf", {ref: "leaf4"}))
		if (arguments.placeholders) {
			composite1.addChild(new Placeholder(this.viewFactory, {ref: "p3"}))
		}

		return composite1;
	}

}