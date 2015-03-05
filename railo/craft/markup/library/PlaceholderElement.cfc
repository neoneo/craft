import craft.content.Placeholder;

component extends = ComponentElement accessors = true tag = placeholder {

	property String ref required = true;

	private Component function createComponent() {
		return new Placeholder(this.ref);
	}

	public Boolean function getChildrenReady() {
		return this.getReady();
	}

}