import craft.markup.Element;
import craft.markup.Scope;

component extends = Element accessors = true alias = include {

	property String element required = true;

	public void function construct(required Scope scope) {

		var elementRef = this.element
		if (arguments.scope.has(elementRef)) {
			var element = arguments.scope.get(elementRef)
			this.product = element.product
		}

	}

	public Boolean function getChildrenReady() {
		// Ignore any children.
		return this.getReady();
	}

}