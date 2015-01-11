import craft.content.Composite;

import craft.markup.Element;
import craft.markup.Scope;

/**
 * Base implementation of an element that produces a `Composite`.
 */
component extends="Element" abstract="true" {

	public void function construct(required Scope scope) {

		if (this.getChildrenReady()) {
			var composite = createComposite()

			this.children.each(function (child) {
				composite.addChild(arguments.child.product)
			})

			this.product = composite
		}

	}

	/**
	 * Creates the `Composite` to which the children are added.
	 */
	private Composite function createComposite() {
		abort showerror="Not implemented";
	}

	public Composite function getProduct() {
		return this.product
	}

}