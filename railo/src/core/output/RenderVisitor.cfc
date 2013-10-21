import craft.core.content.Composite;
import craft.core.content.DocumentFoundation;
import craft.core.content.Leaf;
import craft.core.content.Placeholder;
import craft.core.content.Section;
import craft.core.content.Template;
import craft.core.content.Visitor;

import craft.core.output.Renderer;

import craft.core.request.Context;

component implements="Visitor" accessors="true" {

	property String content setter="false";

	public void function init(required Renderer renderer, required Context context) {

		variables.renderer = arguments.renderer
		variables.context = arguments.context
		variables.requestMethod = variables.context.getRequestMethod()

		// Define state. The following state variables will be modified during node traversal.
		// The contentType will contain the content type that the parent can render for the request content type. This will be the request content type itself, or a fallback content type.
		variables.contentType = variables.context.getContentType()
		// The model of the parent is available to every child.
		variables.parentModel = {}
		// The sections in DocumentFoundation instances are kept, so that Placeholder instances can pick them up.
		variables.sections = {}
		// Generated content. At the end of the process, this variable contains the request content.
		variables.content = ""

	}

	public void function visitTemplate(required Template template) {
		arguments.template.getSection().accept(this)
	}

	public void function visitDocument(required DocumentFoundation document) {

		// Pick up the sections / placeholders that this document is filling.
		variables.sections.append(arguments.document.getSections())

		arguments.document.getTemplate().accept(this)
	}

	public void function visitLeaf(required Leaf leaf) {
		render(arguments.leaf.view(variables.context), arguments.leaf.model(variables.context, variables.parentModel))
	}

	public void function visitComposite(required Composite composite) {

		var model = arguments.composite.model(variables.context, variables.parentModel)
		var view = arguments.composite.view(variables.context)

		// Copy state in local variables.
		var parentModel = variables.parentModel
		var contentType = variables.contentType

		// Overwrite state.
		variables.parentModel = model
		variables.contentType = variables.renderer.contentType(view, variables.requestMethod, variables.contentType)

		if (arguments.composite.hasChildren()) {
			// Put the content on the model so the view can include it.
			model.__content__ = traverseChildren(arguments.composite)
		} else {
			// Create the key anyway so the view doesn't have to test for it.
			model.__content__ = ""
		}

		render(view, model)

		// Revert the state to what it was before.
		variables.parentModel = parentModel
		variables.contentType = contentType

	}

	public void function visitPlaceholder(required Placeholder placeholder) {

		// The placeholder is filled if its ref exists as a key in the sections struct.
		var ref = arguments.placeholder.getRef()

		if (variables.sections.keyExists(ref)) {
			variables.sections[ref].accept(this)
		}

	}

	public void function visitSection(required Section section) {
		variables.content = traverseChildren(arguments.section)
	}

	private String function traverseChildren(required Composite composite) {

		// Node traversal has to be included in the visitor, because we have to process the result afterwards.
		var contents = []
		for (var child in arguments.composite.getChildren()) {
			variables.content = ""
			child.accept(this)
			contents.append(variables.content)
		}

		// Convert the child contents into the type this Composite is returning.
		return variables.contentType.convert(contents)
	}

	private void function render(required String view, required Struct model) {
		variables.content = variables.renderer.render(arguments.view, arguments.model, variables.requestMethod, variables.contentType)
	}

}