import craft.core.content.Composite;
import craft.core.content.DocumentFoundation;
import craft.core.content.Leaf;
import craft.core.content.Placeholder;
import craft.core.content.Section;
import craft.core.content.Template;

component implements="craft.core.content.Visitor" accessors="true" {

	property String result;

	// public void function init() {
	// 	variables.context = new ContextStub()
	// }

	public void function visitComposite(required Composite composite) {
		variables.result = "composite"
	}

	public void function visitDocument(required DocumentFoundation document) {
		variables.result = "document"
	}

	public void function visitLeaf(required Leaf leaf) {
		variables.result = "leaf"
	}

	public void function visitPlaceholder(required Placeholder placeholder) {
		variables.result = "placeholder"
	}

	public void function visitSection(required Section section) {
		variables.result = "section"
	}

	public void function visitTemplate(required Template template) {
		variables.result = "template"
	}

}