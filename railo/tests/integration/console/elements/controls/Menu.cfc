import craft.content.Composite;

import craft.markup.Scope;

import craft.markup.library.CompositeElement;

component extends="CompositeElement" tag="menu" {

	private Composite function create(required Scope scope) {
		return new components.Menu();
	}

	public void function add(required Button element) {
		super.add(arguments.element)
	}

}