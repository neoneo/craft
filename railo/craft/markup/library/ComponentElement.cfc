import craft.content.Component;

import craft.markup.Element;
import craft.markup.Scope;

component extends="Element" abstract="true" {

	public void function construct( Scope scope) {
		this.product = createComponent()
	}

	private Component function createComponent() {
		abort showerror="Not implemented";
	}

}