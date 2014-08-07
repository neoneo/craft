import craft.content.*;

/**
 * An empty implementation of Visitor used for mocking.
 */
component implements="Visitor" {

	public void function visitComposite(required Composite composite) {
	}

	// public void function visitContainer(required Container container) {
	// }

	public void function visitDocument(required Document document) {
	}

	public void function visitLeaf(required Leaf leaf) {
	}

	public void function visitPlaceholder(required Placeholder placeholder) {
	}

	public void function visitSection(required Section section) {
	}

	public void function visitLayout(required Layout layout) {
	}

}