import craft.core.content.Composite;

import craft.xml.Reader;

/**
 * Base implementation of an element that produces a `Composite`.
 *
 * @abstract
 */
component extends="NodeElement" {

	public void function construct(required Reader reader) {

		if (childrenReady()) {
			var composite = createComposite(arguments.reader)

			for (var child in children()) {
				composite.addChild(child.product())
			}

			setProduct(composite)
		}

	}

	/**
	 * Creates the `Composite` to which the children are added.
	 * The `Reader` is passed in so that this class can also be used for more advanced uses. In such cases, the `createComposite()`
	 * method is an extension to the `construct()` method.
	 */
	private Composite function createComposite(required Reader reader) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}