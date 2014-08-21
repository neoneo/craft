import craft.content.Composite;

import craft.markup.Scope;

import craft.markup.library.CompositeElement;

component extends="CompositeElement" tag="composite" {

	private Composite function create(required Scope scope) {
		return new components.Composite(getRef())
	}


}