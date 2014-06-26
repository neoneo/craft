import craft.core.content.Composite;

import craft.markup.Scope;

/**
 * Base implementation of an element that produces a `Composite`.
 *
 * @abstract
 */
component extends="ComponentElement" {

	public void function construct(required Scope scope) {

		if (childrenReady()) {
			var composite = createComposite(arguments.scope)

			children().each(function (child) {
				composite.addChild(arguments.child.product())
			})

			setProduct(composite)
		}

	}

	/**
	 * Creates the `Composite` to which the children are added.
	 */
	private Composite function createComposite(required Scope scope) {
		abort showerror="Not implemented";
	}

}