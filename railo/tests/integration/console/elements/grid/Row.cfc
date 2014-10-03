import craft.content.Composite;

import craft.markup.Scope;

import craft.markup.library.CompositeElement;

component extends="CompositeElement" tag="row" {

	private Composite function create() {
		return this.contentFactory.create("grid.components.Row");
	}

	public void function add(required Column element) {
		super.add(arguments.element)
	}

}