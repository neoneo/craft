import craft.content.Composite;

import craft.markup.Scope;

component extends="craft.markup.library.CompositeElement" tag="composite" accessors="true" {

	private Composite function createComposite(required Scope scope) {
		return new crafttests.integration.components.Composite(getRef())
	}


}