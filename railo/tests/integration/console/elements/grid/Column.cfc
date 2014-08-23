import craft.content.Composite;

import craft.markup.Scope;

import craft.markup.library.CompositeElement;

component extends="CompositeElement" accessors="true" tag="column" {

	property Numeric span default="1";

	private Composite function create() {
		return new components.Column(getSpan());
	}

}