import craft.core.content.Composite;
import craft.core.content.DocumentFoundation;
import craft.core.content.Leaf;
import craft.core.content.Placeholder;
import craft.core.content.Section;
import craft.core.content.Template;

import craft.core.request.Context;

component accessors="true" {

	property Context context;

	public void function init(required Context context) {
		variables.context = arguments.context
		variables.sections = {}
	}

	public String function visitTemplate(required Template template) {
		return arguments.template.getSection().accept(this, {})
	}

	public String function visitDocument(required DocumentFoundation document) {

		// pick up the sections / placeholders that this document is filling
		variables.sections.append(arguments.document.getSections())

		return arguments.document.getTemplate().accept(this)
	}

	public String function visitLeaf(required Leaf leaf, required Struct baseModel) {

		var context = getContext()

		return render(arguments.leaf.view(context), arguments.leaf.model(context, arguments.baseModel))
	}

	public String function visitComposite(required Composite composite, required Struct baseModel) {

		var context = getContext()
		var model = arguments.composite.model(context, arguments.baseModel)
		var view = arguments.composite.view(context)
		// FIXME: find way to get the extension
		var extension = result.extension // the extension corresponding to the output

		var contents = []
		if (hasChildren()) {
			for (var child in getChildren()) {
				// pass the model as the base model to the child
				contents.append(child.accept(this, model))
			}

			// convert the child contents into the type this component is returning
			var content = extension.convert(contents)
			// put it on the model so the view can include it
			model.__children__ = content
		} else {
			model.__children__ = ""
		}

		return render(view, model)
	}

	public String function visitPlaceholder(required Placeholder placeholder, required Struct baseModel) {

		// the placeholder is filled if its ref exists as a key in the sections struct
		var ref = arguments.placeholder.getRef()

		return variables.sections.keyExists(ref) ? variables.sections[ref].accept(this, arguments.baseModel) : ""
	}

	public String function visitSection(required Section section, required Struct baseModel) {

		var extension = getContext().getExtension()
		var contents = []
		for (var child in getChildren()) {
			contents.append(child.accept(this, arguments.baseModel))
		}

		return extension.convert(contents)
	}

}