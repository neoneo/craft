import craft.content.Component;

import craft.markup.Element;
import craft.markup.Scope;

/**
 * @abstract
 */
component extends = Element {

	public void function construct( Scope scope) {
		this.product = createComponent()
	}

	private Component function createComponent() {
		abort showerror="Not implemented";
	}

}