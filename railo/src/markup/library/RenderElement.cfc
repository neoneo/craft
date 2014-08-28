import craft.content.Component;

component extends="CompositeElement" accessors="true" tag="render" {

	property String view required="true";

	private Composite function create() {
		return new ViewContent(getView());
	}

}