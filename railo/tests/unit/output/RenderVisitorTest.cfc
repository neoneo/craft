import craft.output.*;
import craft.content.*;
import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.context = mock(CreateObject("Context"))
		context.requestMethod = "get"

		this.visitor = new RenderVisitor(this.context)
	}

	public void function VisitLeaf_Should_CallModelAndView() {
		var model = {key: 1}
		var view = mock(CreateObject("ViewStub"))
			.render("{any}").returns("done")
		var leaf = mock(CreateObject("Leaf"))
			.process("{object}").returns(model) // Don't know why I can't pass in this.context as the first argument..
			.view("{object}").returns(view)

		// Call the component under test.
		this.visitor.visitLeaf(leaf)

		leaf.verify().process("{object}")
		leaf.verify().view("{object}")

		view.verify().render("{any}")

		// The visitor should make the rendered output ('done') available.
		assertEquals("done", this.visitor.content)
	}

	public void function VisitComposite_Should_CallProcessViewAndTraverse() {
		var model = {key: 1}
		var view = mock(CreateObject("ViewStub"))
			.render("{any}").returns("done")
		var composite = mock(CreateObject("Composite"))
			.process("{object}").returns(model)
			.view("{object}").returns(view)
			.traverse("{object}")
		composite.children = []

		this.visitor.visitComposite(composite)

		composite.verify().process("{object}")
		composite.verify().view("{object}")
		composite.verify().traverse("{object}")

		view.verify().render("{any}")

		assertEquals("done", this.visitor.content)
	}

	public void function VisitLeafWithoutView_Should_ReturnNoContent() {
		var model = {key: 1}
		var leaf = mock(CreateObject("Leaf"))
			.process("{object}").returns(model)
			.view("{object}").returns(null) // No view.

		this.visitor.visitLeaf(leaf)

		leaf.verify().process("{object}")
		leaf.verify().view("{object}")

		// The rendered content should be null.
		var content = this.visitor.content
		assertTrue(content === null, "content should be null, but returned '#content#'")
	}

	public void function VisitCompositeWithoutView_Should_ReturnNoContent() {
		var model = {key: 1}
		// Mock a composite without a view, containing a child with a view.
		var view = mock(CreateObject("ViewStub"))
			.render("{any}").returns("done")
		var child = mock(CreateObject("Leaf"))
			.process("{object}").returns(model)
			.view("{object}").returns(view)

		var composite = mock(CreateObject("Composite"))
			.process("{object}").returns(model)
			.view("{object}").returns(null) // No view.

		// Stub the traverse method so the child is actually visited.
		composite.traverse = function () {
			this.visitor.visitLeaf(child)
		}

		// Actual test.
		this.visitor.visitComposite(composite)

		composite.verify().process("{object}")
		composite.verify().view("{object}")

		// The rendered content should be null.
		var content = this.visitor.content
		assertTrue(content === null, "content should be null, but returned '#content#'")

		child.verify().process("{object}")
		child.verify(0).view("{object}") // Should not be called.
		view.verify(0).render("{any}") // And this view should therefore not be rendered.

	}

	public void function VisitLayout_Should_CallSectionAccept() {
		var section = mock(CreateObject("Section")).accept(this.visitor)
		var layout = mock(CreateObject("Layout"))
		layout.section = section

		this.visitor.visitLayout(layout)

		section.verify().accept(this.visitor)
	}

	public void function VisitDocument_Should_CallLayoutAccept() {
		var layout = mock(CreateObject("Layout")).accept(this.visitor)
		var document = mock(CreateObject("Document"))
		document.layout = layout
		document.sections = {}

		this.visitor.visitDocument(document)

		layout.verify().accept(this.visitor)
	}

	public void function VisitPlaceholder_ShouldNot_CallAccept_When_NoSections() {
		var placeholder = mock(CreateObject("Placeholder")).accept(this.visitor)
		placeholder.ref = "p1"

		this.visitor.visitPlaceholder(placeholder)

		placeholder.verify(0).accept(this.visitor)
	}

	public void function VisitPlaceholder_Should_CallSectionAccept_When_MatchingSection() {
		// To add sections to the visitor we have to utilize a document mock.
		// The document will contain a section linked to placeholder 'p2'.
		// The layout is needed because the visitor will try to get it from the document while visiting.
		var layout = mock(CreateObject("Layout")).accept("{object}")
		var section = mock(CreateObject("Section")).accept("{object}")
		var document = mock(CreateObject("Document"))
		document.layout = layout
		document.sections = {"p2": section}

		// Add the section by visiting the document. Unfortunately the visitor does not provide another way to do this.
		this.visitor.visitDocument(document)

		// Now the actual test.
		var placeholder1 = mock(CreateObject("Placeholder"))
		placeholder1.ref = "p1"
		this.visitor.visitPlaceholder(placeholder1)
		// The section should not have been called.
		section.verify(0).accept("{object}")

		var placeholder2 = mock(CreateObject("Placeholder"))
		placeholder2.ref = "p2"
		this.visitor.visitPlaceholder(placeholder2)
		// Now we expect a call to the section.
		section.verify().accept("{object}")
	}

	public void function VisitSectionWithoutComponents_Should_ReturnNoContent() {
		var section = mock(CreateObject("Section"))
		section.traverse = function () {} // No components.

		this.visitor.visitSection(section)

		// The rendered content should be null.
		var content = this.visitor.content
		assertTrue(content === null, "content should be null")
	}

	public void function VisitSectionWithOneComponent_Should_ReturnComponentContent() {
		var view = mock(CreateObject("ViewStub"))
			.render("{any}").returns("done") // This is what the component ultimately returns.
		var component = mock(CreateObject("Leaf"))
			.process("{object}").returns({})
			.view("{object}").returns(view)

		var section = mock(CreateObject("Section"))
		section.traverse = function () {
			this.visitor.visitLeaf(component)
		}

		// Test.
		this.visitor.visitSection(section)

		component.verify().process("{object}")
		component.verify().view("{object}")
		view.verify().render("{any}")

		var content = this.visitor.content
		assertEquals("done", content)
	}

	public void function VisitSectionWithComponents_Should_ReturnConcatenatedContent_When_SimpleValues() {
		// If the section contains multiple components whose views return simple values, those values should be concatenated.

		var view1 = mock(CreateObject("ViewStub"))
			.render("{any}").returns("view1")
		var component1 = mock(CreateObject("Leaf"))
			.process("{object}").returns({})
			.view("{object}").returns(view1)

		var view2 = mock(CreateObject("ViewStub"))
			.render("{any}").returns("view2")
		var component2 = mock(CreateObject("Leaf"))
			.process("{object}").returns({})
			.view("{object}").returns(view2)

		var section = mock(CreateObject("Section"))
		section.traverse = function () {
			this.visitor.visitLeaf(component1)
			this.visitor.visitLeaf(component2)
		}

		// Test.
		this.visitor.visitSection(section)

		component1.verify().process("{object}")
		component1.verify().view("{object}")
		view1.verify().render("{any}")
		component2.verify().process("{object}")
		component2.verify().view("{object}")
		view2.verify().render("{any}")

		var content = this.visitor.content
		assertEquals("view1view2", content)
	}

	public void function VisitSectionWithComponents_Should_ThrowException_When_NotSimpleValues() {
		var view1 = mock(CreateObject("ViewStub"))
			.render("{any}").returns({key: "view1"}) // Complex value returned by view.
		var component1 = mock(CreateObject("Leaf"))
			.process("{object}").returns({})
			.view("{object}").returns(view1)

		var view2 = mock(CreateObject("ViewStub"))
			.render("{any}").returns("view2") // This view renders a string.
		var component2 = mock(CreateObject("Leaf"))
			.process("{object}").returns({})
			.view("{object}").returns(view2)

		var section = mock(CreateObject("Section"))
		section.traverse = function () {
			this.visitor.visitLeaf(component1)
			this.visitor.visitLeaf(component2)
		}

		// Test.
		try {
			this.visitor.visitSection(section)
			fail("exception should have been thrown")
		} catch (DatatypeConfigurationException e) {}

		component1.verify().process("{object}")
		component1.verify().view("{object}")
		view1.verify().render("{any}")
		component2.verify().process("{object}")
		component2.verify().view("{object}")
		view2.verify().render("{any}")

	}

}