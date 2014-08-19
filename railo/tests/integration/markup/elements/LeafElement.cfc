import craft.markup.Scope;

import craft.markup.library.ComponentElement;

component extends="ComponentElement" tag="leaf" {

	private Component function create(required Scope scope) {
		return new components.Leaf(getRef());
	}

}