import craft.content.Component;

import craft.markup.library.ComponentElement;

component extends="ComponentElement" tag="logo" {

	private Component function create(required Scope scope) {
		return new components.Logo()
	}

}