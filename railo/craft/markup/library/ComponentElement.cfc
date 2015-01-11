import craft.content.Component;

import craft.markup.Element;
import craft.markup.Scope;

component extends="Element" abstract="true" {

	public void function construct( Scope scope) {
		this.product = createComponent()
	}

	/**
	 * Creates the `Component`.
	 */
	private Component function createComponent() {
		abort showerror="Not implemented";
	}

	/**
	 * The product of a `ComponentElement` can only be a `Component`.
	 */
	public Component function getProduct() {
		return this.product
	}

}