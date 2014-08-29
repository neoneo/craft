import craft.content.Component;
import craft.content.Placeholder;

component extends="ComponentElement" accessors="true" tag="placeholder" {

	property String ref required="true";

	private Component function create() {
		return new Placeholder(this.ref);
	}

	public Boolean function childrenReady() {
		// Ignore any children.
		return this.getReady();
	}

}