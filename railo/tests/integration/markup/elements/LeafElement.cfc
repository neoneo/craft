import craft.content.Component;

import craft.markup.library.ComponentElement;

import tests.integration.markup.components.Leaf;

component extends="ComponentElement" tag="leaf" {

	private Component function createComponent() {
		return new Leaf(this.ref)
	}

}