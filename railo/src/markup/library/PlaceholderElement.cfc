import craft.content.Component;
import craft.content.Placeholder;

import craft.markup.Scope;

component extends="ComponentElement" accessors="true" tag="placeholder" {

	property String ref required="true";

	private Component function create(required Scope scope) {
		return new Placeholder(getRef())
	}

	public Boolean function childrenReady() {
		// Ignore any children.
		return ready()
	}

}