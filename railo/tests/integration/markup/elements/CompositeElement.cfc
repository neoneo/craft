import craft.content.Component;

import craft.markup.Scope;

import tests.integration.markup.components.Composite;

component extends="craft.markup.library.CompositeElement" tag="composite" {

	private Component function createComponent() {
		return new Composite(this.ref)
	}

}