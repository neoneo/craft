import craft.content.Composite;

import craft.markup.Scope;

component extends="craft.markup.library.CompositeElement" tag="composite" {

	private Composite function createComposite() {
		return this.contentFactory.createComponent("Composite", {ref: getRef()})
	}

}