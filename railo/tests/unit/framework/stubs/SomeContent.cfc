import craft.content.*;

component extends="Leaf" accessors="true" {

	property Struct parameters;

	public void function init() {
		this.parameters = arguments
	}

}