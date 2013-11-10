component extends="Node" accessors="true" {

	property String ref;

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitPlaceholder(this)
	}

	public Boolean function hasChildren() {
		return false
	}

	public Struct function model(required Context context, required Struct parentModel) {
		Throw("Not supported", "NotSupportedException")
	}

	public String function view(required Context context) {
		Throw("Not supported", "NotSupportedException")
	}

}