import craft.core.content.Placeholder;

import craft.core.xml.Element;

component extends="Element" tag="placeholder" {

	public void function construct(required Director director) {
		setProduct(new Placeholder(getRef()))
	}

}