/**
 * Represents an XML element.
 * An `Element` constructs a `Content` instance. It takes the role of the builder in the builder pattern.
 *
 * @abstract
 */

import craft.core.content.Content;

component accessors="true" {

	property String ref;

	variables._product = null

	public Boolean function ready() {
		return !IsNull(variables._product)
	}

	/**
	 * Returns the resulting `Content` instance.
	 */
	public Content function product() {
		return variables._product
	}

	/**
	 * Sets the final product and signals the construction is complete.
	 */
	private void function setProduct(required Content product) {
		variables._product = arguments.product
	}

	/**
	 * Constructs the `Content` instance. The `Director` provides access to the other `Element`s in the document.
	 * If construction can be completed, `setProduct()` should be called. This will be the case in most situations. However, an `Element`'s
	 * dependencies may not be ready yet. In this case, do not call `setProduct()` so the `Director` will retry later.
	 */
	public void function construct(required Director director) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}