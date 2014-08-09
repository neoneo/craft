import craft.markup.Element;
import craft.markup.Scope;

component extends="Element" accessors="true" tag="include" {

	property String element;

	public void function construct(required Scope scope) {

		var elementRef = getElement()
		if (arguments.scope.has(elementRef)) {
			var element = arguments.scope.get(elementRef)
			setProduct(element.product())
		}

	}

	public Boolean function childrenReady() {
		// Ignore any children.
		return ready()
	}

}