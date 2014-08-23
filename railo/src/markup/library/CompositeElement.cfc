import craft.content.Composite;

import craft.markup.Scope;

/**
 * Base implementation of an element that produces a `Composite`.
 */
component extends="ComponentElement" abstract="true" {

	public void function construct(required Scope scope) {

		if (childrenReady()) {
			var composite = create()

			children().each(function (child) {
				composite.addChild(arguments.child.product())
			})

			setProduct(composite)
		}

	}

	/**
	 * Creates the `Composite` to which the children are added.
	 */
	private Composite function create() {
		abort showerror="Not implemented";
	}

}