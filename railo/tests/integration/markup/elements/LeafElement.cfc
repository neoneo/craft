import craft.content.Component;

import craft.markup.library.ComponentElement;

component extends="ComponentElement" tag="leaf" {

	private Component function createComponent() {
		return this.contentFactory.createComponent("Leaf", {ref: getRef()})
	}

}