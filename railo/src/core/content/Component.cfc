import craft.core.output.View;

import craft.core.request.Context;

/**
 * Base class for the composite pattern.
 *
 * @abstract
 */
component implements="Content" {

	public void function accept(required Visitor visitor) {
		abort showerror="Not implemented";
	}

	public Boolean function hasParent() {
		return !IsNull(variables._parent)
	}

	public Composite function parent() {
		if (!hasParent()) {
			Throw("Component has no parent", "NoSuchElementException")
		}

		return variables._parent
	}

	public void function setParent(required Composite parent) {
		variables._parent = arguments.parent
	}

	public Boolean function hasChildren() {
		abort showerror="Not implemented";
	}

	/**
	 * Returns the name of the view that renders this component.
	 */
	public String function view(required Context context) {
		abort showerror="Not implemented";
	}

	/**
	 * Returns data for the view. This method is called during tree traversal, and calls the method corresponding
	 * to the request method. Override this method, or implement the supported methods.
	 */
	public Struct function model(required Context context) {
		return this[arguments.context.requestMethod()](arguments.context)
	}

	/**
	 * Collects data for a GET request.
	 */
	public Struct function get(required Context context) {
		Throw("Not supported", "UnsupportedOperationException")
	}

	/**
	 * Collects data for a POST request.
	 */
	public Struct function post(required Context context) {
		Throw("Not supported", "UnsupportedOperationException")
	}

	/**
	 * Collects data for a PUT request.
	 */
	public Struct function put(required Context context) {
		Throw("Not supported", "UnsupportedOperationException")
	}

	/**
	 * Collects data for a DELETE request.
	 */
	public Struct function delete(required Context context) {
		Throw("Not supported", "UnsupportedOperationException")
	}

	/**
	 * Collects data for a PATCH request.
	 */
	public Struct function patch(required Context context) {
		Throw("Not supported", "UnsupportedOperationException")
	}

}