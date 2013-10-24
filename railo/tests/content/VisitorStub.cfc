import craft.core.content.Composite;
import craft.core.content.DocumentFoundation;
import craft.core.content.Leaf;
import craft.core.content.Placeholder;
import craft.core.content.Section;
import craft.core.content.Template;

/**
 * An empty implementation of Visitor used for mocking.
 */
component implements="craft.core.content.Visitor" {

	public void function visitComposite(required Composite composite) {
	}

	public void function visitDocument(required DocumentFoundation document) {
	}

	public void function visitLeaf(required Leaf leaf) {
	}

	public void function visitPlaceholder(required Placeholder placeholder) {
	}

	public void function visitSection(required Section section) {
	}

	public void function visitTemplate(required Template template) {
	}

}