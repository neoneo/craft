import craft.core.content.Composite;

import craft.markup.Scope;

/**
 * Base implementation of an element that produces a `Composite`.
 *
 * @abstract
 */
component extends="ComponentElement" {

	public void function build(required Scope scope) {

		if (childrenReady()) {
			var composite = createComposite(arguments.scope)

			for (var child in children()) {
				composite.addChild(child.product())
			}

			setProduct(composite)
		}

	}

	/**
	 * Creates the `Composite` to which the children are added.
	 * The `Scope` is passed in so that this class can also be used for more advanced uses. In such cases, the `createComposite()`
	 * method is an extension to the `build()` method.
	 */
	private Composite function createComposite(required Loader loader) {
		abort showerror="Not implemented";
	}

}