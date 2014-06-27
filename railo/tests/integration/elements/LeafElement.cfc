import craft.markup.Scope;

component extends="craft.library.ComponentElement" tag="leaf" accessors="true" {

	public void function construct(required Scope scope) {
		setProduct(new crafttests.integration.components.Leaf(getRef()))
	}

}