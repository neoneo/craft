import craft.core.content.Node;

import craft.xml.Element;

/**
 * @abstract
 */
component extends="Element" {

	/**
	 * The product of a `NodeElement` can only be a `Node`.
	 */
	public Node function product() {
		return super.product()
	}

}