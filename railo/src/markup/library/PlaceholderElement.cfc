import craft.content.Component;

component extends="ComponentElement" accessors="true" tag="placeholder" {

	property String ref required="true";

	private Component function create() {
		return this.contentFactory.create("Placeholder", {ref: this.ref});
	}

	public Boolean function getChildrenReady() {
		// Ignore any children.
		return this.getReady();
	}

}