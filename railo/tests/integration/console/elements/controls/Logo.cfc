import craft.content.Component;

import craft.markup.library.ComponentElement;

component extends="ComponentElement" tag="logo" {

	private Component function create() {
		return new components.Logo()
	}

}