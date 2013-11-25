import craft.core.output.*;
import craft.core.content.*;
import craft.core.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.contentType = mock(CreateObject("ContentType"))
		variables.context = mock(CreateObject("Context"))
			.getRequestMethod().returns("get")
			.contentType().returns(variables.contentType)
		variables.renderer = mock(new RendererStub())

		variables.visitor = new RenderVisitor(variables.renderer, variables.context)
	}

	public void function VisitLeaf_Should_CallModelAndView() {
		var model = {key: 1}
		var leaf = mock(CreateObject("Leaf"))
			.model("{any}", "{struct}").returns(model) // Don't know why I can't pass in variables.context as the first argument..
			.view(variables.context).returns("leaf") // And here it seems to work.

		// Add mocking to the renderer. This is the call that should happen for this leaf.
		// Couldn't get argument matching to work properly here.
		variables.renderer.render("{+}").returns("done")

		// Call the component under test.
		variables.visitor.visitLeaf(leaf)

		leaf.verify()
			.model("{any}", "{struct}")
			.view(variables.context)
		variables.renderer.verify()
			.render("{+}")

		// The visitor should make the rendered output ('done') available.
		assertEquals("done", variables.visitor.content())
	}

	public void function VisitComposite_Should_CallModelViewAndTraverse() {
		var model = {key: 1}
		var composite = mock(CreateObject("Composite"))
			.model("{any}", "{struct}").returns(model)
			.view(variables.context).returns("composite")
			.traverse(variables.visitor)
		// Mock contentType.convert(. The visitor calls it to convert the output of the children (an empty array at this point).
		variables.contentType.convert("{array}").returns("")

		variables.renderer
			.render("{+}").returns("done")
			.contentType("{+}").returns(variables.contentType)

		variables.visitor.visitComposite(composite)

		composite.verify()
			.model("{any}", "{struct}")
			.view(variables.context)
			.traverse(variables.visitor)
		variables.contentType.verify().convert("{array}")
		variables.renderer.verify()
			.render("{+}")

		assertEquals("done", variables.visitor.content())
	}

	public void function VisitTemplate_Should_CallSectionAccept() {
		var section = mock(CreateObject("Section")).accept(variables.visitor)
		var template = mock(CreateObject("Template")).section().returns(section)

		variables.visitor.visitTemplate(template)

		section.verify().accept(variables.visitor)
	}

	public void function VisitDocument_Should_CallTemplateAccept() {
		var template = mock(CreateObject("Template")).accept(variables.visitor)
		var document = mock(CreateObject("Document"))
			.template().returns(template)
			.sections().returns({})

		variables.visitor.visitDocument(document)

		template.verify().accept(variables.visitor)
	}

	public void function VisitPlaceholder_ShouldNot_CallAccept_When_NoSections() {
		var placeholder = mock(CreateObject("Placeholder")).ref().returns("p1").accept(variables.visitor)

		variables.visitor.visitPlaceholder(placeholder)

		placeholder.verify(0).accept(variables.visitor)
	}

	public void function VisitPlaceholder_Should_CallSectionAccept_When_MatchingSection() {
		// To add sections to the visitor we have to utilize a document mock.
		// The document will contain a section linked to placeholder 'p2'.
		// The template is needed because the visitor will try to get it from the document while visiting.
		var template = mock(CreateObject("Template")).accept(variables.visitor)
		var section = mock(CreateObject("Section")).accept(variables.visitor)
		var document = mock(CreateObject("Document"))
			.sections().returns({"p2": section})
			.template().returns(template)

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