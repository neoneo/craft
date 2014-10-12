import craft.request.Context;

component extends="Component" accessors="true" {

	property String ref setter="false";

	public void function init(required String ref) {
		this.ref = arguments.ref
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitPlaceholder(this)
	}

	public Boolean function getHasChildren() {
		return false;
	}

	public Any function view(required Context context) {
		Throw("Not supported", "UnsupportedOperationException");
	}

}