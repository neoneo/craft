import craft.content.Component;

import craft.markup.library.ComponentElement;

component extends="ComponentElement" accessors = true tag="button" {

	property String label required="true";

	private Component function create() {
		return this.contentFactory.create("controls.components.Button", {label: getLabel()});
	}

}