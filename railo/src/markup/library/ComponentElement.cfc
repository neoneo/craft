import craft.content.Component;

import craft.markup.Element;
import craft.markup.Scope;

component extends="Element" abstract="true" {

	public void function construct(required Scope scope) {
		setProduct(create())
	}

	/**
	 * Creates the `Component`.
	 */
	private Component function create() {
		abort showerror="Not implemented";
	}

	/**
	 * The product of a `ComponentElement` can only be a `Component`.
	 */
	public Component function product() {
		return super.product();
	}

}