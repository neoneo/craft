import craft.content.Content;
import craft.content.ContentFactory;

/**
 * Represents a markup element.
 * An `Element` constructs a `Content` instance.
 */
component accessors="true" abstract="true" {

	// All elements may have a 'ref' attribute.
	property String ref;

	property Array children setter="false" attribute="false"; // Element[]
	property Boolean childrenReady setter="false" attribute="false";
	property ContentFactory contentFactory attribute="false";
	property Boolean hasChildren setter="false" attribute="false";
	property Boolean hasParent setter="false" attribute="false";
	property Element parent attribute="false";
	property Content product attribute="false";
	property Boolean ready setter="false" attribute="false";
	property Array siblings setter="false" attribute="false"; // Element[]
	property Numeric siblingIndex setter="false" attribute="false";

	this.children = []
	this.parent = null
	this.product = null

	public void function init(required ContentFactory contentFactory, Struct attributes = {}) {
		this.contentFactory = arguments.contentFactory
		arguments.attributes.each(function (name, value) {
			this[arguments.name] = arguments.value
		})
	}

	public Boolean function getReady() {
		return this.product !== null;
	}

	/**
	 * Constructs the `Content` instance. The `Scope` provides access to the other `Element`s in the document.
	 * If construction can be completed, `setProduct()` should be called with the created `Content` instance as its argument.
	 * This will be the case in most situations. However, an `Element`'s dependencies may not be ready yet. In this case,
	 * do not call `setProduct()` so construction is retried later.
	 */
	public void function construct(required Scope scope) {
		abort showerror="Not implemented";
	}

	/**
	 * Sets the final product and signals that construction is complete.
	 */
	private void function setProduct(required Content product) {
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
			return arguments.child.getReady();
		});
	}

	public Element[] function getSiblings() {
		return this.getHasParent() ? this.parent.children.filter(function (element) {
			return arguments.element !== this;
		}) : []
	}

	public Numeric function getSiblingIndex() {
		return this.getHasParent() ? this.parent.children.find(this) : 0
	}

}