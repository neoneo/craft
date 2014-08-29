import craft.output.*;
import craft.content.*;
import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.context = mock(CreateObject("Context"))
		context.requestMethod = "get"
		this.viewFinder = mock(CreateObject("ViewFinder"))

		this.visitor = new RenderVisitor(this.context, this.viewFinder)
	}

	public void function VisitLeaf_Should_CallModelAndView() {
		var model = {key: 1}
		var view = mock(CreateObject("ViewStub"))
			.render("{any}").returns("done")
		var leaf = mock(CreateObject("Leaf"))
			.model("{object}").returns(model) // Don't know why I can't pass in this.context as the first argument..
			.view("{object}").returns("view")
		this.viewFinder
			.get("view").returns(view)

		// Call the component under test.
		this.visitor.visitLeaf(leaf)

		leaf.verify().model("{object}")
		leaf.verify().view("{object}")

		this.viewFinder.verify().get("view")

		view.verify().render("{any}")

		// The visitor should make the rendered output ('done') available.
		assertEquals("done", this.visitor.content)
	}

	public void function VisitComposite_Should_CallModelViewAndTraverse() {
		var model = {key: 1}
		var view = mock(CreateObject("ViewStub"))
			.render("{any}").returns("done")
		var composite = mock(CreateObject("Composite"))
			.model("{object}").returns(model)
			.view("{object}").returns("view")
			.traverse("{any}")
		this.viewFinder
			.get("view").returns(view)

		this.visitor.visitComposite(composite)

		composite.verify().model("{object}")
		composite.verify().view("{object}")
		composite.verify().traverse("{any}")

		this.viewFinder.verify().get("view")

		view.verify().render("{any}")

		assertEquals("done", this.visitor.content)
	}

	public void function VisitLeafWithoutView_Should_ReturnNoContent() {
		var model = {key: 1}
		var leaf = mock(CreateObject("Leaf"))
			.model("{object}").returns(model)
			.view("{object}").returns(null) // No view.

		this.visitor.visitLeaf(leaf)

		leaf.verify().model("{object}")
		leaf.verify().view("{object}")

		// No view should be retrieved or rendered.
		this.viewFinder.verify(0).get("{any}")

		// The rendered content should be null.
		var content = this.visitor.content
		assertTrue(content === null, "content should be null, but returned '#content#'")
	}

	public void function VisitCompositeWithoutView_Should_ReturnNoContent() {
		var model = {key: 1}
		// Mock a composite without a view, containing a child with a view.
		var child = mock(CreateObject("Leaf"))
			.model("{object}").returns(model)
			.view("{object}").returns("view")

		var composite = mock(CreateObject("Composite"))
			.model("{object}").returns(model)
			.view("{object}").returns(null) // No view.

		// Stub the traverse method.
		composite.traverse = function (visitor) {
			// We make a shortcut here.
			arguments.visitor.visitLeaf(child)
		}

		// Mock the view of the child. This should never be used in this test.
		var view = mock(CreateObject("ViewStub"))
			.render("{any}", "{string}").returns("done")
		this.viewFinder
			.get("view").returns(view)

		// Actual test.
		this.visitor.visitComposite(composite)

		composite.verify().model("{object}")
		composite.verify().view("{object}")

		child.verify().model("{object}")
		child.verify(0).view("{object}") // Should not be called.
		this.viewFinder.verify(0).get("{any}") // No views should be retrieved.
		view.verify(0).render("{any}", "{string}") // And this view should therefore not be rendered.

		// The rendered content should be null.
		var content = this.visitor.content
		assertTrue(content === null, "content should be null, but returned '#content#'")
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
		var layout = mock(CreateObject("Layout")).accept("{any}")
		var section = mock(CreateObject("Section")).accept("{any}")
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
		section.verify(0).accept("{any}")

		var placeholder2 = mock(CreateObject("Placeholder"))
		placeholder2.ref = "p2"
		this.visitor.visitPlaceholder(placeholder2)
		// Now we expect a call to the section.
		section.verify().accept("{any}")
	}

	public void function VisitSection_Should_CallTraverse() {
		var section = mock(CreateObject("Section")).traverse("{any}")

		this.visitor.visitSection(section)

		section.verify().traverse("{any}")
	}

}