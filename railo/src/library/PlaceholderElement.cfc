import craft.core.content.Placeholder;

import craft.xml.Loader;

component extends="ComponentElement" tag="placeholder" {

	public void function construct(required Loader loader) {
		setProduct(new Placeholder(getRef()))
	}

}