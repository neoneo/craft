import craft.content.Component;

import craft.markup.Scope;

import craft.markup.library.ComponentElement;

component extends="ComponentElement" tag="leaf" {

	private Component function create() {
		return this.contentFactory.create("Leaf", {ref: getRef()})
	}

}