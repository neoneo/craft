import craft.content.Composite;

import craft.markup.Scope;

import craft.markup.library.CompositeElement;

component extends="CompositeElement" tag="menu" {

	private Composite function create() {
		return this.contentFactory.create(GetComponentMetaData("components.Menu").name);
	}

	public void function add(required Button element) {
		super.add(arguments.element)
	}

}