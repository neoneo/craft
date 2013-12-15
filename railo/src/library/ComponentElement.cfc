import craft.core.content.Component;

import craft.xml.Element;

/**
 * @abstract
 */
component extends="Element" {

	/**
	 * The product of a `ComponentElement` can only be a `Component`.
	 */
	public Component function product() {
		return super.product()
	}

}