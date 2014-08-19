import craft.content.Component;

import craft.markup.Element;

component extends="Element" abstract="true" {

	public void function construct(required Scope scope) {
		setProduct(create(arguments.scope))
	}

	/**
	 * Creates the `Component`.
	 */
	private Component function create(required Scope scope) {
		abort showerror="Not implemented";
	}

	/**
	 * The product of a `ComponentElement` can only be a `Component`.
	 */
	public Component function product() {
		return super.product()
	}

}