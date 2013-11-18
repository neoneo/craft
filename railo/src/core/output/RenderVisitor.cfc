import craft.core.content.Composite;
import craft.core.content.Container;
import craft.core.content.DocumentFoundation;
import craft.core.content.Leaf;
import craft.core.content.Placeholder;
import craft.core.content.Section;
import craft.core.content.Template;
import craft.core.content.Visitor;

import craft.core.request.Context;

component implements="Visitor" {

	public void function init(required Renderer renderer, required Context context) {

		variables._renderer = arguments.renderer
		variables._context = arguments.context
		variables._requestMethod = variables._context.getRequestMethod()

		// Define state. The following state variables will be modified during node traversal.
		// The contentType will contain the content type that the parent can render for the request content type. This will be the request content type itself, or a fallback content type.
		variables._contentType = variables._context.getContentType()
		// The combined model of all ancestors is available to every child.
		variables._model = {}
		// The sections in Document instances are kept, so that Placeholder instances can pick them up.
		variables._sections = {}
		// Generated content. At the end of the process, this variable contains the request content.
		variables._content = ""
		// Content generated by child nodes. This content is converted to the appropriate content type.
		variables._contents = []

	}

	public String function content() {
		return variables._content
	}

	public void function visitTemplate(required Template template) {
		arguments.template.section().accept(this)
	}

	public void function visitDocument(required Document document) {

		// Pick up the sections / placeholders that this document is filling.
		variables._sections.append(arguments.document.sections())

		arguments.document.template().accept(this)
	}

	public void function visitLeaf(required Leaf leaf) {

		var currentModel = arguments.leaf.model(variables._context, variables._model)
		// Append the model on the current model without overwriting. This effectively makes all variables of ancestor nodes available.
		currentModel.append(variables._model, false)
		var view = arguments.leaf.view(variables._context)

		variables._content = variables._renderer.render(view, currentModel, variables._requestMethod, variables._contentType)
		variables._contents.append(variables._content)

	}

	public void function visitComposite(required Composite composite) {

		// Copy state in local variables._
		var model = variables._model
		var contentType = variables._contentType
		var contents = variables._contents

		var currentModel = arguments.composite.model(variables._context, variables._model)
		currentModel.append(variables._model, false)
		var view = arguments.composite.view(variables._context)

		// Overwrite state.
		variables._model = currentModel
		variables._contentType = variables._renderer.contentType(view, variables._requestMethod, variables._contentType)
		variables._contents = []

		arguments.composite.traverse(this)

		// Put the content on the model so the view can include it.
		currentModel.__content__ = variables._contentType.convert(variables._contents)

		variables._content = variables._renderer.render(view, currentModel, variables._requestMethod, variables._contentType)

		// Revert state.
		variables._contents = contents
		variables._contentType = contentType
		variables._model = model

		variables._contents.append(variables._content)

	}

	public void function visitPlaceholder(required Placeholder placeholder) {

		// The placeholder is filled if its ref exists as a key in the sections struct.
		var ref = arguments.placeholder.ref()

		if (variables._sections.keyExists(ref)) {
			variables._sections[ref].accept(this)
		}

	}

	public void function visitSection(required Section section) {
		arguments.section.traverse(this)
	}

}