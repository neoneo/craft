import craft.core.content.Placeholder;

import craft.markup.Scope;

component extends="ComponentElement" accessors="true" tag="placeholder" {

	property String ref required="true";

	public void function construct(required Scope scope) {
		setProduct(new Placeholder(getRef()))
	}

}