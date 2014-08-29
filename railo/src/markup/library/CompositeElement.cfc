import craft.content.Composite;

import craft.markup.Scope;

/**
 * Base implementation of an element that produces a `Composite`.
 */
component extends="ComponentElement" abstract="true" {

	public void function construct(required Scope scope) {

		if (this.getChildrenReady()) {
			var composite = create()

			this.children.each(function (child) {
				try {

				composite.addChild(arguments.child.product)
				} catch (any e) {
					dump(arguments.child)
					abort;
				}
			})

			this.product = composite
		}

	}

	/**
	 * Creates the `Composite` to which the children are added.
	 */
	private Composite function create() {
		abort showerror="Not implemented";
	}

}