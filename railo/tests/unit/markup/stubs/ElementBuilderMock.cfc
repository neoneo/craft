import craft.markup.ElementBuilder;

component extends="ElementBuilder" accessors="true" {

	property Element element;

	private Element function instantiate(required XML node) {
		// Take a shortcut by returning the element property.
		return this.element;
	}

}