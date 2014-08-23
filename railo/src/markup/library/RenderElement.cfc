import craft.content.Component;

component extends="ComponentElement" accessors="true" tag="render" {

	property String view required="true";

	private Component function create() {
		return new ViewComponent(getView());
	}

}