component extends="ComponentElement" accessors="true" tag="placeholder" {

	property String ref required="true";

	private Component function createComponent() {
		return this.getContentFactory().createPlaceholder(this.ref);
	}

	public Boolean function getChildrenReady() {
		return this.getReady();
	}

}