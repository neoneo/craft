component extends="Node" accessors="true" {

	property String ref setter="false";

	public void function init(required String ref) {
		super.init()
		variables.ref = arguments.ref
	}

	public String function render(required Context context) {
		return getInsert()
	}

	public String function getInsert() {
		return "[[" & getRef() & "]]"
	}

}