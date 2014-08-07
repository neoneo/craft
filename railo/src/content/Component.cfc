import craft.output.View;

import craft.request.Context;

/**
 * Base class for the composite pattern.
 *
 * @abstract
 */
component implements="Content" {

	variables._parent = null

	public void function accept(required Visitor visitor) {
		abort showerror="Not implemented";
	}

	public Boolean function hasParent() {
		return variables._parent !== null
	}

	public Composite function parent() {
		if (!hasParent()) {
			Throw("Component has no parent", "NoSuchElementException")
		}

		return variables._parent
	}

	/**
	 * Sets the parent of this `Component`. Accepted types are `Composite` or null.
	 */
	public void function setParent(required Any parent) {
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
	 * Processes the request and returns data for the view.
	 */
	public Any function model(required Context context) {
		abort showerror="Not implemented";
	}

}