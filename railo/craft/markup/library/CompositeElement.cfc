import craft.content.Composite;

import craft.markup.Element;
import craft.markup.Scope;

/**
 * Base implementation of an element that produces a `Composite`.
 */
component extends="ComponentElement" abstract="true" {

	public void function construct(required Scope scope) {

		if (this.getChildrenReady()) {
			var composite = createComponent()

			this.children.each(function (child) {
				composite.addChild(arguments.child.product)
			})

			this.product = composite
		}

	}

	private Composite function createComponent() {
		abort showerror="Not implemented";
	}

	public Composite function getProduct() {
		return this.product
	}

}