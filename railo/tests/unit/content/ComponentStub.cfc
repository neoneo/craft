import craft.content.*;

component extends="Component" accessors="true" {

	property String property1;
	property String property2;
	property Boolean injectedFactory default="false";
	property Boolean injectedParameters default="false";

	public void function init(required ViewFactory viewFactory, Struct parameters = {}) {
		this.injectedFactory = true
		this.injectedParameters = !arguments.parameters.isEmpty() // For testing purposes, the empty struct is equal to no parameters.
		super.init(argumentCollection: arguments)
	}

	private void function configure(String property1, String property2) {
		this.property1 = arguments.property1
		this.property2 = arguments.property2
	}

}