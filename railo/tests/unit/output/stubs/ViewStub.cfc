import craft.output.*;

component extends="View" accessors="true" {

	property Boolean configureCalled default="false";
	property Struct properties;

	private void function configure() {
		this.configureCalled = true;
		this.properties = arguments;
	}

	public Any function render(required Any model) {
		return null
	}

}