component extends="Component" {

	public void function init(required String ref) {
		variables._ref = arguments.ref
	}

	public String function ref() {
		return variables._ref
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitPlaceholder(this)
	}

	public Boolean function hasChildren() {
		return false
	}

	public View function view(required Context context) {
		Throw("Not supported", "UnsupportedOperationException")
	}

}