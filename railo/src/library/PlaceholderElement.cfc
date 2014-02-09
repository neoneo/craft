import craft.core.content.Placeholder;

import craft.xml.Loader;

component extends="ComponentElement" accessors="true" tag="placeholder" {

	property String ref required="true";

	public void function construct(required Loader loader) {
		setProduct(new Placeholder(getRef()))
	}

}