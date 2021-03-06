/**
 * Represents a markup element.
 * An `Element` constructs a product in one or more steps.
 *
 * @abstract
 * @transient
 */
component accessors = true {

	// All elements may have a 'ref' attribute.
	property String ref;

	property Array children setter = false inject = false; // Element[]
	property Boolean childrenReady setter = false inject = false;
	property Boolean hasChildren setter = false inject = false;
	property Boolean hasParent setter = false inject = false;
	property Element parent inject = false;
	property Any product inject = false;
	property Boolean ready setter = false inject = false;
	property Array siblings setter = false inject = false; // Element[]
	property Numeric siblingIndex setter = false inject = false;

	this.children = []
	this.parent = null
	this.product = null

	public Boolean function getReady() {
		return this.product !== null;
	}

	/**
	 * Constructs the product. The `Scope` provides access to the other `Element`s in the document.
	 * If construction can be completed, `setProduct()` should be called with the created product as its argument.
	 * This will be the case in most situations. However, an `Element`'s dependencies may not be ready yet. In this case,
	 * do not call `setProduct()` so construction is retried later.
	 */
	public void function construct(required Scope scope) {
		abort showerror="Not implemented";
	}

	/**
	 * Sets the final product and signals that construction is complete.
	 */
	private void function setProduct(required Any product) {
		this.product = arguments.product
	}

	public Boolean function getHasParent() {
		return this.parent !== null;
	}

	public void function add(required Element element) {
		this.children.append(arguments.element)
		arguments.element.parent = this
	}

	public Boolean function getHasChildren() {
		return !this.children.isEmpty();
	}

	public Boolean function getChildrenReady() {
		return this.children.every(function (child) {
			return arguments.child.getReady(); // Using the property accessors throws.
		});
	}

	public Element[] function getSiblings() {
		return this.getHasParent() ? this.parent.children.filter(function (element) {
			return arguments.element !== this;
		}) : [];
	}

	public Numeric function getSiblingIndex() {
		if (this.getHasParent()) {
			// children.find(this) compares based on the values of the properties.
			// Using === (probably) compares by hash code.
			return this.parent.children.find(function (child) {
				return arguments.child === this;
			});
		}

		return 0;
	}

}