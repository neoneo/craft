import craft.request.Context;

/**
 * Base class for the composite pattern.
 *
 * @abstract
 */
component implements="Content" accessors="true" {

	property Boolean hasChildren setter="false";
	property Boolean hasParent setter="false";
	property Composite parent;

	this.parent = null

	public void function accept(required Visitor visitor) {
		abort showerror="Not implemented";
	}

	public Boolean function getHasParent() {
		return this.parent !== null;
	}

	public Boolean function getHasChildren() {
		abort showerror="Not implemented";
	}

	/**
	 * Returns the `View` that renders this `Component`, or null.
	 */
	public Any function view(required Context context) {
		abort showerror="Not implemented";
	}

	/**
	 * Processes the request and returns data for the view, or null.
	 */
	public Any function process(required Context context) {
		abort showerror="Not implemented";
	}

}