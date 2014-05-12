import craft.core.output.*;
import craft.core.content.*;
import craft.core.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.context = mock(CreateObject("Context"))
			.requestMethod().returns("get")
		variables.viewFinder = mock(CreateObject("ViewFinder"))

		variables.visitor = new RenderVisitor(variables.context, variables.viewFinder)
	}

	public void function VisitLeaf_Should_CallModelAndView() {
		var model = {key: 1}
		var view = mock(CreateObject("View"))
			.render("{struct}", "{string}").returns("done")
		var leaf = mock(CreateObject("Leaf"))
			.model("{any}").returns(model) // Don't know why I can't pass in variables.context as the first argument..
			.view("{any}").returns("view")
		variables.viewFinder
			.get("view").returns(view)

		// Call the component under test.
		variables.visitor.visitLeaf(leaf)

		leaf.verify()
			.model("{any}")
			.view("{any}")
		variables.viewFinder.verify()
			.get("view")
		view.verify()
			.render("{struct}", "{string}")

		// The visitor should make the rendered output ('done') available.
		assertEquals("done", variables.visitor.content())
	}

	public void function VisitComposite_Should_CallModelViewAndTraverse() {
		var model = {key: 1}
		var view = mock(CreateObject("View"))
			.render("{struct}", "{string}").returns("done")
		var composite = mock(CreateObject("Composite"))
			.model("{any}").returns(model)
			.view("{any}").returns("view")
			.traverse(variables.visitor)
		variables.viewFinder
			.get("view").returns(view)

		variables.visitor.visitComposite(composite)

		composite.verify()
			.model("{any}")
			.view("{any}")
			.traverse(variables.visitor)
		variables.viewFinder.verify()
			.get("view")
		view.verify()
			.render("{struct}", "{string}")

		assertEquals("done", variables.visitor.content())
	}

	public void function VisitLayout_Should_CallSectionAccept() {
		var section = mock(CreateObject("Section")).accept(variables.visitor)
		var layout = mock(CreateObject("Layout")).section().returns(section)

		variables.visitor.visitLayout(layout)

		section.verify().accept(variables.visitor)
	}

	public void function VisitDocument_Should_CallLayoutAccept() {
		var layout = mock(CreateObject("Layout")).accept(variables.visitor)
		var document = mock(CreateObject("Document"))
			.layout().returns(layout)
			.sections().returns({})

		variables.visitor.visitDocument(document)

		layout.verify().accept(variables.visitor)
	}

	public void function VisitPlaceholder_ShouldNot_CallAccept_When_NoSections() {
		var placeholder = mock(CreateObject("Placeholder")).ref().returns("p1").accept(variables.visitor)

		variables.visitor.visitPlaceholder(placeholder)

		placeholder.verify(0).accept(variables.visitor)
	}

	public void function VisitPlaceholder_Should_CallSectionAccept_When_MatchingSection() {
		// To add sections to the visitor we have to utilize a document mock.
		// The document will contain a section linked to placeholder 'p2'.
		// The layout is needed because the visitor will try to get it from the document while visiting.
		var layout = mock(CreateObject("Layout")).accept(variables.visitor)
		var section = mock(CreateObject("Section")).accept(variables.visitor)
		var document = mock(CreateObject("Document"))
			.sections().returns({"p2": section})
			.layout().returns(layout)

		// Add the section by visiting the document. Unfortunately the visitor does not provide another way to do this.
		variables.visitor.visitDocument(document)

		// Now the actual test.
		var placeholder1 = mock(CreateObject("Placeholder")).ref().returns("p1")
		variables.visitor.visitPlaceholder(placeholder1)
		// The section should not have been called.
		section.verify(0).accept(variables.visitor)

		var placeholder2 = mock(CreateObject("Placeholder")).ref().returns("p2")
		variables.visitor.visitPlaceholder(placeholder2)
		// Now we expect a call the section.
		section.verify().accept(variables.visitor)
	}

	public void function VisitSection_Should_CallTraverse() {
		var section = mock(CreateObject("Section")).traverse(variables.visitor)

		variables.visitor.visitSection(section)

		section.verify().traverse(variables.visitor)
	}

}