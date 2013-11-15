import craft.core.content.Composite;

import craft.core.xml.Element;

/**
 * Simple implementation of a `Composite` element.
 *
 * @abstract
 */
component extends="Element" {

	public Boolean function construct(required Director director) {

		var ref = getRef()
		if (arguments.director.childrenReady(ref)) {
			var product = createComposite()

			for (var element in arguments.director.children(ref)) {
				product.addChild(element.product())
			}

			setProduct(product)
		}

	}

	private Composite function createComposite() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}