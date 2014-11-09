import craft.content.Placeholder;

component extends="Element" accessors="true" tag="placeholder" {

	property String ref required="true";

	public void function construct(required Scope scope) {
		this.product = this.getContentFactory().createPlaceholder(this.ref);
	}

	public Boolean function getChildrenReady() {
		return this.getReady();
	}

}