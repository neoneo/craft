import craft.core.content.Placeholder;

import craft.markup.Loader;

component extends="ComponentElement" accessors="true" tag="placeholder" {

	property String ref required="true";

	public void function construct(required Repository repository) {
		setProduct(new Placeholder(getRef()))
	}

}