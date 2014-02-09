import craft.core.content.Composite;

import craft.xml.Loader;

/**
 * Base implementation of an element that produces a `Composite`.
 *
 * @abstract
 */
component extends="ComponentElement" {

	public void function construct(required Loader loader) {

		if (!hasChildren() || childrenReady()) {
			var composite = createComposite(arguments.loader)

			for (var child in children()) {
				composite.addChild(child.product())
			}

			setProduct(composite)
		}

	}

	/**
	 * Creates the `Composite` to which the children are added.
	 * The `Loader` is passed in so that this class can also be used for more advanced uses. In such cases, the `createComposite()`
	 * method is an extension to the `construct()` method.
	 */
	private Composite function createComposite(required Loader loader) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}