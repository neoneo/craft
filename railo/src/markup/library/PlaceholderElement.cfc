import craft.content.Placeholder;

component extends="Element" accessors="true" tag="placeholder" {

	property String ref required="true";

	public void function construct(required Scope scope) {
		this.product = new Placeholder(this.ref);
	}

	public Boolean function getChildrenReady() {
		return this.getReady();
	}

}