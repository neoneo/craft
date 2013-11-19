/**
 * Represents an XML element.
 * An `Element` constructs a `Content` instance. It takes the role of the builder in the builder pattern.
 *
 * @abstract
 */

import craft.core.content.Content;

component accessors="true" {

	property String ref;

	variables._parent = null
	variables._children = []
	variables._product = null

	public Boolean function ready() {
		return !IsNull(variables._product)
	}

	/**
	 * Constructs the `Content` instance. The `Director` provides access to the other `Element`s in the document.
	 * If construction can be completed, `setProduct()` should be called. This will be the case in most situations. However, an `Element`'s
	 * dependencies may not be ready yet. In this case, do not call `setProduct()` so the `Director` will retry later.
	 */
	public void function construct(required Director director) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	/**
	 * Sets the final product and signals that construction is complete.
	 */
	private void function setProduct(required Content product) {
		variables._product = arguments.product
	}

	/**
	 * Returns the resulting `Content` instance.
	 */
	public Content function product() {
		return variables._product
	}

	public Boolean function hasParent() {
		return !IsNull(variables._parent)
	}

	public void function setParent(required Element parent) {
		variables._parent = arguments.parent
	}

	public Element function parent() {
		return variables._parent
	}

	public void function add(required Element element) {
		variables._children.append(arguments.element)
	}

	public Array function children() {
		return variables._children
	}

	public Boolean function childrenReady() {

		var ready = true
		for (var child in children()) {
			if (!child.ready()) {
				ready = false
				break;
			}
		}

		return ready
	}

	public Array function siblings() {
		return hasParent() ? parent().children().filter(function (element) {
			return arguments.element !== this
		}) : []
	}

	public Numeric function siblingIndex() {
		return hasParent() ? parent().children().find(this) : 0
	}

}