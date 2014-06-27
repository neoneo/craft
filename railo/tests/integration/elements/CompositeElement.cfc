import craft.core.content.Composite;

import craft.markup.Scope;

component extends="craft.library.CompositeElement" tag="composite" accessors="true" {

	private Composite function createComposite(required Scope scope) {
		return new crafttests.integration.components.Composite(getRef())
	}


}