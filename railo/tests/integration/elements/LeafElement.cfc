import craft.markup.Scope;

component extends="craft.markup.library.ComponentElement" tag="leaf" accessors="true" {

	public void function construct(required Scope scope) {
		setProduct(new crafttests.integration.components.Leaf(getRef()))
	}

}