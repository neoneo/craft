component extends="Node" accessors="true" {

	property String ref setter="false";

	public void function init(required String ref) {
		super.init()
		variables.ref = arguments.ref
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitPlaceholder(this)
	}

	public String function view(required Context context) {
		return ""
	}

}