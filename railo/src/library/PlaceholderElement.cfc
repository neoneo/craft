import craft.core.content.Placeholder;

import craft.xml.Reader;

component extends="ComponentElement" tag="placeholder" {

	public void function construct(required Reader reader) {
		setProduct(new Placeholder(getRef()))
	}

}