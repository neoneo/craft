import craft.core.content.Component;

import craft.markup.Element;

component extends="Element" abstract="true" {

	/**
	 * The product of a `ComponentElement` can only be a `Component`.
	 */
	public Component function product() {
		return super.product()
	}

}