import craft.content.Composite;
import craft.content.Document;
import craft.content.Layout;
import craft.content.Leaf;
import craft.content.Placeholder;
import craft.content.Section;
import craft.content.Visitor;

import craft.output.ViewRepository;

import craft.request.Context;

/**
 * @transient
 */
component implements = Visitor accessors = true {

	property Any content setter = false;

	public void function init(required Context context, required ViewRepository viewRepository) {

		this.context = arguments.context
		this.viewRepository = arguments.viewRepository

		// Define state. The following state variables will be modified during component traversal.
		// The sections in document instances are kept, so that placeholder instances can pick them up.
		this.sections = {}
		// Generated content. At the end of the process, this variable contains the request content.
		this.content = null
		// Content generated by child components.
		this.output = []

	}

	public void function visitComposite(required Composite composite) {

		// Keep state in local variables.
		var output = this.output

		var model = arguments.composite.process(this.context)
		var viewMapping = output !== null ? arguments.composite.view(this.context) : null

		// Overwrite state. Set output to null if there is no view defined.
		// As a consequence, children will not be rendered either.
		this.output = viewMapping !== null ? [] : null

		// During traversal, the output of the children will be appended to the output array.
		arguments.composite.traverse(this)

		if (viewMapping !== null) {
			// Put the content of the children on the model so the view can include it.
			model.__children__ = this.output
			// Get the view and render it using the model.
			this.content = this.viewRepository.get(viewMapping).render(model, this.context)
			// Append the generated content on the 'parent' output array.
			output.append(this.content)
		}

		// Revert state.
		this.output = output

	}

	public void function visitDocument(required Document document) {

		// Pick up the sections / placeholders that this document is filling.
		this.sections.append(arguments.document.sections)

		arguments.document.layout.accept(this)
	}

	public void function visitLayout(required Layout layout) {
		arguments.layout.section.accept(this)
	}

	public void function visitLeaf(required Leaf leaf) {

		var model = arguments.leaf.process(this.context)

		// If output is null, rendering the view is useless.
		if (this.output !== null) {
			var viewMapping = arguments.leaf.view(this.context)
			if (viewMapping !== null) {
				this.content = this.viewRepository.get(viewMapping).render(model, this.context)
				this.output.append(this.content)
			}
		}

	}

	public void function visitPlaceholder(required Placeholder placeholder) {

		// The placeholder is filled if its ref exists as a key in the sections struct.
		var ref = arguments.placeholder.ref

		if (this.sections.keyExists(ref)) {
			this.sections[ref].accept(this)
		}

	}

	public void function visitSection(required Section section) {

		// A section is like a composite without a view, so the reasoning is the same.
		var output = this.output
		this.output = []

		section.traverse(this)

		/*
			Place the content produced by the components in the section in this.content.
			The section has no view that can combine complex content, so we handle only the following
			cases:
			- If there is no content item, we set this.content to null.
			- If there is one content item, no combination is needed and we can place the one
				item in this.content.
			- If all items are strings, concatenate them. This is justified because the section
				is primarily intended for html output.
			- Otherwise content will be lost, and we throw an exception.
		*/
		if (this.output.isEmpty()) {
			this.content = null
		} else if (this.output.len() == 1) {
			this.content = this.output[1]
		} else if (this.output.every(
			function (output) {
				return arguments.output === null || IsSimpleValue(arguments.output) || IsInstanceOf(arguments.output, "Stringifiable");
			}
		)) {
			this.content = this.output.toList("")
		} else {
			this.content = null
			Throw("Cannot render content", "DatatypeConfigurationException", "If multiple components generate complex content, the section cannot render.");
		}

		// Append the generated content on the 'parent' output array.
		output.append(this.content)

		// Revert state.
		this.output = output

	}

}