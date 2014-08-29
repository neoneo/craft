import craft.content.Composite;

import craft.markup.Scope;

component extends="craft.markup.library.CompositeElement" tag="composite" {

	private Composite function create() {
		return new components.Composite(getRef())
	}


}